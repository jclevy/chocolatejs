QueryString = require 'querystring'

exports.stringify = QueryString.stringify
exports.escape = QueryString.escape
exports.unescape = QueryString.unescape

exports.parse = (qs, sep, eq, options) ->
  unless options?.ordered is yes then return QueryString.parse qs, sep, eq, options
  
  return {list:[], dict:{}} unless typeof qs is 'string' and qs.length isnt 0
  
  sep = sep or "&" ; eq = eq or "=" ; maxKeys = 1000
  maxKeys = options.maxKeys if options and typeof options.maxKeys is 'number'
  
  obj = {} ; ind = {} ; arr = []
  qs = qs.split(sep)
  len = qs.length
  
  len = maxKeys if maxKeys > 0 and len > maxKeys

  for i in [0...len]
    x = qs[i].replace(/\+/g, "%20")
    idx = x.indexOf(eq)
    
    if idx >= 0
      kstr = x.substr(0, idx)
      vstr = x.substr(idx + 1)
    else
      kstr = x
      vstr = ""
      
    try
      k = decodeURIComponent(kstr)
      v = decodeURIComponent(vstr)
    catch e
      k = QueryString.unescape(kstr, true)
      v = QueryString.unescape(vstr, true)
    
    unless Object.prototype.hasOwnProperty(ind, k)
      ind[k] = i
      arr[i] = {key:k,value:v}
      obj[k] = v
    else if arr[ind[k]] instanceof Array
      arr[ind[k]].push v
      obj[k].push v
    else
      arr[ind[k]] = [ind[k], v]
      obj[k] = [ind[k], v]
      
  list:arr, dict:obj
