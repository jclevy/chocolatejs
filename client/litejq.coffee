# liteJq - lite jQuery

# adapted from
#https://github.com/soyjavi/QuoJS
#https://github.com/jquery/jquery
#https://github.com/dciccale/ki.js
#https://github.com/ded/domready

return unless window? and not (window.$? and window.$.fn? and window.$.fn.jquery?)

core_version = "0.1.1"
core_object = {}
core_array = []

# returns array of dom nodes
core_toArray = (a) ->
    return a if $.type(a) is 'array'
    i = -1 ; result = []
    while item = a[++i] then result[i] = item
    return result

core_hasOwn = core_object.hasOwnProperty

core_isArraylike = (obj) ->
    length = obj.length ; type = $.type obj

    return false if $.isWindow obj
    return true if obj.nodeType is 1 and length

    return type is "array" or type isnt "function" and (length is 0 or typeof length is "number" and length > 0 and (length - 1) of obj)

# $ definition
previous$ = window.$

$ = window.litejQ = (s) ->
    return new $.prototype.init(s)

window.$ = $ unless previous$?

$.expando = "litejQ" + (core_version + Math.random()).replace /\D/g, ""

$.noConflict = ->
        window.$ = previous$
        return $
    
$.type = (obj) ->
    return String(obj) unless obj?
    
    class2type = 
        "[object Boolean]": "boolean"
        "[object Number]": "number"
        "[object String]": "string"
        "[object Function]": "function"
        "[object Array]": "array"
        "[object Date]": "date"
        "[object RegExp]": "regexp"
        "[object Object]": "object"
        "[object Error]": "error"
    
    if typeof obj is "object" or typeof obj is "function" then class2type[Object::toString.call(obj)] or "object" else typeof obj

$.isArray = Array.isArray or (obj) -> $.type(obj) is "array"

$.isWindow = (obj) -> return obj? and obj is obj.window

$.isPlainObject = (obj) ->
    # Must be an Object.
    # Because of IE, we also have to check the presence of the constructor property.
    # Make sure that DOM nodes and window objects don't pass through, as well
    return no if not obj or $.type(obj) isnt "object" or obj.nodeType or $.isWindow(obj)
        

    try # Not own constructor property must be Object
        return no if obj.constructor and not core_hasOwn.call(obj, "constructor") and not core_hasOwn.call(obj.constructor.prototype, "isPrototypeOf")
    catch # IE8,9 Will throw exceptions on certain host objects #9897
        return no

    # Support: IE<9
    # Handle iteration over inherited properties before own properties.
    if $.support.ownLast
        for key of obj then return core_hasOwn.call obj, key

    # Own properties are enumerated firstly, so to speed up,
    # if last one is own, then all properties are own.
    for key of obj then {}

    return key is undefined or core_hasOwn.call obj, key

# each method
# elements = the collection to iterate
# callback = the function to call each loop
# return this    
$.each = (elements, callback) ->
    if core_isArraylike elements
        i = 0
        while i < elements.length
            return elements if callback.call(elements[i], i, elements[i]) is false
            i++
    else
        for key of elements
            return elements if callback.call(elements[key], key, elements[key]) is false
    elements
    
$.map = (elems, callback, arg) ->
    ret = [] ; i = 0 ; value = null
    length = elems.length
    
    _mapone = ->
        value = callback elems[i], i, arg
        ret[ret.length] = value if value?
            
    # Go through the array, translating each of the items to their
    if core_isArraylike(elems)
        while i < length then _mapone() ; i++

    # Go through every key on the object,
    else
        for i of elems then _mapone()

    # Flatten any nested arrays
    [].concat.apply [], ret

$.extend = ->
    target = arguments[0] or {}
    i = 1
    length = arguments.length
    deep = false

    # Handle a deep copy situation
    if typeof target is "boolean"
        deep = target
        target = arguments[1] or {}
        # skip the boolean and the target
        i = 2

    # Handle case when target is a string or something (possible in deep copy)
    target = {} if typeof target isnt "object" and not $.type(target) is "function"
        
    # extend $ itself if only one argument is passed
    if length is i then target = @ ; --i

    while i < length
        # Only deal with non-null/undefined values
        if (options = arguments[i])?
            # Extend the base object
            for name of options
                src = target[name]
                copy = options[name]

                # Prevent never-ending loop
                if target is copy then continue

                # Recurse if we're merging plain objects or arrays
                if deep and copy and ($.isPlainObject(copy) or (copyIsArray = $.isArray(copy)))
                    if copyIsArray
                        copyIsArray = no
                        clone = if src and $.isArray(src) then src else []
                    else 
                        clone = if src and $.isPlainObject(src) then src else {}

                    # Never move original objects, clone them
                    target[name] = $.extend deep, clone, copy

                    # Don't bring in undefined values
                else if copy isnt undefined
                    target[name] = copy
        i += 1

    # Return the modified object
    target

$.globalEval = (text) ->
    return text unless text
    
    if window.execScript then window.execScript text
    else
        script = document.createElement 'script'
        script.setAttribute 'type', 'text/javascript'
        script.text = text
        document.head.appendChild script
        document.head.removeChild script
        
    return text

