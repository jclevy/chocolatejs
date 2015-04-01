_module = window ? module

_module[if _module.exports? then "exports" else "Chocodash"] = _ = {}

# `_.type` returns the type of an object
#
#     _type({}) === '[object Object]'
_.type = (o) -> Object.prototype.toString.apply o

# `_.Type` provides a Type enumeration
#
#     _type({}) === _.Type.Object
_.Type = 
    Object: '[object Object]'
    Array: '[object Array]'
    Boolean: '[object Boolean]'
    Number: '[object Number]'
    Date: '[object Date]'
    Function: '[object Function]'
    Math: '[object Math]'
    String: '[object String]'
    Undefined: '[object Undefined]'
    Null: '[object Null]'

# `_.isObject` returns true if value is not a primitive
_.isObject = (o) ->
    return no unless o?
    
    switch typeof o
        when 'object', 'function' then yes
        else no

# `_.isBasicObject` returns true if value is a basic object
_.isBasicObject = (o) ->
    return no unless o?
    
    return o.constructor is {}.constructor

# `_.prototype` makes it easy to create a Javascript prototype
#
# following the classical class way:
#
#     Service = _.prototype 
#         add: (a,b) -> a+b
#         sub: (a,b) -> a-b
#
# or the mixin way:
#
#     Service = _.prototype()
#     Service.use ->
#         @add = (a,b) -> a+b
#         @sub = (a,b) -> a-b
#
# Then use your prototype to create javascript objects:
#
#     sevr = new Service
#     expect(serv instanceof Service).toBe true
#     expect(serv.add 1,1).toBe 2
#
# You can define a prototype initializer by using the `constructor` keyword:
#
#     Service = _.prototype 
#         constructor: (@name) ->
#
#     serv = new Service "MyDoc"
#     expect(serv.name).toBe "MyDoc"
#
# You can also create a prototype by adopting/copying  
# another prototype's beahaviour and adding new functions:
#
#     MoreMath = ->
#         @multiply = (a,b) -> a * b
#         @divide = (a,b) -> a / b
#            
#     CopiedService = _.prototype adopt:Service, use:MoreMath
#     cop = new CopiedService
#        
#     expect(cop.add 2,2).toBe 4
#     expect(cop.multiply 3,3).toBe 9
#
# You can finally create a prototype by inheriting
# another prototype's beahaviour and adding new functions 
# that can access parent's overriden function:
#
#     InheritedService = _.prototype 
#         inherit:Service
#         use: -> @sub = (a,b) -> 
#             a + ' - ' + b + ' = ' + _.super @, a,b
#
#     inh = new InheritedService
#     expect(inh.add 2,2).toBe 4
#     expect(inh.sub 2,2).toBe "2 - 2 = 0"
#
_.prototype = (options, more) ->
    if more?
        if options? then for k,v of more then options[k] = v 
        else options = more
        more = null

    prototype = do ->
        flatten = -> 
            args = []
            if arguments[0]? then Array::push.apply args, arguments
            args
        
        use: ->
            for o in flatten arguments... then o.call @::
            @

        adopt: -> 
            for o in flatten arguments...
                @[k] = v for own k,v of o 
                @::[k] = v for own k,v of o::
            @
            
        inherit: (parent) ->
            child = @
            if parent?
                child[k] = v for own k,v of parent
                ctor = -> @constructor = child; return
                ctor:: = parent::
                child:: = new ctor()
                child.__super__ = parent::
            @

    constructor = if options?.hasOwnProperty 'constructor' then options.constructor else null
    
    ctor = if constructor? then -> constructor.apply @, arguments; return 
    else if options?.inherit? then -> Array.prototype.unshift.call(arguments, @); _.super.apply _, arguments; return else ->

    if options?
        for name, value of options
            if name in ['adopt', 'inherit', 'use']
                prototype[name].call ctor, value
            else ctor::[name] = value unless name is 'constructor'
        
    ctor[name] = fn for own name,fn of prototype when not ctor[name]?
    
    ctor

# `_.super` calls the parent's function in an overriden function
_.super = () ->
    super_func = null
    [func, self] = arguments
    
    if typeof func isnt 'function' then self = func; func = null
    
    _func = if func? then func else arguments.callee.caller
    
    _name = null
    constructor = self.constructor
    while constructor and not super_func?
    
        for own k, v of constructor.prototype
            if _func is v then _name = k; break
    
        super_func = constructor.__super__[_name] if _name?
    
        unless super_func?
            constructor = if constructor.__super__? then constructor.__super__.constructor else null 
    
    if super_func
        return super_func.apply self, Array.prototype.slice.call arguments, if func? then 2 else 1 

