Interface = require '../../general/locco/interface'

describe 'Interface', ->
    it 'should create an Interface', ->
        expect((new Interface) instanceof Interface).toBeTruthy()
    it 'should know Interface.Reaction', ->
        expect((new Interface.Reaction) instanceof Interface.Reaction).toBeTruthy()