$.Environment = do ->
    _current = null
    
    Mobile_is_webkit = /WebKit\/([\d.]+)/
    
    Mobile_supported_os =
        Android: /(Android)\s+([\d.]+)/
        ipad: /(iPad).*OS\s([\d_]+)/
        iphone: /(iPhone\sOS)\s([\d_]+)/
        Blackberry: /(BlackBerry|BB10|Playbook).*Version\/([\d.]+)/
        FirefoxOS: /(Mozilla).*Mobile[^\/]*\/([\d\.]*)/
        webOS: /(webOS|hpwOS)[\s\/]([\d.]+)/

    _detectEnvironment = ->
        user_agent = navigator.userAgent
        environment = {}
        environment.browser = _detectBrowser(user_agent)
        environment.os = _detectOS(user_agent)
        environment.isMobile = !!environment.os
        environment.screen = _detectScreen()
        environment

    _detectBrowser = (user_agent) ->
        is_webkit = user_agent.match(Mobile_is_webkit)
        if is_webkit then is_webkit[0] else user_agent

    _detectOS = (user_agent) ->
        detected_os = null
        for os of Mobile_supported_os
            supported = user_agent.match(Mobile_supported_os[os])
            if supported
                detected_os =
                    name: (if (os is "iphone" or os is "ipad") then "ios" else os)
                    version: supported[2].replace("_", ".")
                break
        detected_os

    _detectScreen = ->
        width: window.innerWidth
        height: window.innerHeight

    isMobile: ->
        _current = _current or _detectEnvironment()
        _current.isMobile

    environment: ->
        _current = _current or _detectEnvironment()
        _current

    isOnline: ->
        navigator.onLine

$.websocket = (url, options = {}) ->

    # Creates a fallback object implementing the WebSocket interface
    FallbackSocket = (url, options  = {}) ->
        
        # WebSocket interface constants
        CONNECTING = 0
        OPEN = 1
        CLOSING = 2
        CLOSED = 3

        pollInterval = null
        openTimout = null
        
        options.fallbackPollInterval ?= 3000
        options.fallbackPollParams ?= {}
        options.fallbackOnly ?= false

        furl = url.replace('ws:', 'http:').replace('wss:', 'https:')

        # create WebSocket object
        fws =
            # ready state
            readyState: CONNECTING

            bufferedAmount: 0

            send: (data) ->
                return false unless fws.socket_id?
                
                success = true
                $.ajax
                    type: 'POST'
                    url: furl + '?' + $.param getFallbackParams()
                    data: data
                    dataType: 'text'
                    headers: 
                        'x-litejq-websocket':'fallback'
                        'x-litejq-websocket-id': fws.socket_id
                    contentType : "application/x-www-form-urlencoded; charset=utf-8"
                    success: (data) -> fws.onmessage "data" : data
                    error: (xhr) -> success = false; fws.onerror(xhr)
                return success

            close: () ->
                clearTimeout openTimout
                clearInterval pollInterval
                this.readyState = CLOSED
                fws.onclose()
                
            onopen: ->
            onmessage: ->
            onerror: ->
            onclose: ->

            previousRequest: null
            currentRequest: null
            socket_id: null

        getFallbackParams = () ->
            # update timestamp of previous and current poll request
            fws.previousRequest = fws.currentRequest;                    
            fws.currentRequest = new Date().getTime();

            # extend default params with plugin options
            return $.extend {"previousRequest": fws.previousRequest, "currentRequest": fws.currentRequest}, options.fallbackPollParams

        poll = ->
            return unless fws.socket_id?
            $.ajax
                type: 'GET'
                url: furl + '?' + $.param getFallbackParams()
                dataType: 'text'
                headers: 
                    'x-litejq-websocket':'fallback'
                    'x-litejq-websocket-id': fws.socket_id
                success: (data) -> 
                    fws.onmessage "data" : data
                    if data? and data isnt '' then setTimeout poll, 0
                error: (xhr) -> fws.onerror(xhr)

        $.ajax
            type: 'OPTIONS'
            url: furl
            dataType: 'text'
            headers: 'x-litejq-websocket':'fallback'
            success: (data, xhr) -> 
                fws.socket_id = xhr.getResponseHeader('x-litejq-websocket-id')
                fws.readyState = OPEN
                fws.onopen()
                poll()
                pollInterval = setInterval poll, options.fallbackPollInterval
            error: (xhr) -> fws.onerror(xhr)

        return fws
    
    if options.fallbackOnly or not window.WebSocket then new FallbackSocket(url, options)
    else new WebSocket(url)

