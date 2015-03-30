unless window?
    Reserve = require '../server/reserve'
    {Uuid} = _ = require '../general/chocodash'

    describe 'Reserve', ->
        describe 'Space', ->
            space = undefined
            
            it 'should create a Space', ->
                expect(space = new Reserve.Space(jasmine.getEnv().__.datadir, 'reserve.spec.db')).not.toBeUndefined()
                expect(space instanceof Reserve.Space).toBeTruthy()
                
            describe 'Path', ->
                it 'should get an index from an int', ->
                    expect(Reserve.Space.Path.Address.from_int(4294967296).toString()).toEqual((new Buffer [0, 0, 1, 0, 0, 0, 0]).toString())
                it 'should get an int from an index', ->
                    expect(Reserve.Space.Path.Address.to_int(new Buffer [0, 0, 1, 0, 0, 0, 0])).toEqual(4294967296)
                it 'should be able to append a buffer address to a path', ->
                    expect(Reserve.Space.Path.append(new Buffer([0, 0, 1, 0, 0, 0, 0]), new Buffer([0, 0, 0, 0, 0, 1, 0])).toString('hex')).toEqual((new Buffer [0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0]).toString('hex'))
                it 'should be able to append an int address to a path', ->
                    expect(Reserve.Space.Path.append(new Buffer([0, 0, 1, 0, 0, 0, 0]), 256).toString('hex')).toEqual((new Buffer [0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0]).toString('hex'))
                it 'should give next address when we provide one', ->
                    expect(Reserve.Space.Path.next(new Buffer [0, 0, 1, 0, 0, 0, 255]).toString('hex')).toEqual((new Buffer [0, 0, 1, 0, 0, 1, 0]).toString('hex'))

            describe 'JS', ->
                
                sub_uuid = Uuid()
                
                Todo = class
                    constructor: (@title, @parent, @dimensions, @uuid = Uuid()) ->
                        @list = [10,11,12,13]
                        @list[6] = 16
                        @list.ext = 'an extension'
                        @subs = [{onemore:123, twomore:345}]
                        @test_data =
                            boolean: yes
                            number: 1.23
                        @test_struct =
                            object:
                                name: 'object in struct'
                                value: 'ok'
                        @test_func = 
                            add: (x,y) -> x+y
                        @date =
                            creation: new Date()
                            modified: new Date()
                            
                dimensions = 
                    Action: "Do"
                    Intention: "Make"
                    Need: "No need"
                    Priority: "Now"
                    Scope: "Me"
                    Share: "No share"
                    Wish: "No wish"

                todo = new Todo 'todo', null, dimensions

                it 'should returns null when reading non-existent container', ->
                    result = undefined
                    runs -> space.read 1, (error, data) -> result = {data}
                    waitsFor (-> result?), 'space.read(1)', 1000
                    runs -> expect(result.data).toBe null

                it 'should save a JS Object', ->
                    result = undefined
                    runs -> space.write todo, (error, uuid) -> result = {error, uuid}
                    waitsFor (-> result?), 'space.write(todo)', 1000
                    runs -> expect(result.error).toBe null
                    runs -> 
                        expect(result.uuid).toBe todo.uuid
                        expect(todo._._.id?).toBe true

                it 'should send an error when saving the same JS Object', ->
                    result = undefined
                    runs -> space.write todo, (error) -> result = {error}
                    waitsFor (-> result?), 'space.write(todo)', 1000
                    runs -> expect(result.error).not.toBe null

                it 'should save a new JS Object', ->
                    result = undefined
                    runs -> 
                        todo = new Todo 'new_todo', null, Action:"Wait", Intention: "Make"
                        todo.test_struct.object.uuid = sub_uuid
                        space.write todo, (error) -> result = {error}
                    waitsFor (-> result?), 'space.write(todo)', 1000
                    runs -> expect(result.error).toBe null

                it 'should have extended JS Object', ->
                    expect(todo._.list.uuid).not.toBe null
                    expect(todo.list._[0].uuid).not.toBe null

                it 'should read a JS Object from database', ->
                    result = undefined
                    runs -> space.read todo.uuid, (error, data) -> result = {data}
                    waitsFor (-> result?), 'space.read(todo.uuid)', 1000
                    runs ->
                        expect(result.data).not.toBe null
                        new_todo = result.data
                        expect(new_todo.title).toBe 'new_todo'
                        expect(new_todo.list[0]).toBe 10
                        expect(new_todo.list[6]).toBe 16
                        expect(new_todo._.list.uuid).toBe todo._.list.uuid
                        expect(new_todo.list._[0].uuid).toBe todo.list._[0].uuid
                        expect(new_todo.list._[6].uuid).toBe todo.list._[6].uuid
                        expect(new_todo.test_data.boolean).toBe yes
                        expect(new_todo.test_struct.object.name).toBe 'object in struct'
                        expect(_.type new_todo.date.creation).toBe '[object Date]'
                        expect(new_todo.date.creation.toString()).toBe todo.date.creation.toString()

                it 'should read first level of a JS Object from database', ->
                    result = undefined
                    runs -> space.read todo.uuid, depth:1, (error, data) -> result = {data}
                    waitsFor (-> result?), 'space.read(todo.uuid, depth:1)', 1000
                    runs ->
                        expect(result.data).not.toBe null
                        new_todo = result.data
                        expect(new_todo.title).toBe 'new_todo'
                        expect(typeof new_todo.test_data).toBe 'object'
                        expect(new_todo.test_data.boolean).toBe undefined
                        expect(new_todo.test_struct.object).toBe undefined

                it 'should read a sub JS Object from database', ->
                    result = undefined
                    runs -> space.read sub_uuid, (error, data) -> result = {data}
                    waitsFor (-> result?), 'space.read(sub_uuid)', 1000
                    runs ->
                        expect(result.data).not.toBe null
                        new_object = result.data
                        expect(new_object.name).toBe 'object in struct'

                it 'should modify a JS Object value in database', ->
                    result = undefined
                    runs -> space.Container.modify uuid:todo.test_data._.number.uuid, data:2.34, (error) -> result = {error}
                    waitsFor (-> result?), 'space.Container.modify uuid:todo.test_data._.number.uuid, data:2.34', 1000
                    runs -> expect(result.error).toBe null
                        
                it 'should modify a JS Object property name in database', ->
                    result = undefined
                    runs -> space.Container.modify uuid:todo._.test_data.uuid, name:'test_value', (error) -> result = {error}
                    waitsFor (-> result?), 'space.Container.modify uuid:todo.test_data._.number.uuid, name:"test_value"', 1000
                    runs -> expect(result.error).toBe null
                        
                it 'should read a modified JS Object from database', ->
                    result = undefined
                    runs -> space.read todo.uuid, (error, data) -> result = {todo:data}
                    waitsFor (-> result?), 'space.read(todo.uuid)', 1000
                    runs -> 
                        expect(result.todo.test_data).toBe undefined
                        expect(result.todo.test_value.number).toBe 2.34

                it 'should destroy an Object from database', ->
                    result = undefined
                    runs -> space.forget todo, (error) -> result = {error}
                    waitsFor (-> result?), 'Reserve.space.forget(todo)', 1000
                    runs -> expect(result.error).toBe null

                it 'should returns null when reading removed container', ->
                    result = undefined
                    runs -> space.read todo.uuid, (error, data) -> result = {data}
                    waitsFor (-> result?), 'space.read(1)', 1000
                    runs -> expect(result.data).toBe null
                
            describe 'end', ->
                it 'should delete Space db file', ->
                    expect(-> require('fs').unlinkSync space.db_path).not.toThrow()
