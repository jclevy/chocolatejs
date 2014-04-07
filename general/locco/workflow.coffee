Workflow = class
    constructor: ->
        bin: {}
    
    execute: (action) ->
        for action in action.actions
            switch so
                when 'go'
                    @bin = {} # on a besoin de la Reserve maintenant

Workflow.Action = Action = class
    constructor: ->
        @actions = []
    
    do: (what, value, type) ->
        @actions.push {so: 'do', what, value, type} ; @
        
    move: (what, way) ->
        way ?= Action.go.Way.Export
        @actions.push {so: 'move', what, way} ; @
    
    eval: (what, value) ->
        @actions.push {so: 'eval', what, value} ; @

    go: (what, where) ->
        where ?= Action.go.Where.Inside
        @actions.push {so: 'go', what, where} ; @

Action::move.Way = Export:0, Import:1
Action::go.Where = Discover:0, Inside:1, Through:2

_module = window ? module
if _module.exports? then _module.exports = Workflow else window.Locco?.Workflow = Workflow