$.Ajax = do ->
    Ajax_default =
        type: "GET"
        mime: "json"

    Ajax_mime_types =
        script: "text/javascript, application/javascript"
        json: "application/json"
        'json-late': "application/json-late"
        xml: "application/xml, text/xml"
        html: "text/html"
        text: "text/plain"

    Ajax_jsonp_id = 0
    
    Ajax_settings =
        type: Ajax_default.type
        async: true
        success: ->
        error: ->
        context: null
        dataType: Ajax_default.mime
        headers: {}
        xhr: -> new window.XMLHttpRequest()
        crossDomain: false
        timeout: 0
        cache: true

    $.ajax = (url, options) ->
        options = if typeof url is "object" then url else $.extend options, {url}

        settings = $.extend {}, Ajax_settings, options

        if settings.type is Ajax_default.type
            if settings.data?
                settings.url += "?" + $.param(settings.data) 
                delete settings.data
        else
            settings.data = $.param(settings.data)
        
        dataType = settings.dataType.toLowerCase()
        
        if settings.cache is off or options?.cache isnt on and dataType in ['jsonp', 'script']
            settings.url += (if settings.url.indexOf('?') >= 0 then '&' else '?') + "_=" + (_xhrId++).toString(36)

        return _jsonp(settings) if dataType is 'jsonp'

        xhr = settings.xhr()

        xhr.onreadystatechange = ->
            if xhr.readyState is 4
                clearTimeout abortTimeout
                _xhrStatus xhr, settings

        xhr.open settings.type, settings.url, settings.async
        _xhrHeaders xhr, settings

        if settings.timeout > 0
            abortTimeout = setTimeout((-> _xhrTimeout xhr, settings ), settings.timeout)

        try
            xhr.send settings.data
        catch error
            xhr = error
            _xhrError "Resource not found", xhr, settings

        (if (settings.async) then xhr else _parseResponse(xhr, settings))

    $.get = (url, data, success, dataType) ->
        $.ajax
            url: url
            data: data
            success: success
            dataType: dataType

    $.post = (url, data, success, dataType) -> _xhrForm("POST", url, data, success, dataType)

    $.getJson = (url, data, success) -> $.get url, data, success, Ajax_default.mime

    $.getScript = (url, success) -> $.get url, undefined, success, "script"

    $.param = (parameters) ->
        return encodeURIComponent parameters if $.type(parameters) is 'string'
        
        serialize = []
        for parameter of parameters
            if parameters.hasOwnProperty(parameter)
                serialize.push "#{encodeURIComponent parameter}=#{encodeURIComponent parameters[parameter]}"
        serialize.join '&'

    _xhrId = Date.now()

    _xhrStatus = (xhr, settings) ->
        if (xhr.status >= 200 and xhr.status < 300) or xhr.status is 0
            if settings.async
                _xhrSuccess _parseResponse(xhr, settings), xhr, settings
                return
        else
            _xhrError "$.ajax: Unsuccesful request", xhr, settings
            return

    _xhrSuccess = (response, xhr, settings) ->
        settings.success.call settings.context, response, xhr
        return

    _xhrError = (type, xhr, settings) ->
        settings.error.call settings.context, type, xhr, settings
        return

    _xhrHeaders = (xhr, settings) ->
        settings.headers["Content-Type"] = settings.contentType if settings.contentType
        settings.headers["Accept"] = Ajax_mime_types[settings.dataType] if settings.dataType
        for header of settings.headers
            xhr.setRequestHeader header, settings.headers[header]
        return

    _xhrTimeout = (xhr, settings) ->
        xhr.onreadystatechange = {}
        xhr.abort()
        _xhrError "$.ajax: Timeout exceeded", xhr, settings
        return

    _xhrForm = (method, url, data, success, dataType) ->
        $.ajax
            type: method
            url: url
            data: data
            success: success
            dataType: dataType
            contentType: "application/x-www-form-urlencoded"

    _parseResponse = (xhr, settings) ->
        response = xhr.responseText
        if response
            switch settings.dataType 
                when Ajax_default.mime
                    try
                        response = JSON.parse(response)
                    catch error
                        response = error
                        _xhrError "$.ajax: Parse Error", xhr, settings
                when "xml"
                    response = xhr.responseXML
                when "script"
                    $.globalEval response
        response
        
    _jsonp = (settings) ->
        if settings.async
            callbackName = "jsonp" + (++Ajax_jsonp_id)
            script = document.createElement("script")
            xhr = abort: ->
                $(script).remove()
                window[callbackName] = {} if callbackName of window

            abortTimeout = undefined
            window[callbackName] = (response) ->
                clearTimeout abortTimeout
                $(script).remove()
                delete window[callbackName]

                _xhrSuccess response, xhr, settings

            script.src = settings.url + (if settings.url.indexOf('?') >= 0 then '&' else '?') + "callback=" + callbackName
            $("head").append script
            if settings.timeout > 0
                abortTimeout = setTimeout((-> _xhrTimeout xhr, settings), settings.timeout)
            xhr
        else
            console.error "$.ajax: Unable to make jsonp synchronous call."
        
