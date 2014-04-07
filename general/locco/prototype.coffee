_ = require '../../general/chocodash'

Prototype = _.prototype
    constructor: ->

_module = window ? module
if _module.exports? then _module.exports = Prototype else window.Locco?.Prototype = Prototype
