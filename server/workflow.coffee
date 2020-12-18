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
Readable = require('stream').Readable
Zlib = require('zlib')
_ = require '../general/chocodash'

#### Workflow sessions management

# `Sessions` object will maintain a list of all session objects
class Sessions
    constructor: (cache) ->
        # The sessions store is managed by the `Document.Cache` service
        store = @store = cache.ensure 'Locco_Workflow_Sessions_Store', {}

        for id, session of store then store[id] = Session.fromStore session

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
        if (browser_session_id = cookies.bsid)?
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
                    if session.keys?.constructor isnt {}.constructor then session.keys = {}
                    createSession = false
        
        # If we didn't find a session in store
        # we create a new Session with a new id and store it in `store`
        if createSession
            browser_session_id ?= _.Uuid()
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
        @keys = {}
        @lastAccess = new Date

    # `newExpiration`, a Session class method, calculates a new expiration date
    @newExpiration: -> new Date((+new Date) + 3600 * 1000)
    
    @fromStore: (o) ->
        session = new Session
        for k,v of o then session[k] = v
        session
    
    # add `key` to keychain
    addKey: (key) -> @keys[key] = null
    
    # remove `key` from keychain
    removeKey: (key) -> delete @keys[key]

    # remove all keys from keychain
    clearKeys: -> @keys = {}

#### Workflow websockets management

# `Websockets` object will maintain a list of all websocket objects
class WebSockets
    constructor: ->
        @clients = {}
        @rooms = do ->
            rooms = {}
                
            register = (id, ws) ->
                list = rooms[id] ?= []
                list.push ws unless list.indexOf(ws) >= 0
                return
            
            unregister = (id, ws) ->
                if not ws? then ws = id; id = null
                
                if not id? and ws?
                    rooms_to_delete = []
                    for name, list of rooms
                        if (index = list.indexOf(ws)) >= 0
                            list.splice index, 1
                            if list.length is 0 then rooms_to_delete.push id
                    for room_id in rooms_to_delete then delete rooms[room_id]
                else
                    return unless (list = rooms[id])? and (index = list.indexOf(ws)) >= 0
                    list.splice index, 1
                    if list.length is 0 then delete rooms[id]
                return
                
            broadcast = (from_ws, id, message, send_to_self = false) ->
                return unless (list = rooms[id])? and list.indexOf(from_ws) >= 0
                for to_ws in list when to_ws isnt from_ws or send_to_self then to_ws.send message
                return
            
            {register, unregister, broadcast}
        
    get: (request) ->
        # Get the cookies and the remote ip address from the `request`
        cookies = Interface.cook request
        
        if cookies.bsid?
            wss = @clients[cookies.bsid] ?= []
            do (wss, rooms=@rooms) ->
                register: -> rooms.register.apply null, arguments
                unregister: -> rooms.unregister.apply null, arguments
                broadcast: -> rooms.broadcast.apply null, arguments
                close: -> for ws in wss then ws.close.apply ws, arguments
                send: -> for ws in wss then ws.send.apply ws, arguments
        else
            null

    register: (ws) ->
        cookies = Interface.cook ws.upgradeReq
        if cookies.bsid?
            #if @clients[cookies.bsid]? then console.log "client with bsid:#{cookies.bsid} has already a registered websocket"
            array = @clients[cookies.bsid] ?= []
            array.push ws
        return
    
    unregister: (ws) ->
        cookies = Interface.cook ws.upgradeReq
        if cookies.bsid?
            array = @clients[cookies.bsid]
            return unless array?
            
            @rooms.unregister ws
            
            for item, i in array when item is ws
                array.splice i, 1
        
            if array.length is 0
                delete @clients[cookies.bsid]
        return
        

#### `Sni-callback` to manage SSL
# based on https://github.com/Daplie/letsencrypt-express
#

