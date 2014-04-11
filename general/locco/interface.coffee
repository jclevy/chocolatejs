_ = require '../../general/chocodash'
Chocokup = require '../../general/chocokup'

Interface = _.prototype

    constructor: (service) ->
        service = action:service if typeof service is 'function'
        
        @rules = _.defaults @rules, service.rules if service?.rules?
        @action = service.action if service?.action?
        
        return
    
    review: (bin, reaction, next) ->
        check =
            # `defaults` ensure default values are set on an object
            defaults: (object, defaults) ->
                set = (o, d) ->
                    for own dk,dv of d
                        if _.type(o[dk]) is _.Type.Object and _.type(dv) is _.Type.Object and not dv instanceof Interface then set o[dk], dv
                        else o[dk] = dv if not o[dk]? 
                    o
                   
                set object, defaults
        
            # `locks` ensure keys are provided for every present lock
            locks: (keys, locks) ->
                return yes unless locks?
                
                for lock in locks then return no if lock not in keys
                
                yes
                
            # `values` ensure values at the right scale, in the right range...
            values: (bin, controller) -> controller.call bin

        check_services = ->
            check_services_result = null
            
            _.serialize (defer) ->
                check_service = (service_bin) ->
                    for name, service of service_bin when service instanceof Interface
                        do (_bin = service_bin, _name = name, _service = service) ->
                            defer (next_service) ->
                                _bin[_name].bin ?= {__:_bin.__}
                                service_result = _service.review _bin[_name].bin, reaction, next_service
                                if service_result is next_service then check_services_result = next else next_service()
                                service_result

                        check_service service_bin[name]
                
                check_service bin
                
                defer off, -> next()
                
            check_services_result
            
        reaction.certified ?= yes
        
        if @rules?
            check.defaults bin, @rules.defaults if @rules.defaults?
            reaction.certified = check.locks bin.__?.session?.keys, @rules.locks if @rules.locks?
            reaction.certified = check.values bin, @rules.values if @rules.values?
            
            review_result = @rules.steps.call {bin, reaction}, {bin, reaction, next:check_services} if reaction.certified and @rules?.steps?
            
            return switch review_result
                when check_services then next
                when undefined then check_services()
                else null
        
        return check_services()
        
    submit: (bin) ->
        publisher = new _.Publisher
        
        reaction = new Interface.Reaction
        
        _.serialize @, (step) ->
            step (next) -> 
                result = @review bin, reaction, next ; next() unless result is next
                
            step (next) -> 
                result = @action.call {bin, reaction}, {bin, reaction, next} if reaction.certified and @action?
                reaction.bin = result unless reaction.bin? or result is next
                next() unless result is next
                
            step off, -> 
                publisher.notify reaction
        
        publisher

Interface.Reaction = _.prototype
    constructor: (@bin, @certified) ->

Interface.Web = _.prototype inherit:Interface, use: ->
    
    @type = 'App'

    @review = (bin, reaction, next) ->
        
        _.serialize @, (step) ->
            step (next) -> result = _.super Interface.Web::review, @, bin, reaction, next; next() unless result is next
            step off, ->
                reaction.bin = ''
                for name, service of bin when service instanceof Interface.Web
                    reaction.kups ?= {}
                    reaction.kups[name] ?= service.action?.overriden ? service.action
                next()
        
        next

    @submit = (bin) ->
        unless @action?.overriden
            chocokup_code = @action ? ->
            @action = (params) => 
                {bin, reaction} = params
                
                kups = reaction.kups
                delete reaction.kups
                
                reaction.bin = switch @type
                    when 'Panel'then new Chocokup.Panel {bin, kups}, chocokup_code
                    else new Chocokup[@type] bin?.name ? '', {bin, kups}, chocokup_code
                    
            @action.overriden = chocokup_code
        
        _.super @, bin

Interface.Web.App = Interface.Web

Interface.Web.Document = _.prototype inherit:Interface.Web, use: -> @type = 'Document'

Interface.Web.Panel = _.prototype inherit:Interface.Web, use: -> @type = 'Panel'
    
_module = window ? module
if _module.exports? then _module.exports = Interface else window.Locco?.Interface = Interface
