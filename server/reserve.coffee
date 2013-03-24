# **Reserve** is a system module which offers services on Ijax system database

Sqlite = require 'sqlite3'
Events = require 'events'
Data = require '../general/intentware/data'
Uuid = require '../general/intentware/uuid'

#### Path
# **Path** : it's a list of addresses in a buffer
Path =
    # **Address** : it's an int in a 7 bytes buffer
    Address:
        # `from_int` convert an integer to a blob index representation
        from_int: (int) ->
            index = new Buffer(7)
            for i in [0..6]
                index[6 - i] = Math.floor(int / Math.pow(256, i)) % 256
            return index
        
        # `to_int` convert a blob index representation to its numerical value
        to_int: (index, offset) ->
            offset ?= 0
            int = 0
            for i in [0..6]
                int += index[offset + 6 - i] * Math.pow(256, i)
            return int
        
    # `append` append an address (buffer or int) to a path buffer
    append: (path, address) =>
        if not path? 
            Path.Address.from_int(address)
        else
            new_path = new Buffer path.length + 7
            path.copy new_path
            address = Path.Address.from_int(address) unless address instanceof Buffer
            address.copy new_path, path.length
            new_path
        
    # `next` get next path address
    next: (path) =>
        if not path? then return null

        returns = new Buffer(path.length)
        path.copy returns
        
        address = Path.Address.from_int(Path.Address.to_int(path, path.length - 7) + 1)
        address.copy returns, path.length - 7
        returns
                
