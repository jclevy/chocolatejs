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
            for o in flatten arguments... 
                switch _.type o 
                    when _.Type.Function then o.call @::
                    when _.Type.Array then for oo in o then @::[k] = v for own k,v of oo
                    else @::[k] = v for own k,v of o
            @

        adopt: -> 
            for o in flatten arguments...
                @[k] = v for own k,v of o 
                @::[k] = v for own k,v of o::
            @
            
        inherit: (parent) ->
            child = @
            if parent?
                if parent instanceof _.Prototyper then child.__prototyper__ = parent.prototyper ; parent = parent.prototyper()
                child[k] = v for own k,v of parent
                ctor = -> @constructor = child; return
                ctor:: = parent::
                child:: = new ctor()
                child.__super__ = parent::
            @

    constructor = if options?.hasOwnProperty 'constructor' then options.constructor else null
    
    ctor = switch
        when constructor? and options?.inherit? then -> Array.prototype.unshift.call(arguments, @); _.super.apply _, arguments; Array.prototype.shift.call(arguments); constructor.apply @, arguments; return
        when constructor? then -> constructor.apply @, arguments; return 
        when options?.inherit? then -> Array.prototype.unshift.call(arguments, @); _.super.apply _, arguments; return 
        else ->

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
    
    if constructor is _func.caller then super_func = constructor.__super__.constructor
    else while constructor and not super_func?
    
        for own k, v of constructor.prototype
            if _func is v then _name = k; break
    
        super_func = constructor.__super__[_name] if _name?
    
        unless super_func?
            constructor = if constructor.__super__? then constructor.__super__.constructor else null 
    
    if super_func
        return super_func.apply self, Array.prototype.slice.call arguments, if func? then 2 else 1 

# `_.Prototyper` allows to higher order function inheritance
_.Prototyper = _.prototype constructor:(@prototyper) ->

_.prototyper = (prototyper) -> new _.Prototyper prototyper

# `_.stringify` transforms a javascript object in a string that can be parsed back as an object
#
# You can stringify every property of an object, even a function or a Date:
#
# options: 
#    mode:
#         'json': reroute to JSON.stringify
#         'js' (default): returns a javascript string to recreate the given object 
#         'full' : same as 'js' mode, but treats Array objects as full object and stringifies values by keys instead of by indexes
#    prettify: multiline indented json presentation
#    own: stringify only own object properties not inherited ones
#    write: a function that will be called for each produced chunk of data
#         write = function (chunk) {...}
#           chunk: piece of string produced by the stringify function
#    strict: a boolean to tell wether we accept a user typed object. If not we throw an error
#    filter: do not stringify user defined types ojects unless type is present in filter list
#    variable: when stringifying an object, it will declare a variable for every object's property
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
    
    array_as_object = no

    switch options.mode
        when 'json' then return JSON.stringify object, null, tab
        when 'full' then array_as_object = yes
        when 'js' then # default mode

    write = if typeof options.write is 'function' then options.write else (str) -> str
    concat = (w1, w2, w3) ->
        if w1? and w2? and w3? then w1 + w2 + w3
        else null
    
    doit = (o, level, index) ->
        level ?= 0
        indent = if tab is '' then '' else (tab for [0...level]).join ''
        ni = newline + indent
        nit = ni + tab
        type = Object.prototype.toString.apply o
        sep = if index > 0 then ',' + nit else ''
        switch type
            when '[object Object]'
                if o.constructor isnt {}.constructor and o.stringify? and typeof o.stringify is 'function' then write sep + o.stringify()
                else 
                    if o.constructor isnt {}.constructor and options.strict then throw "_.stringify in strict mode can only accept pure objects"
                    else
                        i = 0 ; concat write(sep + "#{if options.variable and level is 0 then 'var ' else '{'}#{nit}"), "#{(chunk for k,v of o when ((not options.filter? or (v.constructor in options.filter))) and (options.own isnt true or {}.hasOwnProperty.call(o, k)) and (chunk = write((if i++ > 0 then ',' + nit else '') + (if options.variable and level is 0 then k else "'" + k.toString().replace(/\'/g, "\\'") + "'") + (if options.variable and level is 0 then '=' else ':')) + doit(v, level+1))).join('')}", write("#{ni}#{if options.variable and level is 0 then ';' else '}'}")
            when '[object Array]'
                if array_as_object then i = 0 ; concat write(sep + "function () {#{nit}var a = []; var o = {#{nit}"), "#{(chunk for own k,v of o when (chunk = write((if i++ > 0 then ',' + nit else '') + k + ':') + doit(v, level+1))).join('')}", write("};#{nit}for (var k in o) {a[k] = o[k];} return a; }()") # necessary to serialize both indexes and properties
                else concat write(sep + "[#{nit}"), "#{(chunk for v, i in o when (chunk = doit(v, level+1, i))?).join ('')}", write("#{ni}]")
            when '[object Boolean]' then write sep + o
            when '[object Number]' then write sep + o
            when '[object Date]' then write sep + "new Date(#{o.valueOf()})"
            when '[object Function]' then write sep + o.toString()
            when '[object Math]' then write sep + 'Math'
            when '[object String]' then write sep + "'#{o.replace /\'/g, '\\\''}'"
            when '[object Undefined]' then write sep + 'void 0'
            when '[object Null]' then write sep + 'null'
            when '[object Buffer]', '[object SlowBuffer]'
                write sep + (if o.length is 16 then _.Uuid.unparse o else o.toString())

    doit(object)
        
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

