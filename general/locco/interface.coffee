_ = require '../../general/chocodash'
Chocokup = require '../../general/chocokup'

# Interface
#  defaults: {} or ->
#  locks: [] or ->
#  check: ->
#  steps: ->
#  render : ->
Interface = _.prototype

    constructor: (defaults, service) ->
        if not service? then service = defaults ; defaults = undefined
        service = render:service if typeof service is 'function'
        service.defaults = defaults if service? and defaults?
        
        if service?
            if service.defaults?
                if typeof service.defaults is 'function' then @defaults = service.defaults 
                else @defaults = _.defaults @defaults, service.defaults
            if service.locks?
                if typeof service.locks is 'function' then @locks = service.locks 
                else @locks = (@locks ?= []).concat service.locks 
            @check = service.check if service.check?
            @steps = service.steps if service.steps?
            
            @render = service.action if service.action? # 'action' is synonym to 'render'
            
            @[name] = item for name, item of service when name not in ['defaults', 'locks', 'check', 'steps'] # service, actor, document, update...
            
        return
    
    bind: (actor, document, @name) ->
        unless @actor? and @document?
            @actor = actor
            @document = document
            switch _.type @update
                when _.Type.Function then @observe @update 
                when _.Type.String then @observe (html) => $(@update).html html; return
    
    review: (bin, reaction, end) ->
        self = {bin, props:bin, space:bin?.__?.space, document:@document, 'interface':@, actor:@actor}
        check =
            # `defaults` ensure default values are set on an object
            defaults: (object, defaults) =>
                if typeof defaults is 'function' then defaults = defaults.call self, object
                
                set = (o, d) ->
                    for own dk,dv of d
                        if (_.isBasicObject(o[dk]) or o[dk] instanceof Interface.Web.Global) and (_.isBasicObject(dv) or dv instanceof Interface.Web.Global) then set o[dk], dv
                        else o[dk] = dv if not o[dk]? 
                    o
                   
                set object, defaults
        
            # `locks` ensure keys are provided for every present lock (a lock is a uid or an object id and key fields)
            locks: (keys, locks) =>
                return yes unless locks?
                if typeof locks is 'function' then locks = locks.call self
                
                for lock in locks then return no unless (lock.key ? lock) of keys
                
                yes
                
            # `values` ensure values at the right scale, in the right range...
            values: (bin, controller) => controller.call self, bin
        
        reaction.certified ?= yes

        check.defaults bin, @defaults if @defaults?
        if reaction.certified then reaction.certified = check.locks bin.__?.session?.keys, @locks if @locks?
        if reaction.certified then reaction.certified = check.values bin, @check if @check?
        
        # check_services()
        end()
        
    submit: (bin = {}) ->
        publisher = new _.Publisher
        
        reaction = new Interface.Reaction
        
        _.flow self:@, (run) ->
            getSelf = (end) ->
                respond = (o) -> @reaction.props = @reaction.bin = o ; end()
                respond.later = end.later
                
                transmit = (actor, service) ->
                    actor[service].submit(@bin).subscribe (reaction) => @respond reaction.bin
                    respond.later
                        
                { bin, props:bin, space:bin?.__?.space, document:@document, 'interface':@, actor:@actor, reaction, respond, transmit }
                
            run (end) -> 
                end.with @review bin, reaction, end
            
            run (end) ->
                if reaction.certified and @steps?
                    self = getSelf.call this, end
                    result = @steps.call self, bin
                end.with result

            run (end) ->
                if reaction.certified 
                    if @render?
                        self = getSelf.call this, end
                        result = @render.call self, bin
                        reaction.props = reaction.bin = result unless reaction.bin? or result is end.later
                else
                    if @redirect? 
                        self = getSelf.call this, end
                        reaction.redirect = if typeof @redirect is 'function' then @redirect.call self else @redirect
                        
                end.with result

            run -> 
                publisher.notify reaction
        
        publisher
    
    observe: (render) ->
        new _.Observer => 
            @document.signal?.value() ; @submit().subscribe ({bin}) -> render if typeof bin.render is 'function' then bin.render() else bin

Interface.Reaction = _.prototype
    constructor: (@bin, @certified) -> @props = @bin ; return
        
Interface.Remote = _.prototype inherit:Interface, use: ->
    @submit = (bin = {}) ->
        if '__' of bin then _.super @, bin
        else @actor.submit @name, bin

