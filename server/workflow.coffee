# Here is the root of the Chocolate system. 

# It animates the Chocolate server *world*
# by providing a **start** service that starts our World as an https server

# It also provides a Session management to maintain the requestor identity between requests

Https = require 'https'
Http = require 'http'
WebSocket = require 'ws'
Fs = require 'fs'
Path = require 'path'
Formidable = require 'formidable'
Interface = require './interface'
Document = require './document'
Reserve = require './reserve'
Workflow = require '../general/locco/workflow'
QueryString = require './querystring'
Url = require 'url'
_ = require '../general/chocodash'

#### Workflow sessions management

# `Sessions` object will maintain a list of all session objects
class Sessions
    constructor: (cache) ->
        # The sessions store is managed by the `Document.Cache` service
        store = @store = cache.ensure 'Locco_Workflow_Sessions_Store', {}
        
        # The `cleanup` function will be called 
        # when a session will expire to remove it from the list
        cleanup = ->
            now = new Date ; next = Infinity
            
            for own key, object of store
                if object.expires < now then delete store[key]
                else next = if next < object.expires then next else object.expires
            
            setTimeout cleanup, if next is Infinity then 60000 else next - (+new Date) + 1000
        
        setTimeout cleanup, 5000

    # The `Get` method returns the session associated with the provided `request`
    # or creates a new one if none exists.
    get: (request) ->
        # Get the cookies and the remote ip address from the `request`
        cookies = Interface.cook request
        remoteAddress = request.headers['x-forwarded-for'] or request.connection.remoteAddress
        
        # 
        createSession = true ; session = null
        
        # Did we receive a cookie ?
        if cookies.bsid?
            # Checks if we already have a session in `store`
            if (session = @store[cookies.bsid])?
                # Is the remoteAddress the same as it was when we created the session ?
                # We will create a new session if not.
                # 
                # If everythings ok, we record the access date 
                # and set the session expiration date to a new date 
                if session.remoteAddress is remoteAddress
                    session.hasCookie = true
                    session.lastAccess = new Date
                    session.expires = Session.newExpiration()
                    createSession = false
        
        # If we didn't find a session in store
        # we create a new Session with a new id and store it in `store`
        if createSession
            browser_session_id = _.Uuid()
            session = @store[browser_session_id] ?= new Session(browser_session_id, remoteAddress)
            
        session
        
# `Session` object keeps informations about a session
#
# - `id` : session unique identifier
# - `remoteAddress` : requestor remote ip address for that session
# - `hasCookie` : has the session already received a cookie
# - `expires` : when will the session expire (on the server and in the browser)
class Session
    constructor: (@id, @remoteAddress, @hasCookie = false, @expires = Session.newExpiration()) ->
        @keys = []
        @lastAccess = new Date

    # `newExpiration`, a Session class method, calculates a new expiration date
    @newExpiration: -> new Date((+new Date) + 3600 * 1000)
        
#### The World to animate 

