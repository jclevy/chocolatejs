_ = require '../general/chocodash'

describe 'prototype', ->
    Document = _.prototype()
    DocWithCons = DocWithInst = null
    doc = null
    
    it 'should create a basic Prototype', ->
        expect(Document.use).not.toBe undefined
        expect(new Document instanceof Document).toBeTruthy()

    it 'should create a Prototype with a constructor', ->
        DocWithCons = _.prototype constructor: (@name) ->
        dwc = new DocWithCons "MyDoc"
        expect(dwc.name).toBe "MyDoc"
        
    it 'should create a Prototype with an instance function', ->
        DocWithInst = _.prototype 
            add: (a,b) -> a+b
            sub: (a,b) -> a-b
        dwi = new DocWithInst
        expect(dwi.add 1,1).toBe 2
        
    it 'allows a Prototype to use some functions', ->
        Document.use ->
            @add = (a,b) -> a+b
            @sub = (a,b) -> a-b
    
        doc = new Document
        expect(doc.add 1,1).toBe 2
        expect(doc.sub 1,1).toBe 0
    
    CopiedDocument = null
    cop = null
    
    it 'should create a Prototype by adopting another prototype and using functions', ->
        MoreMath = ->
            @multiply = (a,b) -> a * b
            @divide = (a,b) -> a / b
            
        CopiedDocument = _.prototype adopt:Document, use:MoreMath
        
        cop = new CopiedDocument
        
        expect(cop.add 2,2).toBe 4
        expect(cop.multiply 3,3).toBe 9
        expect(cop.divide 3,3).toBe 1

    InheritedDocument = null
    inh = null
    
    it 'should create a Prototype by inheriting from another prototype', ->
        InheritedDocument = _.prototype inherit:Document, use: -> @sub = (a,b) -> a + ' - ' + b + ' = ' + _.super @, a,b
        
        inh = new InheritedDocument
        expect(inh.add 2,2).toBe 4

    it 'makes an inherited Prototype access its parent functions if superseeded', ->
        expect(inh.sub 2,2).toBe "2 - 2 = 0"

    it 'should create a Prototype by inheriting from another prototype with a constructor', ->
        InheritedDocWithCons = _.prototype inherit:DocWithCons
        idwc = new InheritedDocWithCons "MyDoc"
        expect(idwc.name).toBe "MyDoc"
        
    it 'should create a Prototype by inheriting from another prototype and acccess parent\'s instance function', ->
        InheritedDocWithInst = _.prototype inherit:DocWithInst,
            add: (a,b) -> a + " + " + b + " = " + _.super @, a,b
        
        InheritedDocWithInst.use ->
            @sub = (a,b) -> a + " - " + b + " = " + _.super @, a,b
            
        idwi = new InheritedDocWithInst
        expect(idwi.add 2,3).toBe "2 + 3 = 5"
        expect(idwi.sub 2,2).toBe "2 - 2 = 0"
        
    it 'allows a copied Prototype to be independant from its model', ->
        Document::add = (a,b) -> a + " " + b
        
        expect(doc.add 2,2).toBe "2 2"
        expect(cop.add 2,2).toBe 4
        
    it 'makes an inherited Prototype dependant of its model', ->
        expect(inh.add 2,2).toBe "2 2"

describe 'Data', ->
    describe 'Serialization services', ->
        o = 
            u:undefined
            n:null
            i:1
            f:1.11
            s:'2'
            b:yes
            add:(a,b) -> a+b
            d:new Date("Sat Jan 01 2011 00:00:00 GMT+0100")
        s = ''
        
        it 'should stringify an object', ->
            expect(s = _.stringify o).toBe "{u:void 0,n:null,i:1,f:1.11,s:'2',b:true,add:function (a, b) {\n          return a + b;\n        },d:new Date(1293836400000)}"
        
        it 'should parse a string to an object', ->
            a = _.parse s
            expect(a.u).toBe undefined
            expect(a.n).toBe null
            expect(a.i).toBe 1
            expect(a.f).toBe 1.11
            expect(a.s).toBe '2'
            expect(a.b).toBe yes
            expect(a.add(1,1)).toBe 2
            expect(a.d.valueOf()).toBe new Date("Sat Jan 01 2011 00:00:00 GMT+0100").valueOf()