Interface.Web = _.prototype inherit:Interface, use: ->
    
    get_declare_kups = (kups) ->
        declare_kups = []
        declare_path = {}
        for kup in kups
            path = "this.locals"
            for step in kup.scope
                path += ".#{step}"
                unless declare_path[path]?
                    declare_path[path] = "#{path} = #{path} ? #{path} : {}"
                    declare_kups.push declare_path[path]
            declare_kups.push "this.locals#{if kup.scope.length > 0 then '.' + kup.scope.join('.') else ''}.#{kup.name} = _kup_#{kup.id}"
        declare_kups
    
    @type = 'App'
    
    @review = (bin, reaction, end) ->
        
        _.flow self:@, (run) ->
            run (end) -> 
                end.with _.super Interface.Web::review, @, bin, reaction, end

            run ->
                if reaction.certified
                    reaction.props = reaction.bin = ''
                    return end() if reaction.kups is false
                    
                    scope = []
                    checked = []
                    
                    check_interfaces = (bin) ->
                        local_kups = []
                        for name, service of bin
                            if service instanceof Interface.Web
                                unless not service?.defaults? or service in checked
                                    checked.push service
                                    defaults = service.defaults
                                    if typeof defaults is 'function' then defaults = defaults()
                                    scope_ = scope
                                    scope = []
                                    kups = check_interfaces defaults
                                    scope = scope_
                                else 
                                    kups = []
    
                                declare_kups = get_declare_kups kups
    
                                service_id = _.Uuid().replace /\-/g, '_'
                                service_kup = new Function 'args', """
                                    var interface = this.interface, bin = this.bin, props = this.props, keys = this.keys, actor = this.actor, __hasProp = {}.hasOwnProperty, Interface = this.params.Interface;
                                    try {this.interface = bin#{if scope.length > 0 then '.' + scope.join('.') else ''}.#{name};} 
                                    catch (error) { try {this.interface = bin.#{name};} catch (error) {}; };
                                    this.actor = this.interface != null ? (this.interface.actor != null ? this.interface.actor : actor) : actor;
                                    this.keys = [];
                                    this.props = this.bin = {__:bin.__};
                                    this.space = this.bin != null && this.bin.__ != null ? this.bin.__.space : {};
                                    bin_cp = function(b_, _b) {
                                      var done = false, k, v;
                                      for (k in _b) {
                                        if (!hasProp.call(_b, k) || (k === '__')) continue; 
                                        if (((v = _b[k]) != null ? v.constructor : void 0) === {}.constructor) { b_[k] = {}; if (!(done = bin_cp(b_[k], v))) { delete b_[k]; } } 
                                        else if ((v instanceof Interface.Web) || (v instanceof Interface.Web.Global)) { b_[k] = v; done = true; }
                                      }
                                      return done;
                                    };
                                    bin_cp(this.bin, bin);
                                    if (args != null) {for (k in args) {if (__hasProp.call(args, k)) { this.bin[k] = args[k]; this.keys.push(k); }}}
                                    reaction = {kups:false};
                                    if (this.interface != null)
                                        this.interface.review(this.bin, reaction, function(){});
                                    if (reaction.certified) {
                                        #{declare_kups.join ';\n'};
                                        with (this.locals) {(#{(service.render?.overriden ? service.render).toString()}).call(this, this.bin);}
                                    }
                                    this.bin = bin; this.props = props; this.keys = keys; this.interface = interface, this.actor = actor;
                                    """
    
                                reaction.kups ?= {}
                                reaction.kups["_kup_#{service_id}"] ?= service_kup
                                    
                                local_kups.push {name, scope:[].concat(scope), id:service_id}
                            else
                                if name isnt '__' and (_.isBasicObject(service) or service instanceof Interface.Web.Global)
                                    scope.push name
                                    checked.push service
                                    local_kups = local_kups.concat check_interfaces service
                                    scope.pop()
    
                        return local_kups
     
                    checked.push bin
                    reaction.local_kups = check_interfaces bin
                end()
        
        end

    @submit = (bin) ->
        unless @render?.overriden
            render_code = @render ? ->
            chocokup_code = null
            @render = (bin) ->
                bin ?= {}

                kups = @reaction.kups
                delete @reaction.kups

                local_kups = @reaction.local_kups
                delete @reaction.local_kups
                
                declare_kups = get_declare_kups local_kups

                chocokup_code = if declare_kups.length > 0 then new Function 'args', """
                        this.keys = [];
                        if (args != null) {for (k in args) {if ({}.hasOwnProperty.call(args, k)) { this.bin[k] = args[k]; this.keys.push(k); }}}
                        #{declare_kups.join ';\n'};
                        with (this.locals) {return (#{render_code.toString()}).apply(this, arguments);}
                    """
                else render_code
                
                options = {bin, props:bin, space:bin?.__?.space, document:@document, Interface, 'interface':@, actor:@actor, kups}
                options.theme = bin.theme if bin.theme?
                options.with_coffee = bin.with_coffee if bin.with_coffee?
                options.manifest = bin.manifest if bin.manifest?
                
                @reaction.props = @reaction.bin = switch @interface.type
                    when 'Panel'then new Chocokup.Panel options, chocokup_code
                    else new Chocokup[@interface.type] bin?.name ? '', options, chocokup_code
                    
            @render.overriden = chocokup_code ? render_code
        
        if typeof bin is 'function' then callback = bin ; bin = {}
            
        result = _.super @, bin

        if callback? then result.subscribe (reaction) -> callback reaction.bin.render()
        
        result

Interface.Web.Global = _.prototype
    constructor: (o) -> @[k] = v for own k,v of o

Interface.Web.App = Interface.Web

Interface.Web.Document = _.prototype inherit:Interface.Web, use: -> @type = 'Document'

Interface.Web.Panel = Interface.Web.Html = _.prototype inherit:Interface.Web, use: -> @type = 'Panel'

_module = window ? module
if _module.exports? then _module.exports = Interface else window.Locco ?= {} ; window.Locco.Interface = Interface