# `_.stringify` transforms a javascript object in a string that can be parsed back as an object
#
# You can stringify every property of an object, even a function or a Date:
#
# options: 
#    prettify : multiline indented json presentation
#    own : stringify only own object properties not inherited ones
#    filter : do not stringify user defined types ojects unless type is present in filter list
#
#     o = {
#         u: void 0,
#         n: null,
#         i: 1,
#         f: 1.11,
#         s: '2',
#         b: true,
#         add: function(a, b) {
#           return a + b;
#         },
#         d: new Date("Sat Jan 01 2011 00:00:00 GMT+0100")
#     };
#
#     s = _.stringify o
#     expect(s).toBe "{u:void 0,n:null,i:1,f:1.11,s:'2',b:true,add:function (a, b) {\n          return a + b;\n        },d:new Date(1293836400000)}"
_.stringify = ->
    return undefined if arguments.length is 0
    
    object = arguments[0]
    options = arguments[1] ? {}
    
    if options.prettify is yes
        tab = '    '
        newline = '\n'
    else
        tab = newline = ''
    
    doit = (o, level, p) ->
        result = []
        level ?= 0
        indent = (tab for [0...level]).join ''
        ni = newline + indent
        nit = ni + tab
        type = Object.prototype.toString.apply o
        # if  v isnt p.constructor.prototype[k]
        result.push switch type
            when '[object Object]' then "{#{nit}#{(k + ':' + doit(v, level+1) for k,v of o when (not options.filter? or (v.constructor in options.filter)) and (options.own isnt true or {}.hasOwnProperty.call(o, k))).join(',' + nit)}#{ni}}"
            when '[object Array]' then "function () {#{nit}var a = []; var o = {#{nit}#{(k + ':' + doit(v, level+1) for own k,v of o).join(',' + nit)}};#{nit}for (var k in o) {a[k] = o[k];} return a; }()" # necessary to serialize both indexes and properties
            when '[object Boolean]' then o
            when '[object Number]' then o
            when '[object Date]' then "new Date(#{o.valueOf()})"
            when '[object Function]' then o.toString()
            when '[object Math]' then 'Math'
            when '[object String]' then "'#{o.replace /\'/g, '\\\''}'"
            when '[object Undefined]' then 'void 0'
            when '[object Null]' then 'null'
            when '[object Buffer]', '[object SlowBuffer]'
                if o.length is 16 then _.Uuid.unparse o else o.toString()
            
        result
    
    doit(object).join(', ')
        
# `_.parse` transforms a stringified javascript object back to a javascript object
#
#     a = _.parse "{u:void 0,n:null,i:1,f:1.11,s:'2',b:true,add:function (a, b) {\n          return a + b;\n        },d:new Date(1293836400000)}"
#
#     expect(a.u).toBe undefined
#     expect(a.n).toBe null
#     expect(a.i).toBe 1
#     expect(a.f).toBe 1.11
#     expect(a.s).toBe '2'
#     expect(a.b).toBe yes
#     expect(a.add(1,1)).toBe 2
#     expect(a.d.valueOf()).toBe new Date("Sat Jan 01 2011 00:00:00 GMT+0100").valueOf()
_.parse = (str) ->
    (new Function "return " + str)()

#
# `_.param` transforms a javascript value to an url query parameter
#
#     a = _.param {u:1, v:2}
#     expect(a).toBe 'u=1&v=2'
#
_.param = (parameters) ->
    return encodeURIComponent parameters if _.type(parameters) is _.Type.String
    
    serialize = []
    for own parameter of parameters
        serialize.push "#{encodeURIComponent parameter}=#{encodeURIComponent parameters[parameter]}"
    serialize.join '&'
        
# `_.serialize` helps manage asynchronous calls serialization.  
    #
    # - use **self** to pass an object to which **this** will be binded when deferred functions will be called
    # - use **local** to share variables between the deferred functions
    # - **fn** is a function in which you declare the asynchronous functions you want to defer and serialize
    #
    # >     _.serialize (defer) ->
    # >         defer (next) ->
    # >             my_first_async_func ->
    # >                 # ...
    # >                 next()
    # >         defer (next) ->
    # >             my_second_async_func ->
    # >                 # ...
    # >                 next()
_.serialize = (self, local, fn) ->
    if typeof local is 'function' then fn = local; local = {}
    if typeof self is 'function' then fn = self; self = fn; local = {}
    
    deferred = []
    async = off
    defer = (has_more, fn) -> 
        unless fn then fn = has_more; has_more = yes
        if has_more
            deferred.push fn
        else 
            deferred.push -> if async is off then setTimeout fn, 0 else fn()

    fn.call self, defer, local
    deferred.shift().call self, next = -> 
        if deferred.length
            result = deferred.shift().call self, next
            async = on if result is next

_.parallelize = (self, fn) ->
    if typeof self is 'function' then fn = self; self = fn
    pushed = []
    on_join = null ; join = (fn) -> on_join = fn
    
    count = 0 ; end = -> count += -1 ;  if count is 0 then on_join?.call self
    push = (fn) -> pushed.push -> setTimeout (-> fn.call(self) ; end()), 0
    
    fn.call self, push, join
    
    count = pushed.length ; for dfn in pushed then dfn.call self

