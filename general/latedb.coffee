loadedDBs = {}

_defaults = 
    filename: 'db.log'
    datadir: '.'

Log = ->
    Fs = undefined
    BufferStream = undefined
    Path = undefined
    _ = undefined
    
    _exists = no
    _flushed = []
    _loaded = false

    _db = {}
    _ops = []
    _op_index = {}
    _paths = []
    _path_index = {}
    _modules = {}

    _queue = ''

    unless window? then _defaults.datadir = require('chocolate/server/document').datadir
    _datadir = _defaults.datadir
    _filename = _defaults.filename
    _pathname = null
    
    setTimeout (-> flush()), 100

    init = (current = '', options = {}) ->
        {module, var_str} = options
        module ?= off

        if typeof current is 'object' and current._db?
            var_str = """
                var _db = #{stringify current._db, mode:'json'},
                _o = [#{(f.toString() for f in current._ops).join ','}],
                _oi = #{stringify current._op_index, mode:'json'},
                _p = #{stringify current._paths, mode:'json'},
                _pi = #{stringify current._path_index, mode:'json'},
                _m = #{stringify current._modules},
                p, op;
                """
            current = ''
        else
            var_str ?= """
                var _db = {},
                _o = [],
                _oi = {},
                _p = [],
                _pi = {},
                _m = {},
                p, op;
                """
        
        if options.alias
            var_str += """
                _o = _ops;
                _oi = _op_index;
                _p = _paths;
                _pi = _path_index;
                _m = _modules;
            """
            
        if options.rebuild
            var_str += """
                #{if options.alias then '\n' else ''}if (_oi === null) {
                    var i, len;
                    _oi = {};
                    for (i = 0, len = _o.length; i < len; i++) {
                      _oi[_o[i].toString()] = i;
                    }
                    #{if options.alias then """
                    _op_index = _oi;""" else ""}
                };
            """
            
        func_str = """
            var _ = function(oi, pi, data) {
              var i, len, node, op, path, step, steps;
              op = _o[oi];
              path = _p[pi];
              node = _db;
              steps = path.split('.');
              for (i = 0, len = steps.length; i < len; i++) {
                step = steps[i];
                if (node[step] == null) {
                  node[step] = {};
                }
                node = node[step];
              }
              op.call(node, data, _m);
            };
            """
            
        returns = if window?
            """
            #{var_str}
            #{func_str}
            #{current}
            """
        else
            """
            #{var_str}
            #{func_str}
            module.exports = {
            _db:_db,
            _ops:_o,
            _op_index:_oi,
            _paths:_p,
            _path_index:_pi,
            _modules:_m
            };
            """
        
        if module
            returns = """
            (function () {
                #{returns}
                return {_db:_db,_ops:_o,_op_index:_oi,_paths:_p,_path_index:_pi,_modules:_m}
            })()
            """

        returns + '\n'
    
    keyname = (name) ->
        if name? then 'LateDB-' + name
        else 'LateDB-' + filename()
        
    filename = (name) ->
        if name? then _filename = name
        _filename
        
    pathname = (name, path) ->
        _datadir = path if path?
        
        unless name?
            unless _pathname? then _pathname =  _datadir + '/' + _filename
            _pathname
        else
            _datadir + '/' + name
        
    ensure = (path) ->
        node = _db
        steps = path.split '.'
        for step in steps when node?
            unless node[step]? then node[step] = {}
            node = node[step]
        node

    stringify = ->
        return undefined if arguments.length is 0
        
        object = arguments[0]
        options = arguments[1] ? {}
        
        if options.prettify is yes
            tab = '    '
            newline = '\n'
        else
            tab = newline = ''
        
        array_as_object = no
    
        switch options.mode
            when 'json' then return JSON.stringify object, null, tab
            when 'full' then array_as_object = yes
            when 'js' then # default mode
    
        write = if typeof options.write is 'function' then options.write else (str) -> str
        concat = (w1, w2, w3) ->
            if w1? and w2? and w3? then w1 + w2 + w3
            else null
        
        doit = (o, level, index) ->
            level ?= 0
            indent = if tab is '' then '' else (tab for [0...level]).join ''
            ni = newline + indent
            nit = ni + tab
            type = Object.prototype.toString.apply o
            sep = if index > 0 then ',' + nit else ''
            switch type
                when '[object Object]'
                    if o.constructor isnt {}.constructor and o.stringify? and typeof o.stringify is 'function' then write sep + o.stringify()
                    else 
                        if o.constructor isnt {}.constructor and options.strict then throw "_.stringify in strict mode can only accept pure objects"
                        else
                            i = 0 ; concat write(sep + "#{if options.variable and level is 0 then 'var ' else '{'}#{nit}"), "#{(chunk for k,v of o when ((not options.filter? or (v.constructor in options.filter))) and (options.own isnt true or {}.hasOwnProperty.call(o, k)) and (chunk = write((if i++ > 0 then ',' + nit else '') + (if options.variable and level is 0 then k else "'" + k.toString().replace(/\'/g, "\\'") + "'") + (if options.variable and level is 0 then '=' else ':')) + doit(v, level+1))).join('')}", write("#{ni}#{if options.variable and level is 0 then ';' else '}'}")
                when '[object Array]'
                    if array_as_object then i = 0 ; concat write(sep + "function () {#{nit}var a = []; var o = {#{nit}"), "#{(chunk for own k,v of o when (chunk = write((if i++ > 0 then ',' + nit else '') + k + ':') + doit(v, level+1))).join('')}", write("};#{nit}for (var k in o) {a[k] = o[k];} return a; }()") # necessary to serialize both indexes and properties
                    else concat write(sep + "[#{nit}"), "#{(chunk for v, i in o when (chunk = doit(v, level+1, i))?).join ('')}", write("#{ni}]")
                when '[object Boolean]' then write sep + o
                when '[object Number]' then write sep + o
                when '[object Date]' then write sep + "new Date(#{o.valueOf()})"
                when '[object Function]' then write sep + o.toString()
                when '[object Math]' then write sep + 'Math'
                when '[object String]' then write sep + "'#{o.replace /\'/g, '\\\''}'"
                when '[object Undefined]' then write sep + 'void 0'
                when '[object Null]' then write sep + 'null'
                when '[object Buffer]', '[object SlowBuffer]'
                    write sep + (if o.length is 16 then _.Uuid.unparse o else o.toString())
    
        doit(object)
        
    require_db = (name) ->
        Path ?= require 'path'
        required = Path.resolve pathname(name ? _filename)
        delete require.cache[required]                        
        result = require required
        result

    load = (initial_queue) ->
        _queue = ''
        
        initial_queue ?= ''
        
        if window?
            current = localStorage.getItem keyname()
            
            if current? and current isnt ""
                {_db,_ops,_op_index,_paths,_path_index,_modules} = eval init current, module:on
            
            _queue = initial_queue
        else
            Fs ?= require 'fs'
            if Fs.existsSync pathname()
                {_db,_ops,_op_index,_paths,_path_index,_modules} = require_db()
            else
                _queue = init()
                
            _queue += (if _queue isnt '' then '\n' else '') + initial_queue 
        
        _exists = yes
        _loaded = yes
    
    loaded = -> _loaded
    
    io = (path, data, op) ->
        return _db unless typeof path is 'string'
        
        if arguments.length is 3
            updates = {}
            updates[path] = {data, op}
            return update updates
        
        node = _db
        steps = path.split '.'
        for step in steps when node?
            return null unless node[step]? 
            node = node[step]
        node

    write = (op_index, path_index, data) ->
        switch arguments.length
            when 0
                # write timestamp
                _queue += "// #{Date.now().valueOf()}\n"
            when 2
                if typeof path_index is 'string'
                    path = path_index
                    # write path registration
                    _queue += "p='#{path}';\n_pi[p]=_p.push(p)-1;\n"
                else
                    op = path_index
                    # write op registration
                    _queue += "op=#{op.toString().replace /^\/\/.*(\n)*/mg, ''};\n_oi[op.toString()]=_o.push(op)-1;\n"
            else
                # write data update
                _queue += "_(#{op_index},#{path_index},#{JSON.stringify(data)});\n"

    update_one = (path, data, op) ->
        op_hash = op.toString()
        op_index = _op_index[op_hash]
        unless op_index?
            op_index = _op_index[op_hash] = -1 + _ops.push op
            write op_index, op
            
        path_index = _path_index[path]
        unless path_index?
            path_index = _path_index[path] = -1 + _paths.push path
            write op_index, path

        write op_index, path_index, data
        op.call ensure(path), data, _modules

        return
        
    update = ->
        # extract path, data, op from updates
        # save on disk then in mem
        # write update timestamp
        # this = db node at path, then execute op with this and data
        # look for op index then if found write _(op_id, data) in log
        # if not found then calculate hash for op and then add op as ops(op_hash, op) in log then write _(op_id, data) in log
        
        write()
        
        if arguments.length is 2
            if typeof arguments[1] is 'function'
                [updates, op] = arguments
                for path, data of updates then update_one path, data, op
            else
                [data, updates] = arguments
                for path, op of updates then update_one path, data, op
        else
            [updates] = arguments
            for path, {data, op} of updates then update_one path, data, op
        
        return

    flush = ->
        if _queue.length > 0
            unless _exists then load _queue
            if window?
                current = localStorage.getItem keyname()
                localStorage.setItem keyname(), (current ? "") + _queue
                setTimeout (-> (for f in _flushed then f()); return), 10
                setTimeout (-> flush()), 100
            else
                Fs.appendFile pathname(), _queue, ->
                    for f in _flushed then f()
                    setTimeout (-> flush()), 100

            _queue = ""
        else
            setTimeout (-> flush()), 100
        return

    forget = (callback) ->
        _queue = ""
        
        if window?
            localStorage.removeItem keyname()
            _exists = no
            callback?()
        else
            Fs.unlink pathname(), -> 
                _exists = no
                callback?()
        
        return

    clear = (options, callback) ->
        if typeof options is 'function'
            callback = options
            options = null

        _db = {}
        _ops = []
        _op_index = {}
        _paths = []
        _path_index = {}
        _modules = {}
        
        if options?.forget then forget(-> _loaded = no ; callback?())
        else setTimeout (-> _loaded = no ; callback?()), 10
        return

    register = (name, service) ->
        do_register = (n, f, p, m) ->
            unless f?
                m[n] = require name
                _queue += "_m#{if p isnt '' then '["' + s + '"]' for s in p.split('.') else ''}[\"#{n}\"] = require('#{name}');\n"
            else if typeof f is 'function' 
                m[n] = f
                _queue += "_m#{if p isnt '' then '["' + s + '"]' for s in p.split('.') else ''}[\"#{n}\"] = (function (#{name}) { return #{f.toString().replace /^\/\/.*(\n)*/mg, ''}; })(_m[\"#{name}\"])\n"
            else
                m[n] = {}
                _queue += "_m#{if p isnt '' then '["' + s + '"]' for s in p.split('.') else ''}[\"#{n}\"] = {};\n"
                
            if f? then for own k,v of f then do_register k, v, p + (if p is '' then '' else '.') + n, m[n]
       
        write()
        do_register name, service, "", _modules
        _modules[name]
    
    upgrade = (name, service) ->
        current = _modules[name]
        timestamped = no
        
        do_remove = (n, f, p, m) ->
            if m[n]? and not f? 
                delete m[n]
                unless timestamped then write() ; timestamped = yes
                _queue += "delete _m#{if p isnt '' then '["' + s + '"]' for s in p.split('.') else ''}[\"#{n}\"];\n"
    
            if m[n]? and f? then for own k of m[n] then do_remove k, f[k], p + (if p is '' then '' else '.') + n, m[n]
            
        do_append = (n, f, p, m) ->
            unless f? 
                if m[n] isnt req = require name
                    m[n] = req
                    unless timestamped then write() ; timestamped = yes
                    _queue += "_m#{if p isnt '' then '["' + s + '"]' for s in p.split('.') else ''}[\"#{n}\"] = require('#{name}');\n"
            else if typeof f is 'function' 
                if not m[n]? or (m[n].toString().replace(/^\/\/.*(\n)*/mg, '') isnt f.toString().replace(/^\/\/.*(\n)*/mg, ''))
                    m[n] = f
                    unless timestamped then write() ; timestamped = yes
                    _queue += "_m#{if p isnt '' then '["' + s + '"]' for s in p.split('.') else ''}[\"#{n}\"] = (function (#{name}) { return #{f.toString().replace /^\/\/.*(\n)*/mg, ''}; })(_m[\"#{name}\"])\n"
            else
                unless m[n]?
                    m[n] = {}
                    unless timestamped then write() ; timestamped = yes
                    _queue += "_m#{if p isnt '' then '["' + s + '"]' for s in p.split('.') else ''}[\"#{n}\"] = {};\n"
            
            if f? then for own k,v of f then do_append k, v, p + (if p is '' then '' else '.') + n, m[n]
        
        do_remove name, service, "", _modules
        do_append name, service, "", _modules
        
        _modules[name]

    module_ = (name) -> _modules[name]
    
    parse = (context, time_limit, only_after) ->
        only_after ?= no
        context.after ?= no
        
        if context.line[0] is '/' and context.line[1] is '/'
            items = context.line.split ' '
            time = parseInt items[1]
            context.after = yes if time_limit? and time > time_limit
            
        if (not only_after and context.after) or (only_after and not context.after)
            return no
                
        if context.log? 
            context.log += context.line + '\n'
        yes

    revert = (time, callback) ->
        if window?
            context = log: ''
            current = localStorage.getItem keyname()
            lines = current.split '\n'
            for line, i in lines
                context.line = line
                context.index = i
                unless parse context, time then break
            localStorage.setItem keyname(), context.log
            load() ; if callback? then setTimeout callback, 10
        else
            context = {}
            BufferStream ?= require 'bufferstream'
            buffer = new BufferStream size:'flexible', split:'\n'
            i = 0
            bytes = 0
            buffer.on 'data', (chunk) ->
                context.line = chunk.toString()
                context.index = i++
                unless parse context, time
                    readStream.unpipe()
                else
                    bytes += 1 + Buffer.byteLength(context.line, 'utf8')
                    
            buffer.on 'unpipe', ->
                clear ->
                    Fs.truncate pathname(), bytes, ->
                        load() ; callback?()

            readStream = Fs.createReadStream pathname()
            readStream.on 'open', -> readStream.pipe buffer
            
        return

    compact = (time, options, callback) ->
        if typeof options is 'function'
            callback = options
            options = time
            time = null

        if typeof time is 'function'
            callback = time
            options = null
            time = null
            
        if window?
            context = log: ''
            current = localStorage.getItem keyname()
            lines = current.split '\n'
            context.found = no
            only_after = no
            for line, i in lines
                context.line = line
                context.index = i
                unless parse context, time, only_after
                    unless context.found
                        context.found = yes
                        context.log = init eval init(context.log, module:on)
                        only_after = yes
                        parse context, time, only_after
                        
            localStorage.setItem keyname(), context.log
            load() ; if callback? then setTimeout callback, 10
        else
            page_size = options?.page_size ? 128 * 1024
            temp_filename = [(now = new Date()).getFullYear(), (if now.getMonth() + 1 < 10 then '0' else '') + (now.getMonth() + 1), (if now.getDate() < 10 then '0' else '') + now.getDate(), '-', process.pid, '-', (Math.random() * 0x100000000 + 1).toString(36)].join ''

            copy = (context, options, callback) ->
                if typeof options is 'function'
                    callback = options
                    options = null
                options ?= {append: off}
                
                if options.append and not time?
                    setTimeout (-> callback()), 10
                    return

                BufferStream ?= require 'bufferstream'
                buffer = new BufferStream size:'flexible', split:'\n'
                i = 0
                buffer.on 'data', (chunk) ->
                    context.line = chunk.toString()
                    context.index = i++
                    unless parse context, time, options.append
                        unless options.append then readStream.unpipe()
                    else
                        if context.log.length > page_size and context.flushable
                            context.flushable = no
                            Fs.appendFile pathname(temp_filename), context.log.substr(), -> context.flushable = yes
                            context.log = ''
                
                buffer.on 'unpipe', ->
                    wait_io = ->
                        if context.flushable
                            Fs.appendFile pathname(temp_filename), context.log, -> 
                                callback()
                        else setTimeout wait_io, 10
                    wait_io()

                readStream = Fs.createReadStream pathname()
                readStream.on 'open', -> readStream.pipe buffer

            # 1-copy-cut part to be compacted
          
            context = log: '', flushable: yes
            copy context, ->
                # 2-empty current db
                clear ->
                    # 3-reload compacting db
                    compacting_db = require_db temp_filename
                    # 4-stringify it with a JSON stream writer
                    
                    Fs.unlink pathname(temp_filename), ->
                        context = log: '', flushable: yes
                        writer = (chunk, index) ->
                            context.log += (if index > 0 then ',' else '') + chunk ? ''
                            if context.flushable and (context.log.length > page_size or not chunk?)
                                context.flushable = no
                                Fs.appendFile pathname(temp_filename), context.log.substr(), -> context.flushable = yes
                                context.log = ""
                            return
                        
                        compacting_db._op_index = null
                        stringify compacting_db, {write:writer, strict:on, variable:on}
                        
                        wait_io = ->
                            if context.flushable
                                context.log += "#{init '', var_str:'', alias:on, rebuild:on}\n"
                                
                                Fs.appendFile pathname(temp_filename), context.log, ->
                                    context = log: '', flushable: yes
                                    # 5-concatene rest of the log to that file
                                    copy context, append:on, ->
                                    # 6-forget old log, rename file to be current log
                                        Fs.unlink pathname(), ->
                                            Fs.rename pathname(temp_filename), pathname(), ->
                                                # 7-reload log
                                                load() ; callback?()
                            else
                                setTimeout wait_io, 10
                        wait_io()

            
        return

    flushed = (callback) ->
        if _queue.length > 0
            _flushed.push callback
        else
            setTimeout (-> callback?()), 10
    
    {load, loaded, io, write, update, flushed, register, upgrade, module:module_, clear, revert, compact, filename, pathname}

