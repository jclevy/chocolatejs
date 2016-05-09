_ = require '../../general/chocodash'
Chocokup = require '../../general/chocokup'

# Interface
#  defaults: {} or ->
#  locks: {} or ->
#  values: ->
#  steps: ->
#  action : ->
Interface = _.prototype

    constructor: (service) ->
        service = action:service if typeof service is 'function'
        
        if service?
            if service.defaults?
                if typeof service.defaults is 'function' then @defaults = service.defaults 
                else @defaults = _.defaults @defaults, service.defaults
            if service.locks?
                if typeof service.locks is 'function' then @locks = service.locks 
                else @locks = _.defaults @locks, service.locks 
            @values = service.values if service.values?
            @steps = service.steps if service.steps?
            
            @[name] = item for name, item of service when name not in ['defaults', 'locks', 'values', 'steps'] # action, actor, document, update...
            
        return
    
    bind: (actor, document, @name) ->
        unless @actor? and @document?
            @actor = actor
            @document = document
            switch _.type @update
                when _.Type.Function then @observe @update 
                when _.Type.String then @observe (html) => $(@update).html html; return
    
    review: (bin, scope, reaction, end) ->
        check =
            # `defaults` ensure default values are set on an object
            defaults: (object, defaults) =>
                if typeof defaults is 'function' then defaults = defaults.call @
                
                set = (o, d) ->
                    for own dk,dv of d
                        if _.isBasicObject(o[dk]) and _.isBasicObject(dv) then set o[dk], dv
                        else o[dk] = dv if not o[dk]? 
                    o
                   
                set object, defaults
        
            # `locks` ensure keys are provided for every present lock
            locks: (keys, locks) =>
                return yes unless locks?
                if typeof locks is 'function' then locks = locks.call @
                
                for lock in locks then return no if lock not in keys
                
                yes
                
            # `values` ensure values at the right scale, in the right range...
            values: (bin, controller) -> controller.call bin
            
        check_services = ->
            
            _.flow (run) ->
                check_service = (service_bin, local_scope) ->
                    for name, service of service_bin when name isnt '__'
                        if service instanceof Interface
                            do (_bin = service_bin, _name = name, _service = service, _local_scope = if local_scope? then local_scope.slice(0) else null) ->
                                run (next_service) ->
                                    _bin[_name].bin = {__:_bin.__} unless _bin[_name] in scope.reviewed
                                    if _local_scope? 
                                        scope.global.push item for item in _local_scope
                                        _next_service = next_service
                                        next_service = -> scope.global.pop() for item in _local_scope ; _next_service()

                                    unless _bin[_name] in scope.reviewed
                                        scope.reviewed.push _bin[_name]
                                        service_result = _service.review _bin[_name].bin, scope, reaction, next_service 
                                    
                                    if service_result isnt next_service 
                                        if _local_scope? 
                                            scope.global.pop() for item in _local_scope
                                        next_service()
                                    
                                    service_result
                        else
                            if _.isBasicObject service
                                _local_scope = if local_scope? then local_scope.slice(0) else []
                                _local_scope.push name
                                check_service service, _local_scope
                                    
                    return
                
                check_service bin
                
                run -> end()
                
            end
        
        reaction.certified ?= yes

        check.defaults bin, @defaults if @defaults?
        reaction.certified = check.locks bin.__?.session?.keys, @locks if @locks?
        reaction.certified = check.values bin, @values if @values?
        
        check_services()
        
        
    submit: (bin = {}) ->
        publisher = new _.Publisher
        
        reaction = new Interface.Reaction
        
        _.flow self:@, (run) ->
            run (end) -> 
                end.with @review bin, global:[], local:[], reviewed:[], reaction, end

            run (end) ->
                if reaction.certified and @steps?
                    respond = (o) -> @reaction.bin = o ; end()
                    respond.later = end
                    self = {bin, document:@document, 'interface':@, actor:@actor, reaction, respond, transmit: ((actor, service) -> actor[service].submit(@bin).subscribe((reaction) => @respond reaction.bin); respond.later) }
                    result = @steps.call self, self
                end.with result

            run (end) ->
                if reaction.certified and @action?
                    respond = (o) -> @reaction.bin = o ; end()
                    respond.later = end
                    self = {bin, document:@document, 'interface':@, actor:@actor, reaction, respond, transmit: ((actor, service) -> actor[service].submit(@bin).subscribe((reaction) => @respond reaction.bin); respond.later) }
                    result = @action.call self, self 
                    reaction.bin = result unless reaction.bin? or result is end.later
                end.with result

            run -> 
                publisher.notify reaction
        
        publisher
    
    observe: (action) ->
        new _.Observer => 
            @document.signal?.value() ; @submit().subscribe ({bin}) -> action bin.render()

