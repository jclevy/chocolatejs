File = require '../server/file'
Path = require 'path'

describe 'File', ->
    describe 'Public File services', ->
        datadir = undefined
        test_path = "chocolatejs_file_spec_test.txt"

        it 'should create a test file', ->
            result = undefined
            runs ->
                datadir = jasmine.getEnv().ijax.datadir
                event = File.writeToFile datadir + '/' + test_path, 'Some New Text Content'
                event.on 'end', (err) -> result = err ? on
            waitsFor (-> result?), 'File.writeToFile', 1000
            runs -> expect(result).toBe(on)
            
        it 'should get test file modification date', ->
            modifiedDate = undefined
            runs ->
                event = File.getModifiedDate datadir + '/' + test_path
                event.on 'end', (date) -> modifiedDate = date
            waitsFor (-> modifiedDate?), 'File.getModifiedDate', 1000
            runs -> expect(modifiedDate >= 1363115895000).toBeTruthy()
            
        it 'should delete test file', ->
            result = undefined
            runs ->
                event = File.moveFile datadir + '/' + test_path, ''
                event.on 'end', (err) -> result = err ? on
            waitsFor (-> result?), 'File.moveFile from, toEmpty', 1000
            runs -> expect(result).toBe(on)

        it 'should get directory content', ->
            dirContent = undefined
            runs ->
                event = File.getDirContent './server'
                event.on 'end', (content) -> dirContent = content
            waitsFor (-> dirContent?), 'File.getDirContent', 1000
            runs -> expect((item for item in dirContent when item.name is 'file.coffee').length).toBe(1)