# `_.extend` copies values from an object to another object
#
# Copy values unless `overwrite` is false:
#
#     o = _.extend {first:1}, {second:2}
#          expect(o.first).toBe(1)
#          expect(o.second).toBe(2)
#
# Copy values on sub-object and overwrite values if overwrite is not false:
#
#     o = _.extend {second:{sub1:'sub1'}}, {first:2, second:sub1:'sub2'}
#          expect(o.first).toBe(2)
#          expect(o.second.sub1).toBe('sub2')
#
# Copy values on sub-object if not set and preserve other values if overwrite is false:
#
#     o = _.extend {second:{sub1:'sub1'}}, {first:2, second:sub1:'sub2'}, false
#          expect(o.first).toBe(2)
#          expect(o.second.sub1).toBe('sub1')
_.extend = (object, values, overwrite) ->
    set = (o, val) ->
        for own k,v of val
            o ?= {}
            if _.type(o[k]) is _.Type.Object and _.type(v) is _.Type.Object then set o[k], v
            else o[k] = v unless overwrite is false and o[k]?
        o
       
    set object, values

# `_.defaults` ensure default values are set on an object
#
# Set default values if not set:
#
#     o = _.defaults {first:1}, {second:2}
#          expect(o.first).toBe(1)
#          expect(o.second).toBe(2)
#
# Set default values on sub-object if not set and preserve other values:
#
#     o = _.defaults {second:{sub1:'sub1'}}, {first:2, second:sub2:'sub2'}
#          expect(o.first).toBe(2)
#          expect(o.second.sub1).toBe('sub1')
#          expect(o.second.sub2).toBe('sub2')
_.defaults = (object, defaults) ->
    _.extend object, defaults, false

# Signals and Observers
# Adapted from Reactor written by fynyky (https://github.com/fynyky/reactor.js) 

# Signals represent values which can be observed
# A signal's value can depend on one or more other signals

# Observers represent reactions to changes in signals
# An observer can be observing one or more signals

# Together, signals and observers form a directed acyclic graph
# Signals form the root and intermediate nodes of the graph
# Observers form the leaf nodes in the graph
# When a signal is updated, it propagates its changes through the graph
# Observers are updated last after all affected signals have been updated
# From the perspective of observers, all signals are updated atomically and instantly 

# Observer and signal dependencies are set automatically and dynamically
# It detects when a signal is being used at run time, and automatically establishes the link
# This means there is no need to explicitly declare dependencies
# And dependencies can be changed across the execution of the program

# TODOs
# remove redundant triggering when same value is made
# add in ability to get old values
# recompile with latest coffeescript compiler
# events
# multi commit batching
# avoid removing array and setter methods if user overrides them


# Signals are objects representing observed values
# They are read by executing the `value()` function with no arguments
# They are set by executing the `value()` function with a signal definition as the only argument
# If the definition is itself a function - it is executed to retrive the signal value
# Otherwise, the definition is read as the value directly
# If a signal definition reads other signals, it automatically gets set as a dependent
# If any signal dependencies get updated, the dependent signal is automatically updated as well
# Note that a signal's definition should NOT have any external effects
# It should only read other values and return its own value
# For external effects, use observers instead
# To "destroy" a signal, just set its definition to null

# -----------------------------------------------------------------------------
# Signals themselves have 3 main components 
#     A value - the cached value returned when the signal is read
#     An evaluate function - the "guts" which sets the value and handles propagation
#     The signal function - a wrapper providing the interface to read and write to the signal

