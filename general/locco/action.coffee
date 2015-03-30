_ = require '../../general/chocodash'

Action = _.prototype
    constructor: ->
        @actions = []
    
    do: (what, value, type) ->
        @actions.push {so: 'do', what, value} ; @
        
    move: (what, where, how) ->
        @actions.push {so: 'move', what, way} ; @
    
    eval: (what, value) ->
        @actions.push {so: 'eval', what, value} ; @

    go: (what, where) ->
        where ?= Action.go.Where.Inside
        @actions.push {so: 'go', what, where} ; @

Action::do.What = New:0, Set:1, Delete:2
Action::move.How = Replace:0, Append:1, Prepend:2, InsertBefore:3, InsertAfter:4
Action::go.Where = Front:0, Inside:1, Through:2

_module = window ? module
if _module.exports? then _module.exports = Action else window.Locco ?= {} ; window.Locco.Action = Action
