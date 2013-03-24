# Specolate

Specolate is a client and server side behavior/test driven development tool.

It uses Jasmine, a great behavior-driven development framework for testing JavaScript code.

&nbsp;

## References

[Jasmine web site](http://pivotal.github.com/jasmine)


## Usage

Something interesting is that it runs your specs in the server **and** in the browser contexts.

You only have add, at the begining of your spec file:

### Server only module

    unless window?
        describe ...

### Browser only module

    if window?
        describe ...

### General module

    Newnotes = require './newnotes'
    
    describe 'Newnotes', ->
        it 'creates, then lists a basic todo', ->
            newnotes = new Newnotes
            newnotes.add 'do first'
            newnotes.add 'do after'
            expect([todo.title for todo in newnotes.list()].join(',')).toEqual 'do first,do after'
