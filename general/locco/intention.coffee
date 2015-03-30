###
    Intention
    Data
    Action
    Document
    Workflow
    Interface
    Actor
    Reserve
    Prototype
###

if window? and not window.modules?.locco?
    window.modules = locco: window[if window.exports? then "exports" else "Locco"] = {}

    unless $ and $.ajax
        unless window.require? then window.require = -> window.exports
        return

    # Simple and temporary Require function
    previousRequire = window.require

    use_cache = on
    
    window.require = require = (modulename, filename, options) ->
        if arguments.length is 2 and Object.prototype.toString.apply filename isnt '[object String]'
            options = filename
            filename = null
            
        filename = modulename unless filename? 
        filename = resolve filename
        
        if options?.use_cache?
            _previous_use_cache = use_cache
            use_cache = options.use_cache
    
        result = previousRequire? filename
        return result if result?
    
        if use_cache
            cachedModule = window.modules[filename]
            return cachedModule if cachedModule?
        
        _previousExports = window.exports
        window.exports = {}
        
        url = '/static/lib/' + filename + '.js'
    
        $.ajax
            url: url
            async: false
            cache: on
            error: (type, xhr, settings) -> console.log 'require("' + url + '") failed' + if xhr.status? then ' with error ' + xhr.status? else ''
            dataType: 'script'
        
        result = window.modules[filename] = window.exports
        window.exports = _previousExports
    
        if options?.use_cache?
            use_cache = _previous_use_cache
        
        result
    
    window.require.resolve = resolve = (filename) ->
        filename = filename.toLowerCase().replace(/^\.\//, '').replace(/\.\.\//g, '').replace(/^general\//, '').replace(/^client\//, '').replace(/^server\//, '')
        filename = if (i=filename.lastIndexOf '.') >= 0 then filename[0...i] else filename
    
    window.require.cache = (used) -> use_cache = used