describe 'Flow', ->
    f1 = (cb) -> setTimeout (-> cb new Date().getTime()), 250
    f2 = (cb) -> setTimeout (-> cb new Date().getTime()), 150
    f3 = (cb) -> setTimeout (-> cb new Date().getTime()), 350
    
    it 'should not serialize three async functions without _.serialize', ->
        start = new Date().getTime()
        time1 = time2 = time3 = null
        
        runs ->
            f1 (time) -> time1 = time
            f2 (time) -> time2 = time
            f3 (time) -> time3 = time

        waitsFor (-> time1? and time2? and time3?), 'serial call of f1(), f2() and f3()', 1000
        runs -> 
            expect(time1 - start).toBeGreaterThan 250 - 10
            expect(time2 - start).toBeLessThan 150 + 10
            expect(time3 - start).toBeLessThan 350 + 10
        
    it 'should serialize three async functions with _.serialize', ->
        start = new Date().getTime()
        time1 = time2 = time3 = end = null
        data = sum:0
        
        runs -> 
            _.serialize null, data, (defer, local) ->
                defer (next) -> f1 (time) -> time1 = time; local.sum += 1 ; next()
                defer (next) -> f2 (time) -> time2 = time; local.sum += 1 ; next()
                defer (next) -> f3 (time) -> time3 = time; local.sum += 1 ; next()
            
            end = new Date().getTime()
                
        waitsFor (-> time1? and time2? and time3?), '_.serialize()', 1000
        runs -> 
            expect(time1 - start).toBeGreaterThan 250 - 5
            expect(time2 - start).toBeGreaterThan 400 - 5
            expect(time3 - start).toBeGreaterThan 750 - 5
            expect(end - start).toBeLessThan 10
            expect(data.sum).toBe 3

    it "_.parallelize and join after completion", ->
        nop_count = 1000000
        time1M = new Date().getTime()
        for [0...nop_count] then 0;
        time1M = new Date().getTime() - time1M
        
        start = new Date().getTime()
        time1 = time2 = time3 = next = end = null
        
        runs -> 
            _.parallelize (push, join) ->
                push -> for [0...nop_count] then 0; time1 = new Date().getTime()
                push -> for [0...nop_count] then 0; time2 = new Date().getTime()
                push -> for [0...nop_count] then 0; time3 = new Date().getTime()
                join ->
                    end = new Date().getTime()
            next = new Date().getTime()
            
        waitsFor (-> time1? and time2? and time3?), '_.parallelize()', 1000
        runs ->
            expect(time1M).toBeGreaterThan 2
            expect(end - start).toBeGreaterThan 3 * time1M - 1
            expect(next - start).toBeLessThan 4

describe 'defaults', ->
    it 'should set default values if not set', ->
        o = _.defaults {}, {first:1}
        expect(o.first).toBe(1)
    it 'should not set default values if already set', ->
        o = _.defaults {first:1}, {first:2}
        expect(o.first).toBe(1)
    it 'should set default values if not set and preserve other values', ->
        o = _.defaults {second:{sub:'sub'}}, {first:2, second:{sub:'newsub'}}
        expect(o.first).toBe(2)
        expect(o.second.sub).toBe('sub')
    it 'should set default values on sub-object if not set and preserve other values', ->
        o = _.defaults {second:{suba:'suba'}}, {first:2, second:subb:'subb'}
        expect(o.first).toBe(2)
        expect(o.second.suba).toBe('suba')
        expect(o.second.subb).toBe('subb')

{Signal, Observer, Publisher} = _

