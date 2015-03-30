_ = require '../../general/chocodash'

Data = _.prototype 
    constructor: (@uuid = _.Uuid(), @name, @data) ->

_module = window ? module
if _module.exports? then _module.exports = Data else window.Locco ?= {} ; window.Locco.Data = Data