class World
    # Here is what we do when we create a new World !
    constructor : (appdir = '.', port, key, cert) ->
        
        # If Node.js crashes unexpectedly, we will receive an `uncaughtException` and log it in a file
        process.on 'uncaughtException', (err) ->
            Fs.createWriteStream(datadir + '/uncaught.err', {'flags': 'a'}).write new Date() + '\n' + err.stack + '\n\n'
    
        cwd = process.cwd()
        if cwd is appdir then process.chdir(__dirname + '/..') ; cwd = process.cwd()
        appdir =  Path.relative cwd, appdir if appdir isnt '.'
        app_pathname = Path.resolve appdir
        
        sysdir = Path.relative app_pathname, cwd
        sys_pathname = cwd
        
        datadir = appdir + '/data'

        Document.datadir = datadir
        cache = new Document.Cache async:off
        sessions = new Sessions cache
        
        space = new Reserve.Space datadir
        
        workflow = Workflow.main

        # Get application Config for Http only server and base port, key and cert options
        config = require '../' + datadir + '/config'
        port ?= config.port
        port ?= 8026
        key ?= config.key
        key ?= 'privatekey.pem'
        cert ?= config.cert
        cert ?= 'certificate.pem'

        # Https security options
        options = unless config.http_only
                [
                    key: Fs.readFileSync datadir + '/' + key
                    cert: Fs.readFileSync datadir + '/' + cert
                ]
            else
                []
                
        network = if config.http_only then Http else Https

        extract = (request, url) ->
            # We extract infos from the Request
            request.url = url if url?
            url = Url.parse request.url
            query = QueryString.parse url.query, null, null, ordered:yes
            pathname = url.pathname
            extension = Path.extname pathname
            if (app_pathname + pathname).indexOf(sys_pathname) is 0 then pathname = '/-' + (app_pathname + pathname).substr sys_pathname.length
            path = pathname.split '/'
            keywords = ['so', 'what', 'sodowhat', 'how']

            # Check if first param key isnt a keyword and then set `sodowhat` to that key
            param = query.list[0]
            if param? and  param.key not in keywords and param.value is ''
                query.dict.sodowhat = param.key
                query.list.push key:'sodowhat', value:param.key
                query.list.splice 0,1
            
            # `params` will contains the parameters extracted from the query part of the request
            params = {}
            for param, param_index in query.list when param.key not in keywords
                params[if param.value != '' then param.key else '__' + param_index] = decodeURI(if param.value isnt '' then param.value else param.key)
            
            # Feed workflow with action request infos
            #
            # `so` indicates the action type.  
            # `what` adds a precision on the action object (usualy its name).  
            # `where` tells where the action should take place.  
            # `how` asks for a special type of respond if available (web, raw, help).
            #
            #     http://myserver/myworld/myfolder?so=move&what=/myworld/mydocument
            #       so = move
            #       what = /myworld/mydocument
            #       where = /myworld/myfolder
            #       how = web (by default) - will return an answer as Html.
            #
            # `backdoor_key` will contain the key you use to have system access
            #
            #     http://myserver/!/my_backdoor_key/myworld/myfolder
            
            sodowhat = query.dict['sodowhat'] ? null
            so = ('do' if sodowhat?) ? query.dict['so'] ? 'go'
            what = sodowhat ? query.dict['what'] ? ''
            how = query.dict['how'] ? 'web'
            backdoor_key = if path[1] is '!' then path[2] else ''
            where_index = 1 + if backdoor_key isnt '' then 2 else 0
            where_path = path[(where_index + if path[where_index] is '-' then 1 else 0)..]
            region = if path[where_index] is '-' then 'system' else if where_path[0] is 'static' and how is 'web' then 'static' else 'app'
            where = where_path.join '/'
            
            session = sessions.get(request)
            
            {space, workflow, so, what, how, where, region, params, sysdir, appdir, datadir, backdoor_key, request, session}

        exchange = (bin, response) ->
            Interface.exchange bin, (result) ->
                # We will send back a cookie with an id and an expiration date
                result.headers['Set-Cookie'] = 'bsid=' + bin.session.id + ';path=/;secure;httponly;expires=' + bin.session.expires.toUTCString()
                # And here is our response to the requestor
                response.writeHead result.status, result.headers
                response.end result.body

        upgrade = do ->
            
            websockets = {}
            
            Fallback_Websocket = _.prototype
                constructor: (@id) -> @messages = []
                send: (message) -> @messages.unshift message
            
            get_websocket = (request) ->
                id = request.headers['x-litejq-websocket-id']
                return null unless id?

                websockets[id] ?= new Fallback_Websocket id
            
            (request, response) ->
                upgraded = no
                
                empty = ->
                    response.writeHead 200, { "Content-Type": "text/plain" }
                    response.end ''
                                        
                if request.headers['x-litejq-websocket'] is 'fallback'
                    switch request.method
                        when 'OPTIONS'
                            response.writeHead 200, "Content-Type": "text/plain", 'x-litejq-websocket-id':  _.Uuid()
                            response.end ''
                            
                        when 'POST'
                            upgraded = true
                            ws = get_websocket request
                            return empty() unless ws?
                            
                            fields = []
                            form = new Formidable.IncomingForm()
                            form
                                .on 'field', (field, value) -> 
                                    fields.push if value? and value isnt '' then value else field
                                .on 'end', ->
                                    message = _.parse fields.join ''
                                    return empty() unless message?
                                        
                                    bin = extract request, message.url
                                    bin.websocket = ws
                                
                                    Interface.exchange bin, (result) ->
                                        response.writeHead result.status, result.headers
                                        response.end "{result:#{result.body},id:#{message.id}}"
                                    
                            form.parse request
                                
                        when 'GET'
                            upgraded = true
                            ws = get_websocket request
                            return empty() unless ws?
                            
                            response.writeHead 200, { "Content-Type": "text/plain" }
                            response.end if message = ws.messages.pop() then message else ''
                            
                upgraded

        # We create an Https or Http server
        #
        # It will receive an [HttpRequest](http://nodejs.org/docs/latest/api/all.html#http.ServerRequest)
        # and fills an [HttpResponse](http://nodejs.org/docs/latest/api/all.html#http.ServerResponse)
        server = network.createServer.apply network, options.concat (request, response) ->
            try
                # upgrade a fallback websocket call
                return if upgrade request, response
                
                # Extract 'so, do, what...' infos from the Request
                bin = extract request
                # We call the Interface service to make an exchange between the requestor and the place specified in `where`
                exchange bin, response

            # If we have an error, we send it back as is.
            catch err
                response.writeHead 200, { "Content-Type": "text/plain" }
                response.end 'error : ' + err.stack
                
        # Start our web server
        server.listen port

        unless config.http_only
            # Start Http server with redirection to Https
            Http.createServer (request, response) ->
                response.writeHead 302, {'Location': "https://#{request.headers.host}" }
                response.end ''
            .listen port+1

        new WebSocket.Server {server} 
        .on 'connection', (ws) ->
            ws.on 'message', (str) ->
                message = _.parse str
                bin = extract ws.upgradeReq, message.url

                Interface.exchange bin, (result) ->
                    ws.send "{result:#{result.body},id:#{message.id}}" if result.body? and result.body isnt ''
        
        return
        
#### Start
# The main workflow service.
exports.start = (appdir, port) ->
    world = new World(appdir, port)

#### Temporary experiments

exports.say_hello = (who = 'you', where = 'there') ->
    'hello ' + who + ' in ' + where

exports.ping_json = ->
    date: new Date()
    town: 'Paris'
    zip: 75000