Log.exists = (name, datadir, callback) ->
    if typeof datadir is 'function' then callback = datadir ; datadir = null
    if typeof name in ['function', 'undefined'] then callback = name ; name = _defaults.filename
    unless datadir? then datadir = _defaults.datadir
    
    if window?
        setTimeout (-> callback? localStorage.getItem('LateDB-' + name)?), 10
    else
        Fs = require 'fs'
        Fs.exists datadir + '/' + name, (exists) -> callback? exists
    return

lateDB = (name, path) ->
    name ?= _defaults.filename
    db = loadedDBs[name]
    
    if db? and not db.loaded() then db.load() ; if db.tables.count() > 0 then db.tables.init() 
    return db if db?

    log = Log()
    if name isnt _defaults.filename then log.filename name
    if path? then log.pathname name, path
    log.load()
    
    db = (path, data, op) -> log.io.apply log, arguments

    db.flushed = (callback) -> log.flushed.apply log, arguments
    db.revert = (time, callback) -> log.revert.apply log, arguments
    db.compact = (time, callback) -> log.compact.apply log, arguments
    db.register = (name, service) -> log.register.apply log, arguments
    db.module = (name) -> log.module.apply log, arguments
    db.clear = (options, callback) -> log.clear.apply log, arguments
    db.pathname = (options, callback) -> log.pathname.apply log, arguments
    db.update = (updates) -> log.update.apply log, arguments
    db.filename = (name) -> log.filename.apply log, arguments
    db.load = -> log.load.apply log, arguments
    db.loaded = -> log.loaded.apply log, arguments

    db.world = do ->
        get_world = -> log.module 'World'
                
        select = (query) ->
            return unless (World = get_world())?
            
            {path, uuid} = query
            
            if typeof query is 'string' then uuid = query
            
            if path?
                self = db path
                return unless self?
                
                if uuid? then self[uuid] else self
            else
                World[uuid]
        
        insert = (path, uuid, object) ->
            return unless path? and uuid?
            unless get_world()?
                log.register 'World', {}

            db path, {uuid, object}, (o, {World}) -> 
                self = @[o.uuid] ?= {}
                self[k] = v for k, v of o.object
                World[o.uuid] = self
                return
        
        update = (path, uuid, object) ->
            return unless get_world()? and path? and uuid? and object?

            db path, {uuid, object}, (o, {World}) ->
                self = World[o.uuid]
                self[k] = v for k, v of o.object
                return
        
        delete_ = (path, uuid) ->
            return unless get_world()? and path? and uuid?
            
            db path, {uuid}, (o, {World}) ->
                delete World[o.uuid]
                delete @[o.uuid]
                return
        
        {select, insert, update, delete:delete_}

    db.tables = do ->
        
        Table = table_module =  log.module 'Table'
        
        unless Table?
            Table = ->
                lines: {}
                length: 0
            
            Table.insert = (table, line) ->
                return unless line.id?
                inc = if table.lines[line.id]? then 0 else 1
                table.lines[line.id] = line
                table.length += inc
                Table.notify table, 'insert', line
    
            Table.update = (table, update) ->
                return unless update.id?
                line = table.lines[update.id]
                return unless line?
                for k,v of update when k isnt 'id' then line[k] = v
                Table.notify table, 'update', update
            
            Table.delete = (table, line) ->
                return unless line?.id? or line?
                dec = if table.lines[line.id ? line]? then 1 else 0
                delete table.lines[line.id ? line]
                table.length -= dec
                Table.notify table, 'delete', line
            
            Table.notify = (table, event, line) ->
                if (observers = table.observers?[event])? 
                    for observer in observers
                        observer table, line
            
            Table.observe = (table, event, observer) ->
                table.observers ?= {}
                observers = table.observers[event] ?= []
                observers.push observer
            
            Table.toArray = (table) ->
                arr = []
                for id, line of table.lines then arr.push line
                arr
        
        if table_module? then log.upgrade 'Table', Table
        
        List = ->
            items: {}
            first: null
            last: null            
        
        List.upgrade = (table) ->
            unless table.list?
                table.list = List()
                
                for id, line of table.lines then List.insert table, line
        
                Table.observe table, 'insert', List.insert
                Table.observe table, 'delete', List.delete
            table
        
        List.insert = (table, line) -> 
            list = table.list
            item = list.last ? line: null, previous: null, next: null
            
            unless list.first? 
                item.line = line
                list.first = item
            else
                item.next = item = line:line, previous:item, next:null
                
            list.last = item
            
            list.items[line.id] = item
                
            item
            
        List.delete = (table, line) ->
            list = table.list
            deleted = list.items[line.id]
            delete list.items[line.id]
            {previous, next} = deleted
            previous?.next = next
            next?.previous = previous
            if deleted is list.first then list.first = next
            if deleted is list.last then list.last = previous
            deleted
        
        TransientTable = (table) -> table ? []

        TransientTable.insert = (table, line) ->
            table.push line

        TransientTable.fromTable = (table, filter) ->
            t_table = []
            if table.lines?
                if filter?
                    for id, line of table.lines when filter(line) then t_table.push line
                else
                    for id, line of table.lines then t_table.push line
                    
            else
                if filter?
                    for line in table when filter(line) then t_table.push line
                else
                    t_table = table.slice()
            t_table   

        IndexTable = ->
            table = Table()
            table.list = List()
            table
        
        IndexTable.insert = (table, line) ->
            table.lines[line.id ? table.length] = line
            table.length++
            List.insert table, line
            return
            
        IndexTable.delete = (table, line) ->
            if line.id?
                delete table.lines[line.id]
            else 
                for id, one_line of table.lines then if one_line is line then delete table.lines[id]; break
            table.length--
            
            List.delete table, line
            return

        Iterator = (table) ->
            {
                current: null
                index: 0
                
                has_next: ->
                    if table.lines? 
                        if @current? then @current.next? else table.list.first?
                    else
                        table[@index + 1]
                        
                next: -> 
                    if table.lines?
                        @index++
                        @current = if @current? then @current.next else table.list.first
                        @current?.line
                    else
                        @current = table[@index++]
            }

        Index = {}

        Index.create = (table, fields_only) ->
            unless table.index?
                for id, line of table.lines then Index.create_line_fields_index table, line

            unless fields_only is on
                for id, line of table.lines then Index.create_line_cross_refs table, line

            return

        Index.create_line_fields_index = (table, line) ->
            table.index ?= {}
            table.index.id ?= {}
            for field, value of line
                if field in ['id', 'idx'] or field[-3..] in ['_id', 'Idx'] 
                    if field isnt 'id'
                        table.index[field] ?= {}
                        index_table = table.index[field][value] ?= IndexTable()
                        IndexTable.insert index_table, line
                    else
                        table.index.id[value] = line
            return

        Index.delete_line_fields_index = (table, line) ->
            return unless table.index?
            for field, value of line
                if field in ['id', 'idx'] or field[-3..] in ['_id', 'Idx'] 
                    if field isnt 'id'
                        index_table = table.index[field]?[value]
                        if index_table? then IndexTable.delete index_table, line
                    else
                        delete table.index.id?[value]
            return

        Index.create_line_cross_refs = (table, line) ->
            tables = db 'tables'
            entities = db 'entities'

            for field, value of line
                # create `joins` (1 >> n link) and `ref` (n >> 1 link) fields
                if field[-3..] is '_id'
                    linked_entity_name = field[...-3].toLowerCase()
                    joined_table_name = entities[linked_entity_name]
                    
                    if (joined_table = tables[joined_table_name])?
                        unless joined_table.index? then Index.create joined_table, yes
                        if (joined_line = joined_table.index.id[value])?
                            joined_line_join_table = joined_line[table.name + '_joins'] ?= IndexTable()
                            IndexTable.insert joined_line_join_table, line
    
                            # add index infos in `joins` tables
                            joined_line_join_table.index ?= {}
                            for k, v of line when k in ['id', 'idx'] or k[-3..] in ['_id', 'Idx'] 
                                joined_line_join_table.index[k] ?= {}
                                index_in_joined_table = joined_line_join_table.index[k][v] ?= IndexTable()
                                IndexTable.insert index_in_joined_table, line
    
                            line[joined_table_name + '_ref'] = joined_line
            return

        Index.delete_line_cross_refs = (table, line) ->
            tables = db 'tables'
            entities = db 'entities'

            for field, value of line
                # delete `joins` (1 >> n link) and `ref` (n >> 1 link) fields
                if field[-3..] is '_id'
                    linked_entity_name = field[...-3].toLowerCase()
                    joined_table_name = entities[linked_entity_name]
                    
                    if (joined_table = tables[joined_table_name])?
                        continue unless joined_table.index?
                        joined_line = joined_table.index.id[value]
                        joined_line_join_table = joined_line[table.name + '_joins']
                        if joined_line_join_table then IndexTable.delete joined_line_join_table, line

                        # remove index infos in `joins` tables
                        continue unless joined_line_join_table.index?
                        for k, v of line when k in ['id', 'idx'] or k[-3..] in ['_id', 'Idx'] 
                            continue unless joined_line_join_table.index[k]?
                            index_in_joined_table = joined_line_join_table.index[k][v]
                            if index_in_joined_table then IndexTable.delete index_in_joined_table, line

                        delete line[joined_table_name + '_ref']
            return
    
        Index.insert_line = (table, line) ->
            Index.create_line_fields_index table, line
            Index.create_line_cross_refs table, line
            return

        Index.delete_line = (table, line) ->
            Index.delete_line_fields_index table, line
            Index.delete_line_cross_refs table, line
            return

        History = {}

        History.insert = (table, line) ->

        _query_defs = {}
        _helpers = {}

        extend = (object, values) ->
            set = (o, val) ->
                for own k,v of val
                    o ?= {}
                    if Object.prototype.toString.apply(o[k]) is '[object Object]' and Object.prototype.toString.apply(v) is '[object Object]' then set o[k], v
                    else o[k] = v
                o
               
            set object, values
        
        entity = (name) ->
            name_parts = name.split '_'
            entity_name = []
            for part in name_parts then entity_name.push part[...-1]
            entity_name = entity_name.join '_'
            
        list = ->
            tables = db 'tables'
            return [] unless tables?
            (k for k of tables).sort()
        
        # create a table in lateDB
        # name: 
        #   table name following this protocol `entities_linkedEntities/singularEntity_singularLinkedEntity`
        #   plural form is supposed to be one letter added at the end of singular form
        #   if not, or if plral form is unregular, you must provide the singular entity name
        # 
        # so it can be something like:
        #  `books`
        #  `books_versions`
        #  `categories/category`
        create = (name, options = {}) ->
            if count() is 0 then log.register 'Table', Table
            
            [name, entity_name] = name.split '/'
            
            entity_name ?= entity name

            db 'entities', {entity_name, name}, (o) -> @[o.entity_name] = o.name
            db 'tables', {name}, (o, {Table}) -> @[o.name] = Table()
            
            alias = (part[0].toUpperCase() + part[1..] for part in entity_name.split('_')).join('')  + '_'

            db 'tables', {name, entity_name, alias, options}, (o) -> 
                table = @[o.name]
                table.name = o.name
                table.entity_name = o.entity_name
                table.alias = o.alias
                table.options = o.options
                table.options.history ?= off
                table.options.index ?= on
            
            List.upgrade db("tables.#{name}")
            
            return
        
        exists = (table_name) ->
            db("tables.#{table_name}")?
            
        alter = (name, options = {}) ->
            db 'tables', {name, options}, (o) -> 
                table = @[o.name]
                table.options = o.options
                table.options.history ?= off
                table.options.index ?= on

            return            

        insert = (table_name, line) ->
            table = db("tables.#{table_name}")
            throw "can't insert line into non-existing table '#{table_name}'" unless table? and Object.prototype.toString.call(table) is '[object Object]'
            throw "can't insert a line without an `id` field into table '#{table_name}'" unless line?.id?

            db "tables.#{table_name}", line, (line, {Table}) -> Table.insert @, line
            
            unless table.options.index is off
                Index.insert_line table, line

            unless table.options.history is off
                History.insert table, line
            
            return
        
        update = (table_name, line_update) ->
            table = db("tables.#{table_name}")
            throw "can not update line into non-existing table '#{table_name}'" unless table? and Object.prototype.toString.call(table) is '[object Object]'

            line = table.lines[line_update?.id]
            throw "can't update a non existing line (id:#{line_update?.id}) in #{table_name}'" unless line?
            
            unless table.options.index is off
                Index.delete_line table, line
            
            db "tables.#{table_name}", line_update, (line_update, {Table}) -> Table.update @, line_update

            unless table.index is off
                Index.insert_line table, line
            return

        delete_ = (table_name, line_to_delete) ->
            table = db("tables.#{table_name}")
            throw "can not delete line from non-existing table '#{table_name}'" unless table? and Object.prototype.toString.call(table) is '[object Object]'

            line = table.lines[line_to_delete?.id ? line_to_delete]
            throw "can't update a non existing line (id:#{line_to_delete?.id ? line_to_delete}) in #{table_name}'" unless line?

            db "tables.#{table_name}", {id: line_to_delete?.id ? line_to_delete}, (line, {Table}) -> Table.delete @, line

            unless table.options.index is off
                Index.delete_line table, line
            return

        id = (table_name) ->
            table = db("tables.#{table_name}")
            throw "can not get new id from non-existing table '#{table_name}'" unless table? and Object.prototype.toString.call(table) is '[object Object]'

            id = table.id
            
            unless id?
                id = 0
                for k, line of table.lines
                    if line.id > id then id = line.id
                id += 1

            db "tables.#{table_name}", {id}, ({id}) -> @id = id + 1
            
            id

        get = (table_name, id) ->
            table = db("tables.#{table_name}")
            throw "can not get an item from non-existing table '#{table_name}'" unless table? and Object.prototype.toString.call(table) is '[object Object]'
            
            table.lines[id]
            
        QueryIterator = class
            constructor: (@table) -> 
                if @table?
                    @iterator = Iterator @table
                else
                    @iterator = Iterator []
                    @continue = no
                    
                    
            iterator: null
            filtered: no
            continue: yes
            check: (field_def, table_name) ->
                if table_name? and (index = field_def.indexOf table_name) is 0 
                    if field_def[table_name.length] is '.' then field_def.substr(table_name.length + 1) else null
                else
                    if (index = field_def.indexOf '.') >= 0 then null else field_def
        
            next: (filter, keys, table_name) ->
                next = @iterator.next()
                @continue = no unless @iterator.has_next()
                
                return next if @filtered
                return next unless filter?
                
                if typeof filter is 'function' 
                    return if filter.call({helpers:_helpers}, next, keys, table_name) then next else null
                
                joined_lines = @table
                key_values = {}
                if filter.keys? then for key, i in filter.keys
                    key_values[key] = keys[i]
                
                if filter.clauses? then for clause in filter.clauses
                    filter_field = @check (clause.field ? clause), table_name
                    continue unless filter_field?
        
                    unless clause.field?
                        key_value = key_values[filter_field]
                        if @table.index?
                            joined_lines = @table.index[filter_field + '_id']?[key_value] ? @table.index[filter_field]?[key_value] ? vtable = TransientTable.fromTable @table, (line) -> line[filter_field] is key_value
                        else
                            joined_lines = TransientTable.fromTable @table, (line) -> line[filter_field + '_id'] is key_value or line[filter_field] is key_value
                    else
                        value = clause.value ? if clause.key? then key_values[clause.key] else null
                        continue unless value?
                        
                        clause.oper ?= 'is'
                        
                        new_joined_lines = if clause.oper is 'is' then @table.index?[filter_field]?[value] else null
                        if new_joined_lines? and filter_field is 'id' 
                            new_joined_lines = TransientTable [new_joined_lines]
                        
                        unless new_joined_lines?
                            new_joined_lines = TransientTable.fromTable joined_lines, (line) ->
                                switch clause.oper
                                    when 'is'
                                        line[filter_field] is value
                                    when 'isnt'
                                        line[filter_field] isnt value
                                    else
                                        no
                                        
                        joined_lines = new_joined_lines
                    
                if joined_lines is @table
                    @filtered = yes
                    return next
                
                @table = joined_lines
                @filtered = yes
                @iterator = Iterator @table
                next = @iterator.next()
                @continue = no unless @iterator.has_next()
                return next

        query = (entity_name, keys, query_name) ->
            tables = db 'tables'
            entities = db 'entities'
            
            if typeof entity_name isnt 'string' then query_name = keys ; keys = entity_name ; entity_name = null
            if Object.prototype.toString.apply(keys) isnt '[object Array]' then query_name = keys ; keys = null
            keys ?= [] ; query_name ?= ''
                
            (query_def = query_name)  if query_name? and typeof query_name isnt 'string'
            
            if typeof query_def is 'function' then query_def = filter:query_def
            
            unless entity_name?
                name = query_def?.table ? query_def?.select.split('.')[0] ? ''
                entity_name = entity name
            else 
                if entity_name[0] is entity_name[0].toLowerCase()
                    (query_def ?= {}).table = entity_name
                    entity_name = entity entity_name
                
            query_def ?= _query_defs[entity_name + '_' + keys.length + if query_name isnt '' then '_' + query_name else '']
            entity_table = query_def?.table ? entities[((if char >= 'A' and char <= 'Z' and i > 0 then '_' else '') + char.toLowerCase() for char, i in entity_name).join '']
            module_table = tables[entity_table]
            
            return [] unless module_table? or query_def?
        
            query_def ?= {}
        
            has_query_def_field = -> 
                result = no 
                for k of query_def.fields then result = yes ; break
                result
                
            tableExtend = (line, line_num) -> 
                if line_num is 0
                    remove = (field) -> 
                        if query_def.map?.remove? then ( if field in query_def.map.remove then yes else no )
                        else no
            
                    fields_existing = {} ; for k of line then fields_existing[k] = on
                    
                o = {} ; o[if query_def.map?.rename? and query_def.map?.rename[k]? then query_def.map?.rename[k] else k] = v for k, v of line
                
                if query_def.map?.name?
                    [dst, src] = query_def.map.name.split '-'
                    
                    if query_def.select? then o[entity_table + '.' + 'name'] = line[entity_table + '.' + "name#{dst}"] + (if src? and line[entity_table + '.' + "name#{src}"] isnt null then ' - ' + line[entity_table + '.' + "name#{src}"] else '')
                    else o.name = line["name#{dst}"] + (if src? and line["name#{src}"] isnt null then ' - ' + line["name#{src}"] else '')
                
                if query_def.map?.add? then query_def.map.add.call({helpers:_helpers}, o, line, keys)
        
                if line_num is 0
                    query_def.fields[k] = on for k of o when not Object.prototype.hasOwnProperty.call(fields_existing, k)
                    
                o
        
            tableFilter = (line) ->
                return yes unless has_query_def_field()
                
                hash = "" ; for k,v of line when query_def.fields[k] is on then hash += (if hash isnt "" then ',' else '') + v
                unless result_unique[hash]?
                    result_unique[hash] = on
                    yes
                else
                    no
        
            result_unique = {}
            
            table = do ->
                select_query_def = if typeof query_def.select is 'function' then query_def.select.call({helpers:_helpers}, keys) else (query_def.select ? entity_table)
                result_table = []
                result_table_is_full = no
                path = select_query_def.split '.'
                query_def.fields = {}
                query_def.fields_tables = []
                
        
                [table_name] = path[step = 0].split '('
        
                iterator = new QueryIterator tables[table_name]
                while iterator.continue and not result_table_is_full
                    selected = has_fields:no, values:{}, first_line:on, line_ids:{}
                    do next_step = (iterator, step) ->
                        [table_name, field_infos] = path[step].split '(' ; if step+1 < path.length then [joined_table_name] = path[step+1].split '(' else joined_table_name = undefined
                        field_infos = field_infos[...-1] if field_infos? and field_infos[-1..] is ')'
                        table_name = table_name[1...-1] if table_name[0] is '['
                        table_name_prefix = if query_def.select? then table_name + '.' else ''
                        
                        line = iterator.next query_def.filter, keys, table_name
                        if line?
                            selected.line_ids[table_name] = line.id
                            selected.values[table_name_prefix + k] = line[k] for k of line
                            
                            if field_infos? and selected.first_line
                                selected.has_fields = yes
                                if field_infos is '*' 
                                    query_def.fields[table_name_prefix + k] = on for k of line when (k[-3..] isnt '_id') and (k[-4..] isnt '_ref') and (k[-6..] isnt '_joins')
                                    query_def.fields_tables.push table_name
                                else 
                                    (k = k.trim() ; query_def.fields[table_name_prefix + k] = on) for k in field_infos.split ','
                                    query_def.fields_tables.push table_name
                            
                            if joined_table_name?[0] is '{'
                                step += 1
                                joined_table_name = joined_table_name[1...-1]
                                virtual_line = tables[joined_table_name].index.id[selected.line_ids[joined_table_name]]
                                [joined_table_name] = path[step+1].split '('
                                
                            link_type_is_many = no ; if joined_table_name?[0] is '[' then joined_table_name = joined_table_name[1...-1] ; link_type_is_many = yes
                            
                            if step+1 < path.length
                                if link_type_is_many is no
                                    ref_field_name = joined_table_name + "_ref"
                                    ref_line = (virtual_line ? line)[ref_field_name]
                                    if ref_line?
                                        ref_line_table = TransientTable [ref_line]
                                        next_step new QueryIterator(ref_line_table), step+1 
                                else
                                    unless query_def.joins? and (join = query_def.joins[table_name_prefix + joined_table_name])?
                                        joins_field_name = joined_table_name + "_joins"
                                        joins_lines = (virtual_line ? line)[joins_field_name]
                                    else
                                        joins_lines = TransientTable.fromTable tables[joined_table_name], (joined_line) -> join.call({helpers:_helpers}, line, joined_line)
                                    
                                    if joins_lines?
                                        selected_ = selected
                                        join_iterator = new QueryIterator joins_lines
                                        while join_iterator.continue
                                            selected = has_fields:selected.has_fields, values:extend({}, selected.values), first_line:selected.first_line, line_ids:extend(selected.line_ids)
                                            next_step join_iterator, step+1
                                        selected = selected_
                            else 
                                unless selected.has_fields or not selected.first_line or query_def.select? or query_def.map?.alias
                                    selected.has_fields = yes
                                    query_def.fields[table_name_prefix + k] = on for k,v of line when (k[-3..] isnt '_id') and (k[-4..] isnt '_ref') and (k[-6..] isnt '_joins')
                                    query_def.fields_tables.push table_name
        
                                result_line = tableExtend selected.values, result_table.length
                                result_table.push result_line if tableFilter result_line
                                
                                if query_def.fields_tables.length is 1
                                    if result_table.length >= tables[query_def.fields_tables[0]].length
                                        result_table_is_full = yes
                                        return
                                
                                selected.first_line = off
                            return
                    
                result_table
        
            table ?= Table.toArray(module_table)
            return [] unless table?
            
            tableReduce = (line) ->
                return {} unless has_query_def_field()
                
                o = {} ; o[k] = v for k, v of line when query_def.fields[k] is on
                
                for k, v of o when k.indexOf('.') >= 0
                    keep_field = no
                    [table_name, field_name] = k.split '.'
                    if query_def.map?.alias is on 
                        o[tables[table_name].alias + field_name] = v 
                    else 
                        unless o[field_name]? then o[field_name] = v else keep_field = yes
                    delete o[k] unless keep_field
        
                o
        
            table = table.map tableReduce
            
            tableSort = if query_def.sort? then (line1, line2) ->
                for item, i in query_def.sort
                    if item?.length? and typeof item is 'string' 
                        query_def.sort[i] = {}
                        query_def.sort[i][k = item] = (v = 1)
                        item = query_def.sort[i]

                    for k, v of item
                        if line1[k] > line2[k] 
                            return v
                        else if line1[k] < line2[k] 
                            return -v
                
                return 0
        
            if tableSort? then table.sort tableSort
            
            table

        query.register = (options = {}) ->
            {helpers, query_defs} = options
            
            query_defs = options unless helpers? or query_defs?

            if helpers?
                for k, v of helpers then _helpers[k] = do (v) -> -> v.apply({helpers:_helpers}, arguments)
            
            if query_defs?
                _query_defs[k] = v for k, v of query_defs
            return

        query.exists = (name) -> _query_defs[name]?
        
        count = ->
            tables = db 'tables'
            c = 0
            
            switch arguments.length
                when 0
                    for k of tables then c++
                when 1
                    [name] = arguments
                    table = tables[name]
                    c = table.length
            
            c

        init = (name) ->
            tables = db 'tables'
            
            if name?
                table = tables[name]
                Index.create table
                List.upgrade table
            else
                for name, table of tables then Index.create table
                for name, table of tables then List.upgrade table
                
            return
        
        if count() > 0 then init()
                        
        {init, count, list, exists, create, alter, insert, update, delete:delete_, id, get, query}

    db.cells = do ->
        
        Signal =
            # Constants
            type: 0x0100
            idle: 0x0001
            initialized: 0x0002
            object: 0x0004
            array: 0x0008
            

        Cell = log.module 'Cell'

        unless Cell?
            Cell = ->
                value: null
        
        

    loadedDBs[log.filename()] = db

    db

lateDB.exists = -> Log.exists.apply Log, arguments

_module = window ? module
_module[if _module.exports? then "exports" else "Chocokup"] = lateDB