# `_.param` transforms a javascript value to an url query parameter
#
#     a = _.param {u:1, v:2}
#     expect(a).toBe 'u=1&v=2'
_.param = (parameters) ->
    return encodeURIComponent parameters if _.type(parameters) is _.Type.String
    
    serialize = []
    for own parameter of parameters
        serialize.push "#{encodeURIComponent parameter}=#{encodeURIComponent parameters[parameter]}"
    serialize.join '&'
        
# `_.serialize` helps manage asynchronous calls serialization.
# `_.async` and `_.run` are synonyms to `_.serialize`
#
# - use **self** to pass an object to which **this** will be binded when deferred functions will be called
# - use **local** to share variables between the deferred functions
# - **fn** is a function in which you declare the asynchronous functions you want to defer and serialize
# - use **option** with value `async:off` to ask **_.serialize** not to enforce async call on the last `run`
#
# Here is a simple example:
#
#      _.serialize (run) ->
#          run (end) ->
#              my_first_async_func ->
#                  # ...
#                  end()
#          run (end) ->
#              my_second_async_func ->
#                  # ...
#                  end()
#
# Each run can return one of the following values that will tell the _.serialize service that 
# one of its runs is async and that it is not forced to run its last run as async
#
# 
#     run (end) -> end  
#
# or
#
#     run (end) -> end.later
#
# Here is an example with async and sync runs mixed, using the _.async syntax:
#
#     _.async (await) ->
#         await (next) ->
#             my_first_async_func ->
#                 # ...
#                 next()
#             next.later
#
#         await (next) ->
#             sync_func()
#             next()
#
#         await (next) ->
#             my_second_async_func ->
#                 # ...
#                 next()
#             next.later
_.serialize = _.flow = _.async = (options, fn) ->
    unless fn? then fn = options; options = {}
    {self, local} = options
    self ?= {}
    local ?= {}

    deferred = []
    async = off
    defer = (fn) ->
        if arguments.length is 2 then fn = arguments[1] # first argument now unused

        deferred.push fn
        
    undefer = ->
        undefered = deferred.shift()
    
        if deferred.length is 0 and async is off and options?.async isnt off 
            (next) ->
                setTimeout (-> undefered?.call self, next), 0 
        else 
            undefered
    
    next = ->
        if deferred.length
            result = undefer().call self, next
            switch result
                when next then async = on
            result

    next.later = next
    next.with = (result) -> if result isnt next.later then next() else next.later
    self.next = next unless options.self?

    fn_self = options.self
    fn_self ?= fn
    
    fn.call fn_self, defer, local
    undefer()?.call self, next

