_ = require '../../general/chocodash'
Interface = require '../locco/interface'
Workflow = require '../locco/workflow'
Document = require '../locco/document'

# An `Actor` is a Document full of Data and Actions
# placed in a Flow and providing Interfaces
Actor = _.prototype
    adopt:
        go: (where, callback) -> _.go where, callback
                
        awake: (uuid, __) ->
            unless window?
            
                return undefined if uuid? and __.session.frozen? and not __.session.frozen[uuid]?
                
                publisher = new _.Publisher
                
                __.space.read uuid, (frozen) ->
                    publisher.notify frozen
                    
                publisher

    constructor: (options) ->
        
        is_ready = new _.Publisher
        
        @ready = (callback) -> is_ready.subscribe (=> callback.call @)
        @stage = options?.workflow ? Workflow.main
        
        is_ready.subscribe (=> @stage.enter @)
        
        if window? then @stage.ready =>
            @stage.broadcast @, 'awake', options?.uuid, how:'json', (frozen) =>
                if frozen? then @[k] = v for k,v of frozen
                is_ready.notify()
        else
            setTimeout (-> is_ready.notify()), 0
        
        (doc = v; break) for k, v of @ when v instanceof Document
        doc = {} unless doc?
        
        _.do.internal v, 'parent', @ for k, v of @ when v instanceof Actor
        
        _bind = (o) =>
            for k, v of o
                if v instanceof Interface then v.bind(@, doc, k)
                else if v.constructor is {}.constructor then _bind v
            
            return
            
        _bind @

        return
    
    id: ->
        _.do.identify @, filter:[Document] unless @._?._?.uuid?
        @._._.uuid
        
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

_module = window ? module
if _module.exports? then _module.exports = Actor else window.Locco ?= {} ; window.Locco.Actor = Actor