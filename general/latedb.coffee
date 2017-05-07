lateDB = do ->

    _filename = 'db.log'
    _exists = no
    _loading = no
    _ready = []
    _flushed = []

    _db = {}
    _ops = []
    _op_index = {}
    _paths = []
    _path_index = {}

    log = do ->
        Fs = undefined
        BufferStream = undefined
        Path = undefined
        _ = undefined
        
        _queue = ''
        _pathname = null
        _datadir = null
        
        setTimeout (-> flush()), 100

        init = (current = '', options = {}) ->
            {module, var_str} = options
            module ?= off

            if typeof current is 'object' and current._db?
                var_str = """
                    var _db = #{JSON.stringify current._db},
                    _o = [#{(f.toString() for f in current._ops).join ','}],
                    _oi = #{JSON.stringify current._op_index},
                    _p = #{JSON.stringify current._paths},
                    _pi = #{JSON.stringify current._path_index},
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
                    p, op;
                    """
            
            if options.alias
                var_str += """
                    _o = _ops;
                    _oi = _op_index;
                    _p = _paths;
                    _pi = _path_index;
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
                  op.call(node, data);
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
                _path_index:_pi
                };
                """
            
            if module
                returns = """
                (function () {
                    #{returns}
                    return {_db:_db,_ops:_o,_op_index:_oi,_paths:_p,_path_index:_pi}
                })()
                """

            returns + '\n'
        
        pathname = (filename) ->
            _datadir ?= require('chocolate/server/document').datadir
            
            unless filename?
                unless _pathname? then _pathname =  _datadir + '/' + _filename
                _pathname
            else
                _datadir + '/' + filename
            
        require_db = (filename) ->
            Path ?= require 'path'
            required = Path.resolve pathname(filename ? _filename)
            delete require.cache[required]                        
            require required
            
        load = (initial_queue, callback) ->
            return if _loading
            
            _loading = yes
            _queue = ''
            
            if typeof initial_queue is 'function'
                callback = initial_queue
                initial_queue = ""
            
            initial_queue ?= ''
            
            if window?
                current = localStorage.getItem 'LateDB'
                
                if current? and current isnt ""
                    {_db,_ops,_op_index,_paths,_path_index} = eval init current, module:on
                
                setTimeout (-> _queue = initial_queue ; _loading = no ; _exists = yes ; (for f in _ready then f()) ; callback?()), 10
            else
                Fs ?= require 'fs'
                Fs.exists pathname(), (exists) ->
                    unless exists then _queue = init()
                    else {_db,_ops,_op_index,_paths,_path_index} = require_db()
                    
                    _queue += (if _queue isnt '' then '\n' else '') + initial_queue 
    
                    _loading = no
                    _exists = yes
                    for f in _ready then f()
                    callback?()

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

        flush = ->
            if _queue.length > 0
                do_flush = ->
                    if window?
                        current = localStorage.getItem 'LateDB'
                        localStorage.setItem 'LateDB', (current ? "") + _queue
                        setTimeout (-> for f in _flushed then f()), 10
                        setTimeout (-> flush()), 100
                    else
                        Fs.appendFile pathname(), _queue, ->
                            for f in _flushed then f()
                            setTimeout (-> flush()), 100

                    _queue = ""

                unless _exists then load(_queue, do_flush) else do_flush()
            else
                setTimeout (-> flush()), 100

        forget = (callback) ->
            _queue = ""
            
            if window?
                localStorage.removeItem 'LateDB'
                _exists = no
                callback?()
            else
                Fs.unlink pathname(), -> 
                    _exists = no
                    callback?()
            
            return

        exists = (callback) ->
            if window?
                setTimeout (-> callback? localStorage.getItem('LateDB')?), 10
            else
                Fs ?= require 'fs'
                Fs.exists pathname(), (exists) -> callback? exists
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
            if options?.forget then forget(callback)
            else setTimeout (-> callback?()), 10
            return
        
        hash = (s) ->
            h = 0
            if s.length == 0
                return h
            i = 0
            while i < s.length
                c = s.charCodeAt(i)
                h = (h << 5) - h + c
                h |= 0
                i++
            h

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
                current = localStorage.getItem 'LateDB'
                lines = current.split '\n'
                for line, i in lines
                    context.line = line
                    context.index = i
                    unless parse context, time then break
                localStorage.setItem 'LateDB', context.log
                load -> callback?()
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
                            load -> callback?()

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
                current = localStorage.getItem 'LateDB'
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
                            
                localStorage.setItem 'LateDB', context.log
                load -> callback?()
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
              
                _ ?= require './chocodash'
                
                context = log: '', flushable: yes
                copy context, ->
                    # 2-empty current db
                    clear ->
                        # 3-reload compacting db
                        compacting_db = require_db temp_filename
                        # 4-stringify it with a JSON stream writer
                        
                        Fs.unlink pathname(temp_filename), ->
                            context = log: '', flushable: yes
                            write = (chunk, index) ->
                                context.log += (if index > 0 then ',' else '') + chunk ? ''
                                if context.flushable and (context.log.length > page_size or not chunk?)
                                    context.flushable = no
                                    Fs.appendFile pathname(temp_filename), context.log.substr(), -> context.flushable = yes
                                    context.log = ""
                                return
                            
                            compacting_db._op_index = null
                            _.stringify compacting_db, {write, strict:on, variable:on}
                            
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
                                                    load -> callback?()
                                else
                                    setTimeout wait_io, 10
                            wait_io()

                
            return

        ready = (callback) -> _ready.push callback

        flushed = (callback) ->
            if _queue.length > 0
                _flushed.push callback
            else
                setTimeout (-> callback?()), 10
            
        {exists, ready, load, write, flushed, clear, hash, revert, compact, pathname}

    lateDB = (name) ->
        if name? then _filename = name

        db = (path) ->
            
            return _db unless path?
            
            node = _db
            steps = path.split '.'
            for step in steps when node?
                unless node[step]? then node[step] = {}
                node = node[step]
            node

        db.ready = (callback) -> log.ready.apply log, arguments
        db.flushed = (callback) -> log.flushed.apply log, arguments
        db.revert = (time, callback) -> log.revert.apply log, arguments
        db.compact = (time, callback) -> log.compact.apply log, arguments
        db.clear = (options, callback) -> log.clear.apply log, arguments
        db.pathname = (options, callback) -> log.pathname.apply log, arguments
        db.filename = -> _filename

        db.update = (updates) ->
            # extract path, data, op from updates
            # save on disk then in mem
            # write update timestamp
            # this = db node at path, then execute op with this and data
            # look for op index then if found write _(op_id, data) in log
            # if not found then calculate hash for op and then add op as ops(op_hash, op) in log then write _(op_id, data) in log
            
            log.write()
            
            for path, {data, op} of updates
                op_hash = log.hash op.toString()
                op_index = _op_index[op_hash]
                unless op_index?
                    op_index = _op_index[op_hash] = -1 + _ops.push op
                    log.write op_index, op
                    
                path_index = _path_index[path]
                unless path_index?
                    path_index = _path_index[path] = -1 + _paths.push path
                    log.write op_index, path

                op.call db(path), data
                log.write op_index, path_index, data
            return

        log.load()

        db

    lateDB.exists = (callback) -> log.exists callback
    
    lateDB

_module = window ? module
_module[if _module.exports? then "exports" else "Chocokup"] = lateDB