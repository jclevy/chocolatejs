_ = require '../../general/chocodash'
Chocokup = require '../../general/chocokup'

Interface = _.prototype

    constructor: (service) ->
        service = action:service if typeof service is 'function'
        
        if service?
            if service.defaults?
                if typeof service.defaults is 'function' then @defaults = service.defaults 
                else @defaults = _.defaults @defaults, service.defaults
            @locks = _.defaults @locks, service.locks if service.locks?
            @values = _.defaults @values, service.values if service.values?
            @steps = _.defaults @steps, service.steps if service.steps?
            
            
            @[name] = item for name, item of service when name not in ['defaults', 'locks', 'values', 'steps'] # action, actor, document, update...
            
        return
    
    bind: (actor, document, @name) ->
        unless @actor? and @document?
            @actor = actor
            @document = document
            switch _.type @update
                when _.Type.Function then @observe @update 
                when _.Type.String then @observe (html) => $(@update).html html; return
    
    review: (bin, scope, reaction, next) ->
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
            was_synchronous = true
            
            _.serialize (step) ->
                check_service = (service_bin, local_scope) ->
                    for name, service of service_bin
                        if service instanceof Interface
                            do (_bin = service_bin, _name = name, _service = service, _local_scope = if local_scope? then local_scope.slice(0) else null) ->
                                step (next_service) ->
                                    _bin[_name].bin ?= {__:_bin.__}
                                    if _local_scope? 
                                        scope.global.push item for item in _local_scope
                                        _next_service = next_service
                                        next_service = -> scope.global.pop() for item in _local_scope ; _next_service()
                                        
                                    service_result = _service.review _bin[_name].bin, scope, reaction, next_service
                                    
                                    if service_result is next_service 
                                        was_synchronous = false
                                    else
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
                
                step off, -> next()
                
            return if was_synchronous then null else next
            
        reaction.certified ?= yes

        check.defaults bin, @defaults if @defaults?
        reaction.certified = check.locks bin.__?.session?.keys, @locks if @locks?
        reaction.certified = check.values bin, @values if @values?
        
        review_result = @steps.call {bin, document:@document, 'interface':@, actor:@actor, reaction}, {bin, document:@document, 'interface':@, actor:@actor, reaction, next:check_services} if reaction.certified and @steps?
        
        return switch review_result
            when check_services then next
            when undefined then check_services()
            else null
        
        
    submit: (bin = {}) ->
        publisher = new _.Publisher
        
        reaction = new Interface.Reaction
        
        _.serialize @, (step) ->
            step (next) -> 
                result = @review bin, global:[], local:[], reaction, next ; next() unless result is next
                
            step (next) -> 
                result = @action.call {bin, document:@document, 'interface':@, actor:@actor, reaction}, {bin, document:@document, 'interface':@, actor:@actor, reaction, next} if reaction.certified and @action?
                reaction.bin = result unless reaction.bin? or result is next
                next() unless result is next
                
            step off, -> 
                publisher.notify reaction
        
        publisher
    
    observe: (action) ->
        new _.Observer => 
            @document.signal?.value() ; @submit().subscribe ({bin}) -> action bin.render()

Interface.Reaction = _.prototype
    constructor: (@bin, @certified) ->

Interface.Web = _.prototype inherit:Interface, use: ->
    
    @type = 'App'
    
    @review = (bin, scope, reaction, next) ->
        
        _.serialize @, (step) ->
            step (next) -> result = _.super Interface.Web::review, @, bin, scope, reaction, next; next() unless result is next
            step off, ->
                reaction.bin = ''
                scope.local.length = 0
                check_interfaces = (bin) ->
                    for name, service of bin 
                        if service instanceof Interface.Web
                            kups = reaction.kups ?= {}
                            for step in scope.global then kups = kups[step] ?= {}
                            local_kups = ''
                            if scope.global.length > 0
                                local_kups = ("#{k} = #{scope.global.join('.')}.#{k}" for k of kups).join ', '
                                local_kups = "\nvar #{local_kups};" if local_kups isnt ""

                            kups[name] ?= new Function 'o', """
                                var interface = this.interface, bin = this.bin, actor = this.actor, __hasProp = {}.hasOwnProperty;#{local_kups}
                                this.interface = bin#{if scope.local.length > 0 then '.' + scope.local.join('.') else ''}.#{name};
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
                                
                            check_interfaces bin[name].bin if bin[name]?.bin?
                        else
                            if _.isBasicObject service
                                scope.global.push name
                                scope.local.push name
                                check_interfaces service
                                scope.local.pop()
                                scope.global.pop()

                    return
                        
                check_interfaces bin
                next()
        
        next

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

Interface.Web.Panel = _.prototype inherit:Interface.Web, use: -> @type = 'Panel'

_module = window ? module
if _module.exports? then _module.exports = Interface else window.Locco ?= {} ; window.Locco.Interface = Interface
