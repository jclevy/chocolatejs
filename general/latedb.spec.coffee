lateDB = require 'chocolate/general/latedb'

describe 'lateDB', ->
    db = undefined
    times = []

    it 'does not already exist ', ->
        ready = no
        exists = undefined
        lateDB.exists (e) -> ready = yes ; exists = e

        waitsFor (-> ready), 'LateDB to tell if it already exists', 1000
        
        runs ->
            expect(exists).toBe false
            
    it 'should create a default DB', ->
        db = lateDB()
        expect(db).not.toBe undefined
        expect(db.filename()).toBe 'db.log'

    it 'should register some modules', ->
        Text = 
            upper: (t) -> t.toUpperCase()
            lower: (t) -> t.toLowerCase()
            
        registered = db.register 'Text', Text
        
        expect(registered.upper).toBe Text.upper
        expect(registered.lower).toBe Text.lower
        
    it 'should log some modifications', ->
        db.update 'result':
            data:'done'
            op:(data) -> (@debug_log ?= []).push data
        expect(db()?.result.debug_log?.length).toBe 1
        expect(db()?.result.debug_log[0]).toBe 'done'

    it 'should flush the modifications to localStorage or to disk', ->
        flushed = no
        runs ->
            db.flushed -> flushed = yes 
        waitsFor (-> flushed), 'LateDB to be flushed', 1000
        runs ->
            expect(flushed).toBe true
        
    it 'should clear the DB', ->
        cleared = no
        runs ->
            db.clear -> cleared = yes

        waitsFor (-> cleared is yes), "database to be cleared", 500
        
        runs ->
            is_empty = do ->
                for own key of db()? then no
                yes
                
            expect(is_empty).toBe true
        
    it 'should reload the DB in the previous state', ->
        db = lateDB()
        expect(db()?.result.debug_log[0]).toBe 'done'

    it 'should increase the DB size with alternate update notation and using Text module service', ->
        count = 0
        
        update = ->
            count += 1
            db 'result', "done #{count} time#{if count>1 then 's' else ''}", 
                (data, modules) -> (@debug_log ?= []).push modules.Text.lower modules.Text.upper data
            times.push Date.now()
            if count < 5 then setTimeout update, 200
        
        setTimeout update, 200
        
        waitsFor (-> count is 5), "database to have its size increased with count", 2000
        
        runs ->
            expect(db()?.result.debug_log[count]).toBe 'done 5 times'
        
    it 'should flush again the modifications to localStorage or to disk', ->
        flushed = no
        runs ->
            db.flushed -> flushed = yes
        waitsFor (-> flushed), 'LateDB to be flushed again', 1000
        runs ->
            expect(flushed).toBe true
            
    it 'should revert the DB to some point in the past', ->
        done = no
        runs ->
            db.revert times[times.length-2], -> done = yes
        waitsFor (-> done), 'LateDB to be reverted', 2000
        runs ->
            count = db()?.result.debug_log.length - 1
            expect(db()?.result.debug_log[count]).toBe 'done 4 times'

    it 'should compact at some point in the past', ->
        done = no
        runs ->
            db.compact times[times.length-3], page_size:10, (-> done = yes)
        waitsFor (-> done), 'LateDB to be compacted in the past', 2000
        runs ->
            count = db()?.result.debug_log.length - 1
            expect(db()?.result.debug_log[count]).toBe 'done 4 times'
            unless window?
                lines = require('fs').readFileSync(db.pathname(), 'utf8').split '\n'
                expect(lines[0]).toBe "var _db={'result':{'debug_log':['done','done 1 time','done 2 times','done 3 times']}},_ops=[function (data) {"
                expect(lines[lines.length-2]).toBe '_(1,0,"done 4 times");'
                expect(lines[lines.length-1]).toBe ''
            else
                lines = localStorage.getItem('LateDB-' + db.filename()).split '\n'
                expect(lines[0]).toBe 'var _db = {"result":{"debug_log":["done","done 1 time","done 2 times","done 3 times"]}},'
                expect(lines[lines.length-3]).toBe '_(1,0,"done 4 times");'
                expect(lines[lines.length-2]).toBe ''

    it 'should compact now', ->
        done = no
        runs ->
            db.compact page_size:10, (-> done = yes)
        waitsFor (-> done), 'LateDB to be compacted now', 2000
        runs ->
            count = db()?.result.debug_log.length - 1
            expect(db()?.result.debug_log[count]).toBe 'done 4 times'

    it 'should delete the DB', ->
        done = no
        runs ->
            db.clear forget:on, -> done = yes
        waitsFor (-> done), 'LateDB to be deleted', 1000
        runs ->
            expect(db()?.constructor).toBe {}.constructor
        
    it 'should not exist anymore', ->
        done = no
        exists = undefined
        lateDB.exists (e) -> done = true ; exists = e

        waitsFor (-> done), 'LateDB to tell if it still exists', 1000
        
        runs ->
            expect(exists).toBe false

    it 'could update a forgot DB by recreating it', ->
        db.update 'result':
            data:"done again"
            op:(data) -> (@debug_log ?= []).push data
        flushed = no
        runs ->
            db.flushed -> flushed = yes
        waitsFor (-> flushed), 'LateDB to be flushed again', 1000
        runs ->
            expect(flushed).toBe true

    it 'should log some more modifications with alternative syntax', ->
        db.update 
            'result_2': 'done 2'
            'result_3': 'done 3'
            , (data) -> (@debug_log ?= []).push data
        expect(db()?.result_2.debug_log?.length).toBe 1
        expect(db()?.result_2.debug_log[0]).toBe 'done 2'

        expect(db()?.result_3.debug_log?.length).toBe 1
        expect(db()?.result_3.debug_log[0]).toBe 'done 3'
        
    it 'should log some more modifications with a second alternative syntax', ->
        db.update {name:'doe', firstname:'john'},
            'result_4': (data) -> for k, v of data then @[k] = v.toString().toUpperCase()
            'result_5': (data) -> for k, v of data then @[k] = v.toString().substr(0,2)
            
        expect(db()?.result_4.name).toBe 'DOE'
        expect(db()?.result_4.firstname).toBe 'JOHN'

        expect(db()?.result_5.name).toBe 'do'
        expect(db()?.result_5.firstname).toBe 'jo'

    it 'should delete the default DB again', ->
        done = no
        runs ->
            db.clear forget:on, -> done = yes
        waitsFor (-> done), 'LateDB to be deleted again', 1000
        runs ->
            expect(db()?.constructor).toBe {}.constructor
        
    it 'should not exist anymore again', ->
        done = no
        exists = undefined
        lateDB.exists (e) -> done = true ; exists = e

        waitsFor (-> done), 'LateDB to tell if it still exists again', 1000
        
        runs ->
            expect(exists).toBe false

    it 'has no table', ->
        expect(db.tables.count()).toBe 0

    it 'can create a table', ->
        db.tables.create 'categories/category'
        table = db "tables.categories"
        expect(table.entity_name).toBe('category')
        expect(table.alias).toBe('Category_')

        db.tables.create 'colors'
        table = db "tables.colors"
        expect(table.entity_name).toBe('color')
        expect(table.alias).toBe('Color_')

    it 'can insert some lines in a table', ->
        db.tables.insert 'colors', id:1, name:'white'
        db.tables.insert 'colors', id:2, name:'black'
        db.tables.insert 'colors', id:3, name:'red'

        expect(db('tables.colors').lines[1].id).toBe 1
        expect(db('tables.colors').lines[3].name).toBe 'red'
    
    it 'can build an ìd', ->
        id = db.tables.id 'colors'
        db.tables.insert 'colors', id:id, name:'grey'

        expect(id).toBe 4
        expect(db('tables.colors').lines[id].id).toBe 4
        expect(db('tables.colors').lines[id].name).toBe 'grey'
    

    it 'has created primary key indexes', ->
        expect(db('tables.colors').index.id[1].id).toBe 1
        expect(db('tables.colors').index.id[3].name).toBe 'red'
        
    it 'can create other tables', ->
        db.tables.create 'brands'
        table = db "tables.brands"
        expect(table.entity_name).toBe('brand')

    it 'can insert some lines in another table', ->
        db.tables.insert 'brands', id:1, name:'Mercedes'
        db.tables.insert 'brands', id:2, name:'BMW'
        db.tables.insert 'brands', id:3, name:'Toyota'
        db.tables.insert 'brands', id:4, name:'Honda'

        expect(db('tables.brands').lines[2].id).toBe 2
        expect(db('tables.brands').lines[4].name).toBe 'Honda'

    it 'can create last table', ->
        db.tables.create 'cars'
        table = db "tables.cars"
        expect(table.entity_name).toBe('car')

    it 'can insert some lines in last table', ->
        db.tables.insert 'cars', id:1, name:'SLK 200', color_id:1, brand_id:1
        db.tables.insert 'cars', id:2, name:'SL 600', color_id:2, brand_id:1
        db.tables.insert 'cars', id:3, name:'BMW Série 2 Cabriolet', color_id:2, brand_id:2
        db.tables.insert 'cars', id:4, name:'BMW Série 3 Berline', color_id:3, brand_id:2
        db.tables.insert 'cars', id:5, name:'Toyota Prius', color_id:1, brand_id:3
        db.tables.insert 'cars', id:6, name:'Toyota Aygo', color_id:3, brand_id:3
        db.tables.insert 'cars', id:7, name:'Honda Accord', color_id:2, brand_id:4
        db.tables.insert 'cars', id:8, name:'Honda Jazz', color_id:1, brand_id:4

        expect(db('tables.cars').lines[4].id).toBe 4
        expect(db('tables.cars').lines[5].name).toBe 'Toyota Prius'
        expect(db('tables.cars').lines[8].color_id).toBe 1

    it 'can add and use a basic query that retrieve all colors', ->
        db.tables.query.register 'Color_0':{}
        lines = db.tables.query 'Color'
        
        expect(lines.length).toBe 4
        expect(lines[2].name).toBe 'red'
        
    it 'can add and use a simple query that retrieve cars by color_id', ->
        db.tables.query.register 
            'Car_1_byColor': 
                filter: 
                    keys: ['color']
                    clauses: ['color'] 
        lines = db.tables.query 'Car', [1], 'byColor'
        
        expect(lines.length).toBe 3
        expect(lines[1].name).toBe 'Toyota Prius'

    it 'can add and use a simple query that retrieve cars by name', ->
        db.tables.query.register 
            'Car_1_byName': 
                filter: 
                    keys: ['name']
                    clauses: ['name']
        lines = db.tables.query 'Car', ['SL 600'], 'byName'
        
        expect(lines.length).toBe 1
        expect(lines[0].id).toBe 2

    it 'can directly query and retrieve cars by brand_id', ->
        lines = db.tables.query 'Car', [2],
            filter: 
                keys: ['brand']
                clauses: ['brand'] 

        expect(lines.length).toBe 2
        expect(lines[1].name).toBe 'BMW Série 3 Berline'

    it 'can directly query and sort cars', ->
        lines = db.tables.query 'Car', sort: ['name']

        expect(lines.length).toBe 8
        expect(lines[4].name).toBe 'SL 600'

    it 'can try to query (with table\'s name) a non-existing table', ->
        lines = db.tables.query 'bikes'

        expect(lines.length).toBe 0

    it 'can try to query (with table\'s name) an existing but empty table', ->
        db.tables.create 'nulls'
        table = db "tables.nulls"
        expect(table.entity_name).toBe('null')
        
        lines = db.tables.query 'nulls'

        expect(lines.length).toBe 0

    it 'can directly query (with table\'s name) and sort cars in reverse order', ->
        lines = db.tables.query 'cars', sort: ['name':-1]

        expect(lines.length).toBe 8
        expect(lines[4].name).toBe 'Honda Jazz'

    it 'can query and directly filter with a function', ->
        lines = db.tables.query 'cars', (o) -> o.name is 'Honda Jazz'

        expect(lines.length).toBe 1
        expect(lines[0].id).toBe 8

    it 'can query and directly filter with a function, getting line in this', ->
        lines = db.tables.query 'cars', -> @name is 'Honda Jazz'

        expect(lines.length).toBe 1
        expect(lines[0].id).toBe 8

    it 'can directly query and sort cars on multiple fields', ->
        lines = db.tables.query
            select: 'cars(*).brands(name)'
            sort: ['brands.name', 'name':-1]

        expect(lines.length).toBe 8
        expect(lines[4].name).toBe 'SLK 200'

    it 'can query and retrieve cars when brand_id is 2 and color_id isnt 1', ->
        lines = db.tables.query 'Car', [2],
            filter: 
                keys: ['brand']
                clauses:['brand', {field:'color_id', oper:'isnt', value:2}]

        expect(lines.length).toBe 1
        expect(lines[0].name).toBe 'BMW Série 3 Berline'

    it 'can query with function filter and retrieve cars when name does not start by "SL"', ->
        lines = db.tables.query 'Car',
            filter: (line, keys, tableName) -> 
                line.name.indexOf('SL') isnt 0

        expect(lines.length).toBe 6
        expect(lines[0].name).toBe 'BMW Série 2 Cabriolet'

    it 'can query and join tables to get color names used by cars', ->
        lines = db.tables.query
            select: 'cars.brands(*)'
            sort:['name']

        expect(lines.length).toBe 4
        expect(lines[0].name).toBe 'BMW'
        expect(lines[3].name).toBe 'Toyota'

    it 'can query and join tables to get brand names used by cars with a color_id 2', ->
        lines = db.tables.query 'Car',
            select: 'colors.[cars].brands'
            filter:
                clauses: [field:'colors.id', oper:'is', value:2]
            map:
                add: (o, i) ->
                    o.id = i['cars.id']
                    o.name = i['cars.name']
                    o.brand = i['brands.name']

        expect(lines.length).toBe 3
        expect(lines[0].name).toBe 'SL 600'
        expect(lines[2].brand).toBe 'Honda'

    it 'can query and join tables using a straightforward syntax to get brand names used by cars with a color_id 2', ->
        lines = db.tables.query
            select: 'colors.cars.brands'
            fields: ({cars, brands}) ->
                id: cars.id
                name: cars.name
                brand: brands.name
            where: 
                colors: -> @id is 2

        expect(lines.length).toBe 3
        expect(lines[0].name).toBe 'SL 600'
        expect(lines[2].brand).toBe 'Honda'

    it 'can query and join tables using a straightforward syntax to get brand names used by cars with a color_id 2 and brand is Honda', ->
        lines = db.tables.query
            select: 'colors.cars.brands'
            fields: ({cars, brands}) ->
                id: cars.id
                name: cars.name
                brand: brands.name
            params: 
                color: 2,
                brand: 'Honda'
            where: 
                colors: ({color}) -> @id is color
                brands: ({brand}) -> @name is brand

        expect(lines.length).toBe 1
        expect(lines[0].brand).toBe 'Honda'

    it 'should flush the tables\‘ modifications to localStorage or to disk', ->
        flushed = no
        runs ->
            db.flushed -> flushed = yes 
        waitsFor (-> flushed), 'LateDB to be flushed', 1000
        runs ->
            expect(flushed).toBe true
        
    it 'should clear the DB with tables', ->
        cleared = no
        runs ->
            db.clear -> cleared = yes

        waitsFor (-> cleared is yes), "database to be cleared", 500
        
        runs ->
            is_empty = do ->
                for own key of db()? then no
                yes
                
            expect(is_empty).toBe true
        
    it 'should reload the DB with tables in the previous state', ->
        db = lateDB()
        expect(db()?.tables.cars.name).toBe 'cars'
        
    it 'can query again (after reload) and join tables to get color names used by cars', ->
        lines = db.tables.query
            select: 'cars.brands(*)'
            sort:['name']

        expect(lines.length).toBe 4
        expect(lines[0].name).toBe 'BMW'
        expect(lines[3].name).toBe 'Toyota'

    it 'can remove a line from a table', ->
        expect(db('tables.cars').index.brand_id[4].length).toBe 2
        expect(db('tables.brands').lines[4].cars_joins.length).toBe 2
        expect(db('tables.brands').lines[4].cars_joins.index.color_id[2].length).toBe 1

        db.tables.delete 'cars', id:7
        
        expect(db('tables.cars').lines[7]).toBe undefined
        expect(db('tables.cars').index.id[6].name).toBe 'Toyota Aygo'
        expect(db('tables.cars').index.id[7]).toBe undefined
        expect(db('tables.cars').index.brand_id[4].length).toBe 1
        expect(db('tables.cars').length).toBe 7
        
        expect(db('tables.brands').lines[4].cars_joins.length).toBe 1
        expect(db('tables.brands').lines[4].cars_joins.index.color_id[2].length).toBe 0
        expect(db('tables.brands').lines[4].cars_joins.index.color_id[2].list.items[7]).toBeUndefined()

    it 'can update a line in a table', ->
        db.tables.update 'brands', id:3, name:'Toyota Motors'
        expect(db('tables.brands').lines[3].name).toBe 'Toyota Motors'
        
        lines = db.tables.query
            select: 'cars.brands(*)'
            sort:['name']

        expect(lines.length).toBe 4
        expect(lines[3].name).toBe 'Toyota Motors'

    it 'can list tables in LateDB', ->
        expect(db.tables.list()?[1]).toBe("cars")

    it 'can list fields in a Table', ->
        expect(db.tables.list('cars')?[1]).toBe("name")

    it 'can list fields in a Table when upgrading from a Table without fields list', ->
        delete db('tables.cars').fields
        expect(db.tables.list('cars')?[1]).toBe("name")

    it 'can add a field in a Table', ->
        db.tables.alter 'cars', add:'model'
        expect(db.tables.list('cars')?[6]).toBe("model")

    it 'can get field value from a Table', ->
        db.tables.update 'cars', id:5, model:'Prius'
        line = db.tables.get 'cars', 5
        expect(line.model).toBe("Prius")
        
    it 'can drop a field from a Table', ->
        db.tables.alter 'cars', drop:'model'
        expect(db.tables.list('cars')?[6]).toBe undefined
        line = db.tables.get 'cars', 5
        expect(line.model).toBe undefined

    it 'can drop a table', ->
        expect(db('tables.brands')).not.toBeNull()
        db.tables.drop 'brands'
        expect(db('tables.brands')).toBeNull()

    it 'can not update an object in the world space before creating it', ->
        db.world.update 'users', "1ae2c4de", country:'spain'
        expect(db('users')).toBeNull()
        
    it 'can insert an object inside the world space', ->
        db.world.insert 'users', "1ae2c4de", name:'john doe', country:'usa'
        db.world.insert 'users', "eb41aa9f", name:'henri dupont', country:'france'
        expect(db('users')["1ae2c4de"].name).toBe 'john doe'

    it 'can select an object by id from the world space', ->
        user = db.world.select "eb41aa9f"
        expect(user.name).toBe 'henri dupont'
        
    it 'can select all objects at path in the world space', ->
        users = db.world.select path:'users'
        names = (user.name for id, user of users).join(',')
        expect(names).toBe 'john doe,henri dupont'

    it 'can update an object in the world space', ->
        db.world.update 'users', "1ae2c4de", country:'spain'
        user = db.world.select "1ae2c4de"
        expect(user.country).toBe 'spain'
        
    it 'can remove an object from the world space', ->
        db.world.delete 'users', "1ae2c4de"
        user = db.world.select "1ae2c4de"
        expect(user).toBeUndefined()
        users = db.world.select path:'users'
        names = (user.name for id, user of users).join(',')
        expect(names).toBe 'henri dupont'

    it 'should flush the world\‘s modifications to localStorage or to disk', ->
        flushed = no
        runs ->
            db.flushed -> flushed = yes 
        waitsFor (-> flushed), 'LateDB to be flushed', 1000
        runs ->
            expect(flushed).toBe true
        
    it 'should clear the DB with tables and world', ->
        cleared = no
        runs ->
            db.clear -> cleared = yes

        waitsFor (-> cleared is yes), "database to be cleared", 500
        
        runs ->
            is_empty = do ->
                for own key of db()? then no
                yes
                
            expect(is_empty).toBe true

    it 'should reload the DB with tables in the previous state', ->
        db = lateDB()
        expect(db()?.tables.cars.name).toBe 'cars'
        expect(db('users')["1ae2c4de"]).toBe undefined
        expect(db('users')["eb41aa9f"].name).toBe 'henri dupont'

    it 'finally waits for the db to be flushed', ->
        flushed = no
        runs ->
            db.flushed -> flushed = yes
        waitsFor (-> flushed), 'LateDB to be finaly flushed', 1000
        runs ->
            expect(flushed).toBe true

    it 'should finally delete the default DB again', ->
        done = no
        runs ->
            db.clear forget:on, -> done = yes
        waitsFor (-> done), 'LateDB to be finally deleted', 1000
        runs ->
            expect(db()?.constructor).toBe {}.constructor
        
    it 'should finally not exist anymore', ->
        done = no
        exists = undefined
        lateDB.exists (e) -> done = true ; exists = e

        waitsFor (-> done), 'LateDB to tell if it still finally exists', 1000
        
        runs ->
            expect(exists).toBe false

        