describe 'Signal', ->

  it 'Signal is a Signal', ->
    a = new Signal 1

    expect(a instanceof Signal).toBe true
    
  it 'Single static signal', ->
    a = new Signal 1

    expect(a.value()).toEqual 1
    expect(a.value(2)).toEqual 2
    expect(a.value()).toEqual 2
    expect(a.value(3)).toEqual 3
    expect(a.value()).toEqual 3

  it 'Second static signal', ->
    a = new Signal 1
    b = new Signal 2

    expect(a.value()).toEqual 1
    expect(b.value()).toEqual 2
    expect(a.value()).toEqual 1
    expect(b.value(3)).toEqual 3
    expect(a.value()).toEqual 1
    expect(b.value()).toEqual 3
    expect(a.value()).toEqual 1
    expect(b.value(4)).toEqual 4
    expect(a.value()).toEqual 1
    expect(b.value()).toEqual 4

  it "Signal with simple single dependency", ->
    a = new Signal 1
    b = new Signal -> a.value()
    expect(a.value()).toEqual 1
    expect(b.value()).toEqual 1
    a.value(2)
    expect(a.value()).toEqual 2
    expect(b.value()).toEqual 2
    c = new Signal 3
    expect(a.value()).toEqual 2
    expect(b.value()).toEqual 2

  it "multi dependents", ->
    a = new Signal 1
    b = new Signal -> a.value()
    c = new Signal -> a.value() + 1
    expect(a.value()).toEqual 1
    expect(b.value()).toEqual 1
    expect(c.value()).toEqual 2
    a.value(2)
    expect(a.value()).toEqual 2
    expect(b.value()).toEqual 2
    expect(c.value()).toEqual 3

  it "Breaking dependency", ->
    a = new Signal 1
    b = new Signal -> a.value()
    expect(a.value()).toEqual 1
    expect(b.value()).toEqual 1
    a.value(2)
    expect(a.value()).toEqual 2
    expect(b.value()).toEqual 2
    b.value(3)
    expect(a.value()).toEqual 2
    expect(b.value()).toEqual 3
    a.value(7)
    expect(a.value()).toEqual 7
    expect(b.value()).toEqual 3

  it "Signal with modified single dependency", ->
    a = new Signal 1
    b = new Signal -> a.value() + 10
    expect(a.value()).toEqual 1
    expect(b.value()).toEqual 11
    a.value(2)
    expect(a.value()).toEqual 2
    expect(b.value()).toEqual 12

  it "Signal with simple chain dependency", ->
    a = new Signal 1
    b = new Signal -> a.value()
    c = new Signal -> b.value()
    expect(a.value()).toEqual 1
    expect(b.value()).toEqual 1
    expect(c.value()).toEqual 1
    a.value(2)
    expect(a.value()).toEqual 2
    expect(b.value()).toEqual 2
    expect(c.value()).toEqual 2

  it "Signal with complex chain dependency", ->
    a = new Signal 1
    b = new Signal -> a.value() + 1
    c = new Signal -> b.value() + 1
    expect(a.value()).toEqual 1
    expect(b.value()).toEqual 2
    expect(c.value()).toEqual 3
    a.value(4)
    expect(a.value()).toEqual 4
    expect(b.value()).toEqual 5
    expect(c.value()).toEqual 6

  it "Signal with multiple dependency", ->
    a = new Signal 1
    b = new Signal 2
    c = new Signal -> a.value() + b.value()
    expect(a.value()).toEqual 1
    expect(b.value()).toEqual 2
    expect(c.value()).toEqual 3
    a.value(3)
    expect(a.value()).toEqual 3
    expect(b.value()).toEqual 2
    expect(c.value()).toEqual 5
    b.value(4)
    expect(a.value()).toEqual 3
    expect(b.value()).toEqual 4
    expect(c.value()).toEqual 7

  it "Multipath dependencies", ->
    a = new Signal 1
    b = new Signal -> a.value() + 1
    c = new Signal -> a.value() + b.value()
    expect(a.value()).toEqual 1
    expect(b.value()).toEqual 2
    expect(c.value()).toEqual 3
    a.value(7)
    expect(a.value()).toEqual 7
    expect(b.value()).toEqual 8
    expect(c.value()).toEqual 15
    b.value(3)
    expect(a.value()).toEqual 7
    expect(b.value()).toEqual 3
    expect(c.value()).toEqual 10
    a.value(4)
    expect(a.value()).toEqual 4
    expect(b.value()).toEqual 3
    expect(c.value()).toEqual 7

  it "avoid redundant multipath triggering", ->
    cCount = 0
    a = new Signal 1
    b = new Signal -> a.value() + 1
    c = new Signal -> 
      a.value() + b.value()
      cCount += 1
    a.value(2)
    expect(cCount).toEqual 2

  it "deferred signal with simple single dependency", ->
    a = b = null
    
    runs ->
        a = new Signal 1
        b = new Signal (deferred) -> setTimeout (-> deferred -> 2 * a.value()), 200; deferred

    waitsFor (-> b.idle()), 'define - deferred signal with simple single dependency', 500
    runs ->
        expect(a.value()).toEqual 1
        expect(b.value()).toEqual 2
        
    runs ->
        a.value(2)
        
    waitsFor (-> b.idle()), 'update - deferred signal with simple single dependency', 1000
    
    runs ->
        expect(a.value()).toEqual 2
        expect(b.value()).toEqual 4    

  it "deferred multi dependents", ->
    a = b = c = null
    
    runs ->
        a = new Signal 1
        b = new Signal (deferred) -> setTimeout (-> deferred -> 2 * a.value()), 100; deferred
        c = new Signal (deferred) -> setTimeout (-> deferred -> 1 + b.value()), 300; deferred 

    waitsFor (-> b.idle() and c.idle()), 'define - deferred multi dependents', 500
    runs ->
        expect(a.value()).toEqual 1
        expect(b.value()).toEqual 2
        expect(c.value()).toEqual 3
        
    runs ->
        a.value(2)
    waitsFor (-> b.idle() and c.idle()), 'update - deferred multi dependents', 500
    runs ->
        expect(a.value()).toEqual 2
        expect(b.value()).toEqual 4
        expect(c.value()).toEqual 5
        