_.parallelize = (self, fn) ->
    if typeof self is 'function' then fn = self; self = fn
    pushed = []
    on_join = null ; join = (fn) -> on_join = fn
    
    count = 0 ; end = -> count += -1 ;  if count is 0 then on_join?.call self
    push = (fn) -> pushed.push -> setTimeout (-> fn.call(self) ; end()), 0
    
    fn.call self, push, join
    
    count = pushed.length ; for dfn in pushed then dfn.call self

# `_.throttle` Returns a new function that, when invoked, invokes `func` at most once per `wait` milliseconds
#
# `options`:
#   `wait`: number of milliseconds that must elapse between `func` invocations (defaults to 1000).
#   `reset`: boolean to reset wait period every time the throttled function is called
#   `accumulate`: boolean to accumulate arguments before calling throttled function.
# `func`: Function to wrap.
# return A new function that wraps the `func` function passed in.
# 
# Thanks to: https://github.com/component/throttle
_.throttle = (options, func) ->
    unless func? then func = options ; options = {}
    {wait, reset, accumulate} = options
    wait ?= 1000; reset ?= off; accumulate ?= off

    ctx = undefined
    args = undefined
    rtn = undefined
    timeoutID = undefined

    last = 0

    call = ->
        timeoutID = undefined
        last = (new Date).getTime()
        rtn = func.apply(ctx, args)
        ctx = undefined
        args = undefined
        return

    ->
        ctx = this
        unless accumulate then args = arguments 
        else unless args? then args = [arguments] else args.push(arguments)
        delta = (new Date).getTime() - last
        if reset
            clearTimeout timeoutID if timeoutID?
            timeoutID = setTimeout(call, wait)
        else unless timeoutID?
            if delta >= wait then call()
            else timeoutID = setTimeout(call, wait - delta)
            
        rtn
    
# `_.extend` copies values from an object to another object (no deep copy)
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

# `_.clone` deeply copies values from an object to another object
#
#     o = _.clone {first:1}, {second:2}
#          expect(o.first).toBe(1)
#          expect(o.second).toBe(2)
#
_.clone = ->
    target = arguments[0] or {}
    length = arguments.length

    if length is 1 then i = 0; target = {}
    else
        i = 1
        # Handle case when target is a string or something (possible in deep copy)
        target = {} if typeof target isnt "object" and not _.type(target) is _.Type.Function
        
    while i < length
        # Only deal with non-null/undefined values
        if (options = arguments[i])?
            # Extend the base object
            for name of options
                src = target[name]
                copy = options[name]

                # Prevent never-ending loop
                if target is copy then continue

                # Recurse if we're merging plain objects or arrays
                if copy and (_.isBasicObject(copy) or (copyIsArray = _.type(copy) is _.Type.Array))
                    if copyIsArray
                        copyIsArray = no
                        clone = if src and _.type(src) is _.Type.Array then src else []
                    else 
                        clone = if src and _.isBasicObject(src) then src else {}

                    # Never move original objects, clone them
                    target[name] = _.clone clone, copy

                    # Don't bring in undefined values
                else if copy isnt undefined
                    target[name] = copy
        i += 1

    # Return the modified object
    target

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
# events
# multi commit batching


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

_.cell = (def, options) ->
    signal = new Signal def, options
    (def) ->
        if def?
            if arguments.length > 1
                method = Array::splice.call arguments, 0, 1
                signal[method].apply signal, arguments
            else
                if def is _ then return signal
                else signal.value.call(signal, def)
        else 
            signal.value.call(signal)

_.observer = (def) ->
    observer = new Observer def
    (def) ->
        if arguments.length > 1
            method = Array::splice.call arguments, 0, 1
            observer[method].apply observer, arguments
        else
            observer.observe def

