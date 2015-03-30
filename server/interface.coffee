# Here is the Interface service of the Chocolate system.
# As all non-intentional services, it resides in the *system* sub-section of the *Chocolate* section.

# It manages the exchanges the Chocolate server *world*
# by providing an **exchange** service that can receive a request and produce a response.

# It requires **Node.js events** to communicate with asynchronous functions
Events = require 'events'
Path = require 'path'
Fs = require 'fs'
Crypto = require 'crypto'
File = require './file'
Formidable = require 'formidable'
_ = require '../general/chocodash'
Chocokup = require '../general/chocokup'
Chocodown = require '../general/chocodown'
Highlight = require '../general/highlight'
Interface = require '../general/locco/interface'

#### Cook
# `cook` serves a cookies object containing cookies from the sent request
exports.cook = (request) ->
    cookies = {}
    (cookie_pair = http_cookie.split '=' ; cookies[cookie_pair[0]] = cookie_pair[1]) for http_cookie in http_cookies.split ';' if (http_cookies = request.headers['cookie'])?
    cookies

#### Exchange
# `exchange` operates the interface
exports.exchange = (bin, send) ->
    {space, workflow, so, what, how, where, region, params, sysdir, appdir, datadir, backdoor_key, request, session, websocket} = bin

    config = require('../' + datadir + '/config')
    where = where.replace(/\.\.[\/]*/g, '')

    context = {space, workflow, request, websocket, session, sysdir, appdir, datadir}
    
    # `respond` will send the computed result as an Http Response.
    respond = (result, as = how) ->
        type = 'text'
        subtype = switch as
            when 'web', 'edit', 'help' then 'html'
            when 'manifest' then 'cache-manifest'
            else 'plain'
        
        unless as is 'raw'
            switch request.headers['accept']?.split(',')[0] 
                when 'application/json' then as = 'json'
                when 'application/json-late' then as = 'json-late'

        response_headers = { "Content-Type":"#{type}/#{subtype}; charset=utf-8" }
        
        switch as
            when 'manifest'
                response_headers['Cache-Control'] = 'max-age=0'
                response_headers['Expires'] = new Date().toUTCString()
                
            when 'raw', 'json'
                result = JSON.stringify result unless as is 'raw' and Object.prototype.toString.call(result) is '[object String]'
        
            when 'json-late'
                result = _.stringify result
        
            when 'web', 'edit', 'help'
                # render if instance of Chocokup
                
                if result instanceof Interface.Reaction
                    result = result.bin
                
                if result instanceof Chocokup
                    try
                        result = result.render { backdoor_key }
                    catch error
                        return has500 error
                
                
                # Quirks mode in ie6
                if /msie 6/i.test request.headers['user-agent']
                    result = '<?xml version="1.0" encoding="iso-8859-1"?>\n' + result
                    
                # Defaults to Unicode
                if result?.indexOf?('</head>') > 0
                    result = result.replace('</head>', '<meta http-equiv="content-type" content="text/html; charset=utf-8" /></head>')
                else if result?.indexOf?('<body') > 0
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
    hasSofkey = ->
        hasKeypass = config.keypass is on and File.hasWriteAccess(appdir) is no
        hashed_backdoor_key = if backdoor_key isnt '' then Crypto.createHash('sha256').update(backdoor_key).digest('hex') else ''
        if config.sofkey in [hashed_backdoor_key, backdoor_key] or config.sofkey in session.keys or hasKeypass then true else false         

    # `getMethodInfo` retrieve a method and its parameters from a required module
    getMethodInfo = (required, action) ->
        try
            method = module = require required
            
            method = method[name] for name in action.split('.') when method? if method?
            
            self = null
            if method instanceof Function
                infos = method.toString().match(/function\s+\w*\s*\((.*?)\)/)
                args = infos[1].split(/\s*,\s*/) if infos?
            else if method instanceof Interface
                    self = method
                    method = method.submit
                    args = ['{__}', module]
            else method = undefined
                
            {method, args, self}
        catch error
            error.source = module:required, method:action
            {method:undefined, action:undefined, self:undefined, error}
        
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
                                when '.html', '.md', '.markdown', '.cd', '.chocodown' then "text/html"
                            
                            respondStatic 200, headers, switch extension
                                when '.md', '.markdown', '.cd', '.chocodown' 
                                    try
                                        html = new Chocodown.converter().makeHtml file.toString()
                                        if html.indexOf('<body') < 0 then html = '<html><head><meta http-equiv="content-type" content="text/html; charset=utf-8" /></head><body>' + html + '</body></html>' else html
                                    catch error
                                        'Error loading ' + where + ': ' + error
                                else file
                        
            check_in_appdir = ->
                appdir_ = appdir ? '.' 
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
    
    # `canExchangeClassic` checks if a file can be required at the specified path
    # so that a classic exchange can occur
    canExchangeClassic = (path) ->
        return yes if hasSofkey()
        try require.resolve '../' + (if appdir is '.' then '' else appdir + '/' ) + path 
        catch error then return no
        yes

    # `exchangeClassic` is an interface with classic files (coffeescript or javascript)
    exchangeClassic = () ->
        required = '../' + (if region is 'system' or appdir is '.' then '' else appdir + '/' ) + where
        __ = if region is 'system' or appdir is '.' then undefined else context
        
        what_is_public = no

        switch so
            # if so is 'do' and what is public then authorize access  
            when 'do'
                {method, args, self, error} = getMethodInfo required, what
                return if has500 error
                if (method?) # TODO - should implement security checking
                    what_is_public = yes
    
            # if so is 'go' and where has a public interface then do use interface
            when 'go' 
                if how is 'web' and where isnt 'ping'
                    {method, args, self, error} = getMethodInfo required, 'interface'
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
                    respond '{"status":"Ok"}'
                    return
                        
                # Get the system resource and check how to return it
                resource_path = require.resolve required

                switch how
                    # When `How` is 'web' or 'edit'
                    when 'web', 'edit'
                        File.access(where, backdoor_key, __).on 'end', (html) ->
                            respond html.error ? html
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
                respondOnMoveFile = (count) ->
                    return respond '' if where is '' or count is 0
                    
                    results = []
                    for index in [0...count ? 1]
                        do ->
                            filename = File.setFilenameSuffix where, if index > 0 then "_#{index}" else ''
                            File.getModifiedDate(filename, __).on 'end', (modifiedDate) ->
                                results.push {filename, modifiedDate} if modifiedDate?
                                respond JSON.stringify results

                # Check if the `what` is empty
                if what is '' 
                    # If empty, take the input content from the POST data 
                    if request.method is 'POST'
                        content_type = request.headers['content-type']?.split(';')[0]
                        switch content_type
                            when 'multipart/form-data'
                                form = new Formidable.IncomingForm()
                                form.keepExtensions = yes
                                form.parse request, (err, fields, files) ->
                                    count = sent = received = 0
                                    errs = []
                                    count += 1 for name, file of files
                                    for name, file of files
                                        from = if __?.appdir? then Path.relative __.appdir, file.path else file.path
                                        if Path.extname from is '' 
                                            Fs.renameSync from, from = from + '.tmp'
                                        to = unless err? then where else ''
                                        event = File.moveFile from, File.setFilenameSuffix(to, if sent > 0 then "_#{sent}" else ''), __
                                        event.on 'end', (err) ->
                                            received += 1
                                            errs.push err if err?
                                            if received is count
                                                if errs.length > 0 then respond errs.join('\n') else respondOnMoveFile count
                                        sent += 1
                            else
                                source = chunks:[], length:0
                                request.on 'data', (chunk) ->
                                    source.chunks.push chunk
                                    source.length += chunk.length
                                    # test
                                request.on 'end', () ->          
                                    # When all POST data received, save new version
                                    File.writeToFile(where, Buffer.concat(source.chunks, source.length), __).on 'end', (err) ->
                                        if err? then respond err.toString() else respondOnMoveFile()
                    # If no POST date, create the `where` file with content from first parameter
                    else
                        File.writeToFile(where, params._0, __).on 'end', (err) ->
                            if err? then respond err.toString() else respondOnMoveFile()
                # If specified, move the `what` content to the `where` content
                else
                    File.moveFile(what, where, __).on 'end', (err) ->
                        if err? then respond err.toString() else respondOnMoveFile()
                            
                # Take care of the `eval` and `do` actions
            when 'do', 'eval'
                if so is 'eval'
                    args = [(if how is 'raw' then 'json' else 'html'), required, context]
                    required = '../general/specolate'
                    action = 'inspect'
                    module = require required 
                    method = module[action]
                else if so is 'do'
                    {method, args:expected_args, self, error} = getMethodInfo required, what
                    return if has500 error
                    if '__' in expected_args then params['__'] = context
                    args = []
                    
                    if expected_args[0] is '{__}'
                        bin = {__:context}
                        bin[k] = v for k, v of params when k isnt '__'
                        args.push bin
                    else
                        args_index = 0
                        for arg_name in expected_args
                            args.push if params[arg_name] isnt undefined then params[arg_name] else params[ '__' + args_index++ ]
                        while args_index >= 0
                           if params['__' + args_index] is undefined then args_index = -1
                           else args.push params[ '__' + args_index++ ]

                produced = method.apply self, args
                
                if produced instanceof _.Publisher
                    produced.subscribe (answer) -> respond answer
                else if produced instanceof Events.EventEmitter
                    produced.on 'end', (answer) -> respond answer
                else respond produced
            else
                respond ''
            
    
    # `exchangeSimple` is an interface with intentional entities.
    # However, if a file can be required at the specified path, a classic exchange will occur
    exchangeSimple = () ->
        path = if where is '' and so isnt 'move' then where = 'default' else where

        if canExchangeClassic path
            where = path
            try exchangeClassic() catch err then hasSofkey() and has500(err) or respond ''
        else
            switch so
                when 'do'
                    produced = ''
                when 'move'
                    produced = ''
                when 'eval'
                    produced = ''
                when 'go'
                    # tranlate url query to Reserve query
                    produced = where
                    
            respond produced                             

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
        new Chocokup.Document 'Key registration', kups:{key:enter_kup}, Chocokup.Kups.Tablet

    else
        event = new Events.EventEmitter

        source = ''
        __.request.on 'data', (chunk) ->
            source += chunk
        __.request.on 'end', () ->
            fields = require('querystring').parse source

            __.session.keys.push Crypto.createHash('sha256').update(fields.key).digest('hex')
            
            event.emit 'end', new Chocokup.Document 'Key registration', kups:{key:entered_kup}, Chocokup.Kups.Tablet
        
        event

# `forgetKey` provides a UI to clear keys from browser session cache
exports.forget_keys = (__) ->
    forget_kup = ->
        form method:"post", ->
            input name:"action", type:"submit", value:"Logoff"

    forgeted_kup = ->
        text 'Keys forgotten'
    

    if __.request.method isnt 'POST'
        new Chocokup.Document 'Key unregistration', kups:{key:forget_kup}, Chocokup.Kups.Tablet
    else
        __.session.keys = []
        new Chocokup.Document 'Key unregistration', kups:{key:forgeted_kup}, Chocokup.Kups.Tablet
            
#### Create Hash
# `create_hash` returns the corresponding sha256 hash from a given key
exports.create_hash = (key) ->
    Crypto.createHash('sha256').update(key).digest('hex')