_.Signal = Signal = _.prototype

    adopt:
        # Constants
        type: "SIGNAL"
        arrayMethods: ["pop", "push", "reverse", "shift", "sort", "splice", "unshift"]
        
        ### Events on evalutate
            value   REPLACE - ALL
            set     REPLACE - ONE - at KEY
            delete  REMOVE - ONE - at KEY
            pop     REMOVE - ONE - at LAST
            push    INSERT - ONE or MANY - at END 
            reverse SORT - ALL
            shift   REMOVE - ONE - at FIRST
            sort    SORT - ALL
            splice  REMOVE - ONE or MANY - at INDEX and INSERT - ONE or MANY - at INDEX
            unshift INSERT - ONE or MANY - at FIRST
        ###        
        Event: 
            Type: Insert:0, Replace:1, Remove:2, Sort:3
            What: All:0, One:1, Many:2
            Where: First:0, Last:1, End:2, Index:3
        
        EventDef:
            value: type:'Replace', what: 'All'
            set: type:'Replace', what:'One', where:'Index'
            delete: type:'Remove', what:'One', where:'Index'
            pop: type:'Remove', what:'One', where:'Last'
            push: type:'Insert', what:'One', where:'End'
            reverse: type:'Sort', what:'all'
            shift: type:'Remove', what:'One', where:'First'
            sort: type:'Sort', what:'all'
            splice: type:'Remove', what:'One', where:'Index'
            unshift: type:'Insert', what:'One', where:'First'

        # Global stack to automatically track signal dependencies
        # Whenever a signal or observer is evaluated - it puts itself on the dependency stack
        # When another signals is read - the dependency stack is checked to see who is asking
        # The reader gets added as a dependent to the signal being read
        # wWen a signal or observer's evaluation is done - it pops itself off the stack
        dependencyStack: []
        
        # Global dictionnary to trac active transactions
        transactions: {}
        
        # Defered signal management
        Defer: _.prototype
            constructor: (@signal, @observerList) -> @count = 0
            
            value: (fn) ->
                stack = Signal.dependencyStack
                Signal.dependencyStack = [@signal]
                @signal._value = fn()
                @signal._initialized = true
                @signal._idle = true
                Signal.dependencyStack = stack
                
                @count += -1
                
                # Now ask dependant signals to evaluate themselves
                @signal.propagate @, @observerList

                observer.notify on for observer in @signal.observers
                    
            one: -> @count += 1
            idle: -> @count is 0
                
    constructor: (@definition, @helpers) ->
        
        # @helpers can contain  'set' and array functions helpers to be called in place of our version
        for name, helper of @helpers then do (helper, name, self=@) ->  self.helpers[name] = -> helper.apply self, arguments
        
        # Cached value of this signal calculated by the evaluate function
        # Recalculated when a definition has changed or when notified by a dependency
        @_value = null
        
        # Initialized will be true after first evaluation
        @_initialized = false
        
        # Idle is false when Signal is calculating its value
        @_idle = true
    
        # List of signals that this depends on
        # Used to remove self from their dependents list when necessary
        # Note that while the dependents is a list of evaluate objects
        # dependencies is a list of the signals themselves
        @dependencies = []
        @dependencyType = Signal.type
    
        # Symmetrically - the list of other signals and observers that depend on this signal
        # Used to know who to notify when this signal has been updatedls
        @dependents = []
        @observers = []
        @dependentTargets = []
    
        # run an initial evaluation on creation
        # no need to notify observers/dependents because it shouldnt have any yet
        @evaluate new Signal.Defer @

    # evaluate is a function to calculates the signal value given the definition
    # it recursively revaluates any signals that depend on it as well
    # Simultaneously, in order to know what observers to notify later
    # it recursively passes through a list to collect all the observers of the updated signals
    # After the signal cascade has completed, the observers on the list are notified
    
    evaluate: (defer, observerList) ->
        
        # by default the value is the definition
        @_value = @definition
        @_idle = true
        @_error = null

        # clear old dependencies both forward and back pointers
        for dependency in @dependencies
            dependentIndex = dependency.dependents.indexOf @
            dependency.dependents.splice dependentIndex, 1
        @dependencies = []

        switch type = _.type @definition
        
            # if definition is a function then we need to evaluate it
            # and set it up to be notified when its dependencies change
            when _.Type.Function

                # evaluate the definition and set new dependencies
                Signal.dependencyStack.push @
                
                try
                    deferred = do (signal=@) ->
                        (fn) ->
                            prev = defer.signal
                            defer.signal = signal
                            defer.value.call defer, fn
                            defer.signal = prev
                            
                    try
                        result = @definition deferred
                    catch e
                        result = undefined
                        @_error = e
                        if @_catch?
                            @_catch e
                            @_error = null
                    
                    if result is deferred
                        @_idle = false
                        defer.one()
                        observer.notify(off) for observer in @observers
                    else
                        @_value = result
                        @_initialized = true
                        @_idle = true
                
                finally 
                    Signal.dependencyStack.pop()
            
            when _.Type.Object, _.Type.Array
                
                # convenience method for setting or deleting properties
                unless @set?
                    @set = @helpers?.set ? (key, value) =>
                        if arguments.length is 1 
                            @definition = key
                        else 
                            @definition[key] = value
                            
                        @value(@definition) # Manually trigger the refresh
                
                    @delete = @helpers?.delete ? (key) =>
                        delete @definition[key]
                            
                        @value(@definition) # Manually trigger the refresh
                        
                    if type is _.Type.Array
                        # Set the special array methods if the definition is an array
                        # Essentially providing convenience mutator methods which automatically trigger revaluation
                        for methodName in Signal.arrayMethods then do (methodName) =>
                            @[methodName] = @helpers?[methodName] ?  =>
                                output = @definition[methodName].apply @definition, arguments
                                @value(@definition) # Manually trigger the refresh
                                return output
                
            else 
                if @set?
                    delete @set
                    delete @delete
                    delete @[methodName] for methodName in Signal.arrayMethods

        # Add this signals own observers to the observer list
        if observerList? then for observer in @observers
            observerList.push observer if observer? and (observerList.indexOf observer) < 0

        # Now propagate the evaluation to the dependant signals
        @propagate defer, observerList unless deferred? and result is deferred

    # catch register a function to call when an error occurs
    
    catch: (report) ->
        @_catch = report
        if @_error?
            @_catch @_error
            @_error = null
        
    # Tells whether this Signal is currently calculating its value
    idle: -> @_idle
    
    # propagate the evaluation to the dependant signals
    propagate: (defer, observerList) ->
        # A copy of the dependents to be evaluated
        # This is used to avoid redundant evaluation where a descendent has
        # already read from this value
        # Check to see if a dependent is still on this list before evaluating it
        # If a descendent reads from this signal at some point
        # it will remove itself from this list
        @dependentTargets = @dependents[...]

        # Recursively evaluate any dependents
        # Note that the dependents is a list of the dependents signals
        # and give them the observer list to add to as well
        # need to duplicate list since it will be modified by child evaluations
        for dependent in @dependents[...]
            if dependent? and @dependentTargets.indexOf(dependent) >= 0
                dependent.evaluate defer, observerList
                
    # The actual signal function that is returned to the caller
    # Read by calling with no arguments
    # Write by calling with a new argument
    # Array methods if previously given an array as a definition
    # "set" convenience method if given an object/array as a definition
    value: (newDefinition)->

        # Write path
        # If a new definition is given, update the signal
        # recursively update any dependent signals
        # then finally trigger affected observers
        
        # -------------------------------------------------------------------------
        # Life of a write
        #     new definition is set
        #     delete/configure convenience methods
        #     execute new definition if necessary
        #     add observers to notify later
        #     make list of target dependents to be notified
        #     recursively evaluate dependents
        #         delete/configure convenience methods
        #         execute new definition
        #         get removed from target dependents list
        #         add observers to notify later
        #     notify observers
        if newDefinition isnt undefined
            @definition = newDefinition
            observerList = []
            
            defer = new Signal.Defer @, observerList
            
            @evaluate defer, observerList
            
            if defer.idle()
                observer.trigger() for observer in observerList[...] # Copy the list since the trigger might modify it
            
            return @_value

        # Read path
        # If no definition is given, we treat it as a read call and return the cached value
        # Simultaneously, check for calling signals/observers and register dependenceis accordingly
        
        # -------------------------------------------------------------------------
        # Life of a read
        #     check to see who is asking
        #     remove them from the list of targets to be notified
        #     register them as a dependent
        #     register self and their dependency
        #     return value
        else
            # check the global stack for the most recent dependent being evaluated
            # assume this is the caller and set it as a dependent
            dependent = Signal.dependencyStack[Signal.dependencyStack.length - 1]

            # If its a signal dependency - register it as such
            # symmetrically register self as a dependency for cleaning dependencies later
            if dependent? and dependent.dependencyType is Signal.type
            
                @dependents.push dependent if @dependents.indexOf(dependent) < 0
                dependent.dependencies.push @ if dependent.dependencies.indexOf(@) < 0

                # remove the dependent from the targets list if necessary
                # this is used to avoid duplicate redundant evaluation
                targetDependentIndex = @dependentTargets.indexOf dependent
                @dependentTargets[targetDependentIndex] = null if targetDependentIndex >= 0

            # If it is a observer dependency - similarly register it as a observer
            # symmetrically register self as a observee for cleaning dependencies later
            else if dependent? and dependent.dependencyType is Observer.type
                
                @observers.push dependent if @observers.indexOf(dependent) < 0
                dependent.observees.push @ if dependent.observees.indexOf(@) < 0

            return @_value
                
