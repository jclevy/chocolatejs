# Here is the Interface service of the Ijax system.
# As all non-intentional services, it resides in the *system* sub-section of the *Ijax* section.

# It manages the exchanges the ijax.server *world*
# by providing an **exchange** service that can receive a request and produce a response.

# It requires **Node.js events** to communicate with asynchronous functions
Events = require 'events'
Path = require 'path'
Fs = require 'fs'
Crypto = require 'crypto'
File = require './file'
Chocokup = require '../general/chocokup'

#### Cook
# `cook` serves a cookies object containing cookies from the sent request
exports.cook = (request) ->
    cookies = {}
    (cookie_pair = http_cookie.split '=' ; cookies[cookie_pair[0]] = cookie_pair[1]) for http_cookie in http_cookies.split ';' if (http_cookies = request.headers['cookie'])?
    cookies

#### Exchange
# `exchange` operates the interface
exports.exchange = (so, what, how, where, region, params, appdir, datadir, backdoor_key, request, session, send) ->
    
    sofkey = require('../' + datadir + '/config').sofkey
    where = where.replace(/\.\.[\/]*/g, '')
    
    # `respond` will send the computed result as an Http Response.
    respond = (result, as = how) ->
        type = 'text'
        subtype = switch as
            when 'web', 'edit', 'help' then 'html'
            when 'manifest' then 'cache-manifest'
            else 'plain'
            
        response_headers = { "Content-Type":"#{type}/#{subtype}; charset=utf-8" }
        
        switch as
            when 'manifest'
                response_headers['Cache-Control'] = 'max-age=0'
                response_headers['Expires'] = new Date().toUTCString()
                
            when 'raw'
                result = JSON.stringify result unless Object.prototype.toString.call(result) is '[object String]'
        
            when 'web', 'edit', 'help'
                # render if instance of Chocokup
                if result instanceof Chocokup
                    try
                        result = result.render { backdoor_key }
                    catch error
                        return has500 error
                    
                # Quirks mode in ie6
                if /msie 6/i.test request.headers['user-agent']
                    result = '<?xml version="1.0" encoding="iso-8859-1"?>\n' + result
                    
                # Defaults to Unicode
                if result.indexOf?('</head>') > 0
                    result = result.replace('</head>', '<meta http-equiv="content-type" content="text/html; charset=utf-8" /></head>')
                else if result.indexOf?('<body') > 0
                    result = result.replace('<body', '<head><meta http-equiv="content-type" content="text/html; charset=utf-8" /></head><body')
                else
                    result = '<html><head><meta http-equiv="content-type" content="text/html; charset=utf-8" /></head><body>' + result + '</body></html>'
            
        send status : 200, headers : response_headers, body : result
        
    # `has500` will send an HTTP 500 error
    has500 = (error) ->
        if error?
            source = if (info = error.source)? then "Error in Module:" + info.module + ", with Function :" + info.method + '\n' else ''
            line = if (info = error.location)? then "Coffeescript error at line:" + info.first_line + ", column:" + info.first_column + '\n' else ''
            send status : 500, headers : {"Content-Type": "text/plain"}, body : source + line + error.stack + "\n"
            true
        else
            false
            
    # `hasSofkey` checks if requestor has the system sofkey which gives full rights access
    hasSofkey = () ->
        hashed_backdoor_key = if backdoor_key isnt '' then Crypto.createHash('sha256').update(backdoor_key).digest('hex') else ''
        if sofkey in [hashed_backdoor_key, backdoor_key] or sofkey in session.keys then true else false         

    # `getMethodInfo` retrieve a method and its parameters from a required module
    getMethodInfo = (required, action) ->
        try
            module = require required
            method = module[action] if module?
            args = method.toString().match(/function\s+\w*\s*\((.*?)\)/)[1].split(/\s*,\s*/) if method?
            {method, args}
        catch error
            error.source = module:required, method:action
            {method:undefined, action:undefined, error}
        
    # `respondStatic` will send an HTTP response
    respondStatic = (status, headers, body) ->
        send { status, headers, body }
        
    # `exchangeStatic` is an interface with static web files
    exchangeStatic = () ->
        # Asking for a *static* resource (image, css, javascript...)
        if so is 'go'
            returns_empty = ->
                respondStatic 200, {}, ''
        
            returns = (required) ->
                extension = Path.extname where
                
                Fs.stat required, (error, stats) ->
                    return if has500 error
                    
                    headers =
                        'Date' : (new Date()).toUTCString()
                        'Etag' : [stats.ino, stats.size, Date.parse(stats.mtime)].join '-'
                        'Last-Modified' : (new Date(stats.mtime)).toUTCString()
                        'Cache-Control' : 'max-age=0'
                        'Expires' : new Date().toUTCString()
                    
                    if Date.parse(stats.mtime) <= Date.parse(request.headers['if-modified-since']) or request.headers['if-none-match'] is headers['Etag']
                        return respondStatic 304, headers
                    else
                        Fs.readFile required, null, (error, file) ->  
                            return if has500 error
                            
                            headers["Content-Type"] = switch extension 
                                when '.css' then  "text/css"
                                when '.js' then  "text/javascript"
                                when '.manifest' then "text/cache-manifest"
                                when '.ttf' then "font/ttf"
                            
                            respondStatic 200, headers, file
                        
            check_in_appdir = ->
                appdir_ = if appdir is '.' then 'www' else appdir
                required = Path.resolve appdir_ + '/' +  where
                if required.indexOf(Path.resolve(appdir_) + '/static') is 0
                    return Fs.exists required, (exists) ->
                        if exists then returns required
                        else returns_empty()
                        
                returns_empty()
            
            required = Path.resolve where
            if required.indexOf(Path.resolve __dirname + '/../static') is 0
                Fs.exists required, (exists) ->
                    if exists then returns required 
                    else check_in_appdir()
            else check_in_appdir()
    
    # `canExchange` check if current user has rights to operate exchange
    canExchange = () ->
        return hasSofkey() or (so is 'go' and where is 'ping') or (where is 'server/interface' and so is 'do' and what in ['register_key', 'forget_key'])
    
    # `exchangeSystem` is an interface with system files
    exchangeSystem = () ->
        # When authorized to access system resource -- 
        if canExchange() then exchangeClassic() else respond ''

    # `exchangeClassic` is an interface with classic files (coffeescript or javascript)
    exchangeClassic = () ->
        required = '../' + (if region is 'system' or appdir is '.' then '' else appdir + '/' ) + where
        
        what_is_public = no

        switch so
            # if so is 'do' and what is public then authorize access  
            when 'do' 
                if how is 'web'
                    {method, args, error} = getMethodInfo required, what
                    return if has500 error
                    if (method?) # TODO - should implement security checking
                        what_is_public = yes
    
            # if so is 'go' and where has a public interface then do use interface
            when 'go' 
                if how is 'web' and where isnt 'ping'
                    {method, args, error} = getMethodInfo required, 'interface'
                    return if has500 error
                    if (method?) # TODO - should implement security checking
                        so = 'do'
                        what = 'interface'
        
        
        unless (so is 'do' and (what is 'interface' or what_is_public)) or canExchange() then respond ''; return

        switch so
            # Take care of the `go` action
            when 'go'
                # Answer to ping request
                if where is 'ping'
                    respond 'Ok'
                    return
                        
                # Get the system resource and check how to return it
                resource_path = require.resolve required

                switch how
                    # When `How` is 'web' or 'edit'
                    when 'web', 'edit'
                        File.access(where, backdoor_key, {appdir}).on 'end', (html) ->
                            respond html
                    # when `How` is 'raw'
                    when 'raw', 'manifest'
                        # Read the file and returns it
                        Fs.readFile resource_path, (err, data) ->
                            respond data.toString()

                    # when `How` is 'help'
                    when 'help'
                        # Ask **Doccolate** to generate a help page and returns it
                        Fs.readFile resource_path, (err, data) ->
                            respond require('../general/doccolate').generate resource_path, data.toString()
        
                    # when `How` is unknown
                    else
                        # Returns an error message
                        respond "Don't know how to respond as '" + how + "'"
                            
            # Take care of the `move` action
            when 'move'
                respondOnMoveFile = ->
                    return respond '' if where is ''
                    
                    File.getModifiedDate(where, {appdir}).on 'end', (modifiedDate) ->
                        respond if modifiedDate? then '' + modifiedDate else ''
                        
                # Check if the `what` is empty
                if what is '' 
                    # If empty, take the input content from the POST data 
                    if request.method is 'POST'
                        source = ''
                        request.on 'data', (chunk) ->
                            source += chunk
                        request.on 'end', () ->          
                            # When all POST data received, save new version
                            File.writeToFile(where, source, {appdir}).on 'end', (err) ->
                                if err? then respond err.toString() else respondOnMoveFile()
                    # If no POST date, create the `where` file with content from first parameter
                    else
                        File.writeToFile(where, params._0, {appdir}).on 'end', ->
                            if err? then respond err.toString() else respondOnMoveFile()
                # If specified, move the `what` content to the `where` content
                else
                    File.moveFile(what, where, {appdir}).on 'end', ->
                        if err? then respond err.toString() else respondOnMoveFile()
                            
                # Take care of the `test` and `do` actions
            when 'do', 'test'
                if so is 'test'
                    args = [(if how is 'raw' then 'json' else 'html'), required, {appdir, datadir}]
                    required = '../general/specolate'
                    action = 'inspect'
                    module = require required 
                    method = module[action]
                else if so is 'do'
                    {method, args:expected_args, error} = getMethodInfo required, what
                    return if has500 error
                    if '__' in expected_args then params['__'] = {request, session, appdir, datadir}
                    args = []
                    args_index = 0
                    for arg_name in expected_args
                        args.push if params[arg_name] isnt undefined then params[arg_name] else params[ '__' + args_index++ ]
                    while args_index >= 0
                       if params['__' + args_index] is undefined then args_index = -1
                       else args.push params[ '__' + args_index++ ]

                produced = method args...
                
                if produced instanceof Events.EventEmitter
                    produced.on 'end', (answer) ->
                        respond answer
                else respond produced
            else
                respond ''                             

    # `exchangeSimple` is an interface with intentional entities
    exchangeSimple = () ->
        if where is '' then where = 'default'
        
        where = 'www/' + where if appdir is '.'
        
        try exchangeClassic() catch err then respond ''

    # To log requests...
    # require('../general/debugate').log '-> in ' + region + ' ' + so + ' ' + what + ' at ' + where + ' as ' + how + ' with ' + (k + ':' + v for k,v of params).join(' ')

    switch region
        when 'static' then exchangeStatic()
        when 'system' then exchangeSystem()
        else exchangeSimple()    

