Fs = require 'fs'
Intention = require './intention'

#### System documents

# `Cache` object maintains an objects dictionary
#
# We will serialize this dictionary to a file when the main process exits
# and restore it whe the main process starts
# Be careful: Cache does not handle circular references when serializing to JSON
class Cache
    constructor : (@datadir) ->
        # We then try to restore an existing cache saved in a file
        @awake()

        # We register ourself to be called when our main process ends
        if @datadir? then Intention.callbackOnFinal => @hibernate()
    
    # the cache objects store
    store : {}
    
    # default filename for the cache when serialized 
    filename : 'document.cache'
    
    # returns current path to cache serialized file
    pathname : -> @datadir + '/' + @filename
    
    # `clear` the cache
    clear : ->
        @store = {}
    
    # `get` back an object from the cache
    get : (key) ->
        @store[key]
    
    # `put` an object in cache
    put : (key, object) ->
        @store[key] = object

    # `remove` an object from the cache 
    remove : (key) ->
        delete@store[key]

    # `ensure` puts an object in cache if not already inside
    ensure : (key, object) ->
        @get(key) ? @put key, object
    
    # `hibernate` serializes the cache in a file
    hibernate : -> 
        Fs.writeFileSync @pathname(), JSON.stringify @store
    
    # `awake` deserializes the cache from a file
    awake : ->
        # `reviver` function will be used with `JSON.parse` method to convert back date strings to date objects 
        reviver = (key, value) ->
           if typeof value is 'string' and value.length is 24 and value[value.length-1] is 'Z'
               if not isNaN (new_date = Date.parse value)
                  return new Date new_date
           return value
   
        # If a cache file exits when load and parse it to restore our store !
        @store = if Fs.existsSync(@pathname()) then JSON.parse Fs.readFileSync(@pathname()), reviver else {}

    # `kill` removes the cache file
    kill : ->
        Fs.unlinkSync @pathname()
        
exports.Cache = Cache
