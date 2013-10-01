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
    Function: '[object Function]'
    Math: '[object Math]'
    String: '[object String]'
    Undefined: '[object Undefined]'
    Null: '[object Null]'

Data.toString_ = Data.toString

Data.stringify = Data.toString = () ->
    return Data.toString_() if arguments.length is 0
    
    object = arguments[0]
    options = arguments[1] ? {}
    
    if options.prettify is yes
        tab = '    '
        newline = '\n'
    else
        tab = newline = ''
    
    doit = (o, level) ->
        result = []
        level ?= 0
        indent = (tab for [0...level]).join ''
        ni = newline + indent
        nit = ni + tab
        type = Object.prototype.toString.apply o
        result.push switch type
            when '[object Object]' then "{#{nit}#{(k + ':' + doit(v, level+1) for own k,v of o).join(',' + nit)}#{ni}}"
            when '[object Array]' then "function () {#{nit}var a = []; var o = {#{nit}#{(k + ':' + doit(v, level+1) for own k,v of o).join(',' + nit)}};#{nit}for (var k in o) {a[k] = o[k];} return a; }()"
            when '[object Boolean]' then o
            when '[object Number]' then o
            when '[object Date]' then "new Date(#{o.valueOf()})"
            when '[object Function]' then o.toString()
            when '[object Math]' then 'Math'
            when '[object String]' then "'#{o.replace /\'/g, '\\\''}'"
            when '[object Undefined]' then 'void 0'
            when '[object Null]' then 'null'
            when '[object Buffer]', '[object SlowBuffer]'
                if o.length is 16 then Uuid.unparse o else o.toString()
            
        result
    
    doit(object).join(', ')

Data.parse = Data.fromString = (str) ->
    (new Function "return " + str)()
    
window?.Intentware.Data = window.exports