# todo Letsencrypt
sni_callback = do ->
    crypto = require('crypto')
    tls = require('tls')
    
    create: (opts) -> 
        ipc = {}
        # in-process cache
        # function (err, hostname, certInfo) {}
    
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
            if now > certInfo.bestIfUsedBy and !certInfo.timeout?
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
                    opts.renew args, (err, certInfo) ->
                        if err or !certInfo
                            opts.handleRenewFailure err, hostname, certInfo
                        ipc[hostname] = assignBestByDates(now, certInfo)
                        return
                    
                    return
                ), certInfo.renewTimeout)
            return
    
        cacheResult = (err, hostname, certInfo, sniCb) ->
            if certInfo? and certInfo.cert? and certInfo.tlsContext? and certInfo.cert.valid_from?
                if opts.debug
                    console.log 'cert is looking good'
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
                opts.register args, (err, certInfo) ->
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
            opts.fetch (certInfo, err) ->
                if opts.debug
                    console.log '[ChocoLetsEncrypt] fetch from disk result \'' + hostname + '\':'
                    if err
                        console.error 'unable to load certificate file'
                    else
                        console.log 'certInfo: ' +  if certInfo? then Object.keys(certInfo) else 'no certInfo available'
                if err
                    sniCb? err, null
                    return
                if certInfo?
                    result = cacheResult err, hostname, certInfo, sniCb
                    if sniCb? then return else return result
                registerCert hostname, sniCb
            return
    
        if !opts
            throw new Error('requires opts to be an object')
        if opts.debug
            console.log '[ChocoLetsEncrypt] creating sniCallback', JSON.stringify(opts, ((k, v) ->
                if v instanceof Array
                    return JSON.stringify(v)
                v
            ), '    ')
        if !opts.acme
            throw new Error('requires opts.acme to be an ACME instance')
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
        data_pathname = Path.resolve datadir
        
        # Get application Config for Http only server and base port, key and cert options
        config = require('./config')(datadir).clone()

        if config.log?
            if config.log.inFile then File.logConsoleAndErrors (appdir ? '.' ) + '/data/chocolate.log'
            if config.log.timestamp then File.logWithTimestamp()
        
        # If Node.js crashes unexpectedly, we will receive an `uncaughtException` and log it in a file
        process.on 'uncaughtException', (err) ->
            console.error((err and err.stack) ? new Date() + '\n' + err.stack + '\n\n' : err);

        Document.datadir = datadir
        cache = new Document.Cache async:off
        sessions = new Sessions cache
        websockets = new WebSockets
        
        space = new Reserve.Space datadir, config.extensions
        
        workflow = Workflow.main

        port_https = port
        port_https ?= config.port_https
        port_https ?= config.port
        port_https ?= 8026
        port_http = config.port_http
        port_http ?= port_https + if config.http_only then 0 else 1
        domains = config.letsencrypt?.domains
        if domains?
            hostname = domains[0]
            # todo Letsencrypt
            # There is currently a bug in letsencrypt/core.js which forces us to repeat first domain name at the end of the `domains` array
            # if domains.length > 1 and domains[domains.length - 1] isnt hostname then domains.push hostname
        config.letsencrypt.published = Fs.existsSync datadir + '/acme/' + hostname + '/fullchain.pem' if config.letsencrypt? 
        key ?= config.key
        key ?= if config.letsencrypt?.published is on then 'privkey.pem' else 'privatekey.pem'
        cert ?= config.cert
        cert ?= if config.letsencrypt?.published is on then 'fullchain.pem' else 'certificate.pem'
        
        # todo Letsencrypt
        # LetsEncrypt = if config.letsencrypt? then require('letsencrypt') else null
        ACME = if config.letsencrypt? then require('@root/acme') else null
        
        to_proxy_damain = (request) -> no

        middleware = do ->
            middleware = https:[], http:[], ws:[], wss:[]
            
            if config.letsencrypt? then do ->
                middleware.http.push (args) ->
                    {request, response} = args
                    prefix = '/.well-known/acme-challenge/'
                    if request.url.indexOf(prefix) >= 0
                        response.writeHead 200, { "Content-Type": "text/plain" }
                        key = request.url.slice prefix.length
                        try source = Fs.readFileSync Path.join(datadir + '/acme/challenge', key), 'utf8' 
                        catch then source = ""
                        response.end source
                        return no
                    yes
            
            if config.proxy? then do ->
                proxies = {}
                domain_port = port_https + if config.proxy.proxy_domain? then 0 else 10
                
                domains_proxied = switch _.type(config.proxy)
                    when _.Type.Array then config.proxy
                    when _.Type.Boolean, _.Type.Object then config.letsencrypt?.domains
                
                if domains_proxied? 
                    for domain in domains_proxied
                        redirect_domain = if config.proxy.redirect? then config.proxy.redirect[domain] else null
                        continue if proxies[domain]?
                        if domain.substr(0,4) is 'www.' then redirect_domain = domain.substr 4
                        redirect_port = if redirect_domain? then proxies[redirect_domain].port else null
                            
                        proxies[domain] = host:redirect_domain ? domain, port:redirect_port ? domain_port
                        domain_port += 10 unless redirect_port?
                
                    HttpProxy = require 'http-proxy'
                    proxy = HttpProxy.createProxyServer {}

                    proxy.on 'error', (err, request, response) ->
                        console.log  'Proxy ' + err + ' - Message:' + request.url + ' - Headers: ' + ((k + ':' + v for k,v of request.headers when k in ['host', 'user-agent']).join ', ') + '\n\n'
                        if response.writeHead? then response.writeHead 500, {"Content-Type": if config.displayErrors then "application/json" else "text/plain"}
                        response.end if config.displayErrors then JSON.stringify err else ""

                    if config.proxy.log
                        proxy.on 'proxyReq', (proxyReq, request, response) ->
                            console.log 'proxyReq event:', 'host:' + request.headers.host, 'ip:' + request.connection?.remoteAddress, (k + ':' + v for k,v of proxyReq when k in ['method', 'path']).join ', '
    
                        proxy.on 'proxyRes', (proxyRes, request, response) ->
                            console.log 'proxyRes event:', 'host:' + request.headers.host, 'ip:' + request.connection?.remoteAddress, (k + ':' + (if k is 'headers' then JSON.stringify(v) else v) for k,v of proxyRes when k in ['headers', 'statusCode']).join ', '

                    to_proxy_damain = 
                        (request) -> 
                            proxy_infos = proxies[request.headers.host]
                            not proxy_infos? or proxy_infos.host is config.proxy.proxy_domain
                    
                    middleware[if config.http_only then 'ws' else 'wss'].push (args) ->
                        {request, socket, header} = args
                        proxy_infos = proxies[request.headers.host]
                        if proxy_infos? and config.proxy.proxy_domain is proxy_infos.host
                            if config.proxy.log
                                console.log 'proxyWs event:', 'host:' + request.headers.host, 'ip:' + request.connection?.remoteAddress, (k + ':' + v for k,v of request when k in ['method', 'url']).join ', '
                            return yes
                        unless proxy_infos?.port? then return yes
                        proxy.ws request, socket, header, { target: "#{if config.http_only then 'http' else 'https'}://127.0.0.1:#{proxy_infos.port}", secure:false }
                        no
                        
                    middleware[if config.http_only then 'http' else 'https'].push (args) ->
                        {request, response} = args
                        proxy_infos = proxies[request.headers.host]
                        if proxy_infos? and config.proxy.proxy_domain is proxy_infos.host
                            if config.proxy.log
                                console.log 'proxyReq event:', 'host:' + request.headers.host, 'ip:' + request.connection?.remoteAddress, (k + ':' + v for k,v of request when k in ['method', 'url']).join ', '
                            return yes
                        unless proxy_infos?.port? then response.end('') ; return no
                        proxy_port = parseInt(proxy_infos.port) + if Url.parse(request.url).pathname.indexOf('/-/server/monitor') is 0 then 2 else 0
                        proxy.web request, response, { target: "#{if config.http_only then 'http' else 'https'}://127.0.0.1:#{proxy_port}", secure:false }                        
                        no

            middleware
        
        if config.http_only
            for func in middleware.http then middleware.https.push func
            middleware.http.length = 0

        # Https security options
        options = unless config.http_only then do ->
            dir = datadir + if config.letsencrypt?.published is on then '/acme/' + hostname else ''
            option = 
                key: Fs.readFileSync dir + '/' + key
                cert: Fs.readFileSync dir + '/' + cert
            
            # todo Letsencrypt
            if config.letsencrypt? and config.letsencrypt.domains? and config.letsencrypt.email?
                debugger
                le_config =
                  server: if config.letsencrypt.production is on then "https://acme-v02.api.letsencrypt.org/directory" else "https://acme-staging-v02.api.letsencrypt.org/directory"
                  webrootPath: datadir + '/letsencrypt/root'
                  configDir: datadir + '/letsencrypt'
                  privkeyPath: ':config/live/:hostname/privkey.pem'
                  fullchainPath: ':config/live/:hostname/fullchain.pem'
                  certPath: ':config/live/:hostname/cert.pem'
                  chainPath: ':config/live/:hostname/chain.pem'
                  debug: config.letsencrypt.debug ? false
                  
                Keypairs = require('@root/keypairs')
                accountKeypair = null
                account = null
                accountKey = null
                serverKeypair = null
                serverPem = null
                serverKey = null
                csr = null
                acme_pathname = data_pathname + '/acme'
                webroot_pathname = acme_pathname + '/challenge'
                certdir_pathname = acme_pathname + '/' + hostname
                    
                acme = ACME.create
                    maintainerEmail:config.letsencrypt.email
                    packageAgent: (pkg = require('../package.json')).name + '/' + pkg.version
                    notify: (event, detail) -> 'notif: ' + console.log event + ' : ' + JSON.stringify detail
                    skipChallengeTest: yes
                    skipDryRun: yes

                registerAsync = (args, cb) -> 
                    # args = { email, domains, agreeTos, debug }
                    directoryUrl = if config.letsencrypt.production is on then "https://acme-v02.api.letsencrypt.org/directory" else "https://acme-staging-v02.api.letsencrypt.org/directory"
                    acme.init(directoryUrl).then ->
                        _.async (wait) ->
                            wait (then_1) ->
                                keypair_pathname = acme_pathname + '/keypairs.json'
                                try source = Fs.readFileSync(keypair_pathname)
                                if source? 
                                    accountKeypair = JSON.parse source
                                    then_1()
                                else
                                    Keypairs.generate({ kty: 'EC', format: 'jwk' }). then (result) ->
                                        accountKeypair = result
                                        Fs.mkdirSync acme_pathname unless Fs.existsSync acme_pathname
                                        Fs.writeFileSync keypair_pathname, JSON.stringify accountKeypair
                                        then_1()
                            wait (then_1) ->
                                accountKey = accountKeypair.private
                                acme.accounts.create
                                    subscriberEmail:args.email
                                    agreeToTerms: args.agreeTos
                                    accountKey: accountKey
                                .then (result) ->
                                    account = result
                                    then_1()
                            wait (then_1) ->
                                privkey_pathname = certdir_pathname + '/privkey.pem'
                                try serverPem = Fs.readFileSync(privkey_pathname, 'utf8')
                                if serverPem?
                                    Keypairs.import({ pem: serverPem }).then (result) ->
                                        serverKey = result
                                        then_1()
                                else
                                    _.async (wait) ->
                                        wait (then_2) ->
                                            Keypairs.generate({ kty: 'RSA', format: 'jwk' }).then (result) -> 
                                                serverKeypair = result ; then_2()
                                        wait (then_2) ->
                                            serverKey = serverKeypair.private
                                            Keypairs.export({ jwk: serverKey }).then (result) -> 
                                                serverPem = result
                                                Fs.mkdirSync certdir_pathname unless Fs.existsSync certdir_pathname
                                                Fs.writeFileSync(privkey_pathname, serverPem, 'utf8')
                                                then_2()
                                        wait -> 
                                            then_1()
                            wait (then_1) ->
                                punycode = require('punycode');
                                domains = args.domains.map (name) -> punycode.toASCII(name)
                                
                                CSR = require('@root/csr')
                                PEM = require('@root/pem')
                                
                                CSR.csr({jwk: serverKey, domains, encoding:'der'}).then (csrDer) ->
                                    csr = PEM.packBlock({type: 'CERTIFICATE REQUEST', bytes: csrDer})
                                    then_1()
                            
                            wait (then_1) ->
                                fullchain_pathname = certdir_pathname + '/fullchain.pem'
                                try fullchain = Fs.readFileSync(fullchain_pathname, 'utf8')
                                if fullchain?
                                    tls = require('tls')
                                    net = require('net')
                                    
                                    secureContext = tls.createSecureContext cert: fullchain
                                    secureSocket = new tls.TLSSocket(tmpSocket = new net.Socket(), { secureContext })
                                    cert = secureSocket.getCertificate()
                                    secureSocket.destroy()
                                    tmpSocket.destroy()
                                return then_1() if fullchain?
    
                                challenges =
                                    'http-01': require('acme-http-01-webroot').create webroot:webroot_pathname
                               
                                acme.certificates.create({ account, accountKey, csr, domains, challenges }).then (pems) ->
                                    fullchain = pems.cert + '\n' + pems.chain + '\n';
                                    Fs.writeFileSync(fullchain_pathname, fullchain, 'utf8')
                                    cb(pems)
                                    then_1()
    
                _registerHelper = (args, cb) ->
                    if (args.debug)
                        console.log("[ChocoLetsEncrypt]: begin registration");
                    
                    registerAsync args, (pems) ->
                        if (args.debug)
                            console.log("[ChocoLetsEncrypt]: end registration")
                        cb(null, pems)
                    , cb
                
                register = (args, cb) ->
                    if (args.debug)
                        console.log('[ChocoLetsEncrypt] register')
                    
                    if (!Array.isArray(args.domains))
                        cb(new Error('args.domains should be an array of domains'))
                        return
                    
                    # reload cert as a last check before attempting a renew
                    fetch (hit, err) ->
                        now = Date.now()
                    
                        if (err)
                            # had a bad day
                            cb(err)
                            return
                        else if (hit?)
                            if (not args.duplicate and (now - hit.issuedAt) < ((hit.lifetime or handlers.lifetime) * 0.65))
                                console.warn("\ntried to renew a certificate with over 1/3 of its lifetime left, ignoring")
                                console.warn("(use --duplicate or opts.duplicate to override\n")
                                cb(null, hit)
                                return
                        _registerHelper args, (err) ->
                            if (err)
                                cb(err)
                                return
                        
                            # Sanity Check
                            fetch (pems, err) ->
                                if (pems)
                                    cb(null, pems)
                                    return
                    
                                # still couldn't read the certs after success... that's weird
                                console.error("still couldn't read certs after success... that's weird")
                                cb(err, null)
                                
                renew = (args, cb) ->
                    if args.debug then console.log('[ChocoLetsEncrypt] renew')
                    args.duplicate = no
                    register(args, cb)
                    return
                
                fetch = (cb) ->
                    cert = null
                    tlsContext = null
                    issuedAt = expiresAt = null
                    err = null
                    privkey_pathname = certdir_pathname + '/privkey.pem'
                    try privkey = Fs.readFileSync(privkey_pathname, 'utf8')
                    fullchain_pathname = certdir_pathname + '/fullchain.pem'
                    try fullchain = Fs.readFileSync(fullchain_pathname, 'utf8')
                    if privkey? and fullchain?
                        try
                            tls = require('tls')
                            net = require('net')
                            
                            tlsContext = tls.createSecureContext key: privkey, cert: fullchain
                            secureSocket = new tls.TLSSocket(tmpSocket = new net.Socket(), { secureContext:tlsContext })
                            cert = secureSocket.getCertificate()
                            issuedAt = new Date(cert.valid_from).valueOf() if cert.valid_from?
                            expiresAt = new Date(cert.valid_to).valueOf() if cert.valid_to
                            unless issuedAt? then cert = null
                            
                            secureSocket.destroy()
                            tmpSocket.destroy()
                        catch e
                            cert = null
                            err = new Error 'Unable to load certificate from ' + fullchain_pathname
                    certInfo = { cert, tlsContext, issuedAt, expiresAt } if cert? and issuedAt?
                    cb(certInfo, err)
                
                {email, domains, agreeTos, debug} = config.letsencrypt
                option.SNICallback = sni_callback.create { acme, register, renew, fetch, debug, domains, httpsOptions:_.clone(option), approveRegistration: (hostname, cb) -> cb null, {email, domains, agreeTos, debug} }
            [option]
        else
            []
                
        network = if config.http_only then Http else Https
        
        extract = (request, url) ->
            # We extract infos from the Request
            request.url = url if url?
            # Execute rewrite rules if any
            if config.rewrite?.length > 0
                for rewrite in config.rewrite
                    {rule, replace} = rewrite
                    if typeof replace is 'function' then replace = replace(url)
                    new_url = request.url.replace new RegExp(rule, "ig"), replace
                    (request.url = new_url ; break) if new_url isnt request.url 
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
            only_values = true
            # check if we have only values and no key name in query
            for param, param_index in query.list when param.key not in keywords
                if param.value != '' then only_values = false ; break
            # read keys and/or values in query
            for param, param_index in query.list when param.key not in keywords
                param_key = if param.value is '' and only_values then '__' + param_index else param.key
                param_value = decodeURI(if param.value is '' and only_values then param.key else param.value)
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
            what_pathname = what
            if (app_pathname + (if what[0] isnt '/' then '/' else '' ) + what).indexOf(sys_pathname) is 0 then what_pathname = '/-' + (app_pathname + (if what[0] isnt '/' then '/' else '' ) + what).substr sys_pathname.length
            what_path = what_pathname.split '/'
            how = query.dict['how'] ? 'web' # web, edit, help, manifest, raw, json
            backdoor_key = if path[1] is '!' then path[2] else ''
            where_index = 1 + if backdoor_key isnt '' then 2 else 0
            where_path = path[(where_index + if path[where_index] is '-' then 1 else 0)..]
            region = if path[where_index] is '-' or what_path[1] is '-' then 'system' else if where_path[0] is 'static' and how is 'web' then 'static' else if path[where_index] in ['client', 'general', 'server'] then 'secure' else 'app'
            where = where_path.join '/'
            
            session = sessions.get(request)
            websocket = websockets.get(request)

            {space, workflow, so, what, how, where, region, params, sysdir, appdir, datadir, backdoor_key, request, session, websocket, websockets:websocket}

        exchange = (bin, request, response) ->
            Interface.exchange bin, (result) ->
                if response.finished then return
                # We will send back a cookie with an id and an expiration date
                result.headers['Set-Cookie'] = 'bsid=' + bin.session.id + ';path=/;secure;httponly;expires=' + bin.session.expires.toUTCString()
                # And here is our response to the requestor
                
                if config.compression is on and result.status is 200 and result.headers['Content-Type']?.split(';')[0] in ['text/plain', 'text/html', 'text/javascript', 'application/json', 'application/json-late'] and
                    request.headers['accept-encoding']?.split(',').indexOf('gzip') >= 0
                        result.headers ?= {}
                        result.headers['Content-Encoding'] = 'gzip'
                        response.writeHead result.status, result.headers
                        read = new Readable() ; read._read = ->
                        chunk = result.body
                        chunk = chunk.toString() unless Buffer.isBuffer chunk
                        read.push chunk ; read.push null
                        read.pipe(Zlib.createGzip()).pipe response
                else
                    response.writeHead result.status, result.headers
                    response.end result.body

        upgrade = do ->
            
            fallback_websockets = {}
            
            Fallback_Websocket = _.prototype
                constructor: (@id) -> @messages = []
                send: (message) -> @messages.unshift message
            
            get_websocket = (request) ->
                id = request.headers['x-litejq-websocket-id']
                return null unless id?

                fallback_websockets[id] ?= new Fallback_Websocket id
            
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
                                    bin.response = response
                                
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
        # (however if Letsencrypt is activated, we link our services to Http(s) servers created by Greenlock-express)
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
                bin.response = response
                # We call the Interface service to make an exchange between the requestor and the place specified in `where`
                exchange bin, request, response

            # If we have an error, we send it back as is.
            catch err
                response.writeHead 200, { "Content-Type": "text/plain" }
                response.end 'error : ' + err.stack
        
        # Handle web sockets and middleware to proxy web sockets requests
        
        server.on 'upgrade', (request, socket, header) ->
            if config.proxy? and not to_proxy_damain request
                for func in middleware[if config.http_only then 'ws' else 'wss'] then unless func({request, socket, header}) then return
            else
                ws_server.handleUpgrade request, socket, header, (client) ->
                    ws_server.emit('connection', client, request);
        
        # Start our web server
        server.listen unless config.http_only and not config.letsencrypt? then port_https else port_http

        unless config.http_only and not config.letsencrypt? 
            # Start Http server with redirection to Https
            httpApp = (request, response) ->
                for func in middleware.http then unless func({request, response}) then return

                response.writeHead 302, {'Location': "https://#{request.headers.host}#{request.url}" }
                response.end ''
                
            Http.createServer(httpApp).listen port_http

        ws_server = new WebSocket.Server({noServer:on}).on 'connection', (ws, req) ->
            ws.upgradeReq = req if req?
            websockets.register ws
            
            ws.on 'close', -> websockets.unregister ws

            ws.on 'message', (str) ->
                message = JSON.parse str
                bin = extract ws.upgradeReq, message.url
                bin.websocket = ws
                bin.how = how = 'json'

                Interface.exchange bin, (result) ->
                    result.body ?= ''
                    feedback = "{\"result\":#{if result.body.trim() is '' then 'null' else result.body}, \"id\":#{message.id}}"
                    ws.send feedback
    
        
        return

#### Start
# The main workflow service.
exports.start = (appdir, port) ->
    world = new World(appdir, port)

# Services from server/Interface
exports.Sessions = Sessions
exports.Session = Session

#### Temporary experiments

exports.say_hello = (who = 'you', where = 'there') ->
    'hello ' + who + ' in ' + where

exports.ping_json = ->
    date: new Date()
    town: 'Paris'
    zip: 75000