Interface.Reaction = _.prototype
    constructor: (@bin, @certified) ->
        
Interface.Remote = _.prototype inherit:Interface, use: ->
    @submit = (bin = {}) ->
        if '__' of bin then _.super @, bin
        else @actor.submit @name, bin

Interface.Web = _.prototype inherit:Interface, use: ->
    
    @type = 'App'
    
    @review = (bin, scope, reaction, end) ->
        
        _.flow self:@, (run) ->
            run (end) -> 
                end.with _.super Interface.Web::review, @, bin, scope, reaction, end

            run ->
                reaction.bin = ''
                scope.global.length = 0
                scope.local.length = 0
                check_interfaces = (bin) ->
                
                    for name, service of bin 
                        if service instanceof Interface.Web
                            kups = reaction.kups ?= {}
                            for step in scope.global then kups = kups[step] ?= {}

                            kups[name] ?= new Function 'o', """
                                var interface = this.interface, bin = this.bin, actor = this.actor, __hasProp = {}.hasOwnProperty;
                                try {this.interface = bin#{if scope.local.length > 0 then '.' + scope.local.join('.') else ''}.#{name};} 
                                catch (error) { try {this.interface = bin.#{name};} catch (error) {}; };
                                this.actor = this.interface != null ? this.interface.actor : null;
                                this.bin = this.interface != null ? (this.interface.bin != null ? this.interface.bin : {}) : {};
                                if (o != null) {
                                    for (k in o) {
                                        if (hasOwnProperty.call(o, k)) {
                                            this.bin[k] = o[k];
                                        }
                                    }
                                }
                                (#{(service.action?.overriden ? service.action).toString()}).call(this);
                                this.bin = bin; this.interface = interface, this.actor = actor;
                                """

                            scope.web_reviewed ?= []
                            unless bin[name] in scope.web_reviewed or not bin[name]?.bin?
                                scope.web_reviewed.push bin[name]
                                check_interfaces bin[name].bin
                        else
                            if _.isBasicObject service
                                scope.global.push name
                                scope.local.push name
                                check_interfaces service
                                scope.local.pop()
                                scope.global.pop()

                    return
 
                check_interfaces bin
                end()
        
        end

    @submit = (bin) ->
        unless @action?.overriden
            chocokup_code = @action ? ->
            @action = ({bin, reaction}) =>
                bin ?= {}

                kups = reaction.kups
                delete reaction.kups
                
                options = {bin, document:@document, 'interface':@, actor:@actor, kups}
                options.theme = bin.theme if bin.theme?
                options.with_coffee = bin.with_coffee if bin.with_coffee?
                options.manifest = bin.manifest if bin.manifest?
                
                reaction.bin = switch @type
                    when 'Panel'then new Chocokup.Panel options, chocokup_code
                    else new Chocokup[@type] bin?.name ? '', options, chocokup_code
                    
            @action.overriden = chocokup_code
        
        if typeof bin is 'function' then callback = bin ; bin = {}
            
        result = _.super @, bin

        if callback? then result.subscribe (reaction) -> callback reaction.bin.render()
        
        result


Interface.Web.App = Interface.Web

Interface.Web.Document = _.prototype inherit:Interface.Web, use: -> @type = 'Document'

Interface.Web.Panel = Interface.Web.Html = _.prototype inherit:Interface.Web, use: -> @type = 'Panel'

_module = window ? module
if _module.exports? then _module.exports = Interface else window.Locco ?= {} ; window.Locco.Interface = Interface
