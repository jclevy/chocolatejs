_ = require '../../general/chocodash'
Interface = require '../locco/interface'
Workflow = require '../locco/workflow'
Document = require '../locco/document'
Chocokup = require 'chocolate/general/chocokup'

# An `Actor` is a Document full of Data and Actions
# placed in a Flow and providing Interfaces
Actor = _.prototype
    adopt:
        go: (who, where, callback) ->
            _.go who[where], -> callback.apply(who, arguments) ; if who.stage.is_ready() then who.status.notify(Workflow.Status.Public); 
                
        awake: (uuid, __) ->
            unless window?
            
                return undefined if uuid? and __.session.frozen? and not __.session.frozen[uuid]?
                
                publisher = new _.Publisher
                
                __.space.read uuid, (frozen) ->
                    publisher.notify frozen
                    
                publisher

    constructor: (options) ->
        
        when_ready = new _.Publisher
        
        @ready = (callback) -> when_ready.subscribe (=> callback.call @)
        @stage = options?.workflow ? Workflow.main
        
        when_ready.subscribe (=> @stage.enter @)
        
        if window? then @stage.ready =>
            @stage.call @, 'awake', options?.uuid, how:'json', (frozen) =>
                if frozen? then @[k] = v for k,v of frozen
                when_ready.notify()
        else
            setTimeout (-> when_ready.notify()), 0
        
        (doc = v; break) for k, v of @ when v instanceof Document
        doc = new Document {} unless doc?
        @document = doc
        
        _.do.internal v, 'parent', @ for k, v of @ when v instanceof Actor
        
        _bind = (o) =>
            for k, v of o
                if v instanceof Interface then v.bind(@, doc, k)
                else if v?.constructor is {}.constructor then _bind v
            
            return
            
        _bind @

        return
    
    id: ->
        _.do.identify @, filter:[Document] unless @._?._?.uuid?
        @._._.uuid
        
    status: new _.Publisher
    
    submit: (service, params...) ->
        publisher = new _.Publisher
        if window? and @stage.is_ready()
            @stage.call @, service, params..., (data) -> 
                if data?.bin? and not data.props? then data.props = data.bin
                publisher.notify data
        else
            setTimeout (-> publisher.notify()), 0
        publisher        
        
    show: ->
        
    area: (name, id) ->
        _.do.internal @, 'area', {}
    
        set = (k,v) =>
            unless v? 
                return @_._.area[k] if @_._.area[k]?
                
                parent = @
                
                while (parent = parent._?._?.parent)?
                    return area if (area = parent.area k)?
                
            else @_._.area[k] = v
        
        if _.isBasicObject name then set(k,v) for k,v of name ; return
        else set name, id

Actor.Web = _.prototype inherit:Actor, use: ->
    _shown = {}
    
    @show = (path, source, area) ->
        steps = path.split '.' ; where = @
        for step in steps then where = where[step] ; unless where? then return
        
        area ?= where.area ? 'inline'
        switch area
            when 'inline' then where.submit? (result) ->
                if not (uuid = _shown[path])? or $("##{uuid}").length is 0
                    uuid = _shown[path] = '_' + _.Uuid()
                    result = "<div id='#{uuid}'>#{result}</div>"
                    unless source.after then source = $(source)
                    source.after?.call source, result

            when 'view' then
            when 'modal' then
            when 'popup' then

    @interface = new Interface.Web
        defaults: ->
            if (filename = @actor.options?.filename)?
                start = end = null
                for i in [0...filename.length]
                    if filename[filename.length-1-i] in ['/', '\\'] then start = filename.length-i ; end ?= filename.length ; break
                    if filename[filename.length-1-i] is '.' then end = filename.length-i-1
                start ?= 0
                end ?= filename.length
                basename = filename.substring start, end
            
            options:@actor.options
            name:@actor.options?.name ? basename ? ''
            theme: 'writer'
            manifest:"#{basename ? '/'}?manifest&how=manifest"
            actor:
                source: "var Service = (#{_.stringify(@actor.constructor.__prototyper__ ? -> {})})();"
    
        render: ->
            for src in (@props.options?.script ? '').split('\n') then script {src, charset:"utf-8"}
            for href in (@props.options?.stylesheet ? '').split('\n') then link {rel:"stylesheet", href}
    
            script -> text @props.actor.source
    
            coffeescript (main:@props.options?.main), ->
                $ ->
                    Workflow = require 'general/locco/workflow'
                    Actor = require 'general/locco/actor'
    
                    if window.applicationCache?
                        (cache = window.applicationCache).addEventListener 'updateready', (e) ->
                            (cache.swapCache() ; window.location.reload()) if cache.status is cache.UPDATEREADY
    
                    Workflow.main.ready ->
                        service = new Service 
                        service.ready ->
                            Actor.go service, main ? 'main', (str) -> $('body').html str
                            
    @manifest = (__) ->
        Fs = require 'fs'
        
        to_cache = """
            #{Chocokup.App.manifest.cache}
            /static/lib/chocodown.js
            /static/lib/coffeekup.js
            /static/lib/chocokup.js
            #{@options?.script ? ''}
            #{@options?.stylesheet ? ''}
            """
    
        to_cache_list = []
        to_cache_list.push ((line.split '?')[0]).replace('/-', '') for line in to_cache.split '\n'
    
        time_stamps_list = []
        for filename in to_cache_list
            try
                pathname = require.resolve '/' + __.sysdir + filename
                stats = Fs.statSync pathname
                time_stamps_list.push '#' + filename + ' : ' + stats.mtime.getTime()
        time_stamps = time_stamps_list.join '\n'
    
        """
        CACHE MANIFEST
        # v1.00.000
        # Actor Version:#{if @options?.filename? then (Fs.statSync @options.filename).mtime.getTime() else -1}
        #
        # Files Timestamp
        #
        #{time_stamps}
    
        CACHE:
        #{to_cache}

        FALLBACK:
        favicon.ico /
    
        NETWORK:
        /~
        """
    
_module = window ? module
if _module.exports? then _module.exports = Actor else window.Locco ?= {} ; window.Locco.Actor = Actor