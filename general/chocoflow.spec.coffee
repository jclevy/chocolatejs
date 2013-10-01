Flow = require '../general/chocoflow'

describe 'Flow', ->
    f1 = (cb) -> setTimeout (-> cb new Date().getTime()), 250
    f2 = (cb) -> setTimeout (-> cb new Date().getTime()), 150
    f3 = (cb) -> setTimeout (-> cb new Date().getTime()), 350
    
    it 'should not serialize three async functions without Flow', ->
        start = new Date().getTime()
        time1 = time2 = time3 = null
        
        runs ->
            f1 (time) -> time1 = time
            f2 (time) -> time2 = time
            f3 (time) -> time3 = time

        waitsFor (-> time1? and time2? and time3?), 'serial call of f1(), f2() and f3()', 1000
        runs -> 
            expect(time1 - start).toBeGreaterThan 250
            expect(time2 - start).toBeLessThan 150 + 10
            expect(time3 - start).toBeLessThan 350 + 10
        
    it 'should serialize three async functions with Flow', ->
        start = new Date().getTime()
        time1 = time2 = time3 = end = null
        data = sum:0
        
        runs -> 
            Flow.serialize null, data, (defer, local) ->
                defer (next) -> f1 (time) -> time1 = time; local.sum += 1 ; next()
                defer (next) -> f2 (time) -> time2 = time; local.sum += 1 ; next()
                defer (next) -> f3 (time) -> time3 = time; local.sum += 1 ; next()
            
            end = new Date().getTime()
                
        waitsFor (-> time1? and time2? and time3?), 'Flow.serialize()', 1000
        runs -> 
            expect(time1 - start).toBeGreaterThan 250 - 5
            expect(time2 - start).toBeGreaterThan 400 - 5
            expect(time3 - start).toBeGreaterThan 750 - 5
            expect(end - start).toBeLessThan 10
            expect(data.sum).toBe 3

    it "Flow.parallelize and join after completion", ->
        nop_count = 1000000
        time1M = new Date().getTime()
        for [0...nop_count] then 0;
        time1M = new Date().getTime() - time1M
        
        start = new Date().getTime()
        time1 = time2 = time3 = next = end = null
        
        runs -> 
            Flow.parallelize (push, join) ->
                push -> for [0...nop_count] then 0; time1 = new Date().getTime()
                push -> for [0...nop_count] then 0; time2 = new Date().getTime()
                push -> for [0...nop_count] then 0; time3 = new Date().getTime()
                join ->
                    end = new Date().getTime()
            next = new Date().getTime()
            
        waitsFor (-> time1? and time2? and time3?), 'Flow.parallelize()', 1000
        runs ->
            expect(time1M).toBeGreaterThan 2
            expect(end - start).toBeGreaterThan 3 * time1M - 1
            expect(next - start).toBeLessThan 4
