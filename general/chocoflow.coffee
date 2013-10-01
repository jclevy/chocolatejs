_module = window ? module

_module.exports =
    # `serialize` helps manage asynchronous calls serialization.  
    #
    # - use **self** to pass an object to which **this** will be binded when defered functions will be called
    # - use **local** to share variables between the defered functions
    # - **fn** is a function in which you declare the asynchronous functions you want to defer and serialize
    #
    # >     Flow.serialize (defer) ->
    # >         defer (next) ->
    # >             my_first_async_func ->
    # >                 # ...
    # >                 next()
    # >         defer (next) ->
    # >             my_second_async_func ->
    # >                 # ...
    # >                 next()
    serialize : (self, local, fn) ->
        if typeof local is 'function' then fn = local; local = {}
        if typeof self is 'function' then fn = self; self = fn; local = {}
        
        defered = []
        defer = (fn) -> defered.push fn
        
        fn.call self, defer, local
        defered.shift().call self, next = -> defered.shift().call self, next if defered.length

    parallelize : (self, fn) ->
        if typeof self is 'function' then fn = self; self = fn
        
        pushed = []
        on_join = null ; join = (fn) -> on_join = fn
        
        count = 0 ; end = -> count += -1 ;  if count is 0 then on_join?.call self
        push = (fn) -> pushed.push -> setTimeout (-> fn.call(self) ; end()), 0
        
        fn.call self, push, join
        
        count = pushed.length ; for dfn in pushed then dfn.call self

window?.Chocoflow = window.exports