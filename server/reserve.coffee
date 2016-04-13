# **Reserve** is a system module which offers services on Chocolate system database  

Sqlite = require 'sqlite3'
Events = require 'events'
{Uuid} = _ = require '../general/chocodash'

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
                    javascript      : '312'
                Move :
                    _               : '32'
                    expression      : '321'
                Eval :
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
                javascript          : '91'

    # spaces collection and accessors
    @spaces : {}
    @ensure : (path, name) -> Space.spaces[path + '/' + name] ? new Space(path, name)
    @get : (path) -> Space.spaces[path]
    
    @request: (query, callback, __) -> __?.space?.request query, callback
    @read: (container_id, options, callback, __) -> __?.space?.read container_id, options, callback
    @write: (object, options, callback, __) -> __?.space?.write object, options, callback
    @forget: (object, name, parent, callback, __) -> __?.space?.forget object, name, parent, callback
    
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
                PRAGMA journal_mode = WAL;
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
            
            get_path_query_statement: (type, relation, callback) =>
                stmt_name = "get_path_query_#{relation}_stmt"
                return callback? @Relation[stmt_name] if@Relation[stmt_name]?
                
                @Relation[stmt_name] = @db.prepare switch type
                    when Space.Relation.Type.scope then 'SELECT container.id, container.intention AS parent_intention, ' + relation + '.path, ' + relation + '.depth, matter.depth AS matter_depth FROM container LEFT JOIN matter ON container.matter = matter.id LEFT JOIN container_parent_scope ON container_parent_scope.container = container.id LEFT JOIN ' + relation + ' ON container_parent_scope.' + relation + '=' + relation + '.id  WHERE container.id = ?' 
                    when Space.Relation.Type.category then 'SELECT container.id, container.intention AS parent_intention, ' + relation + '.path, ' + relation + '.depth, matter.depth AS matter_depth FROM container LEFT JOIN matter ON container.matter = matter.id LEFT JOIN container_parent_category ON container_parent_category.container = container.id LEFT JOIN ' + relation + ' ON container_parent_category.' + relation + '=' + relation + '.id  WHERE container.id = ?' 
                    when Space.Relation.Type.matter then 'SELECT container.id, container.intention AS parent_intention, ' + relation + '.path, ' + relation + '.depth FROM container LEFT JOIN ' + relation + ' ON container.' + relation + '=' + relation + '.id  WHERE container.id = ?'
                , => callback? @Relation[stmt_name]

            get_insert_relation_statement: (relation, callback) =>
                stmt_name = "get_insert_relation_#{relation}_stmt"
                return callback? @Relation[stmt_name] if@Relation[stmt_name]?
                
                @Relation[stmt_name] = @db.prepare 'INSERT INTO ' + relation + ' (container, path, depth) VALUES (?, ?, ?)', => callback? @Relation[stmt_name]

            get_update_container_statement: (callback) =>
                stmt_name = "get_update_container_stmt"
                return callback? @Relation[stmt_name] if@Relation[stmt_name]?
                
                @Relation[stmt_name] = @db.prepare 'UPDATE container SET data = NULL WHERE id = ?', => callback? @Relation[stmt_name]

            # `get` : Return the children relation for the provided parent, and create one if necessary
            get: (type, parent, callback) =>
                # Check if `get` is already running for `parent`. Postpone request if it is. Otherwise put a lock.
                if @Relation.locked
                    setImmediate =>
                        @Relation.get type, parent, callback
                    return
                else
                    @Relation.locked = true
                
                
                # `returns` will delete the lock and call the callback with the result
                returns = (error, data) =>
                    @Relation.locked = false
                    callback? error, data

                parent_id = parent.id
                stmt = null

                # Put Container.is_family to local Scope
                is_family = @Container.is_family
                
                # can look for a `scope`, `matter`, `category` or `association` relation
                relation = switch type 
                    when Space.Relation.Type.scope then 'scope' 
                    when Space.Relation.Type.category then 'category' 
                    when Space.Relation.Type.association then 'association' 
                    when Space.Relation.Type.matter then 'matter'
                            
                _.serialize self:@, (defer, local) ->
                    # Convert `parent_id` to int if it's a uuid
                    unless parent.options?.id_isnt_uuid 
                        defer (next) -> @Intention.get_id parent_id, (error, data) -> parent_id = data ; next()

                    # Check if a children relation already exists for the provided parent container Id for Scope, Category or Matter
                    unless parent.options?.relation_is_new 
                        defer (next) -> @db.get 'SELECT id from ' + relation + ' WHERE container = ?', parent_id, (error, data) ->
                            if error? then return returns error, null
                            
                            # if relation already exists, return it
                            if data? then return returns null, id:data.id
                            
                            # if not check if relation type is Association
                            if type is Space.Relation.Type.association then return
                            
                            # if not, create a new children relation
                            next()
                            
                    # Get the path to that container for this relation type (except for association where there is no path), if exists
                    unless parent.parent?.relation?[relation]?.path?
                        defer (next) -> @Relation.get_path_query_statement type, relation, (o) -> stmt = o ; next()
                        defer (next) -> stmt.get parent_id, (error, data) ->
                            if error? then return returns error, null
                            
                            if not data? then return returns 'relation.get - Non-existent container (id:' + parent_id + ')' 
                            
                            local.data = data
                            next()
                    else
                        defer (next) ->
                            local.data = parent.parent.relation[relation]
                            next()
                    
                    defer (next) ->
                        # Scope and Category Matter relation has to be linked to a max depth-1-matter Document
                        if type in [Space.Relation.Type.scope, Space.Relation.Type.category]
                            unless local.data.matter_depth in [null, 1] and is_family local.data.parent_intention, Space.Container.Family.Document._
                                return returns 'Scope and Category Matter relation has to be linked to a max depth-1-matter Document' 
                        
                        next()
                        
                    # If path to container for relation not empty, append new relation to path, otherwise create a new path
                    defer (next) -> @Relation.get_insert_relation_statement relation, (o) -> stmt = o ; next()
                    defer (next) -> stmt.run [parent_id, local.path = Space.Path.append(local.data.path, parent_id), local.depth = (if local.data.depth then local.data.depth + 1 else 1)], (error) ->
                        if error? then return returns error, null

                        # Clear any existing data
                        local.lastID = @lastID
                        next()
                        
                    unless parent.options?.parent_is_new
                        defer (next) -> @Relation.get_update_container_statement (o) -> stmt = o ; next()
                        defer (next) -> stmt.run [parent_id], (error) -> 
                            if error? then return returns error, null
                            next()
                        
                    defer -> returns null, id:local.lastID, path:local.path, depth: local.depth, matter_depth:local.data.matter_depth, parent_intention:local.data.parent_intention
                            
        #### Intention
        @Intention =
            get_get_id_statement: (callback) =>
                return callback? @Intention.get_id_stmt if @Intention.get_id_stmt?
                
                @Intention.get_id_stmt = 
                    @db.prepare 'SELECT id from container WHERE uuid = ?', => 
                        callback? @Intention.get_id_stmt
                
            get_id: (uuid, callback) =>
                if _.type(uuid) is _.Type.String
                    uuid = Uuid.parse uuid, new Buffer(16)
                
                if Buffer.isBuffer uuid
                    _.serialize self:@, (defer) ->
                        stmt = null
                        defer (next) -> @Intention.get_get_id_statement (o) -> stmt = o ; next()
                        defer -> stmt.get [uuid], (error, data) ->
                            callback? error, data?.id 
                else callback? null, uuid

        #### Container
        @Container =
            get_create_statement: (matter, callback) =>
                if matter?
                    return callback? @Container.create_with_matter_stmt if @Container.create_with_matter_stmt?
                    @Container.create_with_matter_stmt =
                        @db.prepare "INSERT INTO container (uuid, position, intention, matter, name, data) VALUES (?1, (SELECT ifnull(?6, ifnull(MAX(position), 0) + 1) FROM container WHERE matter = ?3), ?2, ?3, ?4, ?5)", => 
                            callback? @Container.create_with_matter_stmt
                else
                    return callback? @Container.create_without_matter_stmt if @Container.create_without_matter_stmt? 
                    @Container.create_without_matter_stmt =
                        @db.prepare "INSERT INTO container (uuid, position, intention, matter, name, data) VALUES (?1, (SELECT ifnull(?6, ifnull(MAX(position), 0) + 1) FROM container LEFT JOIN matter ON matter.container = container.id WHERE matter.depth = 1 OR container.matter IS NULL), ?2, ?3, ?4, ?5)", => 
                            callback? @Container.create_without_matter_stmt
            
            get_modify_statement: (intention, name, data, matter, position, callback) =>
                mask = 0
                mask |= 0x01 if intention isnt undefined
                mask |= 0x02 if name isnt undefined
                mask |= 0x04 if data isnt undefined
                mask |= 0x08 if matter isnt undefined
                mask |= 0x10 if position isnt undefined
                
                stmt_name = "update_#{mask}_stmt"
                
                return callback? @Container[stmt_name] if @Container[stmt_name]?
                
                clause = []
                clause.push 'intention=?2' if intention isnt undefined
                clause.push 'name=?3' if name isnt undefined
                clause.push 'data=?4' if data isnt undefined
                clause.push 'matter=?5' if matter isnt undefined
                clause.push 'position=?6' if position isnt undefined
                
                @Container[stmt_name] =
                    @db.prepare "UPDATE container SET #{clause.join ','} WHERE uuid = ?1", => 
                        callback? @Container[stmt_name]

            
            get_destroy_statement: (uuid, callback) =>
                if uuid?
                    return callback? @Container.destroy_with_uuid_stmt if @Container.destroy_with_uuid_stmt? 
                    @Container.destroy_with_uuid_stmt =
                        @db.prepare "DELETE FROM container WHERE uuid = ?", =>
                            callback? @Container.destroy_with_uuid_stmt
                else
                    return callback? @Container.destroy_without_uuid_stmt if @Container.destroy_without_uuid_stmt? 
                    @Container.destroy_without_uuid_stmt =
                        @db.prepare "DELETE FROM container WHERE id = ?", =>
                            callback? @Container.destroy_without_uuid_stmt
                
            create: (options, callback) =>
                {uuid, name, data, intention, matter, position} = options
        
                if _.type(uuid) is _.Type.String then uuid = Uuid.parse uuid, new Buffer(16)
                
                _.serialize self:@, (defer) ->
                    stmt = null
                    defer (next) -> @Container.get_create_statement matter, (o) -> stmt = o ; next()
                    defer -> stmt.run [uuid ? Uuid({}, new Buffer(16)), intention, matter, name, data, position], (error) -> callback? error, if not error then @lastID else null
            
            modify: (options, callback) =>
                {uuid, name, data, intention, matter, position} = options
                
                return unless uuid?

                if _.type(uuid) is _.Type.String then uuid = Uuid.parse uuid, new Buffer(16)

                _.serialize self:@, (defer) ->
                    stmt = null
                    defer (next) -> @Container.get_modify_statement intention, name, data, matter, position, (o) -> stmt = o ; next()
                    defer -> stmt.run [uuid, intention, name, data, matter, position], (error) -> callback? error
            
                
            destroy: (options, callback) =>
                {id, uuid} = options
                
                if _.type(uuid) is _.Type.String then uuid = Uuid.parse uuid, new Buffer(16)
                
                _.serialize self:@, (defer) ->
                    stmt = null
                    defer (next) -> @Container.get_destroy_statement uuid, (o) -> stmt = o ; next()
                    defer -> stmt.run [id ? uuid], (error) -> callback? error

            is_family: (intention, family) ->
                family is intention.substr 0, family.length
        
        #### Document
        @Document =
            get_insert_statement: (callback) =>
                return callback? @Document.get_insert_stmt if @Document.get_insert_stmt?
                @Document.get_insert_stmt = 
                    @db.prepare "INSERT INTO container_parent_scope (container, scope) VALUES (?, ?)", =>
                        callback? @Document.get_insert_stmt
                
            insert: (options, callback) =>
                {container, scope} = options
        
                _.serialize self:@, (defer) ->
                    stmt = null
                    defer (next) -> @Document.get_insert_statement (o) -> stmt = o ; next()
                    defer -> stmt.run [container, scope], (error) -> callback? error, if not error then @lastID else null

    #### Space services
    
    # `uuid` -  Retrieve uuid value from an object
    uuid: (object, name, parent) ->
        return undefined unless object?
        
        object.uuid ? object._?._?.uuid ? parent?._?[name]?.uuid

    # `stage` - manages transactions on Space operations
    stage: ->
        @onstage ?= false
        that = @
        
        live: -> that.onstage
        start: (callback) -> if that.onstage then process.nextTick(-> callback? "Recursive Space.Stage not allowed") else that.onstage = yes ; that.db.run "BEGIN TRANSACTION", callback
        end: (callback) ->  if that.onstage then that.db.run "COMMIT TRANSACTION;", callback ; that.onstage = no else process.nextTick(-> callback? "There is no Space.Stage to end")
        revert: (callback) ->  if that.onstage then that.db.run "ROLLBACK TRANSACTION;", callback ; that.onstage = no else process.nextTick(-> callback? "There is no Space.Stage to revert")
            

    # `create_data` - Add a new data optionaly linked to another parent (uuid) data
    # Structure relation stored in 'matter' table
    create_data: (item, callback) ->
        {uuid, name, intention, type, data, parent, position} = item
        
        type ?= _.type data
        
        _.serialize self:@, (defer) ->
            unless not parent? or parent.relation?.matter? then defer (next) -> @Relation.get Space.Relation.Type.matter, parent, (error, matter) ->
                if error then callback? error; return
                parent.relation ?= {}
                parent.relation.matter = matter
                next()
                
            defer ->
                intention ?= switch type
                    when _.Type.Boolean then Space.Container.Family.Data.boolean
                    when _.Type.Number then (if data % 1 is 0 then Space.Container.Family.Data.integer else Space.Container.Family.Data.number)
                    when _.Type.Date then Space.Container.Family.Data.date
                    when _.Type.String
                        if Uuid.isUuid data then Space.Container.Family.Data.Binary.Uuid._
                        else Space.Container.Family.Data.string
                    when _.Type.Object
                        if data instanceof Buffer then Space.Container.Family.Data.Binary._
                        else Space.Container.Family.Data._
                    when _.Type.Function then data = data.toString() ; Space.Container.Family.Action.Operation.javascript
                    else Space.Container.Family.Data._
                    
                if @Container.is_family(intention, Space.Container.Family.Data.Binary.Uuid._)
                    data = Uuid.parse data, new Buffer(16)
                    
                @Container.create {uuid, name, data, intention, matter:parent?.relation?.matter?.id, position}, (error, data) ->
                    if error then callback? error; return 
                    
                    callback? null, data, parent?.relation
                
    # `create_object` - Add a new document optionaly linked to another parent (uuid) document or included in parent scope
    # Structure relation stored in 'matter' table and Content relation stored in 'scope' table
    create_object: (item, callback) ->
        {uuid, name, type, parent, contained, position} = item

        _.serialize self:@, (defer, local) ->
            relation_type = if contained then Space.Relation.Type.scope else Space.Relation.Type.matter
            relation_name = if contained then 'scope' else 'matter'
            
            unless not parent? or parent.relation?[relation_name]? then defer (next) -> @Relation.get relation_type, parent, (error, link) ->
                if error then callback? error; return
                
                parent.relation ?= {}
                parent.relation.matter = link unless contained 
                parent.relation.scope = link if contained
                next()
                
            defer (next) ->
                object_type = switch type 
                    when _.Type.Array then Space.Container.Family.Document.array
                    else Space.Container.Family.Document._
                
                @Container.create {uuid, name, intention:object_type, matter:parent?.relation?.matter?.id, position}, (error, id) =>
                    if error? then callback? error; return
                    local.id = id
                    next()
    
            defer (next) ->
                if parent?.relation?.scope?.id?
                    @Document.insert {container:local.id, scope:parent.relation.scope.id}, (error) -> 
                        if error? then callback? error; return
                        next()
                else next()
                        
            defer (next) ->
                callback? null, local.id, parent?.relation


    # `write` - Convert a javascript structure to space structure and write it to the database
    write: (object, options, callback) ->
        if typeof options is 'function' then callback = options; options = {}
        
        options ?= {}
        objects = {}
        error = null
        
        object_id = null
        
        materialize = (current, callback) =>
            {item, name, parent, position} = current
            {uuid, type, intention} = {uuid:@uuid(item, name, parent?.object), type:_.type(item), intention:null}
            
            object_id = uuid unless object_id?
            
            if name is '_' then return callback error, parent?.relation

            if objects[uuid ? item]? and uuid?
                item = uuid ; type = _.type(item)
                intention = Space.Container.Family.Data.Binary.Uuid.reference
                uuid = Uuid()
            
            unless options.not_extended
                if _.isObject item
                    item._ ?= if type is _.Type.Array then [] else {}
                    item._._ ?= {uuid}
                if parent?.object?
                    parent.object._ ?= if _.type(parent.object) is _.Type.Array then [] else {}
                    index = name ? position
                    parent.object._[index] ?= if type is _.Type.Array then [] else {}
                    parent.object._[index].uuid ?= uuid ?= Uuid()

            children_relation_options = id_isnt_uuid:yes, relation_is_new:yes, parent_is_new:yes

            switch type
            
                when _.Type.Object, _.Type.Array
                    objects[uuid ? item] = on
                
                    contained = parent?.object?._?[name]?.inside
                
                    @create_object {uuid, name, type, parent, contained, position}, (err, id, relation) ->
                        if err? then error = err; return callback(err)
                        
                        granparent = {relation}

                        switch type 
                            when _.Type.Object
                                _.serialize (defer, local) ->
                                    for own name, value of item
                                        unless error?
                                            do (name, value) -> 
                                                defer (next) -> materialize {item:value, name:name, parent: parent:granparent, object:item, id:id, relation:local.children_relation, options:children_relation_options}, (err, relation) -> 
                                                    local.children_relation = relation
                                                    next()
                                    
                                    defer -> callback err, relation

                            when _.Type.Array
                                _.serialize (defer, local) ->
                                    for own name, value of item
                                        unless error?
                                            do (name, value) ->
                                                pos = null unless (pos = parseInt name).toString() is name
                                                defer (next) -> materialize {item:value, name: (if pos? then undefined else name), parent:{parent:granparent, object:item, id:id, relation:local.children_relation, options:children_relation_options}, position:pos}, (err, relation) ->
                                                    local.children_relation = relation
                                                    next()

                                    defer -> callback err, relation
                else
                    data = item
                    @create_data {uuid, name, intention, type, data, parent, position}, (err, id, relation) ->
                        if err then error = err
                        callback err, relation
        
        _.serialize self:@, (defer, local) ->
            stage_is_live = @stage().live()
            
            unless stage_is_live then defer (next) -> 
                @stage().start -> next()
                
            defer (next) -> 
                materialize {item:object, parent:(if options.parent? then object:options.parent else null), name:options.name}, -> next()
            
            unless stage_is_live then defer (next) -> 
                @stage()[if error? then 'revert' else 'end'] -> next()
            
            defer -> callback? error, object_id

    # `forget` - Remove a javascript object from database
    forget: (object, name, parent, callback) ->
        if typeof name is 'function' then callback = name; name = parent = null
        uuid = @uuid(object, name, parent)
        @Container.destroy {uuid}, callback if uuid?

    # `read` - Read a space structure in database and convert it back to a javascript object
    read: (container_id, options, callback) ->
        if typeof options is 'function' then callback = options; options = {}
        
        options ?= {}
        
        @look container_id, {scan:yes, depth:options.depth}, (error, data) =>
            
            if not error 
                if not data? then callback? error, null; return 
                
                result = null
                for o, i in data
                    c = undefined
                    uuid = Uuid.unparse(o.uuid)
                    
                    switch o.intention
                        when Space.Container.Family.Document._ then c = {}; c._ = {}; c._._ = {uuid}
                        when Space.Container.Family.Document.array then c = []; c._ = []; c._._ = {uuid}
                        when Space.Container.Family.Data.date then c = new Date o.data
                        when Space.Container.Family.Data.boolean then c = (if o.data then yes else no)
                        when Space.Container.Family.Action.Operation.javascript then c = eval("c = " + o.data)
                        else
                            if @Container.is_family o.intention, Space.Container.Family.Data.Binary.Uuid._
                                c = Uuid.unparse o.data
                                if o.intention is Space.Container.Family.Data.Binary.Uuid.reference then c = @world[c]
                            else 
                                c = o.data
        
                    if i is 0 then result = c
                    
                    @world[uuid] = c
                    
                    if  (parent_id = o.parent_uuid ? o.parent_scope_uuid)? and
                        (parent = @world[Uuid.unparse(parent_id)])? and 
                        _.isObject parent
                        
                            js_ext = {uuid}
                            if o.parent_scope_uuid? then js_ext.inside = yes
                            
                            parent_is_array = _.type(parent) is _.Type.Array
                        
                            unless options.not_extended    
                                __ = parent._ ?= if parent_is_array then [] else {}
                                if o.name? then __[o.name] = js_ext else if parent_is_array then __[o.position] = js_ext

                            if o.name? then parent[o.name] = c else if parent_is_array then parent[o.position] = c
                        
                callback? error, result
                        
            else
                callback? error

    # `scan` return a structure directly from database
    scan: (container_id, options, callback) ->
        if typeof options is 'function' then callback = options; options = undefined
        
        @Intention.get_id container_id, (error, id) =>
            container_id = id
            
            depth_clause = if options?.depth? then ' AND matter.depth <= ' + options.depth else ''

            # get the matter id if exists
            @db.get 'SELECT path FROM matter WHERE container = ?', [container_id], (error, data) =>
                if not error
                    has_matter = data?
                    
                    params = []
                    clauses = []
                    if has_matter
                        params.push data.path
                        params.push Space.Path.next(data.path)
                        clauses.push "(matter.path >= ? AND matter.path < ?#{depth_clause})"
                    unless options?.matter
                        params.push container_id
                        clauses.push "container.id = ?"
                    
                    if clauses.length is 0 
                        callback? error, {}
                    else
                        @db.all "
                            SELECT 
                                container.uuid, 
                                parent_container.uuid as parent_uuid, 
                                container.name, 
                                container.data, 
                                container.position, 
                                container.intention
                            FROM 
                                container 
                                LEFT JOIN matter ON container.matter = matter.id 
                                LEFT JOIN container AS parent_container ON matter.container = parent_container.id 
                             
                            #{if clauses.length > 0 then 'WHERE ' + clauses.join(' OR ') else ''}
                            ORDER BY 
                                matter.path, 
                                container.position", params, (error, data) ->
                                    callback? error, data
                else
                    callback? error

    # `look` return a document content directly from database and optionaly scan its structure
    look: (object_id, options, callback) ->

        if typeof options is 'function' then callback = options; options = undefined
        
        @Intention.get_id object_id, (error, id) =>
            object_id = id
            
            depth_clause = if options?.depth? then ' AND scope.depth <= ' + options.depth else ''

            # get the scope id if exists
            @db.get 'SELECT path FROM scope WHERE container = ?', [object_id], (error, data) =>
                if not error
                    has_scope = data?

                    params = []
                    clauses = []
                    if has_scope
                        params.push data.path
                        params.push Space.Path.next(data.path)
                        clauses.push "(scope.path >= ? AND scope.path < ?#{depth_clause})"
                        
                    params.push object_id
                    clauses.push "container.id = ?"
                        
                    @db.all "
                        SELECT
                            container.id,
                            scope.depth,
                            container.uuid, 
                            parent_container.uuid as parent_scope_uuid, 
                            container.name, 
                            container.data, 
                            container.position, 
                            container.intention
                        FROM 
                            container
                            LEFT JOIN container_parent_scope ON container_parent_scope.container = container.id
                            LEFT JOIN scope ON container_parent_scope.scope = scope.id
                            LEFT JOIN container AS parent_container ON scope.container = parent_container.id 
                        #{if clauses.length > 0 then 'WHERE ' + clauses.join(' OR ') else ''}
                        ORDER BY 
                            scope.path, 
                            container.position", params, (error, scope_data) =>
                                return callback? error, scope_data unless options?.scan is yes and scope_data.length > 0

                                # scan document structure
                                matter_data = []
                                
                                _.serialize self:@, (defer) ->
                                    for o in scope_data
                                        scan_options = {matter:yes}
                                        scan_options.depth = options.depth - (if scope_data.depth? then scope_data.depth - 1 else 0) if options?.depth?
    
                                        unless scan_options.depth? and scan_options.depth <= 0
                                            do (o, scan_options) -> defer (next) -> @scan o.id, scan_options, (error, data) ->
                                                matter_data.push data...
                                                next()
                                    defer ->
                                        for oo in scope_data then delete oo.id ; delete oo.depth
                                        scope_data.push matter_data...
                                        callback? error, scope_data
                                        
                else
                    callback? error

    # `go`: select some objects by path
    request: (query, callback) ->
        for action, path of query
            switch action
                when 'go'
                    steps = path.split '/'
                    levels = steps.length
                    params = []
                    
                    query = ["SELECT container_#{levels-1}.id FROM container AS container_#{levels-1}"]
                    
                    for step, i in steps
                        if i is 0 then continue
                        
                        query.push "
                            LEFT JOIN container_parent_scope AS container_parent_scope_#{i-1} ON container_parent_scope_#{i-1}.container = container_#{i}.id
                            LEFT JOIN scope AS scope_#{i-1} ON container_parent_scope_#{i-1}.scope = scope_#{i-1}.id
                            LEFT JOIN container AS container_#{i-1} ON scope_#{i-1}.container = container_#{i-1}.id
                        "
                    query.push "WHERE"
                    
                    for step, i in steps
                        connector = if i > 0 then 'AND ' else ''
                        if step[0] is "#"
                            query.push "#{connector}container_#{i}.uuid = ?"
                            params.push Uuid.parse step.slice(1), new Buffer(16)
                        else
                            query.push "#{connector}container_#{i}.name = ?"
                            params.push step
                    
                    @db.all query.join(' '), params, (error, data) =>
                        callback null, "Data received:" + (k for k of data).join(', ') + ' - '  + error + ' - ' + query.join ' '
                when 'eval' then
                
        #process.nextTick ->
        #    callback null, {}

exports.Space = Space
