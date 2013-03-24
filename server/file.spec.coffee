File = require '../server/file'
Path = require 'path'

describe 'File', ->
    describe 'Public File services', ->
        appdir = undefined

        it 'should get file modification date', ->
            modifiedDate = undefined
            runs ->
                appdir = jasmine.getEnv().ijax.appdir
                event = File.getModifiedDate 'server/file', {appdir}
                event.on 'end', (date) -> modifiedDate = date
            waitsFor (-> modifiedDate?), 'File.getModifiedDate', 1000
            runs -> expect(modifiedDate >= 1363115895000).toBeTruthy()

        it 'should get directory content', ->
            dirContent = undefined
            runs ->
                event = File.getDirContent 'server', {appdir}
                event.on 'end', (content) -> dirContent = content
            waitsFor (-> dirContent?), 'File.getDirContent', 1000
            runs -> expect((item for item in dirContent when item.name is 'file.coffee').length).toBe(1)
