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
    
    created = if constructor? then -> constructor.apply @, arguments; return 
    else if options?.inherit? then -> Array.prototype.unshift.call(arguments, @); _.super.apply _, arguments; return else ->
    
    if options?
        for name, value of options
            if name in ['adopt', 'inherit', 'use']
                prototype[name].call created, value
            else created::[name] = value unless name is 'constructor'
        
    created[name] = fn for own name,fn of prototype when not created[name]?
    
    created

# `_.super` calls the parent's function in an overriden function
_.super = (self) ->
    name = null
    parent = arguments.callee
    while (parent = parent.caller)? and not name? then for k,v of self.constructor.prototype then if parent is v then name = k; break
    
    name ?= 'constructor'
    return self.constructor.__super__[name].apply self, Array.prototype.slice.call arguments, 1


# `_.stringify` transforms a javascript object in a string that can be parsed back as an object
#
# You can stringify every property of an object, even a function or a Date:
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
    
    doit = (o, level) ->
        result = []
        level ?= 0
        indent = (tab for [0...level]).join ''
        ni = newline + indent
        nit = ni + tab
        type = Object.prototype.toString.apply o
        result.push switch type
            when '[object Object]' then "{#{nit}#{(k + ':' + doit(v, level+1) for own k,v of o).join(',' + nit)}#{ni}}"
            when '[object Array]' then "function () {#{nit}var a = []; var o = {#{nit}#{(k + ':' + doit(v, level+1) for own k,v of o).join(',' + nit)}};#{nit}for (var k in o) {a[k] = o[k];} return a; }()"
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
        
# `serialize` helps manage asynchronous calls serialization.  
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

# `defaults` ensure default values are set on an object
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
        set = (o, d) ->
            for own k,v of d
                if _.type(o[k]) is _.Type.Object and _.type(v) is _.Type.Object then set o[k], v
                else o[k] = v if not o[k]?
            o
           
        set object, defaults
        
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
        # Global stack to automatically track signal dependencies
        # Whenever a signal or observer is evaluated - it puts itself on the dependency stack
        # When another signals is read - the dependency stack is checked to see who is asking
        # The reader gets added as a dependent to the signal being read
        # wWen a signal or observer's evaluation is done - it pops itself off the stack
        dependencyStack: []
        
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
                
    constructor: (@definition) ->
        
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
        @dependencyType = "signal"
    
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

        arrayMethods = ["pop", "push", "reverse", "shift", "sort", "splice", "unshift"]
        
        switch type = _.type @definition
        
            # if definition is a function then we need to evaluate it
            # and set it up to be notified when its dependencies change
            when _.Type.Function

                # clear old dependencies
                for dependency in @dependencies
                    dependentIndex = dependency.dependents.indexOf @
                    dependency.dependents.splice dependentIndex, 1
                @dependencies = []
    
                # evaluate the definition and set new dependencies
                Signal.dependencyStack.unshift @
                
                deferred = do (signal=@) ->
                    (fn) ->
                        prev = defer.signal
                        defer.signal = signal
                        defer.value.call defer, fn
                        defer.signal = prev
                        
                result = @definition deferred
                
                if result is deferred
                    @_idle = false
                    defer.one()
                    observer.notify(off) for observer in @observers
                else
                    @_value = result
                    @_initialized = true
                    @_idle = true
                    
                Signal.dependencyStack.shift()
            
            when _.Type.Object, _.Type.Array
                
                # convenience method for setting properties
                @set = (key, value) =>
                    @definition[key] = value
                    @value(@definition) # Manually trigger the refresh
            
                if type is _.Type.Array
                    # Set the special array methods if the definition is an array
                    # Essentially providing convenience mutator methods which automatically trigger revaluation
                    for methodName in arrayMethods
                        do (methodName) =>
                            @[methodName] = =>
                                output = @definition[methodName].apply @definition, arguments
                                @value(@definition) # Manually trigger the refresh
                                return output
                
            else 
                delete @[methodName] for methodName in arrayMethods
                delete @set

        # Add this signals own observers to the observer list
        if observerList? then for observer in @observers
            observerList.push observer if (observerList.indexOf observer) < 0

        # Now propagate the evaluation to the dependant signals
        @propagate defer, observerList unless deferred? and result is deferred

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
            if @dependentTargets.indexOf(dependent) >= 0
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
                observer.trigger() for observer in observerList
            
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
            dependent = Signal.dependencyStack[0]

            # If its a signal dependency - register it as such
            if dependent? and dependent.dependencyType is "signal"

                # remove the dependent from the targets list if necessary
                # this is used to avoid duplicate redundant evaluation
                targetDependentIndex = @dependentTargets.indexOf dependent
                @dependentTargets.splice(targetDependentIndex, 1) if targetDependentIndex >= 0

                # register it as a dependent if necessary
                existingDependentIndex = @dependents.indexOf dependent
                @dependents.push dependent if existingDependentIndex < 0

                # symmetrically - register self as a dependency
                # this is needed for cleaning dependencies later
                existingDependencyIndex = dependent.dependencies.indexOf @
                dependent.dependencies.push @ if existingDependencyIndex < 0

            # If it is a observer dependency - similarly register it as a observer
            else if dependent? and dependent.dependencyType is "observer"
                
                # register the observer if necessary
                existingObserverIndex = @observers.indexOf dependent
                @observers.push dependent if existingObserverIndex < 0

                # symmetrically - register self as a observee
                # this is needed for cleaning obeserver dependencies later
                existingObserveeIndex = dependent.observees.indexOf @
                dependent.observees.push @ if existingObserveeIndex < 0

            return @_value
                
# Observers report signal changes
# They are defined in a manner similar to Signals
# The primary differences of observers are
# - they have no value to read
# - they cannot be observed themselves
# - they are notified only after signals have all been updated
# to remove an observer - just set its value to null

_.Observer = Observer = _.prototype

    constructor: (report) -> 
        @observees = []
        @dependencyType = "observer"

        @observe report

    # returned in the form of a function
    # as with signals - can be provided with a new definition
    observe: (report)->
        @report = report

        @_ready = true
        
        # clear old observees
        for observee in @observees
            observerIndex = observee.observers.indexOf @
            observee.observers.splice observerIndex, 1
        @observees = []
        
        # do initial trigger and set up to listen for future updates
        Signal.dependencyStack.unshift @
        @report() unless @report is null
        Signal.dependencyStack.shift()
        
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
        Signal.dependencyStack.unshift @
        @report() unless @report is null
        Signal.dependencyStack.shift()


    # Tells whether this Observer is currently calculating its value
    ready: -> @_ready

# Publishers report basic signal changes to one-to-many reporters
# They use one internal pair of Signal and Observer
_.Publisher = Publisher = _.prototype
    constructor:  ->
        @subscribers = []
        @signal = new Signal()
        @observer = new Observer => 
            value = @signal.value()
            report value for report in @subscribers
    
    notify: (value) -> @signal.value(value)
    
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
        else if Buffer.isBuffer(value)
            return value.length is 16
        else 
            return false
    
    uuid.interface = ->
        uuid()    
    
    uuid
    