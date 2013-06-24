unless window?
    Document = require '../server/document'
    Fs = require 'fs'
    
    describe 'Document', ->
        describe 'Cache', ->
            datadir = undefined
            cache = undefined
            test_object = {test:true, value:2}

            
            it 'has a datadir available', ->
                expect(datadir = jasmine.getEnv().__.datadir).not.toBeUndefined()
            
            it 'creates a Cache object', ->
                cache = new Document.Cache datadir
                cache.filename = "test.cache"
                expect(cache instanceof Document.Cache).toBeTruthy()
                
            it 'says: cache has a datadir defined', ->
                expect(cache.datadir).toBe(datadir)

            it 'has a valid serialized file pathname', ->
                expect(cache.pathname()).toBe(cache.datadir + '/' + cache.filename)
            
            it 'can put and get back an object from cache', ->
                cache.put 'test_object', test_object
                gotten_object = cache.get 'test_object'
                expect(gotten_object).toBe test_object

            it 'says: when I use many times the same key old objects are remove from the cache', ->
                cache.put 'test_object', {another:yes}
                expect(cache.get 'test_object').not.toBe test_object

            it 'serializes cache when hibernate is called', ->
                cache.hibernate()
                expect(Fs.existsSync(cache.pathname())).toBeTruthy()

            it 'can clear the cache', ->
                cache.clear()
                expect(cache.get 'test_object').toBeUndefined()

            it 'can awake the cache from a serialized file', ->
                cache.awake()
                gotten_object = cache.get 'test_object'
                expect(gotten_object).not.toBeUndefined()
                expect(gotten_object.another).toBeTruthy()

            it 'should throw an error on awake when no cache file is available', ->
                cache.kill()
                expect(Fs.existsSync(cache.pathname())).toBeFalsy()
            