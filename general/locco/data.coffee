_ = require '../../general/chocodash'

Data = _.prototype 
    constructor: (@uuid = _.Uuid(), @name, @data) ->

all = {}

Data.get = (uuid) -> all[uuid]
Data.register = (io) -> all[io.uuid] = io
Data.forget = (io) -> delete all[io.uuid]

_module = window ? module
if _module.exports? then _module.exports = Data else window.Locco?.Data = Data