# Query functions
Query = do ($) ->
    _getSibling = (command) -> @map (index, element) ->
        element = element[command]
        element = element[command] while element and element.nodeType isnt 1
        [element]
        
    _query = (domain, selector) ->
        selector = selector.trim()

        if /^\.([\w-]+)$/.test selector
            elements = domain.getElementsByClassName selector.replace ".", ""
        else if /^[\w-]+$/.test selector
            elements = domain.getElementsByTagName selector
        else if /^#[\w\d-]+$/.test(selector) and domain is document
            elements = domain.getElementById selector.replace "#", ""
            unless elements then elements = []
        else
            elements = domain.querySelectorAll selector

        if elements.nodeType then [elements] else [].slice.call core_toArray elements
    
    _findAncestors = (nodes, depth) ->
        ancestors = []
        while nodes.length > 0 then nodes = $.map nodes, (node) ->
            if depth isnt 0 and (node = node.parentNode) and node isnt document and ancestors.indexOf(node) < 0
                ancestors.push node
                depth += -1 if depth > 0
                node
        ancestors

    _filtered = (nodes, selector) ->
        if selector is undefined then $(nodes) else $(nodes).filter selector
    
    _findParents = (selector, depth) ->
        instance = (property) => @map -> @[property]
        _filtered (if selector? then _findAncestors @, depth else instance "parentNode"), selector
        

    filter: (selector) ->
        $ [].filter.call(this, (element) ->
            element.parentNode and _query(element.parentNode, selector).indexOf(element) >= 0)
            
    find: (selector) ->
        $(if @length is 1 then _query @[0], selector else @map -> _query @, selector)
    
    parent: (selector) ->
        _findParents.call @, selector, 1
        
    parents: (selector) ->
        _findParents.call @, selector
        
    siblings: (selector) -> 
        siblings = @map (index, element) ->
            [].slice.call(core_toArray element.parentNode.children).filter (child) ->
                child isnt element
                
        _filtered siblings, selector

    children: (selector) ->
        _filtered (@map -> [].slice.call core_toArray @children), selector

    first: -> $ @[0]

    last: -> $ @[@length - 1]

    next: -> $ _getSibling.call @, "nextSibling"

    prev: -> $ _getSibling.call @, "previousSibling"

    closest: (selector, context) ->
        node = @[0]
        candidates = $(selector)
        node = null unless candidates.length
        while node and candidates.indexOf(node) < 0
            node = node isnt context and node isnt document and node.parentNode
        $(node)

