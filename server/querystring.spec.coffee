unless window?
    QueryString = require '../../server/querystring'
    
    describe 'QueryString', ->
        it 'should decode a querystring in an array', ->
            sqarr = QueryString.parse "a=test&b=3&c=1", null, null, ordered:yes
            expect(sqarr.list[0].key + ':' + sqarr.list[0].value).toBe('a:test')
            expect(sqarr.list[1].key + ':' + sqarr.list[1].value).toBe('b:3')
            expect(sqarr.dict.a).toBe('test')
            