_.Signal = _.Cell = Signal = _.prototype

    adopt:
        # Constants
        type: 0x0100
        idle: 0x0001
        initialized: 0x0002
        object: 0x0004
        array: 0x0008
        
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
            reverse: type:'Sort', what:'All'
            shift: type:'Remove', what:'One', where:'First'
            sort: type:'Sort', what:'All'
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
                @signal.flags |= Signal.idle | Signal.initialized
                Signal.dependencyStack = stack
                
                @count += -1

                # Now ask dependant signals to evaluate themselves
                @signal.propagate @observerList, @

                if @signal.observers? then observer.notify on for observer in @signal.observers
                    
            one: -> @count += 1
            idle: -> @count is 0
                
    constructor: (@definition, @options) ->
        
        # @helpers can contain  'set' and array functions helpers to be called in place of our version
        for name, helper of @helpers then do (helper, name, self=@) ->  self.helpers[name] = -> helper.apply self, arguments
        
        # With id option, every value inside has to have an id associated
        if @options?.id? then @globalize('uuid', -> _.Uuid())
        
        # Cached value of this signal calculated by the evaluate function
        # Recalculated when a definition has changed or when notified by a dependency
        @_value = null
        
        # Flags for: Type, Idle, Initialized, Object, Array
        # Initialized will be true after first evaluation
        # Idle is false when Signal is calculating its value
        @flags = Signal.type | Signal.idle

        # List of signals that this depends on
        # Used to remove self from their dependents list when necessary
        # Note that while the dependents is a list of evaluate objects
        # dependencies is a list of the signals themselves
        @dependencies = undefined
    
        # Symmetrically - the list of other signals and observers that depend on this signal
        # Used to know who to notify when this signal has been updatedls
        @dependents = undefined
        @observers = undefined
        @dependentTargets = undefined
    
        # run an initial evaluation on creation
        # no need to notify observers/dependents because it shouldnt have any yet
        @evaluate()

    # `globalize` adds an attribute to every Signal's value's sub property
    # and transform any sub-property to a Signal object
    globalize: (property, builder) ->
        globalized = {}

        globalize = (current) ->
            unless current[property]?
                item = current.value
                type = _.type item
                current[property] = builder()
    
            switch type
                when _.Type.Object, _.Type.Array
                    switch type 
                        when _.Type.Object
                            for name, value of item when name isnt '_' and globalized[value._?._?.uuid] isnt true
                                globalize {item:value, name:name, parent:item}
                                if _.isObject value then globalized[value._._.uuid] = true 
                                
                        when _.Type.Array
                            for name, value of item when name isnt '_' and globalized[value._?._?.uuid] isnt true
                                pos = null unless (pos = parseInt name).toString() is name
                                globalize {item:value, name: (if pos? then undefined else name), parent:{item}}
                                if _.isObject value then globalized[value._._.uuid] = true 
            return
        
        globalize this
        return
        
    # evaluate is a function to calculates the signal value given the definition
    # it recursively revaluates any signals that depend on it as well
    # Simultaneously, in order to know what observers to notify later
    # it recursively passes through a list to collect all the observers of the updated signals
    # After the signal cascade has completed, the observers on the list are notified
    
    evaluate: (observerList, defer) ->
        
        # by default the value is the definition
        @_value = @definition
        @error = null
        @flags |= Signal.idle
        @flags &= ~Signal.object & ~Signal.array

        # clear old dependencies both forward and back pointers
        if @dependencies? then for dependency in @dependencies when dependency.dependents?
            dependentIndex = dependency.dependents.indexOf @
            dependency.dependents.splice dependentIndex, 1
        @dependencies = undefined

        switch type = _.type @definition
        
            # if definition is a function then we need to evaluate it
            # and set it up to be notified when its dependencies change
            when _.Type.Function
                
                defer ?= new Signal.Defer @, observerList
                
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
                        @error = e
                        if @_catch?
                            @_catch e
                            @error = null
                    
                    if result is deferred
                        @flags &= ~Signal.idle
                        defer.one()
                        if @observers? then observer.notify(off) for observer in @observers
                    else
                        @_value = result
                        @flags |= Signal.idle | Signal.initialized
                
                finally 
                    Signal.dependencyStack.pop()
            
            when _.Type.Object, _.Type.Array
                @flags |= if type is _.Type.Object then Signal.object else Signal.array

        # Add this signals own observers to the observer list
        if observerList? and @observers? then for observer in @observers
            observerList.push observer if observer? and (observerList.indexOf observer) < 0

        # Now propagate the evaluation to the dependant signals
        @propagate observerList, defer unless deferred? and result is deferred
        
        defer?.idle() ? yes

    set: (key, value, trigger) ->
        if arguments.length is 1 then @definition = key
        else if @flags & (Signal.object | Signal.array) then @definition[key] = value
        @value(@definition) unless trigger is off # Manually trigger the refresh
        
    get: -> @value()
        
    delete: (key, trigger)->
        if @flags & (Signal.object | Signal.array) then delete @definition[key]
        @value(@definition) unless trigger is off # Manually trigger the refresh
    
    pop: -> return unless @flags & Signal.array ; o = @definition.pop.apply @definition, arguments ; @value(@definition) ; o
    push: -> return unless @flags & Signal.array ; o = @definition.push.apply @definition, arguments ; @value(@definition) ; o
    reverse: -> return unless @flags & Signal.array ; o = @definition.reverse.apply @definition, arguments ; @value(@definition) ; o
    shift: -> return unless @flags & Signal.array ; o = @definition.shift.apply @definition, arguments ; @value(@definition) ; o
    sort: -> return unless @flags & Signal.array ; o = @definition.sort.apply @definition, arguments ; @value(@definition) ; o
    splice: -> return unless @flags & Signal.array ; o = @definition.splice.apply @definition, arguments ; @value(@definition) ; o
    unshift: -> return unless @flags & Signal.array ; o = @definition.unshift.apply @definition, arguments ; @value(@definition) ; o
    
    # catch register a function to call when an error occurs
    catch: (report) ->
        @_catch = report
        if @error?
            @_catch @error
            @error = null
        
    # Tells whether this Signal is currently calculating its value
    idle: -> @flags & Signal.idle
    
    # propagate the evaluation to the dependant signals
    propagate: (observerList, defer) ->
        return unless @dependents?
        
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
                dependent.evaluate observerList, defer
                
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
            
            if @evaluate observerList
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
            if dependent? and dependent.flags & Signal.type
                @dependents ?= []
                @dependents.push dependent if @dependents.indexOf(dependent) < 0
                dependent.dependencies ?= []
                dependent.dependencies.push @ if dependent.dependencies.indexOf(@) < 0

                # remove the dependent from the targets list if necessary
                # this is used to avoid duplicate redundant evaluation
                @dependentTargets ?= []
                targetDependentIndex = @dependentTargets.indexOf dependent
                @dependentTargets[targetDependentIndex] = null if targetDependentIndex >= 0

            # If it is a observer dependency - similarly register it as a observer
            # symmetrically register self as a observee for cleaning dependencies later
            else if dependent? and dependent.flags & Observer.type
                @observers ?= []
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
        type: 0x0200

    constructor: (report) ->
        @observees = []
        @flags = Observer.type

        @observe report

    # returned in the form of a function
    # as with signals - can be provided with a new definition
    observe: (report)->
        @report = report

        @_ready = true
        
        # clear old observees
        for observee in @observees when observee.observers?
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
        @unreported = []

    notify: (value) -> 
        if @subscribers.length > 0 then for report in @subscribers then report value
        else @unreported.push value
    
    subscribe: (reporter) -> 
        @subscribers.push reporter
        
        if @unreported.length > 0 
            self = @
            notify = -> 
                for value in self.unreported then reporter value
                self.unreported.length = 0
            setTimeout notify, 0 