# Events functions
Events = do ($) ->
    $.Event = (src, props) ->
        # Allow instantiation without the 'new' keyword
        return new $.Event(src, props) unless this instanceof $.Event
        
        # Event object
        if src and src.type
            @originalEvent = src
            @type = src.type
            
            # Events bubbling up the document may have been marked as prevented
            # by a handler lower down the tree; reflect the correct value.
            @isDefaultPrevented = (if (src.defaultPrevented or src.returnValue is false or src.getPreventDefault and src.getPreventDefault()) then _returnTrue else _returnFalse)
        
        # Event type
        else
            @type = src
        
        # Put explicitly provided properties onto the event object
        $.extend this, props if props
        
        # Create a timestamp if incoming event doesn't have one
        @timeStamp = src and src.timeStamp or $.now()
        
        # Mark it as fixed
        this[$.expando] = on
    
    $.now = -> (new Date()).getTime()

    $.event = 
        fix: (event) ->
            return event if event[$.expando]
            
            # Create a writable copy of the event object and normalize some properties
            type = event.type
            originalEvent = event
            fixHook = Events_fixHooks[type]
            Events_fixHooks[type] = fixHook = (if /^(?:mouse|contextmenu)|click/.test(type) then Events_mouseHooks else (if /^key/.test(type) then Events_keyHooks else {})) unless fixHook
            copy = if fixHook.props then Events_props.concat(fixHook.props) else Events_props
            event = new $.Event originalEvent
            i = copy.length ; while i-- then prop = copy[i] ; event[prop] = originalEvent[prop]
            
            # Support: IE<9
            # Fix target property
            event.target = originalEvent.srcElement or document unless event.target
            
            # Support: Chrome 23+, Safari?
            # Target should not be a text node
            event.target = event.target.parentNode if event.target.nodeType is 3
            
            # Support: IE<9
            # For mouse/key events, metaKey==false if it's undefined (#3368, #11328)
            event.metaKey = !!event.metaKey
            if fixHook.filter then fixHook.filter(event, originalEvent) else event


        add: (element, event_name, callback) ->
            if element.addEventListener?
                element.addEventListener event_name, callback, false
            else if element.attachEvent?
                element.attachEvent "on" + event_name, callback
            else
                element["on" + event_name] = callback
    
        remove: (element, event_name, callback) ->
            if element.removeEventListener
                element.removeEventListener event_name, callback, false
            else if element.detachEvent
                element.detachEvent "on" + event_name, callback
            else
                element["on" + event_name] = null
            
    Events_handlers = {}
    Events_id = 1
    
    Events_methods =
        preventDefault: "isDefaultPrevented"
        stopImmediatePropagation: "isImmediatePropagationStopped"
        stopPropagation: "isPropagationStopped"
        
    Events_desktop =
        touchstart: "mousedown"
        touchmove: "mousemove"
        touchend: "mouseup"
        touch: "click"
        doubletap: "dblclick"
        orientationchange: "resize"

    # Includes some event props shared by KeyEvent and MouseEvent
    Events_props = "altKey bubbles cancelable ctrlKey currentTarget eventPhase metaKey relatedTarget shiftKey target timeStamp view which".split(" ")
    Events_fixHooks = {}
    Events_keyHooks =
        props: "char charCode key keyCode".split ' '
        filter: (event, original) ->
            # Add which for key events
            event.which = (if original.charCode? then original.charCode else original.keyCode) unless event.which?
            event
    
    Events_mouseHooks =
        props: "button buttons clientX clientY fromElement offsetX offsetY pageX pageY screenX screenY toElement".split(" ")
        filter: (event, original) ->
            button = original.button
            fromElement = original.fromElement
            
            # Calculate pageX/Y if missing and clientX/Y available
            if not event.pageX? and original.clientX?
                eventDoc = event.target.ownerDocument or document
                doc = eventDoc.documentElement
                body = eventDoc.body
                event.pageX = original.clientX + (doc and doc.scrollLeft or body and body.scrollLeft or 0) - (doc and doc.clientLeft or body and body.clientLeft or 0)
                event.pageY = original.clientY + (doc and doc.scrollTop or body and body.scrollTop or 0) - (doc and doc.clientTop or body and body.clientTop or 0)
            
            # Add relatedTarget, if necessary
            event.relatedTarget = (if fromElement is event.target then original.toElement else fromElement) if not event.relatedTarget and fromElement
            
            # Add which for click: 1 === left; 2 === middle; 3 === right
            # Note: button is not normalized, so don't use it
            event.which = ((if button & 1 then 1 else ((if button & 2 then 3 else ((if button & 4 then 2 else 0)))))) if not event.which and button isnt `undefined`
            event

    _subscribe = (element, event, callback, selector, delegate_callback) ->
        event = _environmentEvent event
        element_id = _getElementId element
        element_handlers = Events_handlers[element_id] or (Events_handlers[element_id] = [])
        delegate = delegate_callback and delegate_callback callback, event
        handler =
            event: event
            callback: callback
            selector: selector
            proxy: _createProxyCallback delegate, callback, element
            delegate: delegate
            index: element_handlers.length

        element_handlers.push handler
        $.event.add element, handler.event, handler.proxy

    _unsubscribe = (element, event, callback, selector) ->
        event = _environmentEvent event
        element_id = _getElementId element
        for handler in _findHandlers(element_id, event, callback, selector)
            delete Events_handlers[element_id][handler.index]
            $.event.remove element, handler.event, handler.proxy

    _getElementId = (element) -> element._id or (element._id = Events_id++)

    _environmentEvent = (event) ->
        environment_event = (if ($.Environment.isMobile()) then event else Events_desktop[event])
        environment_event or event

    _createProxyCallback = (delegate, callback, element) ->
        callback = delegate or callback
        proxy = (event) ->
            event = $.event.fix event
            result = callback.apply element, [event].concat event.data
            event.preventDefault() if result is no
            result
        proxy

    _findHandlers = (element_id, event, fn, selector) ->
        (Events_handlers[element_id] or []).filter (handler) ->
            handler and (not event or handler.event is event) and (not fn or handler.callback is fn) and (not selector or handler.selector is selector)

    _createProxy = (event) ->
        proxy = $.extend(originalEvent: event, event)
        $.each Events_methods, (name, method) ->
            proxy[name] = ->
                @[method] = -> yes

                event[name].apply event, arguments

            proxy[method] = -> no
        proxy
    
    _returnTrue = -> yes
    
    _returnFalse = -> no
    
    # ready method
    # a = function to call when dom is ready
    # return this
    ready: (callback) ->
        fns = []
        hack = document.documentElement.doScroll
        loaded = (if hack then /^loaded|^c/ else /^loaded|c/).test document['readyState']
        
        flush = (f) ->
            loaded = 1 ; while f = fns.shift() then f()
        
        document.addEventListener? 'DOMContentLoaded', fn = ->
            document.removeEventListener 'DOMContentLoaded', fn, no
            flush()
        , no
        
        if hack then document.attachEvent 'onreadystatechange', fn = ->
            if /^c/.test document['readyState']
              document.detachEvent 'onreadystatechange', fn
              flush()
                    
        if hack
            if window.top isnt window.self
                if loaded then callback() else fns.push callback
            else
                do wait = ->
                    try document.documentElement.doScroll 'left'
                    catch then return setTimeout (-> wait() ), 50
                    callback()
        else
            if loaded then callback() else fns.push callback
    
        return @

    # on method
    # event = string event type i.e 'click'
    # selector = target an item for delegation
    # callback = function
    # return this
    on: (event, selector, callback) ->
        if not selector? or typeof selector is "function" then @bind(event, selector) else @delegate(selector, event, callback)

    # off method
    # event = string event type i.e 'click'
    # selector = target an item for delegation
    # callback = function
    # return this
    off: (event, selector, callback) ->
        if not selector? or typeof selector  is "function" then @unbind(event, selector) else @undelegate(selector, event, callback)

    bind: (event, callback) ->
        @each -> _subscribe @, event, callback ; return

    unbind: (event, callback) ->
        @each -> _unsubscribe @, event, callback ; return

    delegate: (selector, event, callback) ->
        @each (i, element) ->
            _subscribe element, event, callback, selector, (fn) ->
                (e) ->
                    if match = $(e.target or e.srcElement or document).closest(selector, element).get 0
                        evt = $.extend _createProxy(e),
                            currentTarget: match
                            liveFired: element
                        fn.apply match, [ evt ].concat([].slice.call(arguments, 1))
            return

    undelegate: (selector, event, callback) ->
        @each ->
            _unsubscribe @, event, callback, selector
            return

    triggerHandler: (event, args) ->
        result = null

        @each (i, element) ->
            e = _createProxy(if $.type(event) is 'string' then $.Event(event) else event)
            e._args = args
            e.target = element
            element_id = _getElementId element
            $.each _findHandlers(element_id, event.type ? event), (i, handler) ->
                result = handler.proxy e
                return false if e.isImmediatePropagationStopped?() 
                
        result

