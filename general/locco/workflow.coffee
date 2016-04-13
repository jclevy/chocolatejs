_ = require '../../general/chocodash'
Action = require '../locco/action'

# `Workflow` is where Actors are interactng. 
Workflow = _.prototype
    adopt:
        Status: Public:'public', Private: 'private'
        
    constructor: (options = {}) ->
        
        when_ready = new _.Publisher
        
        is_ready = no
        @is_ready = -> is_ready
        
        @actors = {}
        @ready = (func) ->
            if @ws.readyState is 1 then setTimeout (=> is_ready = yes ; func.call @), 0
            else when_ready.subscribe (=> is_ready = yes ; func.call @)
        
        sync = ->
            actions = _.do.flush()
            return unless actions?
            
            # stringify
    
        unless module?
            if $ and $.websocket
                do connect = =>
                    callbacks = {}
                    _id = 1
                    
                    @message_id = (callback) -> 
                        callbacks[_id.toString()] = callback
                        _id++
                
                    @ws = $.websocket "wss://#{window.location.host}/~"

                    @ws.onmessage =  (evt) ->
                        if options.debug then console.log "Message is received:" + evt.data if evt.data isnt ''

                        data = _.parse evt.data
                        if data? and data.result isnt undefined and data.id
                            callback = callbacks[data.id]
                            callback data.result
                            delete callbacks[data.id]
                        
                    @ws.onopen = =>
                        if options.debug then console.log "Connection opened"
                        when_ready.notify()
                        for id, actor of @actors then actor.status.notify(Workflow.Status.Public)
                        return
                        
                    @ws.onclose = =>
                        if options.debug then console.log "Connection closed. Reopening..." 
                        setTimeout connect, 300
                        for id, actor of @actors then actor.status.notify(Workflow.Status.Private)
                        return
                
                setInterval sync, 300

    enter: (actor) ->
        @actors[actor.id()] = actor

    call: (object, service, params..., callback) ->
        if window?
            location = null
            
            for name, module of window.modules
                if module is object.constructor then location = 'general/' + name; break 
            
            unless location? then location = window.location.pathname.substr 1
                
            if service? 
                params = (_.param param for param in params).join '&'
                if params.length > 0 then params = '&' + params
                if params.indexOf('&how=') is -1 then params += '&how=json-late'
                @ws.send "{url:'/#{location}?#{service}#{params}', id:#{@message_id(callback)}}"

    execute: (action) ->
        for action in action.actions
            switch so
                when 'go' then # on a besoin de la Reserve maintenant

Workflow.main = new Workflow
Workflow.actor = (id) -> Workflow.main.actors[id]

_module = window ? module
if _module.exports? then _module.exports = Workflow else window.Locco ?= {} ; window.Locco.Workflow = Workflow