# Observers report signal changes
# They are defined in a manner similar to Signals
# The primary differences of observers are
# - they have no value to read
# - they cannot be observed themselves
# - they are notified only after signals have all been updated
# to remove an observer - just set its value to null

_.Observer = Observer = _.prototype

    adopt:
        # Constants
        type: "OBSERVER"

    constructor: (report) ->
        @observees = []
        @dependencyType = Observer.type

        @observe report

    # returned in the form of a function
    # as with signals - can be provided with a new definition
    observe: (report)->
        @report = report

        @_ready = true
        
        # clear old observees
        for observee in @observees
            observerIndex = observee.observers.indexOf @
            observee.observers.splice(dependentIndex, 1)
        @observees = []
        
        # do initial trigger and set up to listen for future updates
        Signal.dependencyStack.push @
        try @report() if @report?
        finally Signal.dependencyStack.pop()
        
        @_ready = true
        for observee in @observees
            unless observee.idle() then @_ready = false ; break
            
        return null

    # receive a report from a deferred signal and trigger when ready
    notify: (status) ->
        if status is on 
            @_ready = true
            for observee in @observees
                unless observee.idle() then @_ready = false ; break
            if @_ready then @trigger()
        
        else @_ready = false
            
    # Activate the observer as well as reconfigure dependencies
    trigger: ->

        # do trigger and set up to listen for future updates
        Signal.dependencyStack.push @
        try @report() if @report?
        finally Signal.dependencyStack.pop()


    # Tells whether this Observer is currently calculating its value
    ready: -> @_ready

# Publishers report basic signal changes to one-to-many reporters
_.Publisher = Publisher = _.prototype
    constructor:  ->
        @subscribers = []

    notify: (value) -> for report in @subscribers then report value
    
    subscribe: (reporter) -> @subscribers.push reporter
    