describe "Observer", ->
  it "basic observer", ->
    a = new Signal 1
    expect(a.value()).toEqual 1
    b = null
    expect(b).toEqual null
    c = new Observer -> b = a.value()
    expect(b).toEqual 1
    a.value(2)
    expect(b).toEqual 2

  it "multi observer", ->
    a = new Signal 1
    b = new Signal -> a.value()
    c = new Signal -> a.value()
    d = new Signal -> c.value()
    e = 0
    f = new Observer ->
      e += a.value() + b.value() + c.value() + d.value()
    expect(e).toEqual 4
    a.value(2)
    expect(e).toEqual 12

  it "read write observer", ->
    a = new Signal 1
    b = new Signal 2
    expect(a.value()).toEqual 1
    expect(b.value()).toEqual 2
    c = new Observer -> b.value(a.value())
    expect(b.value()).toEqual 1
    a.value(3)
    expect(a.value()).toEqual 3
    expect(b.value()).toEqual 3
    b.value(4)
    expect(a.value()).toEqual 3
    expect(b.value()).toEqual 4

  it "another read write observer", ->
    a = 0
    b = new Signal 1
    c = new Signal 2
    expect(a).toEqual 0
    expect(b.value()).toEqual 1
    expect(c.value()).toEqual 2
    d = new Observer ->
      a += 1
      b.value()
      c.value(3)
    expect(a).toEqual 1
    expect(b.value()).toEqual 1
    expect(c.value()).toEqual 3
    a = 4
    expect(a).toEqual 4
    expect(b.value()).toEqual 1
    expect(c.value()).toEqual 3
    b.value(6)
    expect(a).toEqual 5
    expect(b.value()).toEqual 6
    expect(c.value()).toEqual 3
    c.value(7)
    expect(a).toEqual 5
    expect(b.value()).toEqual 6
    expect(c.value()).toEqual 7

  it "defered multi observer", ->
    a = b = c = d = e = f = null

    runs ->
        a = new Signal 1
        b = new Signal (deferred) -> setTimeout (-> deferred -> a.value()), 100; deferred
        c = new Signal (deferred) -> setTimeout (-> deferred -> a.value()), 100; deferred
        d = new Signal -> c.value()
        e = 0
        f = new Observer ->
            value = a.value() + b.value() + c.value() + d.value()
            e += if a.idle() and b.idle() and c.idle() and d.idle() then value else 0
          
    waitsFor (-> f.ready() ), 'define - deferred multi dependents', 500
    
    runs ->
        expect(e).toEqual 4

    runs ->
        a.value(2)
    waitsFor (-> f.ready()), 'update - deferred multi dependents', 500
    runs ->
        expect(e).toEqual 12

  it "defered read write observer", ->
    a = b = c = d = null

    runs ->
        a = new Signal 1
        b = new Signal (deferred) -> setTimeout (-> deferred -> 2 * a.value()), 100; deferred
        c = new Signal 3
    waitsFor (-> b.idle()), 'define - defered read write observer', 500
    runs ->
        expect(a.value()).toEqual 1
        expect(b.value()).toEqual 2
        expect(c.value()).toEqual 3
        
    runs ->
        d = new Observer -> c.value(b.value())
    waitsFor (-> d.ready()), 'define d - defered read write observer', 500
    runs ->
        expect(c.value()).toEqual 2
        
    runs ->
        a.value(3)
    waitsFor (-> d.ready()), 'update a - defered read write observer', 500
    runs ->
        expect(a.value()).toEqual 3
        expect(b.value()).toEqual 6
        expect(c.value()).toEqual 6

describe "Publisher", ->
  it "Publishs a Signal captured by an Observer", ->
      a = new Publisher()
      b = 0
      a.subscribe (value) -> b = value
      a.notify 123
      expect(b).toEqual 123
        
