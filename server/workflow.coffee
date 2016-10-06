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
File = require './file'
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

#### `Sni-callback` to manage SSL
# based on https://github.com/Daplie/letsencrypt-express
#
sni_callback = do ->
    crypto = require('crypto')
    tls = require('tls')
    
    create: (opts) -> 
        ipc = {}
        # in-process cache
        # function (/*err, hostname, certInfo*/) {}
    
        handleRenewFailure = (err, hostname, certInfo) ->
            console.error 'ERROR: Failed to renew domain \'', hostname, '\':'
            if err
                console.error err.stack or err
            if certInfo
                console.error certInfo
            return
    
        assignBestByDates = (now, certInfo) ->
            certInfo = certInfo or
                loadedAt: now
                expiresAt: 0
                issuedAt: 0
                lifetime: 0
            rnds = crypto.randomBytes(3)
            rnd1 = (rnds[0] + 1) / 257
            rnd2 = (rnds[1] + 1) / 257
            rnd3 = (rnds[2] + 1) / 257
            # Stagger randomly by plus 0% to 25% to prevent all caches expiring at once
            memorizeFor = Math.floor(opts.memorizeFor + opts.memorizeFor / 4 * rnd1)
            # Stagger randomly to renew between n and 2n days before renewal is due
            # this *greatly* reduces the risk of multiple cluster processes renewing the same domain at once
            bestIfUsedBy = certInfo.expiresAt - (opts.renewWithin + Math.floor(opts.renewWithin * rnd2))
            # Stagger randomly by plus 0 to 5 min to reduce risk of multiple cluster processes
            # renewing at once on boot when the certs have expired
            renewTimeout = Math.floor(5 * 60 * 1000 * rnd3)
            certInfo.loadedAt = now
            certInfo.memorizeFor = memorizeFor
            certInfo.bestIfUsedBy = bestIfUsedBy
            certInfo.renewTimeout = renewTimeout
            certInfo
    
        renewInBackground = (now, hostname, certInfo) ->
            if now - (certInfo.loadedAt) < opts.failedWait
                # wait a few minutes
                return
            if now > certInfo.bestIfUsedBy and !certInfo.timeout
                # EXPIRING
                if now > certInfo.expiresAt
                    # EXPIRED
                    certInfo.renewTimeout = Math.floor(certInfo.renewTimeout / 2)
                if opts.debug
                    console.log '[ChocoLetsEncrypt] skipping stagger \'' + certInfo.renewTimeout + '\' and renewing \'' + hostname + '\' now'
                    certInfo.renewTimeout = 500
                certInfo.timeout = setTimeout((->
                    # use all domains in `letsencrypt.domains` instead of [ hostname ]
                    args = 
                        domains: if opts.domains? then [].concat(opts.domains) else [ hostname ]
                        duplicate: false
                    opts.letsencrypt.renew args, (err, certInfo) ->
                        if err or !certInfo
                            opts.handleRenewFailure err, hostname, certInfo
                        ipc[hostname] = assignBestByDates(now, certInfo)
                        return
                    return
                ), certInfo.renewTimeout)
            return
    
        cacheResult = (err, hostname, certInfo, sniCb) ->
            if certInfo and certInfo.fullchain and certInfo.privkey
                if opts.debug
                    console.log 'cert is looking good'
                try
                    certInfo.tlsContext = (tls.createSecureContext ? crypto.createCredentials)(
                        key: certInfo.privkey or certInfo.key
                        cert: certInfo.fullchain or certInfo.cert
                        ca: if opts.httpsOptions.ca then opts.httpsOptions.ca + '\n' + certInfo.ca else certInfo.ca
                        crl: opts.httpsOptions.crl
                        requestCert: opts.httpsOptions.requestCert
                        rejectUnauthorized: opts.httpsOptions.rejectUnauthorized)
                catch e
                    console.warn '[Sanity Check Fail]: a weird object was passed back through le.fetch to ChocoLetsEncrypt.fetch'
                    console.warn '(either missing or malformed certInfo.key and / or certInfo.fullchain)'
                    err = e
                if sniCb? then sniCb err, certInfo.tlsContext else result = certInfo.tlsContext
            else
                if opts.debug
                    console.log 'cert is NOT looking good'
                sniCb? err or new Error('couldn\'t get certInfo: unknown'), null
            now = Date.now()
            certInfo = ipc[hostname] = assignBestByDates(now, certInfo)
            renewInBackground now, hostname, certInfo
            if sniCb? then return else return result
    
        registerCert = (hostname, sniCb) ->
            if opts.debug
                console.log '[ChocoLetsEncrypt] \'' + hostname + '\' is not registered, requesting approval'
            if !hostname
                sniCb? new Error('[registerCert] no hostname')
                return
            opts.approveRegistration hostname, (err, args) ->
                if opts.debug
                    console.log '[ChocoLetsEncrypt] \'' + hostname + '\' registration approved, attempting register'
                if err
                    cacheResult err, hostname, null, sniCb
                    return
                if !(args and args.agreeTos and args.email and args.domains)
                    cacheResult new Error('not approved or approval is missing arguments - such as agreeTos, email, domains'), hostname, null, sniCb
                    return
                opts.letsencrypt.register args, (err, certInfo) ->
                    if opts.debug
                        console.log '[ChocoLetsEncrypt] \'' + hostname + '\' register completed', err and err.stack or null, certInfo
                        if (!err or !err.stack) and !certInfo
                            console.error new Error('[ChocoLetsEncrypt] SANITY FAIL: no error and yet no certs either').stack
                    cacheResult err, hostname, certInfo, sniCb
                    return
                return
            return
    
        fetch = (hostname, sniCb) ->
            if !hostname
                sniCb? new Error('[sniCallback] [fetch] no hostname')
                return
            opts.letsencrypt.fetch { domains: [ hostname ] }, (err, certInfo) ->
                if opts.debug
                    console.log '[ChocoLetsEncrypt] fetch from disk result \'' + hostname + '\':'
                    console.log certInfo and Object.keys(certInfo)
                    if err
                        console.error err.stack or err
                if err
                    sniCb? err, null
                    return
                if certInfo
                    result = cacheResult err, hostname, certInfo, sniCb
                    if sniCb? then return else return result
                registerCert hostname, sniCb
                return
            return
    
        if !opts
            throw new Error('requires opts to be an object')
        if opts.debug
            console.log '[ChocoLetsEncrypt] creating sniCallback', JSON.stringify(opts, ((k, v) ->
                if v instanceof Array
                    return JSON.stringify(v)
                v
            ), '    ')
        if !opts.letsencrypt
            throw new Error('requires opts.letsencrypt to be a letsencrypt instance')
        if !opts.lifetime
            opts.lifetime = 90 * 24 * 60 * 60 * 1000
        if !opts.failedWait
            opts.failedWait = 5 * 60 * 1000
        if !opts.renewWithin
            opts.renewWithin = 3 * 24 * 60 * 60 * 1000
        if !opts.memorizeFor
            opts.memorizeFor = 1 * 24 * 60 * 60 * 1000
        if !opts.approveRegistration
    
            opts.approveRegistration = (hostname, cb) ->
                cb null, null
                return
    
        #opts.approveRegistration = function (hostname, cb) { cb(null, null); };
        if !opts.handleRenewFailure
            opts.handleRenewFailure = handleRenewFailure
        (hostname, cb) ->
            if !hostname
                cb? new Error('[sniCallback] no hostname')
                return
            
            # use first domain name defined in `letsencrypt.domains` 
            # as the certificate for `hostname` will be there
            if opts.domains then hostname = opts.domains[0]

            now = Date.now()
            certInfo = ipc[hostname]
            
            #
            # No cert is available in cache.
            # try to fetch it from disk quickly
            # and return to the browser
            #
            if !certInfo
                if opts.debug
                    console.log '[ChocoLetsEncrypt] no certs loaded for \'' + hostname + '\''
                result = fetch hostname, cb
                if cb? then return else return result
            #
            # A cert is available
            # See if it's old enough that
            # we should refresh it from disk
            # (in the background)
            #
            # once ECDSA is available, wait for cert renewal if its due (renewInBackground)
            if certInfo.tlsContext
                renewInBackground now, hostname, certInfo
                return if certInfo.timeout?
                
                cb? null, certInfo.tlsContext
                if now - (certInfo.loadedAt) < certInfo.memorizeFor
                    # these aren't stale, so don't fall through
                    if opts.debug
                        console.log '[ChocoLetsEncrypt] certs for \'' + hostname + '\' are fresh from disk'
                    if cb? then return else return certInfo.tlsContext
            else if now - (certInfo.loadedAt) < opts.failedWait
                if opts.debug
                    console.log '[ChocoLetsEncrypt] certs for \'' + hostname + '\' recently failed and are still in cool down'
                # this was just fetched and failed, wait a few minutes
                cb? null, null
                return
            if opts.debug
                console.log '[ChocoLetsEncrypt] certs for \'' + hostname + '\' are stale on disk and should be will be fetched again'
                console.log
                    age: now - (certInfo.loadedAt)
                    loadedAt: certInfo.loadedAt
                    issuedAt: certInfo.issuedAt
                    expiresAt: certInfo.expiresAt
                    privkey: ! !certInfo.privkey
                    chain: ! !certInfo.chain
                    fullchain: ! !certInfo.fullchain
                    cert: ! !certInfo.cert
                    memorizeFor: certInfo.memorizeFor
                    failedWait: opts.failedWait
            result = fetch hostname, cb
            if cb? then return else return result

