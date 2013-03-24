unless window?
    workflow = require '../server/workflow'
    describe 'System.Workflow', ->
        it 'should say_hello -- à moi in Paris', ->
            expect(workflow.say_hello 'à moi', 'Paris').toEqual('hello à moi in Paris')