#### Key registration
# `registerKey` provides a UI to register a system key in browser session cache
exports.register_key = (__) ->
    enter_kup = ->
        form method:"post", ->
            text "Enter your Key : "
            input name:"key", type:"password"
            
    entered_kup = ->
        text 'Key registered'
    
    if __.request.method isnt 'POST'
        new Chocokup.Document 'Key registration', helpers:{kup:enter_kup}, Chocokup.Kups.Tablet

    else
        event = new Events.EventEmitter

        source = ''
        __.request.on 'data', (chunk) ->
            source += chunk
        __.request.on 'end', () ->
            fields = require('querystring').parse source

            __.session.keys.push Crypto.createHash('sha256').update(fields.key).digest('hex')
            
            event.emit 'end', new Chocokup.Document 'Key registration', helpers:{kup:entered_kup}, Chocokup.Kups.Tablet
        
        event

# `forgetKey` provides a UI to clear keys from browser session cache
exports.forget_key = (__) ->
    forget_kup = ->
        form method:"post", ->
            input name:"action", type:"submit", value:"Logoff"

    forgeted_kup = ->
        text 'Keys forgotten'
    

    if __.request.method isnt 'POST'
        new Chocokup.Document 'Key unregistration', helpers:{kup:forget_kup}, Chocokup.Kups.Tablet
    else
        __.session.keys = []
        new Chocokup.Document 'Key unregistration', helpers:{kup:forgeted_kup}, Chocokup.Kups.Tablet
            


#### Create Hash
# `create_hash` returns the corresponding sha256 hash from a given key
exports.create_hash = (key) ->
    Crypto.createHash('sha256').update(key).digest('hex')
