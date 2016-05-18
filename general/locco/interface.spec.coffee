Interface = require '../../general/locco/interface'

describe 'Interface', ->
    it 'should create an Interface', ->
        expect((new Interface) instanceof Interface).toBeTruthy()
    it 'should know Interface.Reaction', ->
        expect((new Interface.Reaction) instanceof Interface.Reaction).toBeTruthy()
    it 'get a reply from a simple Interface', ->
        service = new Interface -> 'done'
        result = null
        runs -> service.submit().subscribe (reaction) -> result = reaction.bin
        waitsFor (-> result?), 10
        runs -> expect(result).toBe 'done'

    it 'standard Interface.Web.Html with default values', ->
        service = new Interface.Web.Html
            defaults: name: 'me', place: 'York'
            render: ({name, place}) ->
                text "hello #{if name.join? then name.join(' ') else name} in #{place}"
        result = null
        runs -> service.submit().subscribe (reaction) -> result = reaction.bin?.render?()
        waitsFor (-> result?), 1000
        runs -> expect(result).toBe 'hello me in York'

    it 'standard Interface.Web.Html with params', ->
        service = new Interface.Web.Html
            defaults: name: 'me', place: 'York'
            render: ({name, place}) ->
                text "hello #{if name.join? then name.join(' ') else name} in #{place}"
        result = null
        runs -> service.submit(name:'you', place:'London').subscribe (reaction) -> result = reaction.bin?.render?()
        waitsFor (-> result?), 1000
        runs -> expect(result).toBe 'hello you in London'

    it 'check values with standard Interface.Web.Html and params', ->
        service = new Interface.Web.Html
            defaults: name: 'me', place: 'York'
            check: ({name}) ->
                if name is 'JC' then no else yes
            render: ({name, place}) ->
                text "hello #{if name.join? then name.join(' ') else name} in #{place}"
        result = null
        runs -> service.submit(name:'JC', place:'London').subscribe (reaction) -> result = reaction.bin
        waitsFor (-> result?), 1000
        runs -> expect(result).toBe ''


