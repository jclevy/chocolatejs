_module = window ? module

Intentware = require '../../general/intentware/core'
Uuid = require '../../general/intentware/uuid'

_module.exports = Data = class
    constructor: (@uuid = Uuid(), @name, @data) ->
        return
        
all = {}

Data.get = (uuid) -> all[uuid]
Data.register = (io) -> all[io.uuid] = io
Data.forget = (io) -> delete all[io.uuid]

Data.type = (o) -> Object.prototype.toString.apply o
Data.Type =
    Object: '[object Object]'
    Array: '[object Array]'
    Boolean: '[object Boolean]'
    Number: '[object Number]'
    Date: '[object Date]'
    Math: '[object Math]'
    String: '[object String]'
    Undefined: '[object Undefined]'
    Null: '[object Null]'

window?.Intentware.Data = window.exports
