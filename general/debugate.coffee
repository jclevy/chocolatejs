class Debugate
    @log: (what...) ->
        console.log 'DEBUG:', (""+x for x in what).join(' ')
    
    @profile: do ->
        count = {}
        start = {}
        time = {}
        pulse = {}
        total = count: 0, time: 0
        
        unless window? then try fn = require('microtime') ; fn_now = -> fn.now()
        unless fn_now? then fn_now = -> Date.now() * 1000

        fns =
            count: (x) ->
                count[x] ?= 0
                count[x] += 1
                total.count += 1
            
            start: (x) ->
                fns.count x
                start[x] = fn_now()
                return
            
            end: (x, xx) ->
                now = fn_now()
                time[x] ?= 0
                time[x] += lapse = now - start[x]
                total.time += lapse
                start[x] = null
                if xx? then start[xx] = now ; fns.count xx
                return
            
            toggle: (x) ->
                unless start[x]? then fns.start x
                else fns.end x   
                
            pulse: (x, reset) ->
                pulse[x] ?= 0
                pulse[x] = 0 if reset is on
                
                unless start[xx = x + pulse[x]]? 
                    fns.start xx
                else 
                    unless reset is off
                        fns.end xx, x + ++pulse[x]
                    else
                        fns.end xx
            
            reset: (x) ->
                if x? 
                    total.count -= count[x]
                    total.time -= time[x]
                    count[x] = time[x] = pulse[x] = 0 ;  start[x] = null
                else 
                    for k of count then count[k] = time[k] = pulse[x] = 0 ; start[k] = null
                    total.count = total.time = 0
                
            wait: (y) ->
                for [0...y] then ;
        
            spent: (x) ->
                if x?
                    time: time[x] ? 0
                    count:count[x] ? 0
                    total: total
                else
                    data = {}
                    for k of count
                        data[k] = time: time[k], count:count[k]
                    {data, total}

_module = window ? module
_module[if _module.exports? then "exports" else "Debugate"] = Debugate
