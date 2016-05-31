Fs = require 'fs'
Intention = require './intention'
_ = require '../general/chocodash'

#### System documents
exports.datadir = undefined

# `Structure` provide a documents structure service
class Structure
    constructor : (@datadir, options) ->
        if _.type(@datadir) isnt _.Type.String then options = @datadir; @datadir = null
        
        @datadir ?= exports.datadir
        
        @filename = options.filename if options?.filename?
        @async = options.async if options?.async?
        @indent = options.indent if options?.indent?
        
        # We then try to restore an existing structure saved in a file
        @awake()
        return

    # the structure  store
    store : {}
    
    # default mode used to access file
    async : on
    
    # time to wait between successive hibernate calls
    throttle : 0
    
    # indent the JSON output: null: no indent, number: number of spaces, string: used instead of spaces
    indent: null
    
    # default filename for the structure when serialized 
    filename : 'document.json'
    
    # returns current path to structure serialized file
    pathname : -> @datadir + '/' + @filename
    
    # `hibernate` serializes the structure in a file
    hibernate : do ->
        hibernate = (callback) ->
            dir_names = @pathname().split('/')
            file_name = dir_names.pop()
    
            _.flow (run) =>
                
                path = ''
                # Check the existence of every directory in the path
                for dir_name, i in dir_names
                    if path is '' and dir_name is '' then dir_name = '/'
                    path += (if path != '' then '/' else '') + dir_name
                    
                    if @async
                        run (end) ->
                            Fs.exists path, (exist) ->
                                if path isnt '' and not exist then Fs.mkdir path, '755', -> end()
                            end
                        
                    else
                        # Create the directory if non existent
                        if path isnt '' and not Fs.existsSync path then Fs.mkdirSync path, '755'
                    
            
                if callback? or @async is on 
                    run (end) => 
                        Fs.writeFile @pathname(), JSON.stringify(@store, null, @indent), -> callback?(); end()
                        end
                else try Fs.writeFileSync @pathname(), JSON.stringify @store, null, @indent
        
        if @throttle > 0 then _.throttle wait:@throttle, hibernate
        else hibernate
    
    # `awake` deserializes the structure from a file
    awake : (callback) ->
        # `reviver` function will be used with `JSON.parse` method to convert back date strings to date objects 
        reviver = (key, value) ->
           if typeof value is 'string' and value.length is 24 and value[value.length-1] is 'Z'
               if not isNaN (new_date = Date.parse value)
                  return new Date new_date
           return value
        suffix = '.config.json'
        # If a structure file exits when load and parse it to restore our store !
        if @async is on then Fs.exists @pathname(), (exists) => 
            if exists is yes then Fs.readFile @pathname(), (err, file) =>
                unless err? 
                    @store = JSON.parse file, reviver
                callback? err
            else 
                @store = {}; callback?()
        else 
            @store = if Fs.existsSync(@pathname())
                file = Fs.readFileSync(@pathname())
                try parsed = JSON.parse file, reviver
                parsed ? {}
            else {}

    # `kill` removes the structure file
    kill : (callback) ->
        if @async is on then Fs.unlink @pathname(), -> callback?()
        else Fs.unlinkSync @pathname()

# `Cache` object maintains an objects dictionary
#
# We will serialize this dictionary to a file when the main process exits
# and restore it whe the main process starts
# Be careful: Cache does not handle circular references when serializing to JSON
class Cache extends Structure
    
    constructor : (@datadir, options) ->
        if _.type(@datadir) isnt _.Type.String then options = @datadir; @datadir = null
        
        super 

        # We register ourself to be called when our main process ends
        if @datadir? and options?.autosave isnt off then @callbackOnFinal = (=> @hibernate()) ; Intention.callbackOnFinal @callbackOnFinal
        
        return

    # default filename for the cache when serialized 
    filename : 'document.cache'
    
    # `reload` the cache from file
    reload : (callback) -> 
        @awake callback

    # `save` the cache to file
    save : (callback) -> 
        @hibernate callback

    # `clear` the cache
    clear : ->
        delete @store
        @store = {}
    
    # `get` back an object from the cache
    get : (key) ->
        if key? then @store[key] else @store
        
    # `clone` an object from the cache
    clone : (key) ->
        if key? then _.clone @store[key] else _.clone @store
    
    # `put` an object in cache
    put : (key, object) ->
        @store[key] = object

    # `set` put an object in cache and hibernate immediately
    set : (key, object, callback) ->
        @store[key] = object
        @hibernate callback

    # `remove` an object from the cache 
    remove : (key) ->
        delete @store[key]

    # `ensure` puts an object in cache if not already inside
    ensure : (key, object) ->
        @get(key) ? @put key, object

    # update many keys at once syncing from an optional external store and save updates on file
    update: (store, update, callback) ->
        unless update? or callback? then update = store ; store = null
        if not callback? and typeof update is 'function' then callback = update ; update = store ; store = null
        return unless update?
        store ?= @store
        for key, func of update
            if typeof func is 'function' 
                store[key] ?= {}
                func.apply store[key], arguments
            else 
                store[key] = func
            @put key, store[key] unless store is @store
        @hibernate callback

exports.Structure = Structure
exports.Cache = Cache