#### Space
# used in Reserve to store obects with ordered struture and content
class Space
    @Path : Path
    
    @Relation :
            Type:
                matter : 1
                scope : 2
                category : 3
                association : 4
                
    @Container :
        Family :
            Intention :
                _                   : '1'
            Data :
                _                   : '2'
                boolean             : '21'
                integer             : '22'
                number              : '23'
                date                : '24'
                string              : '25'
                Binary :
                    _               : '26'
                    Uuid :
                        _           : '261'
                        reference   : '2611'
                        key         : '2612'
                        lock        : '2613'
                        family      : '2614'
            Action :
                _                   : '3'
                Operation :
                    _               : '31'
                    expression      : '311'
                Move :
                    _               : '32'
                    expression      : '321'
                Test :
                    _               : '33'
                    expression      : '331'
                    'if'            : '332'
                    'switch'        : '333'
                Go :
                    _               : '34'
                    expression      : '341'
                    'call'          : '342'
                    'while'         : '343'
                    'for'           : '344'
            Document :
                _                   : '4'
                array               : '41'
            Flow :
                _                   : '5'
            Interface :
                _                   : '6'
            Actor :
                _                   : '7'
            Reserve :
                _                   : '8'
            Prototype :
                _                   : '9'

    # spaces collection and accessors
    @spaces : {}
    @ensure : (path, name) -> Space.spaces[path + '/' + name] ? new Space(path, name)
    @get : (path) -> Space.spaces[path]
    
    # `constructor` - uses a sqlite database
    constructor: (@path = '.', @name = 'reserve.db') ->
        @db_path = @path + '/' + @name
        Space.spaces[@db_path] = this
        # `max_path_length` is the maximum length for the string containing the node path (50000 is the standard limit in Sqlite) 
        @max_path_length = 50000
        @world = {}
        
        # `db` gives access to the sqlite internal database
        @db = new Sqlite.Database @db_path, =>
            process.on 'exit', =>
                @db.close()
                
            @db.exec """
                PRAGMA foreign_keys = ON;
                
                CREATE TABLE IF NOT EXISTS container (
                    id INTEGER PRIMARY KEY ,
                    uuid BLOB NOT NULL ,
                    intention TEXT NOT NULL,
                    position INTEGER NOT NULL ,
                    matter INTEGER REFERENCES matter(id) ON DELETE CASCADE , -- parent matter
                    name TEXT ,
                    data
                );
                CREATE UNIQUE INDEX IF NOT EXISTS container_uuid on container (uuid);
                CREATE INDEX IF NOT EXISTS container_intention on container (intention);
                CREATE INDEX IF NOT EXISTS container_position on container (position);
                CREATE INDEX IF NOT EXISTS container_matter on container (matter);
                CREATE INDEX IF NOT EXISTS container_name on container (name);
                CREATE INDEX IF NOT EXISTS container_data on container (data);
                
                
                CREATE TABLE IF NOT EXISTS matter ( -- establishes *structure* link between containers
                    id INTEGER PRIMARY KEY ,
                    container INTEGER NOT NULL REFERENCES container(id) ON DELETE CASCADE , -- master container for this matter
                    depth INTEGER NOT NULL ,
                    path BLOB NOT NULL
                );
                CREATE INDEX IF NOT EXISTS matter_container on matter (container);
                CREATE INDEX IF NOT EXISTS matter_depth on matter (depth);
                CREATE INDEX IF NOT EXISTS matter_path on matter (path);


                CREATE TABLE IF NOT EXISTS container_parent_scope ( -- extension for document containers to establish *contains* relationship
                    id INTEGER PRIMARY KEY ,
                    container INTEGER NOT NULL REFERENCES container(id) ON DELETE CASCADE , -- link to extended container
                    scope INTEGER NOT NULL REFERENCES scope(id) ON DELETE CASCADE -- parent scope
                );
                CREATE INDEX IF NOT EXISTS container_parent_scope_container on container_parent_scope (container);
                CREATE INDEX IF NOT EXISTS container_parent_scope_scope on container_parent_scope (scope);
                
                CREATE TABLE IF NOT EXISTS scope ( -- establishes *contains* relationship for containers that are documents
                    id INTEGER PRIMARY KEY ,
                    container INTEGER NOT NULL REFERENCES container(id) ON DELETE CASCADE , -- master container for this scope
                    depth INTEGER NOT NULL ,
                    path BLOB NOT NULL
                );
                CREATE INDEX IF NOT EXISTS scope_container on scope (container);
                CREATE INDEX IF NOT EXISTS scope_depth on scope (depth);
                CREATE INDEX IF NOT EXISTS scope_path on scope (path);
                
                
                CREATE TABLE IF NOT EXISTS container_parent_category ( -- establishes *multi-group* relationship for containers
                    id INTEGER PRIMARY KEY ,
                    container INTEGER NOT NULL REFERENCES container(id) ON DELETE CASCADE , -- link to grouped container
                    category INTEGER NOT NULL REFERENCES category(id) ON DELETE CASCADE -- parent category
                );
                CREATE INDEX IF NOT EXISTS container_parent_category_container on container_parent_category (container);
                CREATE INDEX IF NOT EXISTS container_parent_category_category on container_parent_category (category);
                
                CREATE TABLE IF NOT EXISTS category ( -- establishes *group* relationship for containers
                    id INTEGER PRIMARY KEY ,
                    container INTEGER NOT NULL REFERENCES container(id) ON DELETE CASCADE , -- master container for this category
                    depth INTEGER NOT NULL ,
                    path BLOB NOT NULL
                );
                CREATE INDEX IF NOT EXISTS category_container on category (container);
                CREATE INDEX IF NOT EXISTS category_depth on category (depth);
                CREATE INDEX IF NOT EXISTS category_path on category (path);
                
                
                CREATE TABLE IF NOT EXISTS association ( -- establishes *association* relationship for containers
                    id INTEGER PRIMARY KEY ,
                    container INTEGER NOT NULL REFERENCES container(id) ON DELETE CASCADE , -- source container for this association
                    linked INTEGER NOT NULL REFERENCES container(id) ON DELETE CASCADE -- linked container for this association
                );
                CREATE INDEX IF NOT EXISTS association_container on association (container);
                CREATE INDEX IF NOT EXISTS association_linked on association (linked);                
                """
    
        #### Relation (matter, scope, category, association)
        @Relation =
            locked: false
                
            # `get` : Return the children relation for the provided container_id, and create one if necessary
            get: (type, container_id, callback) =>
                
                # Put Container.is_family to local Scope
                is_family = @Container.is_family
                
                # Check if `get` is already running for `container_id`. Postpone request if it is. Otherwise put a lock.
                if @Relation.locked
                    process.nextTick =>
                        @Relation.get type, container_id, callback
                    return
                else
                    @Relation.locked = true
                
                
                # `returns` will delete the lock and call the callback with the result
                returns = (error, data) =>
                    @Relation.locked = false
                    callback? error, data
                
                # Convert `container_id` to int if it's a uuid
                @Intention.get_id container_id, (error, data) =>
                    container_id = data
                    
                    # can look for a `scope`, `matter`, `category` or `association` relation
                    relation = switch type 
                        when Space.Relation.Type.scope then 'scope' 
                        when Space.Relation.Type.category then 'category' 
                        when Space.Relation.Type.association then 'association' 
                        when Space.Relation.Type.matter then 'matter'
                        
                    sql = ''; param = null
                    db = @db
                    
                    # Else if relation type is Scope, Category or Matter
                    # Check if a children relation already exists for the provided parent container Id
                    db.get 'SELECT id from ' + relation + ' WHERE container = ?', container_id, (error, data) ->
                        if error? then returns error, null; return
                        
                        # if relation already exists, return it
                        if data? then returns null, data.id; return
                        
                        # if not check if relation type is Association
                        if type is Space.Relation.Type.association then return
                        
                        # if not, create a new children relation
                        
                        # Get the path to that container for this relation type (except for association where there is no path), if exists
                        path_query = switch type
                            when Space.Relation.Type.scope then 'SELECT container.id, container.intention, ' + relation + '.path, ' + relation + '.depth, matter.depth AS matter_depth FROM container LEFT JOIN matter ON container.matter = matter.id LEFT JOIN container_parent_scope ON container_parent_scope.container = container.id LEFT JOIN ' + relation + ' ON container_parent_scope.' + relation + '=' + relation + '.id  WHERE container.id = ?' 
                            when Space.Relation.Type.category then 'SELECT container.id, container.intention, ' + relation + '.path, ' + relation + '.depth, matter.depth AS matter_depth FROM container LEFT JOIN matter ON container.matter = matter.id LEFT JOIN container_parent_category ON container_parent_category.container = container.id LEFT JOIN ' + relation + ' ON container_parent_category.' + relation + '=' + relation + '.id  WHERE container.id = ?' 
                            when Space.Relation.Type.matter then 'SELECT container.id, container.intention, ' + relation + '.path, ' + relation + '.depth FROM container LEFT JOIN ' + relation + ' ON container.' + relation + '=' + relation + '.id  WHERE container.id = ?'
                            
                        db.get path_query, container_id, (error, data) ->
                            if error? then returns error, null; return
                            
                            if not data? then returns 'relation.get - Non-existent container (id:' + container_id + ')'; return
                            
                            # Scope and Category Matter relation has to be linked to a depth-1-matter Document
                            if type in [Space.Relation.Type.scope, Space.Relation.Type.category]
                                unless data.matter_depth is 1 and is_family data.intention, Space.Container.Family.Document._
                                    return returns 'Scope and Category Matter relation has to be linked to a depth-1-matter Document'
                                    
                            # If path to container for relation not empty, append new relation to path, otherwise create a new path
                                
                            db.run 'INSERT INTO ' + relation + ' (container, path, depth) VALUES (?, ?, ?)', [container_id, Space.Path.append(data.path, data.id), (if data.depth then data.depth + 1 else 1)], (error) ->
                                if error? then returns error, null; return

                                # Clear any existing data
                                newRelationId = @lastID
                                db.run 'UPDATE container SET data = NULL WHERE id = ?', [container_id], (error) ->
                                    returns error, if error then null else newRelationId
                            
        #### Intention
        @Intention =
            get_id: (uuid, callback) =>
                if Data.type(uuid) is Data.Type.String then uuid = Uuid.parse uuid
                
                if Buffer.isBuffer uuid
                    @db.get 'SELECT id from container WHERE uuid = ?', [uuid], (error, data) =>
                        callback? error, data?.id 
                else
                    process.nextTick ->
                        callback? null, uuid

        #### Container
        @Container =
            create: (options, callback) =>
                {uuid, name, data, intention, matter} = options
                
                @db.run "INSERT INTO container (uuid, position, intention, matter, name, data) VALUES (?1, (SELECT ifnull(MAX(position), 0) + 1 FROM container #{if matter? then 'WHERE matter = ?3' else 'LEFT JOIN matter ON matter.container = container.id WHERE matter.depth = 1 OR container.matter IS NULL'}), ?2, ?3, ?4, ?5)", [uuid ? Uuid('binary'), intention, matter, name, data], (error) ->
                    callback? error, if not error then @lastID else null
            
            destroy: (options, callback) =>
                @db.run "DELETE FROM container WHERE #{if options.uuid? then 'uuid' else 'id'} = ?", [id = options.id ? options.uuid], (error) ->
                    callback? error
 
            is_family: (intention, family) ->
                family is intention.substr 0, family.length
        
        #### Document
        @Document =
            insert: (options, callback) =>
                {container, scope} = options
        
                @db.run "INSERT INTO container_parent_scope (container, scope) VALUES (?, ?)", [container, scope], (error) ->
                    callback? error, if not error then @lastID else null
                    
    #### Space services
    
    # `create_data` - Add a new data optionaly linked to another parent data
    # Structure relation stored in 'matter' table
    create_data: (item, callback) ->
        {uuid, name, type, data, parent} = item
        
        type ?= Data.type data
        
        create_it = (matter) =>
            intention = switch type
                when Data.Type.Boolean then Space.Container.Family.Data.boolean
                when Data.Type.Number then (if data % 1 is 0 then Space.Container.Family.Data.integer else Space.Container.Family.Data.number)
                when Data.Type.Date then Space.Container.Family.Data.date
                when Data.Type.String then Space.Container.Family.Data.string
                when data instanceof Buffer then Space.Container.Family.Data.Binary._
                else Space.Container.Family.Data._
                
            @Container.create {uuid, name, data, intention, matter}, (error, data) ->
                callback? error, data
        
        # check if parent is specified
        if parent?
            # get parent id from container uuids
            @Relation.get Space.Relation.Type.matter, parent, (error, matter) ->
                if error then callback? error; return
                create_it matter
        else create_it()

    # `create_object` - Add a new document optionaly linked to another parent document or included in parent scope
    # Structure relation stored in 'matter' table and Content relation stored in 'scope' table
    create_object: (item, callback) ->
        {uuid, name, type, parent, contained} = item
        
        create_it = (options) =>
            object_type = switch type 
                when Data.Type.Array then Space.Container.Family.Document.array
                else Space.Container.Family.Document._
                        
            @Container.create {uuid, name, intention:object_type, matter:options?.matter}, (error, id) =>
                if error? then callback? error, null; return

                if options?.scope?
                    @Document.insert id, options.scope, (error) ->
                        callback? error, if error then null else id
                else
                    callback? error, if error then null else id

        # check if parent is specified
        if parent?
            relation_type = if contained then Space.Relation.Type.scope else Space.Relation.Type.matter
            
            # get parent id from container uuids
            @Relation.get relation_type, parent, (error, link) ->
                if not error
                    matter = if contained then undefined else link
                    scope = if contained then link else undefined
                    create_it {matter, scope}
                else callback? error
        else create_it()

    # `write` - Convert a javascript object to space structure and write it to the database
    write: (object, callback) ->
        
        objects = []
        count = 0
        error = null
        
        materialize = (current) =>
            unless current.object in objects then objects.push current.object
            else return count

            for own name, property of current.object
                data = switch Data.type property
                    when Data.Type.Array, Data.Type.Object then undefined
                    else property

                count += 1
                
                do =>
                    value = property
                    value_type = Data.type value

                    if value_type is Data.Type.Object and value in objects
                        if value.uuid? then data = value.uuid; value_type = Data.type value
                        
                    create = if value_type in [Data.Type.Object, Data.Type.Array] then @create_object else @create_data
                    
                    create.call @, {name, data, type:value_type, parent:current.parent}, (result, id) ->
                        error = result if result? and error is null
                        if error? then count += -1; return count
                        
                        switch value_type
                            when Data.Type.Array
                                for sub in value 
                                    materialize {object:sub, parent:id}
                            when Data.Type.Object
                                materialize {object:value, parent:id}
                        
                        count += -1

        wait = ->
            process.nextTick =>        
                if count is 0 then callback? error else wait()
                
        @create_object {uuid:@uuid(object), name:''}, (result, id) ->
            error = result if result?
            if error? then callback? error; return
            
            materialize {object, parent:id}
            wait()
            
    # `uuid` -  Retrieve uuid value from an object
    uuid: (object) ->
        switch object.uuid
            when null then object._?.uuid
            else (if Data.type(object.uuid) is Data.Type.String then Uuid.parse object.uuid else object.uuid)

    # `forget` - Remove a javascript object from database
    forget: (object, callback) ->
        uuid = @uuid(object)
        @Container.destroy {uuid}, callback if uuid?
    
    # `read` - Read a space structure in database an convert it back to a javascript object
    read: (container_id, callback) ->
        @Intention.get_id container_id, (error, id) =>
            container_id = id

            # get the matter id if exists
            @db.get 'SELECT path FROM matter WHERE container = ?', [container_id], (error, data) =>
                if not error
                    if data?
                        result = null
                        @db.all 'SELECT container.uuid, parent_container.uuid as parent_uuid, container.name, container.data, container.intention FROM container LEFT JOIN matter ON container.matter = matter.id LEFT JOIN container AS parent_container ON matter.container = parent_container.id WHERE (matter.path >= ? AND matter.path < ?) OR container.id = ?  ORDER BY matter.path, container.position', [data.path, Space.Path.next(data.path), container_id], (error, data) =>
                            if not error
                                result = null
                                for o, i in data
                                    c = undefined
                                    switch o.intention
                                        when Space.Container.Family.Document._ then c = {}; c._ = {id: {}}
                                        when Space.Container.Family.Document.array then c = []; c._ = {id: {}}
                                        when Space.Container.Family.Data.date then c = new Date o.data
                                        when Space.Container.Family.Data.boolean then c = (if o.data then yes else no)
                                        else c = o.data
                                        
                                    if i is 0 then result = c
                                    
                                    uuid = Uuid.unparse(o.uuid)
                                    @world[uuid] = c
                                    
                                    if o.parent_uuid?
                                        parent = @world[Uuid.unparse(o.parent_uuid)]
                                        switch Data.type parent
                                            when Data.Type.Object then parent[o.name] = c
                                            when Data.Type.Array then parent.push c
                                        parent?._?.id[o.name] = uuid
                                        
                                callback? error, result
                                        
                            else
                                callback? error
                    else 
                        callback? error, null
                else
                    callback? error

    scan: (container_id, callback) ->
        @Intention.get_id container_id, (error, id) =>
            container_id = id
            
            # get the matter id if exists
            @db.get 'SELECT path FROM matter WHERE container = ?', [container_id], (error, data) =>
                if not error
                    result = null
                    @db.all 'SELECT container.uuid, parent_container.uuid as parent_uuid, container.name, container.data, container.intention FROM container LEFT JOIN matter ON container.matter = matter.id LEFT JOIN container AS parent_container ON matter.container = parent_container.id WHERE (matter.path >= ? AND matter.path < ?) OR container.id = ?  ORDER BY matter.path, container.position', [data.path, Space.Path.next(data.path), container_id], (error, data) =>
                        if not error
                            result = null
                            for o, i in data
                                if i is 0 then result = o
                                o.uuid = Uuid.unparse(o.uuid)
                                @world[o.uuid] = o
                                if not o.data?
                                    delete o.data
                                if o.parent_uuid?
                                    parent = @world[Uuid.unparse(o.parent_uuid)]
                                    (parent.matter ?= []).push o
                                delete o.parent_uuid
                                
                            result = '<script> o = ' + JSON.stringify(result, null, 4) + '</script>'
                                    
                            callback? error, result
                        else
                            callback? error
                else
                    callback? error
                
    # `get_root_matters` - Return an array of all root matters
    get_root_matters: (callback) ->
        @db.all 'SELECT container.id, hex(container.uuid) FROM container INNER JOIN matter ON matter.container = container.id WHERE matter.depth = 1', (error, data) ->
            callback? error, data        

    # `get_root_scopes` - Return an array of all root scopes
    get_root_scopes: (callback) ->
        @db.all 'SELECT container.id, hex(container.uuid) FROM container INNER JOIN matter ON matter.container = container.id INNER JOIN scope ON matter.scope = scope.id WHERE matter.depth = 1', (error, data) ->
            callback? error, data
    
exports.Space = Space

exports.test_scan = (container_id, __) ->
    event = new Events.EventEmitter
    space = Space.ensure __.datadir, 'test.db'
    space.scan container_id ? 1, (error, data) ->
        event.emit 'end', if data? then data else error
    event
        
exports.test_read = (container_id, __) ->
    event = new Events.EventEmitter
    space = Space.ensure __.datadir, 'test.db'
    space.read container_id ? 1, (error, data) ->
        event.emit 'end', if data? then data else error
    event
        