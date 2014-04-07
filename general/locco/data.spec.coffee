Data = require '../../general/locco/data'

describe 'Data', ->
    it 'should create a Data', ->
        expect(typeof (new Data).uuid).toBe('string');
