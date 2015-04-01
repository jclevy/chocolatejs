_ = require '../../general/chocodash'
Action = require '../locco/action'

# `Workflow` is where Actors are interactng. 
Workflow = _.prototype
    constructor: (options = {}) ->
        
        is_ready = new _.Publisher
        
        @actors = {}
        @ready = (func) ->
            if @ws.readyState is 1 then setTimeout (=> func.call @), 0
            else is_ready.subscribe (=> func.call @)
        
        sync = ->
            actions = _.do.flush()
            return unless actions?
            
            # stringify
    
        unless module?
            if $ and $.websocket
                do connect = =>
                    callbacks = {}
                    id = 1
                    
                    @message_id = (callback) -> 
                        callbacks[id.toString()] = callback
                        id++
                    
                    @ws = $.websocket "wss://#{window.location.host}/~"

                    @ws.onmessage =  (evt) ->
                        if options.debug then console.log "Message is received:" + evt.data if evt.data isnt ''

                        data = _.parse evt.data
                        if data? and data.result isnt undefined and data.id
                            callback = callbacks[data.id]
                            callback data.result
                            delete callbacks[data.id]
                        
                    @ws.onopen = ->
                        if options.debug then console.log "Connection opened"
                        is_ready.notify()
                        
                    @ws.onclose = ->
                        if options.debug then console.log "Connection closed. Reopening..." 
                        setTimeout connect, 300
                
                setInterval sync, 300

    enter: (actor) ->
        @actors[actor.id()] = actor

    broadcast: (object, service, params..., callback) ->
        if window?
            location = null
            
            for name, module of window.modules
                if module is object.constructor then location = 'general/' + name; break 
                
            if location? and service? 
                params = (_.param param for param in params).join '&'
                if params.length > 0 then params = '&' + params
                @ws.send "{url:'/#{location}?#{service}#{params}', id:#{@message_id(callback)}}"

    execute: (action) ->
        for action in action.actions
            switch so
                when 'go' then # on a besoin de la Reserve maintenant

Workflow.main = new Workflow
Workflow.actor = (id) -> Workflow.main.actors[id]

_module = window ? module
if _module.exports? then _module.exports = Workflow else window.Locco ?= {} ; window.Locco.Workflow = Workflow