# uuid.js
# Generate RFC4122(v4) UUIDs, and also non-RFC compact ids
#
#     uuid = Uuid() // produces a string like "88a8814c-fd78-44cc-b4c1-dbff3cc63abd"
#
#     expect(Uuid.parse("49A15746135C4DEDAB55B2C5F74BD5BB").toString()).toBe([73, 161, 87, 70, 19, 92, 77, 237, 171, 85, 178, 197, 247, 75, 213, 187].toString());
#
# Copyright (c) 2010-2012 Robert Kieffer
# MIT License - http://opensource.org/licenses/mit-license.php
_.Uuid = do (_module) ->

    {require, crypto, define, module} = _module
    
    # Unique ID creation requires a high quality random # generator.  We feature
    # detect to determine the best RNG source, normalizing to a function that
    # returns 128-bits of randomness, since that's what's usually required
    _rng = undefined
    
    # Node.js crypto-based RNG - http://nodejs.org/docs/v0.6.2/api/crypto.html
    #
    # Moderately fast, high quality
    if typeof (require) is "function"
        try
            _rb = require("crypto").randomBytes
            _rng = _rb and ->
                _rb 16
            
    if not _rng and crypto and crypto.getRandomValues
    # WHATWG crypto-based RNG - http://wiki.whatwg.org/wiki/Crypto
    #
    # Moderately fast, high quality
        _rnds8 = new Uint8Array(16)
        _rng = whatwgRNG = ->
            crypto.getRandomValues _rnds8
            _rnds8
          
    unless _rng
    # Math.random()-based (RNG)
    #
    # If all else fails, use Math.random().  It's fast, but is of unspecified
    # quality.
        _rnds = new Array(16)
        _rng = ->
            i = 0
            r = undefined
    
            while i < 16
                r = Math.random() * 0x100000000  if (i & 0x03) is 0
                _rnds[i] = r >>> ((i & 0x03) << 3) & 0xff
                i++
            _rnds
    
    # Buffer class to use
    BufferClass = (if typeof (Buffer) is "function" then Buffer else Array)
    
    # Maps for number <-> hex string conversion
    _byteToHex = []
    _hexToByte = {}
    i = 0
    
    while i < 256
        _byteToHex[i] = (i + 0x100).toString(16).substr(1)
        _hexToByte[_byteToHex[i]] = i
        i++
        
        
    # **`parse()` - Parse a UUID into it's component bytes**
    parse = (s, buf, offset) ->
        i = (buf and offset) or 0
        ii = 0
        buf = buf or []
        s.toLowerCase().replace /[0-9a-f]{2}/g, (oct) ->
          buf[i + ii++] = _hexToByte[oct]  if ii < 16 # Don't overflow!
    
        # Zero out remaining bytes if string was short
        buf[i + ii++] = 0  while ii < 16
        buf
    
    # **`unparse()` - Convert UUID byte array (ala parse()) into a string**
    unparse = (buf, offset) ->
        i = offset or 0
        bth = _byteToHex
        bth[buf[i++]] + bth[buf[i++]] + bth[buf[i++]] + bth[buf[i++]] + "-" + bth[buf[i++]] + bth[buf[i++]] + "-" + bth[buf[i++]] + bth[buf[i++]] + "-" + bth[buf[i++]] + bth[buf[i++]] + "-" + bth[buf[i++]] + bth[buf[i++]] + bth[buf[i++]] + bth[buf[i++]] + bth[buf[i++]] + bth[buf[i++]]
    
    
    # **`v1()` - Generate time-based UUID**
    #
    # Inspired by https://github.com/LiosK/UUID.js
    # and http://docs.python.org/library/uuid.html
    
    # random #'s we need to init node and clockseq
    _seedBytes = _rng()
    
    # Per 4.5, create and 48-bit node id, (47 random bits + multicast bit = 1)
    _nodeId = [_seedBytes[0] | 0x01, _seedBytes[1], _seedBytes[2], _seedBytes[3], _seedBytes[4], _seedBytes[5]]
    
    # Per 4.2.2, randomize (14 bit) clockseq
    _clockseq = (_seedBytes[6] << 8 | _seedBytes[7]) & 0x3fff
    
    # Previous uuid creation time
    _lastMSecs = 0
    _lastNSecs = 0
    
    # See https://github.com/broofa/node-uuid for API details
    v1 = (options, buf, offset) ->
        i = buf and offset or 0
        b = buf or []
        
        options = options or {}
        
        clockseq = (if options.clockseq? then options.clockseq else _clockseq)
        
        # UUID timestamps are 100 nano-second units since the Gregorian epoch,
        # (1582-10-15 00:00).  JSNumbers aren't precise enough for this, so
        # time is handled internally as 'msecs' (integer milliseconds) and 'nsecs'
        # (100-nanoseconds offset from msecs) since unix epoch, 1970-01-01 00:00.
        msecs = (if options.msecs? then options.msecs else new Date().getTime())
        
        # Per 4.2.1.2, use count of uuid's generated during the current clock
        # cycle to simulate higher resolution clock
        nsecs = (if options.nsecs? then options.nsecs else _lastNSecs + 1)
        
        # Time since last uuid creation (in msecs)
        dt = (msecs - _lastMSecs) + (nsecs - _lastNSecs) / 10000
        
        # Per 4.2.1.2, Bump clockseq on clock regression
        clockseq = clockseq + 1 & 0x3fff  if dt < 0 and not options.clockseq?
        
        # Reset nsecs if clock regresses (new clockseq) or we've moved onto a new
        # time interval
        nsecs = 0  if (dt < 0 or msecs > _lastMSecs) and not options.nsecs?
        
        # Per 4.2.1.2 Throw error if too many uuids are requested
        throw new Error("uuid.v1(): Can't create more than 10M uuids/sec")  if nsecs >= 10000
        
        _lastMSecs = msecs
        _lastNSecs = nsecs
        _clockseq = clockseq
        
        # Per 4.1.4 - Convert from unix epoch to Gregorian epoch
        msecs += 12219292800000
        
        # `time_low`
        tl = ((msecs & 0xfffffff) * 10000 + nsecs) % 0x100000000
        b[i++] = tl >>> 24 & 0xff
        b[i++] = tl >>> 16 & 0xff
        b[i++] = tl >>> 8 & 0xff
        b[i++] = tl & 0xff
        
        # `time_mid`
        tmh = (msecs / 0x100000000 * 10000) & 0xfffffff
        b[i++] = tmh >>> 8 & 0xff
        b[i++] = tmh & 0xff
        
        # `time_high_and_version`
        b[i++] = tmh >>> 24 & 0xf | 0x10 # include version
        b[i++] = tmh >>> 16 & 0xff
        
        # `clock_seq_hi_and_reserved` (Per 4.2.2 - include variant)
        b[i++] = clockseq >>> 8 | 0x80
        
        # `clock_seq_low`
        b[i++] = clockseq & 0xff
        
        # `node`
        node = options.node or _nodeId
        n = 0
    
        while n < 6
            b[i + n] = node[n]
            n++
            
        (if buf then buf else unparse(b))
    
    
    
    # **`v4()` - Generate random UUID**
    
    # See https://github.com/broofa/node-uuid for API details
    v4 = (options, buf, offset) ->
        # Deprecated - 'format' argument, as supported in v1.2
        i = buf and offset or 0
        
        if typeof (options) is "string"
          buf = (if options is "binary" then new BufferClass(16) else null)
          options = null
        options = options or {}
        
        rnds = options.random or (options.rng or _rng)()
        
        # Per 4.4, set bits for version and `clock_seq_hi_and_reserved`
        rnds[6] = (rnds[6] & 0x0f) | 0x40
        rnds[8] = (rnds[8] & 0x3f) | 0x80
        
        # Copy bytes to buffer, if provided
        if buf
            ii = 0
    
            while ii < 16
                buf[i + ii] = rnds[ii]
                ii++
    
        buf or unparse(rnds)
        
    
    # Export public API
    uuid = v4
    uuid.v1 = v1
    uuid.v4 = v4
    uuid.parse = parse
    uuid.unparse = unparse
    uuid.BufferClass = BufferClass
    
    if typeof define is "function" and define.amd
        # Publish as AMD module
        define ->
            uuid
    else if typeof module isnt "undefined" and module.exports
        # Publish as node.js module
        module.exports = uuid
    else
        # Publish as global (in browsers)
        _previousRoot = _module.Uuid
        
        # **`noConflict()` - (browser only) to reset global 'uuid' var**
        uuid.noConflict = ->
            _module.Uuid = _previousRoot
            uuid
    
        _module.Uuid = uuid
        
    
    uuid.isUuid = (value) ->
        if value? and Object.prototype.toString.apply value is '[object String]' and value.length is 36
            parsed = parse value
            unparsed = unparse parsed
            return value is unparsed
        else if typeof Buffer is 'function' and Buffer.isBuffer(value)
            return value.length is 16
        else 
            return false
    
    uuid.interface = ->
        uuid()    
    
    uuid

