Newnotes = require './newnotes'

describe 'Newnotes', ->
    it 'creates, then lists a basic todo', ->
        newnotes = new Newnotes
        newnotes.add 'do first'
        newnotes.add 'do after'
        expect([todo.title for todo in newnotes.list()].join(',')).toEqual 'do first,do after'
