Data = require '../../general/intentware/data'

describe 'Data', ->
    describe 'Serialization services', ->
        o = 
            u:undefined
            n:null
            i:1
            f:1.11
            s:'2'
            b:yes
            d:new Date("Sat Jan 01 2011 00:00:00 GMT+0100")
        s = ''
        
        it 'should stringify an object', ->
            expect(s = Data.stringify o).toBe "{u:void 0,n:null,i:1,f:1.11,s:'2',b:true,d:new Date(1293836400000)}"
        
        it 'should parse a string to an object', ->
            a = Data.parse s
            expect(a.u).toBe undefined
            expect(a.n).toBe null
            expect(a.i).toBe 1
            expect(a.f).toBe 1.11
            expect(a.s).toBe '2'
            expect(a.b).toBe yes
            expect(a.d.valueOf()).toBe new Date("Sat Jan 01 2011 00:00:00 GMT+0100").valueOf()