# Style functions
Style = do ($) ->
    _existsClass = (name, className) ->
        classes = className.split /\s+/g
        classes.indexOf(name) >= 0

    _computedStyle = (element, property) ->
        window.getComputedStyle(element, "").getPropertyValue property

    addClass: (name) ->
        @each ->
            unless _existsClass(name, @className)
                @className += " " + name
                @className = @className.trim()

    removeClass: (name) ->
        @each ->
            unless name
                @className = ""
            else
                @className = @className.replace(name, " ").replace(/\s+/g, " ").trim() if _existsClass(name, @className)

    toggleClass: (name) ->
        @each ->
            if _existsClass(name, @className)
                @className = @className.replace(name, " ")
            else
                @className += " " + name
                @className = @className.trim()

    hasClass: (name) ->
        this.length > 0 and _existsClass name, this[0].className

    css: (property, value) ->
        if typeof value != "undefined"
            @each -> @style[property] = value
        else if this.length > 0
            @[0].style[property] or _computedStyle(@[0], property)

# Dom functions
Dom = do ($) ->
    _stripScripts = (text, callback) ->
        scripts = []
        html = text.replace /<script([\s\S]*?)>([\s\S]*?)<\/script>/gi, (all, attr, code) -> scripts.push {attr, code}; return ''

        callback.call @, html
        
        if scripts.length > 0
            for item in scripts
                src = item.attr.match(/src.*?=.*?[\"'](.+?)[\"']/i)
                src = src[1] if src?
                code = item.code
                if (src isnt null and src isnt '') or code isnt ''
                    script = document.createElement 'script'
                    script.setAttribute 'src', src if src isnt null
                    script.setAttribute 'type', 'text/javascript'
                    script.text = code if code isnt ""
                    @appendChild script

        
        return

    text: (value) ->
        unless value?
            ret = []
            ret.push @[i][(if @[i].textContent? then 'textContent' else 'innerText')] for i in [0...@length]
            ret.join ''
        else 
            @.empty().append((@[0] and @[0].ownerDocument or document).createTextNode(value));

    html: (value) ->

        type = $.type(value)
        if type is "undefined"
            (if @length > 0 then @[0].innerHTML else)
        else
            @each ->            
                if type is "string"
                    _stripScripts.call @, value, (html) -> @innerHTML = html
                else if type is "array"
                    $(@).html(v) for v in value
                else
                    @innerHTML = @innerHTML + $(value).html()

    append: (value) ->
        type = $.type(value)
        @each ->
            if type is "string"
                _stripScripts.call @, value, (html) -> @insertAdjacentHTML "beforeend", html
                
            else if type is "array" or value?.length? and core_isArraylike value
                $(@).append(v) for v in value
            else
                @appendChild value

    prepend: (value) ->
        type = $.type(value)
        @each ->
            if type is "string"
                _stripScripts.call @, value, (html) -> @insertAdjacentHTML "afterbegin", html
            else if type is "array"
                $(@).prepend(v) for v in value
            else
                @insertBefore value, @firstChild

    replaceWith: (value) ->
        type = $.type(value)
        @each ->
            if @parentNode
                if type is "string"
                    _stripScripts.call @, value, (html) -> @insertAdjacentHTML "beforeBegin", html
                else if type is "array"
                    $(@).replaceWith(v) for v in value
                else
                    @parentNode.insertBefore value, @
        @remove()

    after: (value) ->
        type = $.type(value)
        @each ->
            if @parentNode
                if type is "string"
                    _stripScripts.call @, value, (html) -> @insertAdjacentHTML "afterend", html
                else if type is "array"
                    $(@).after(v) for v in value
                else
                    @parentNode.insertBefore value, $(@).next()
        
    empty: () ->
        @each -> @innerHTML = ""
        
    attr: (name, value) ->
        if this.length is 0 then null
        
        if $.type(name) is "string" and value is undefined
            this[0].getAttribute name
        else
            @each -> @setAttribute name, value

    removeAttr: (name) ->
        @each -> @removeAttribute name

    data: (name, value) -> @attr "data-" + name, value

    removeData: (name) -> @removeAttr "data-" + name

    val: (value) ->
        if $.type(value) is "string" then @each -> @value = value
        else (if @length > 0 then this[0].value else null)

    show: -> @css "display", ""

    hide: -> @css "display", "none"

    height: ->
        offset = @offset()
        offset.height

    width: ->
        offset = @offset()
        offset.width

    offset: ->
        return {} if this.length is 0
        
        bounding = this[0].getBoundingClientRect()

        left: bounding.left + (window.pageXOffset ? document.documentElement.scrollLeft)
        top: bounding.top + (window.pageYOffset ? document.documentElement.scrollTop)
        width: bounding.right - bounding.left
        height: bounding.bottom - bounding.top

    remove: ->
        @each -> @parentNode.removeChild this if @parentNode?

# core prototype
core =
    # default length
    length: 0 
    
    # init method (internal use)
    # a = selector, dom element, function, object or array    
    init: (a) ->
        core_array.push.apply @, if a and a.nodeType then [a] 
        else (if "" + a is a 
            if a[0] is "<" and a[a.length-1] is ">" and a.length >= 3 
                len = a.length - 1 - if (a[a.length-2] is '/') then 1 else 0
                [document.createElement(a.slice 1, len)]
            else core_toArray(document.querySelectorAll(a)) 
        else (if /^f/.test(typeof a) then [$(document).ready(a)] 
        else switch $.type(a) 
            when 'array' then a 
            when 'object' then [a]
            else[]))
    
    toArray: -> [].slice.call this

    get: (num) ->
        if num == null then @toArray()
        else if num < 0 then @[@.length + num] else @[num]

    each: (callback, args) ->
        $.each @, callback, args
        
    splice: core_array.splice
    
    map: (fn) -> 
        $.map @, (el, i) -> fn.call el, i, el
        
    'indexOf': core_array.indexOf

core[k] = v for k,v of o for o in [Query, Events, Style, Dom]

# set prototypes
$.prototype = $.fn = core.init.prototype = core


# -----------------------
# Support 
$.support = {}

# Support: IE<8
# window.Element
document.querySelectorAll ?=  do ->
    style = document.createStyleSheet()
    
    (selectors) ->
        all = document.all
        elements = []
        selectors = selectors.replace(/\[for\b/gi, '[htmlFor').split ','
        for i in [0...selectors.length] by 1
            style.addRule selectors[i], 'k:v', 0
            for j in [0...all.length] by 1 then all[j].currentStyle.k and elements.push all[j]
            style.removeRule 0
        elements

document.querySelector ?= (selectors) ->
    elements = document.querySelectorAll selectors
    return if elements.length then elements[0] else null

document.getElementsByClassName ?= (classNames) ->
    classNames = String(classNames).replace /^|\s+/g, '.'
    return document.querySelectorAll classNames

# Array filter

Array::filter ?= (fn) ->
    throw new TypeError() unless this?
    throw new TypeError() unless typeof fn is "function"
    t = Object(this) ; len = t.length >>> 0
    res = [] ; thisp = arguments[1]
    i = 0

    while i < len
        if i of t
            val = t[i]
            res.push val if fn.call thisp, val, i, t
        i++
    res

# Trim
String::trim ?= -> return this.replace /^\s+|\s+$/g, ''

# JSON
window.JSON ?= do ->
    cx = /[\u0000\u00ad\u0600-\u0604\u070f\u17b4\u17b5\u200c-\u200f\u2028-\u202f\u2060-\u206f\ufeff\ufff0-\uffff]/g
    escapable = /[\\\"\x00-\x1f\x7f-\x9f\u00ad\u0600-\u0604\u070f\u17b4\u17b5\u200c-\u200f\u2028-\u202f\u2060-\u206f\ufeff\ufff0-\uffff]/g
    gap = undefined
    indent = undefined
    meta =
        "\b": "\\b"
        "\t": "\\t"
        "\n": "\\n"
        "\f": "\\f"
        "\r": "\\r"
        "\"": "\\\""
        "\\": "\\\\"

    rep = undefined
    
    f = (n) -> (if n < 10 then "0" + n else n)
    
    quote = (string) ->
        escapable.lastIndex = 0
        (if escapable.test(string) then "\"" + string.replace(escapable, (a) ->
            c = meta[a]
            (if typeof c is "string" then c else "\\u" + ("0000" + a.charCodeAt(0).toString(16)).slice(-4))
        ) + "\"" else "\"" + string + "\"")
        
    str = (key, holder) ->
        mind = gap
        value = holder[key]
        
        value = value.toJSON(key) if value and typeof value is "object" and typeof value.toJSON is "function"
        value = rep.call(holder, key, value) if typeof rep is "function"
        
        switch typeof value
            when "string" then quote value
            when "number" then (if isFinite(value) then String(value) else "null")
            when "boolean", "null"then String value
            when "object"
                return "null" unless value
                
                gap += indent
                partial = []
                
                if Object::toString.apply(value) is "[object Array]"
                    length = value.length
                    i = 0
                    while i < length
                        partial[i] = str(i, value) or "null"
                        i += 1
                    v = (if partial.length is 0 then "[]" else (if gap then "[\n" + gap + partial.join(",\n" + gap) + "\n" + mind + "]" else "[" + partial.join(",") + "]"))
                    gap = mind
                    return v
                
                if rep and typeof rep is "object"
                    length = rep.length
                    i = 0
                    while i < length
                        if typeof rep[i] is "string"
                            k = rep[i]
                            v = str(k, value)
                            partial.push quote(k) + (if gap then ": " else ":") + v if v
                        i += 1
                else
                    for k of value
                        if Object::hasOwnProperty.call(value, k)
                            v = str(k, value)
                            partial.push quote(k) + (if gap then ": " else ":") + v if v
                
                v = (if partial.length is 0 then "{}" else (if gap then "{\n" + gap + partial.join(",\n" + gap) + "\n" + mind + "}" else "{" + partial.join(",") + "}"))
                gap = mind
                v
                
    if typeof Date::toJSON isnt "function"
        Date::toJSON = -> (if isFinite(@valueOf()) then @getUTCFullYear() + "-" + f(@getUTCMonth() + 1) + "-" + f(@getUTCDate()) + "T" + f(@getUTCHours()) + ":" + f(@getUTCMinutes()) + ":" + f(@getUTCSeconds()) + "Z" else null)

        String::toJSON = Number::toJSON = Boolean::toJSON = -> @valueOf()
        
    stringify: (value, replacer, space) ->
        gap = ""
        indent = ""
        
        if typeof space is "number" then i = 0 ; while i < space then indent += " " : i += 1
        else indent = space if typeof space is "string"
        
        rep = replacer
        throw new Error("JSON.stringify") if replacer and typeof replacer isnt "function" and (typeof replacer isnt "object" or typeof replacer.length isnt "number")
        
        str "", "": value

    parse: (text, reviver) ->
        walk = (holder, key) ->
            value = holder[key]
            if value and typeof value is "object"
                for k of value
                    if Object::hasOwnProperty.call(value, k)
                        v = walk(value, k)
                        if v isnt `undefined` then value[k] = v
                        else delete value[k]
            reviver.call holder, key, value
            
        j = undefined
        text = String(text)
        cx.lastIndex = 0
        
        if cx.test(text)
            text = text.replace(cx, (a) ->
                "\\u" + ("0000" + a.charCodeAt(0).toString(16)).slice(-4))
            
        if /^[\],:{}\s]*$/.test(text.replace(/\\(?:["\\\/bfnrt]|u[0-9a-fA-F]{4})/g, "@").replace(/"[^"\\\n\r]*"|true|false|null|-?\d+(?:\.\d*)?(?:[eE][+\-]?\d+)?/g, "]").replace(/(?:^|:|,)(?:\s*\[)+/g, ""))
            
            j = eval("(" + text + ")")
            
            return (if typeof reviver is "function" then walk("": j, "") else j)
        
        throw new SyntaxError("JSON.parse")

# window.getComputedStyle
window.getComputedStyle ?= do ->
    
    getComputedStylePixel = (element, property, fontSize) ->
        value = element.currentStyle[property].match(/([\d\.]+)(%|cm|em|in|mm|pc|pt|)/) or [0, 0, ""]
        size = value[1]
        suffix = value[2]
        fontSize = (if not fontSize then fontSize else (if /%|em/.test(suffix) and element.parentElement then getComputedStylePixel(element.parentElement, "fontSize", null) else 16))
        rootSize = (if property is "fontSize" then fontSize else (if /width/i.test(property) then element.clientWidth else element.clientHeight))
        (if suffix is "%" then size / 100 * rootSize else (if suffix is "cm" then size * 0.3937 * 96 else (if suffix is "em" then size * fontSize else (if suffix is "in" then size * 96 else (if suffix is "mm" then size * 0.3937 * 96 / 10 else (if suffix is "pc" then size * 12 * 96 / 72 else (if suffix is "pt" then size * 96 / 72 else size)))))))
        
    setShortStyleProperty = (style, property) ->
        borderSuffix = (if property is "border" then "Width" else "")
        t = property + "Top" + borderSuffix
        r = property + "Right" + borderSuffix
        b = property + "Bottom" + borderSuffix
        l = property + "Left" + borderSuffix
        style[property] = ((if style[t] is style[r] and style[t] is style[b] and style[t] is style[l] then [style[t]] else (if style[t] is style[b] and style[l] is style[r] then [style[t], style[r]] else (if style[l] is style[r] then [style[t], style[r], style[b]] else [style[t], style[r], style[b], style[l]])))).join(" ")
    
    # <CSSStyleDeclaration>
    CSSStyleDeclaration = (element) ->
        style = this
        currentStyle = element.currentStyle
        fontSize = getComputedStylePixel(element, "fontSize")
        unCamelCase = (match) ->
            "-" + match.toLowerCase()

        for property of currentStyle
            Array::push.call style, (if property is "styleFloat" then "float" else property.replace(/[A-Z]/, unCamelCase))
            if property is "width"
                style[property] = element.offsetWidth + "px"
            else if property is "height"
                style[property] = element.offsetHeight + "px"
            else if property is "styleFloat"
                style.float = currentStyle[property]
            else if /margin.|padding.|border.+W/.test(property) and style[property] isnt "auto"
                style[property] = Math.round(getComputedStylePixel(element, property, fontSize)) + "px"
            else
                style[property] = currentStyle[property]
        setShortStyleProperty style, "margin"
        setShortStyleProperty style, "padding"
        setShortStyleProperty style, "border"
        style.fontSize = Math.round(fontSize) + "px"
        
    CSSStyleDeclaration:: =
        constructor: CSSStyleDeclaration
        
        getPropertyPriority: ->
            throw new Error "NotSupportedError: DOM Exception 9"
        
        getPropertyValue: (property) ->
            this[property.replace(/-\w/g, (match) ->
                match[1].toUpperCase()
            )]
        
        item: (index) -> this[index]
        
        removeProperty: -> throw new Error "NoModificationAllowedError: DOM Exception 7"
        
        setProperty: -> throw new Error "NoModificationAllowedError: DOM Exception 7"

        getPropertyCSSValue: -> throw new Error "NotSupportedError: DOM Exception 9"

    # <window>.getComputedStyle
    (element) -> new CSSStyleDeclaration element


# Support: IE<9
# Iteration over object's inherited properties before its own.

# (internal use)
# Selectors API Level 1 (http://www.w3.org/TR/selectors-api/)
# http://ajaxian.com/archives/creating-a-queryselector-for-ie-that-runs-at-native-speed

for i of $($.support) then break
$.support.ownLast = i isnt "0"

# indexOf
Array.prototype.indexOf ?= (elem) ->
    if this.charAt?
        for i in [0...this.length] by 1
            if this.charAt(i) is elem then return i
    else
        for i in [0...this.length] by 1
            if this[i] is elem then return i
            
    return -1;
