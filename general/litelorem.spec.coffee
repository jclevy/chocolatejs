lorem = require 'chocolate/general/litelorem'

describe 'lorem', ->

    it 'creates a lorem word', ->
        expect(lorem.word()).not.toBeNull()
    it 'creates a lorem word with a length greater than 0', ->
        expect(lorem.word().length).toBeGreaterThan 0
    it 'creates six words', ->
        expect(lorem.words(6).split(' ').length).toBe 6
        