Debugate = require '../general/debugate'

describe 'Debugate', ->
    describe 'profile', ->
        it 'should count iterations', ->
            for [1..5]
                Debugate.profile.count 'Test count'
            
            expect(Debugate.profile.spent('Test count').count).toBe 5
            
        f1 = (cb) -> setTimeout (-> cb new Date().getTime()), 250
        
        it 'should calculate time spent (250 ms) with start and end', ->
            Debugate.profile.start 'Test time spent'
            
            time1 = null
            
            runs ->
                f1 (time) ->
                    time1 = time
                    Debugate.profile.end 'Test time spent'
    
            waitsFor (-> time1?), 'call of f1()', 1000
            runs -> 
                expect(Debugate.profile.spent('Test time spent').time).toBeGreaterThan (250 - 5) * 1000
                expect(Debugate.profile.spent('Test time spent').time).toBeLessThan (250 + 5) * 1000

        it 'should calculate time spent (add 250 ms so total is 500 ms) with toggle', ->
            Debugate.profile.toggle 'Test time spent'
            
            time1 = null
            
            runs ->
                f1 (time) ->
                    time1 = time
                    Debugate.profile.toggle 'Test time spent'
    
            waitsFor (-> time1?), 'call of f1()', 1000
            runs -> 
                expect(Debugate.profile.spent('Test time spent').time).toBeGreaterThan (500 - 10) * 1000
                expect(Debugate.profile.spent('Test time spent').time).toBeLessThan (500 + 10) * 1000

        it 'should reset counter', ->
            Debugate.profile.reset 'Test time spent'
            
            expect(Debugate.profile.spent('Test time spent').time).toBe 0

        it 'should calculate time spent with iterative pulse', ->
            Debugate.profile.reset()
            Debugate.profile.pulse 'Test time spent'
            
            time1 = time2 = time3 = null
            
            runs ->
                f1 (time) ->
                    time1 = time
                    Debugate.profile.pulse 'Test time spent'
                    
                    f1 (time) ->
                        time2 = time
                        Debugate.profile.pulse 'Test time spent'
    
                        f1 (time) ->
                            time3 = time
                            Debugate.profile.pulse 'Test time spent', off
    
            waitsFor (-> time1? and time2? and time3?), 'three calls of f1()', 1000
            runs -> 
                expect(Debugate.profile.spent('Test time spent'+ '0').time).toBeGreaterThan (250 - 5) * 1000
                expect(Debugate.profile.spent('Test time spent'+ '0').time).toBeLessThan (250 + 5) * 1000
                expect(Debugate.profile.spent('Test time spent'+ '1').time).toBeGreaterThan (250 - 5) * 1000
                expect(Debugate.profile.spent('Test time spent'+ '1').time).toBeLessThan (250 + 5) * 1000
                expect(Debugate.profile.spent('Test time spent'+ '2').time).toBeGreaterThan (250 - 5) * 1000
                expect(Debugate.profile.spent('Test time spent'+ '2').time).toBeLessThan (250 + 5) * 1000
                expect(Debugate.profile.spent('Test time spent'+ '0').count).toBe 1
                expect(Debugate.profile.spent('Test time spent').total.count).toBe 3
                expect(Debugate.profile.spent('Test time spent').total.time).toBeGreaterThan (750 - 5) * 1000

        it 'should calculate time spent with pulse like toggle', ->
            Debugate.profile.reset()
            Debugate.profile.pulse 'Test time spent', on
            
            time1 = time2 = null
            
            runs ->
                f1 (time) ->
                    time1 = time
                    Debugate.profile.pulse 'Test time spent', off
                    
            waitsFor (-> time1?), 'two calls of f1()', 1000
            runs -> 
                expect(Debugate.profile.spent('Test time spent'+ '0').time).toBeGreaterThan (250 - 5) * 1000
                expect(Debugate.profile.spent('Test time spent'+ '0').time).toBeLessThan (250 + 5) * 1000
                expect(Debugate.profile.spent('Test time spent'+ '1').time).toBe 0