describe "Signal misc.", ->
  it "object setter", ->
    a = new Signal {}
    b = new Signal -> "Serialized: " + JSON.stringify(a.value())
    expect(b.value()).toEqual "Serialized: {}"
    a.value()["x"] = 1
    expect(JSON.stringify(a.value())).toEqual '{"x":1}'
    expect(b.value()).toEqual "Serialized: {}"
    a.value(a.value())
    expect(JSON.stringify(a.value())).toEqual '{"x":1}'
    expect(b.value()).toEqual 'Serialized: {"x":1}'
    a.set("x", 2)
    expect(JSON.stringify(a.value())).toEqual '{"x":2}'
    expect(b.value()).toEqual 'Serialized: {"x":2}'
    a.value(3)
    expect(a.value()).toEqual 3
    expect(b.value()).toEqual 'Serialized: 3'
    expect(a.set).toEqual undefined

  it "basic array push ", ->
    a = new Signal []
    a.push "x"
    expect(JSON.stringify(a.value())).toEqual '["x"]'

  it "array initialized properly", ->
    a = new Signal []
    a.push("x")
    expect(JSON.stringify(a.value())).toEqual '["x"]'
    a.push("y")
    expect(JSON.stringify(a.value())).toEqual '["x","y"]'
    a.pop()
    expect(JSON.stringify(a.value())).toEqual '["x"]'
    a.pop()
    expect(JSON.stringify(a.value())).toEqual '[]'
    a.unshift("x")
    expect(JSON.stringify(a.value())).toEqual '["x"]'
    a.unshift("y")
    expect(JSON.stringify(a.value())).toEqual '["y","x"]'
    a.unshift("z")
    expect(JSON.stringify(a.value())).toEqual '["z","y","x"]'
    a.sort()
    expect(JSON.stringify(a.value())).toEqual '["x","y","z"]'
    a.reverse()
    expect(JSON.stringify(a.value())).toEqual '["z","y","x"]'
    a.splice(1,1,"w")
    expect(JSON.stringify(a.value())).toEqual '["z","w","x"]'
    a.shift()
    expect(JSON.stringify(a.value())).toEqual '["w","x"]'

  it "array methods", ->
    a = new Signal []
    b = new Signal -> "Serialized: " + JSON.stringify(a.value())
    expect(JSON.stringify(a.value())).toEqual '[]'
    expect(b.value()).toEqual 'Serialized: []'
    a.value()[0] = "x"
    expect(JSON.stringify(a.value())).toEqual '["x"]'
    expect(b.value()).toEqual 'Serialized: []'
    a.value(a.value())
    expect(JSON.stringify(a.value())).toEqual '["x"]'
    expect(b.value()).toEqual 'Serialized: ["x"]'
    a.set(1, "y")
    expect(JSON.stringify(a.value())).toEqual '["x","y"]'
    expect(b.value()).toEqual 'Serialized: ["x","y"]'
    a.push("z")
    expect(JSON.stringify(a.value())).toEqual '["x","y","z"]'
    expect(b.value()).toEqual 'Serialized: ["x","y","z"]'
    a.unshift("w")
    expect(JSON.stringify(a.value())).toEqual '["w","x","y","z"]'
    expect(b.value()).toEqual 'Serialized: ["w","x","y","z"]'
    c = a.shift()
    expect(JSON.stringify(a.value())).toEqual '["x","y","z"]'
    expect(b.value()).toEqual 'Serialized: ["x","y","z"]'
    expect(c).toEqual "w"
    a.reverse()
    expect(JSON.stringify(a.value())).toEqual '["z","y","x"]'
    expect(b.value()).toEqual 'Serialized: ["z","y","x"]'
    d = a.pop()
    expect(JSON.stringify(a.value())).toEqual '["z","y"]'
    expect(b.value()).toEqual 'Serialized: ["z","y"]'
    a.push("foo")
    a.push("bar")
    expect(JSON.stringify(a.value())).toEqual '["z","y","foo","bar"]'
    expect(b.value()).toEqual 'Serialized: ["z","y","foo","bar"]'
    d = a.splice(1,2)
    expect(JSON.stringify(d)).toEqual '["y","foo"]'
    expect(JSON.stringify(a.value())).toEqual '["z","bar"]'
    expect(b.value()).toEqual 'Serialized: ["z","bar"]'
    a.value("pies")
    expect(a.value()).toEqual "pies"
    expect(b.value()).toEqual 'Serialized: "pies"'
    expect(a.pop).toEqual undefined
    expect(a.push).toEqual undefined
    expect(a.shift).toEqual undefined
    expect(a.unshift).toEqual undefined
    expect(a.sort).toEqual undefined
    expect(a.reverse).toEqual undefined
    expect(a.splice).toEqual undefined