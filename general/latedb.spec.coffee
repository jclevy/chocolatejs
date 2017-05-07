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
        ready = no
        db = lateDB()
        db.ready -> ready = yes
        expect(db).not.toBe undefined
        expect(db.filename()).toBe 'db.log'

        waitsFor (-> ready), 'LateDB to be ready', 1000
        runs ->
            expect(ready).toBe true
    
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
        db.clear()
        expect(db()?.constructor).toBe {}.constructor
    
    it 'should reload the DB in the previous state', ->
        ready = no
        db = lateDB()
        db.ready -> ready = yes
        waitsFor (-> ready), 'LateDB to be ready', 1000
        runs ->
            expect(ready).toBe true
            expect(db()?.result.debug_log[0]).toBe 'done'

    it 'should increase the DB size', ->
        count = 0
        
        update = ->
            count += 1
            db.update 'result':
                data:"done #{count} time#{if count>1 then 's' else ''}"
                op:(data) -> (@debug_log ?= []).push data
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
                lines = localStorage.getItem('LateDB').split '\n'
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

    it 'should delete the default DB again', ->
        done = no
        runs ->
            db.clear forget:on, -> done = yes
        waitsFor (-> done), 'LateDB to be deleted again', 1000
        runs ->
            expect(db()?.constructor).toBe {}.constructor
        
    xit 'should not exist anymore again', ->
        done = no
        exists = undefined
        lateDB.exists (e) -> done = true ; exists = e

        waitsFor (-> done), 'LateDB to tell if it still exists again', 1000
        
        runs ->
            expect(exists).toBe false