#### The World to animate 

class World
    # Here is what we do when we create a new World !
    constructor : (appdir = '.', port, key, cert) ->
        
        cwd = process.cwd()
        if cwd is appdir then process.chdir(__dirname + '/..') ; cwd = process.cwd()
        appdir =  Path.relative cwd, appdir if appdir isnt '.'
        app_pathname = Path.resolve appdir
        
        sysdir = Path.relative app_pathname, cwd
        sys_pathname = cwd
        
        datadir = appdir + '/data'

        File.logConsoleAndErrors (appdir ? '.' ) + '/data/chocolate.log'
        
        # If Node.js crashes unexpectedly, we will receive an `uncaughtException` and log it in a file
        process.on 'uncaughtException', (err) ->
            console.error((err && err.stack) ? new Date() + '\n' + err.stack + '\n\n' : err);

        Document.datadir = datadir
        cache = new Document.Cache async:off
        sessions = new Sessions cache
        
        space = new Reserve.Space datadir

        workflow = Workflow.main

        # Get application Config for Http only server and base port, key and cert options
        config = require('./config')(datadir).clone()
        port_https = port
        port_https ?= config.port_https
        port_https ?= config.port
        port_https ?= 8026
        port_http = config.port_http
        port_http ?= port_https + if config.http_only then 0 else 1
        domains = config.letsencrypt?.domains
        if domains?
            hostname = domains[0]
            # There is currently a bug in letsencrypt/core.js which forces us to repeat first domain name at the end of the `domains` array
            if domains.length > 1 and domains[domains.length - 1] isnt hostname then domains.push hostname
        config.letsencrypt.published = Fs.existsSync datadir + '/letsencrypt/live/' + hostname + '/fullchain.pem' if config.letsencrypt? 
        key ?= config.key
        key ?= if config.letsencrypt?.published is on then 'privkey.pem' else 'privatekey.pem'
        cert ?= config.cert
        cert ?= if config.letsencrypt?.published is on then 'fullchain.pem' else 'certificate.pem'
        
        LetsEncrypt = if config.letsencrypt? then require('letsencrypt') else null

        middleware = do ->
            middleware = https:[], http:[]
            
            if config.letsencrypt? then do ->
                middleware.http.push (args) ->
                    {request, response} = args
                    prefix = '/.well-known/acme-challenge/'
                    if request.url.indexOf(prefix) >= 0
                        response.writeHead 200, { "Content-Type": "text/plain" }
                        key = request.url.slice prefix.length
                        try source = Fs.readFileSync Path.join(datadir + '/letsencrypt/root', key), 'utf8' 
                        catch then source = ""
                        response.end source
                        return no
                    yes
            
            if config.proxy? then do ->
                proxies = {}
                domain_port = port_https + 10
                
                domains_proxied = switch _.type(config.proxy)
                    when _.Type.Array then config.proxy
                    when _.Type.Boolean then config.letsencrypt?.domains
                
                if domains_proxied? then for domain in domains_proxied when not proxies[domain] 
                    if domain.substr(0,4) is 'www.'
                        main_domain = domain.substr 4
                        main_domain_port = proxies[main_domain].port
                        proxies[domain] = host:domain, port:main_domain_port ? domain_port
                        if not main_domain_port? then domain_port += 10
                    else
                        proxies[domain] = host:domain, port:domain_port
                        domain_port += 10
                
                    HttpProxy = require 'http-proxy'
                    proxy = HttpProxy.createProxyServer {}
                
                    proxy.on 'error', (err, request, response) ->
                        console.log  'Proxy ' + err + ' - Message:' + request.url + ' - Headers: ' + ((k + ':' + v for k,v of request.headers when k in ['host', 'user-agent']).join ', ') + '\n\n'
                        
                    middleware[if config.http_only then 'http' else 'https'].push (args) ->
                        {request, response} = args
                        {port} = proxies[request.headers.host]
                        if port is null then response.end('') ; return no 
                        proxy.web request, response, { target: "#{if config.http_only then 'http' else 'https'}://127.0.0.1:#{port}", secure:false }                        

            middleware
        
        if config.http_only
            for func in middleware.http then middleware.https.push func
            middleware.http.length = 0

        # Https security options
        options = unless config.http_only then do ->
            dir = datadir + if config.letsencrypt?.published is on then '/letsencrypt/live/' + hostname else ''
            option = 
                key: Fs.readFileSync dir + '/' + key
                cert: Fs.readFileSync dir + '/' + cert
            if config.letsencrypt? and config.letsencrypt.domains? and config.letsencrypt.email?
                le_config =
                  server: if config.letsencrypt.production is on then LetsEncrypt.productionServerUrl else LetsEncrypt.stagingServerUrl
                  webrootPath: datadir + '/letsencrypt/root'
                  configDir: datadir + '/letsencrypt'
                  privkeyPath: ':config/live/:hostname/privkey.pem'
                  fullchainPath: ':config/live/:hostname/fullchain.pem'
                  certPath: ':config/live/:hostname/cert.pem'
                  chainPath: ':config/live/:hostname/chain.pem'
                  debug: config.letsencrypt.debug ? false
            
                le_handlers =
                  {}
            
                letsencrypt = LetsEncrypt.create le_config, le_handlers
                {email, domains, agreeTos, debug} = config.letsencrypt
                option.SNICallback = sni_callback.create { letsencrypt, debug, domains, httpsOptions:_.clone(option), approveRegistration: (hostname, cb) -> cb null, {email, domains, agreeTos, debug} }
            [option]
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
                param_key = if param.value != '' then param.key else '__' + param_index
                param_value = decodeURI(if param.value isnt '' then param.value else param.key)
                unless params[param_key]?
                    params[param_key] = param_value
                else
                    if _.type(params[param_key]) is _.Type.Array then params[param_key].push param_value
                    else params[param_key] = [params[param_key], param_value]
            
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
            region = if path[where_index] is '-' then 'system' else if where_path[0] is 'static' and how is 'web' then 'static' else if path[where_index] in ['client', 'general', 'server'] then 'secure' else 'app'
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
                                    message = JSON.parse fields.join ''
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
                # execute middleware services if any (like LetsEncrypt...)
                for func in middleware.https then unless func({request, response}) then return
                
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
        server.listen unless config.http_only then port_https else port_http

        unless config.http_only
            # Start Http server with redirection to Https
            Http.createServer (request, response) ->
                for func in middleware.http then unless func({request, response}) then return

                response.writeHead 302, {'Location': "https://#{request.headers.host}" }
                response.end ''
            .listen port_http

        new WebSocket.Server({server}).on 'connection', (ws) ->
            ws.on 'message', (str) ->
                message = JSON.parse str
                bin = extract ws.upgradeReq, message.url
                bin.how = how = 'json'

                Interface.exchange bin, (result) ->
                    feedback = "{\"result\":#{result.body}, \"id\":#{message.id}}"
                    ws.send feedback if result.body? and result.body isnt ''
        
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
