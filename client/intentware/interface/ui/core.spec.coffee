if window?
    Ui = require '../../../../client/intentware/interface/ui/core'
    
    describe 'Intentware.UI', ->
        it 'should be true', ->
            expect(typeof Ui.bindElements).toBe 'function'