#
# Actors operations services
#
do (_) ->
    _.go = (where, callback) ->
        if _.type(where) is _.Type.String then window?.location = where else  where.submit? callback

    actions = []
    
    actions.Type = Create: 1, Attach: 2, Update: 3, Detach: 4, Delete: 5
    
    actions.do = ({action, object, type, uuid, property, value, parent, contained}) ->
            
            type ?= _.type object
            
            # u: uuid, n: name, d:data, p:position, c:contained, a:ancestor
            
            switch action
                when actions.Type.Create 
                    actions.push what:action, where:u: uuid ? object.uuid, n:property, c:contained, a:parent, t:type

                when actions.Type.Attach
                    if type is _.Type.Array then position = property = object.length
                    actions.push what:action, where:u:_.do.uuid({parent:object, property, create:yes}), n:property, d:value, a:object._._.uuid, p:position
                    
                when actions.Type.Update 
                    actions.push what:action, where:u:_.do.uuid({parent:object, property}), d:value
                    
                when actions.Type.Detach 
                    actions.push what:action, where:u:_.do.uuid({parent:object, property})
                    
                when actions.Type.Delete 
                    actions.push what:action, where:u:uuid ? object.uuid

    _.do = (object, uuid) ->
        uuid ?= object.uuid

    # flush actions
    _.do.flush = ->
        return null if actions.length is 0
        
        actions_ = actions[...]
        actions.length = 0
        actions_
    
    # `internal` extends a Javascript object to add _ internal properties
    _.do.internal = (object, name, value) ->
        if _.isObject object
            object._ ?= if _.type(object) is _.Type.Array then [] else {}
            object._._ ?= {}
            if name? then object._._[name] ?= value
        object

    # `identify` extends a Javascript object so that every property has an identity
    # `options.parent` optionaly gives the parent's object
    # `options.name` optionaly tells the object's name given by its parent
    _.do.identify = (object, options) ->
        options ?= {}
        filter = options?.filter
        identified = {}
        
        identify = (current) ->
            {item, name, parent, position} = current
            {uuid, type} = {uuid:_.do.uuid({object:item, parent:parent?.object, property:name}), type:_.type(item)}
            
            if name is '_' then return
    
            _.do.internal item, 'uuid', uuid ? _.Uuid()
    
            if parent?.object?
                parent.object._ ?= if _.type(parent.object) is _.Type.Array then [] else {}
                index = name ? position
                parent.object._[index] ?= if type is _.Type.Array then [] else {}
                parent.object._[index].uuid ?= uuid ?= _.Uuid()
    
            switch type
                when _.Type.Object, _.Type.Array
                    switch type 
                        when _.Type.Object
                            for name, value of item when name isnt '_' and (not filter? or value.constructor in filter) and identified[value._?._?.uuid] isnt true
                                identify {item:value, name:name, parent: object:item}
                                if _.isObject value then identified[value._._.uuid] = true 
                                
                        when _.Type.Array
                            for name, value of item when name isnt '_' and (not filter? or value.constructor in filter) and identified[value._?._?.uuid] isnt true
                                pos = null unless (pos = parseInt name).toString() is name
                                identify {item:value, name: (if pos? then undefined else name), parent:{object:item}, position:pos}
                                if _.isObject value then identified[value._._.uuid] = true 
            return
        
        identify {item:object, parent:(if options.parent? then object:options.parent else null), name:options.name}
        object

    # `uuid` retrieves an object uuid    
    _.do.uuid = ({object, parent, property, create}) ->
        if not object? and parent? and property?
            object = parent[property]

        return undefined unless object?
        
        uuid = object.uuid ? parent?._?[property]?.uuid
        
        if not uuid? and create 
            uuid = _.Uuid()
            if parent? and property? then parent._[property].uuid = uuid
            object._ ?= if _.type(object) is _.Type.Array then [] else {}
            object._._ ?= {uuid}
        
        uuid
        
    # `set` a value inside an object    
    _.do.set = (object, property, value) ->
        
        return unless _.isObject object
        
        _.do.identify object unless object._?
        
        set = (o,k,v) ->
            _.do.identify v if _.isObject(v) and not v._?
            o[k] = v

        action = actions.Type.Update
        
        switch _.type property
            when _.Type.Number, _.Type.String
                action = actions.Type.Attach unless object[property]?
                actions.do {action, object, property, value}
                set object, property, value
    
            when _.Type.Object
                if _.type(object) is _.Type.Array
                    for k,v of property
                        if (index = parseInt(k)) isnt Number.NaN
                            action = actions.Type.Attach unless object[index]?
                            actions.do {action, object, property:index, value:v}
                            set object, index, v
                        else
                            action = actions.Type.Attach unless object[k]?
                            actions.do {action, object, property:k, value:v}
                            set object, k, v
                else
                    for k,v of property
                        action = actions.Type.Attach unless object[k]?
                        actions.do {action, object, property:k, value:v}
                        set object, k, v
                        
        object
        
    _.do.pop = (array) ->
        array.pop()
        
    _.do.push = ->
        array = Array.prototype.shift.call arguments
        
        
        #actions.do {action:actions.Type.Attach, object:array, value:item} for item in arguments

        Array.prototype.push.apply array, arguments
        
    _.do.reverse = ->
        array = Array.prototype.shift.call arguments
        Array.prototype.reverse.apply array, arguments
        
    _.do.shift = ->
        array = Array.prototype.shift.call arguments
        Array.prototype.shift.apply array, arguments
        
    _.do.sort = ->
        array = Array.prototype.shift.call arguments
        Array.prototype.sort.apply array, arguments
        
    _.do.splice = ->
        array = Array.prototype.shift.call arguments
        Array.prototype.splice.apply array, arguments
        
    _.do.unshift = ->
        array = Array.prototype.shift.call arguments
        Array.prototype.unshift.apply array, arguments
        