# slugify function
_.slugify = (text) ->
  # Use hash map for special characters 
  specialChars = 
    'à': 'a'
    'ä': 'a'
    'á': 'a'
    'â': 'a'
    'æ': 'a'
    'å': 'a'
    'ë': 'e'
    'è': 'e'
    'é': 'e'
    'ê': 'e'
    'î': 'i'
    'ï': 'i'
    'ì': 'i'
    'í': 'i'
    'ò': 'o'
    'ó': 'o'
    'ö': 'o'
    'ô': 'o'
    'ø': 'o'
    'ù': 'o'
    'ú': 'u'
    'ü': 'u'
    'û': 'u'
    'ñ': 'n'
    'ç': 'c'
    'ß': 's'
    'ÿ': 'y'
    'œ': 'o'
    'ŕ': 'r'
    'ś': 's'
    'ń': 'n'
    'ṕ': 'p'
    'ẃ': 'w'
    'ǵ': 'g'
    'ǹ': 'n'
    'ḿ': 'm'
    'ǘ': 'u'
    'ẍ': 'x'
    'ź': 'z'
    'ḧ': 'h'
    '·': '-'
    '/': '-'
    '_': '-'
    ',': '-'
    ':': '-'
    ';': '-'
  text.toString().toLowerCase().replace(/\s+/g, '-').replace(/./g, (target, index, str) ->
    specialChars[target] or target
  ).replace(/&/g, '-and-').replace(/[^\w\-]+/g, '').replace(/\-\-+/g, '-').replace(/^-+/, '').replace /-+$/, ''


