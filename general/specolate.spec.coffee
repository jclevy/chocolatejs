unless window?
    describe 'Specolate', ->
        it 'should allow to test a module', ->
            Path = require 'path'
            expect(Path.extname 'test.coffee').toBe '.coffee'