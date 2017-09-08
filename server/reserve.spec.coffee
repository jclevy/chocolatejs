unless window?
    lateDB = require '../general/latedb'
    Reserve = require '../server/reserve'
    {Uuid} = _ = require '../general/chocodash'

    describe 'Reserve', ->
        describe 'Space', ->
            space = undefined
            
            it 'should create a Space', ->
                expect(space = new Reserve.Space(jasmine.getEnv().__.datadir, 'reserve.spec.db')).not.toBeUndefined()
                expect(space instanceof Reserve.Space).toBeTruthy()
                
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

                todo = todo_2 = null

                it 'should returns null when reading non-existent container', ->
                    result = space.select '1', 
                    expect(result).toBe undefined

                it 'should save a JS Object', ->
                    todo = new Todo 'todo', null, dimensions
                    space.insert 'todos', todo
                    result = space.select todo.uuid
                    
                    expect(result.uuid?).toBe true
                    expect(result.uuid).toBe todo.uuid

                it 'should save a new JS Object', ->
                    result = undefined
                    todo_2 = new Todo 'new_todo', null, Action:"Wait", Intention: "Make"
                    space.insert 'todos', todo_2

                    result = space.select todo_2.uuid
                    
                    expect(result.uuid?).toBe true
                    expect(result.uuid).toBe todo_2.uuid

                it 'should read a JS Object from database', ->
                    result = undefined
                    new_todo = space.select todo_2.uuid
                    expect(new_todo.title).toBe 'new_todo'
                    expect(new_todo.list[0]).toBe 10
                    expect(new_todo.list[6]).toBe 16
                    expect(new_todo.test_data.boolean).toBe yes
                    expect(new_todo.test_struct.object.name).toBe 'object in struct'
                    expect(new_todo.date.creation.toString()).toBe todo.date.creation.toString()

                it 'should modify a JS Object property in database', ->
                    result = undefined
                    space.update 'todos', uuid:todo.uuid, title:'modified todo'
                    result = space.select todo.uuid
                    expect(result.title).toBe 'modified todo'
                        
                it 'should destroy an Object from database', ->
                    result = undefined
                    space.delete 'todos', todo.uuid
                    result = space.select todo.uuid
                    expect(result).toBe undefined

                it 'finally waits for the db to be flushed', ->
                    flushed = no
                    runs ->
                        space.db.flushed -> flushed = yes
                    waitsFor (-> flushed), 'LateDB to be finaly flushed', 1000
                    runs ->
                        expect(flushed).toBe true
            
                it 'should finally delete the default DB again', ->
                    done = no
                    runs ->
                        space.db.clear forget:on, -> done = yes
                    waitsFor (-> done), 'LateDB to be finally deleted', 1000
                    runs ->
                        expect(space.db()?.constructor).toBe {}.constructor
                    
                it 'should finally not exist anymore', ->
                    done = no
                    exists = undefined
                    lateDB.exists space.name, space.path, (e) -> done = true ; exists = e
            
                    waitsFor (-> done), 'LateDB to tell if it still finally exists', 1000
                    
                    runs ->
                        expect(exists).toBe false