# cuid.js
# Collision-resistant UID generator for browsers and node.
# Sequential for fast db lookups and recency sorting.
# Safe for element IDs and server-side lookups.
#
# Extracted from CLCTR
#
# Copyright (c) Eric Elliott 2012
# MIT License
_.Cuid = do ->
  c = 0 ; blockSize = 4 ; base = 36 ; discreteValues = Math.pow base, blockSize

  pad = (num, size) -> s = '000000000' + num ; s.substr s.length - size
  randomBlock = -> pad (Math.random() * discreteValues << 0).toString(base), blockSize
  safeCounter = -> (c = if c < discreteValues then c else 0) ; c++ ; c - 1

  api = ->
    letter = 'c'
    timestamp = (new Date).getTime().toString(base)
    counter = undefined
    fingerprint = api.fingerprint()
    random = randomBlock() + randomBlock()
    counter = pad(safeCounter().toString(base), blockSize)
    letter + timestamp + counter + fingerprint + random

  api.slug = ->
    date = (new Date).getTime().toString(36)
    counter = undefined
    print = api.fingerprint().slice(0, 1) + api.fingerprint().slice(-1)
    random = randomBlock().slice(-2)
    counter = safeCounter().toString(36).slice(-4)
    date.slice(-2) + counter + print + random

  api.globalCount = unless window? then undefined else ->
    cache = (-> i = undefined ; count = 0 ; (for i of window then count++) ; count)()
    api.globalCount = -> cache
    cache

  api.fingerprint = if window? 
        -> 
            pad (navigator.mimeTypes.length + navigator.userAgent.length).toString(36) + api.globalCount().toString(36), 4
    else 
        ->
            os = require('os') ; padding = 2
            pid = pad(process.pid.toString(36), padding)
            hostname = os.hostname() ; length = hostname.length
            hostId = pad(hostname.split('').reduce(((prev, char) -> +prev + char.charCodeAt(0) ), +length + 36).toString(36), padding)
            pid + hostId
  api

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

### - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  ###
###  SHA-256 implementation in JavaScript                (c) Chris Veness 2002-2014 / MIT Licence  ###
######
###  - see http://csrc.nist.gov/groups/ST/toolkit/secure_hashing.html                              ###
###        http://csrc.nist.gov/groups/ST/toolkit/examples.html                                    ###
### - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  ###
_.Sha256 = do ->

    ### global define, escape, unescape ###

    Sha256 = undefined
    Sha256 = {}
    
    ###*
    # Generates SHA-256 hash of string.
    #
    # @param   {string} msg - String to be hashed
    # @returns {string} Hash of msg as hex character string
    ###
    
    Sha256.hash = (msg) ->
      t = undefined
      t = undefined
      i = undefined
      H = undefined
      K = undefined
      M = undefined
      N = undefined
      T1 = undefined
      T2 = undefined
      W = undefined
      a = undefined
      b = undefined
      c = undefined
      d = undefined
      e = undefined
      f = undefined
      g = undefined
      h = undefined
      i = undefined
      j = undefined
      l = undefined
      t = undefined
      msg = msg.utf8Encode()
      K = [
        0x428a2f98
        0x71374491
        0xb5c0fbcf
        0xe9b5dba5
        0x3956c25b
        0x59f111f1
        0x923f82a4
        0xab1c5ed5
        0xd807aa98
        0x12835b01
        0x243185be
        0x550c7dc3
        0x72be5d74
        0x80deb1fe
        0x9bdc06a7
        0xc19bf174
        0xe49b69c1
        0xefbe4786
        0x0fc19dc6
        0x240ca1cc
        0x2de92c6f
        0x4a7484aa
        0x5cb0a9dc
        0x76f988da
        0x983e5152
        0xa831c66d
        0xb00327c8
        0xbf597fc7
        0xc6e00bf3
        0xd5a79147
        0x06ca6351
        0x14292967
        0x27b70a85
        0x2e1b2138
        0x4d2c6dfc
        0x53380d13
        0x650a7354
        0x766a0abb
        0x81c2c92e
        0x92722c85
        0xa2bfe8a1
        0xa81a664b
        0xc24b8b70
        0xc76c51a3
        0xd192e819
        0xd6990624
        0xf40e3585
        0x106aa070
        0x19a4c116
        0x1e376c08
        0x2748774c
        0x34b0bcb5
        0x391c0cb3
        0x4ed8aa4a
        0x5b9cca4f
        0x682e6ff3
        0x748f82ee
        0x78a5636f
        0x84c87814
        0x8cc70208
        0x90befffa
        0xa4506ceb
        0xbef9a3f7
        0xc67178f2
      ]
      H = [
        0x6a09e667
        0xbb67ae85
        0x3c6ef372
        0xa54ff53a
        0x510e527f
        0x9b05688c
        0x1f83d9ab
        0x5be0cd19
      ]
      msg += String.fromCharCode(0x80)
      l = msg.length / 4 + 2
      N = Math.ceil(l / 16)
      M = new Array(N)
      i = 0
      while i < N
        M[i] = new Array(16)
        j = 0
        while j < 16
          M[i][j] = msg.charCodeAt(i * 64 + j * 4) << 24 | msg.charCodeAt(i * 64 + j * 4 + 1) << 16 | msg.charCodeAt(i * 64 + j * 4 + 2) << 8 | msg.charCodeAt(i * 64 + j * 4 + 3)
          j++
        i++
      M[N - 1][14] = (msg.length - 1) * 8 / Math.pow(2, 32)
      M[N - 1][14] = Math.floor(M[N - 1][14])
      M[N - 1][15] = (msg.length - 1) * 8 & 0xffffffff
      W = new Array(64)
      a = undefined
      b = undefined
      c = undefined
      d = undefined
      e = undefined
      f = undefined
      g = undefined
      h = undefined
      i = 0
      while i < N
        t = 0
        while t < 16
          W[t] = M[i][t]
          t++
        t = 16
        while t < 64
          W[t] = Sha256.σ1(W[t - 2]) + W[t - 7] + Sha256.σ0(W[t - 15]) + W[t - 16] & 0xffffffff
          t++
        a = H[0]
        b = H[1]
        c = H[2]
        d = H[3]
        e = H[4]
        f = H[5]
        g = H[6]
        h = H[7]
        t = 0
        while t < 64
          T1 = h + Sha256.Σ1(e) + Sha256.Ch(e, f, g) + K[t] + W[t]
          T2 = Sha256.Σ0(a) + Sha256.Maj(a, b, c)
          h = g
          g = f
          f = e
          e = d + T1 & 0xffffffff
          d = c
          c = b
          b = a
          a = T1 + T2 & 0xffffffff
          t++
        H[0] = H[0] + a & 0xffffffff
        H[1] = H[1] + b & 0xffffffff
        H[2] = H[2] + c & 0xffffffff
        H[3] = H[3] + d & 0xffffffff
        H[4] = H[4] + e & 0xffffffff
        H[5] = H[5] + f & 0xffffffff
        H[6] = H[6] + g & 0xffffffff
        H[7] = H[7] + h & 0xffffffff
        i++
      Sha256.toHexStr(H[0]) + Sha256.toHexStr(H[1]) + Sha256.toHexStr(H[2]) + Sha256.toHexStr(H[3]) + Sha256.toHexStr(H[4]) + Sha256.toHexStr(H[5]) + Sha256.toHexStr(H[6]) + Sha256.toHexStr(H[7])
    
    ###*
    # Rotates right (circular right shift) value x by n positions [§3.2.4].
    # @private
    ###
    
    Sha256.ROTR = (n, x) ->
      x >>> n | x << 32 - n
    
    ###*
    # Logical functions [§4.1.2].
    # @private
    ###
    
    Sha256.Σ0 = (x) ->
      Sha256.ROTR(2, x) ^ Sha256.ROTR(13, x) ^ Sha256.ROTR(22, x)
    
    Sha256.Σ1 = (x) ->
      Sha256.ROTR(6, x) ^ Sha256.ROTR(11, x) ^ Sha256.ROTR(25, x)
    
    Sha256.σ0 = (x) ->
      Sha256.ROTR(7, x) ^ Sha256.ROTR(18, x) ^ x >>> 3
    
    Sha256.σ1 = (x) ->
      Sha256.ROTR(17, x) ^ Sha256.ROTR(19, x) ^ x >>> 10
    
    Sha256.Ch = (x, y, z) ->
      x & y ^ ~x & z
    
    Sha256.Maj = (x, y, z) ->
      x & y ^ x & z ^ y & z
    
    ###*
    # Hexadecimal representation of a number.
    # @private
    ###
    
    Sha256.toHexStr = (n) ->
      i = undefined
      s = undefined
      v = undefined
      s = ''
      v = undefined
      i = 7
      while i >= 0
        v = n >>> i * 4 & 0xf
        s += v.toString(16)
        i--
      s
    
    ### - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ###
    
    ###* Extend String object with method to encode multi-byte string to utf8
    #  - monsur.hossa.in/2012/07/20/utf-8-in-javascript.html
    ###
    
    if `typeof String.prototype.utf8Encode == 'undefined'`
    
      String::utf8Encode = -> unescape encodeURIComponent(this)
    
    ###* Extend String object with method to decode utf8 string to multi-byte ###
    
    if `typeof String.prototype.utf8Decode == 'undefined'`
    
      String::utf8Decode = ->
        e = undefined
        try
          return decodeURIComponent(escape(this))
        catch _error
          e = _error
          return this
        return
    
    Sha256

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
                            for name, value of item when name isnt '_' and (not filter? or value?.constructor in filter) and identified[value._?._?.uuid] isnt true
                                identify {item:value, name:name, parent: object:item}
                                if _.isObject value then identified[value._._.uuid] = true 
                                
                        when _.Type.Array
                            for name, value of item when name isnt '_' and (not filter? or value?.constructor in filter) and identified[value._?._?.uuid] isnt true
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
        
