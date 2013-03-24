###
  Generate a RFC4122(v4) UUID

  Documentation at https://github.com/broofa/node-uuid
###

# Use node.js Buffer class if available, otherwise use the Array class
BufferClass = (if typeof (Buffer) == "function" then Buffer else Array)

# Buffer used for generating string uuids
_buf = new BufferClass(16)

# Cache number <-> hex string for octet values
toString = []
toNumber = {}
for i in [0...256]
    toString[i] = (i + 0x100).toString(16).substr(1)
    toNumber[toString[i]] = i


parse = (s) -> 
    buf = new BufferClass(16)
    i = 0
    s.toLowerCase().replace /[0-9a-f][0-9a-f]/g, (octet) ->
        buf[i++] = toNumber[octet]
    return buf

unparse = (buf) ->
  tos = toString; b = buf
  return ''.concat(tos[b[0]] , tos[b[1]] , tos[b[2]] , tos[b[3]] , '-' ,
       tos[b[4]] , tos[b[5]] , '-' ,
       tos[b[6]] , tos[b[7]] , '-' ,
       tos[b[8]] , tos[b[9]] , '-' ,
       tos[b[10]] , tos[b[11]] , tos[b[12]] ,
       tos[b[13]] , tos[b[14]] , tos[b[15]])
  
ff = 0xff

# Feature detect for the WHATWG crypto API. See
# http://wiki.whatwg.org/wiki/Crypto
useCrypto = this.crypto and crypto.getRandomValues
rnds = if useCrypto then new Uint32Array(4) else new Array(4)

uuid = (fmt, buf, offset) ->
    b = if fmt isnt 'binary' then _buf else (if buf then buf else new BufferClass(16))
    i = buf and offset or 0
    
    if useCrypto
        crypto.getRandomValues rnds
    else
        rnds[0] = Math.random()*0x100000000
        rnds[1] = Math.random()*0x100000000
        rnds[2] = Math.random()*0x100000000
        rnds[3] = Math.random()*0x100000000
    
    r = rnds[0]
    b[i++] = r & ff
    b[i++] = r>>>8 & ff
    b[i++] = r>>>16 & ff
    b[i++] = r>>>24 & ff
    r = rnds[1]
    b[i++] = r & ff
    b[i++] = r>>>8 & ff
    b[i++] = r>>>16 & 0x0f | 0x40 # See RFC4122 sect. 4.1.3
    b[i++] = r>>>24 & ff
    r = rnds[2]
    b[i++] = r & 0x3f | 0x80 # See RFC4122 sect. 4.4
    b[i++] = r>>>8 & ff
    b[i++] = r>>>16 & ff
    b[i++] = r>>>24 & ff
    r = rnds[3]
    b[i++] = r & ff
    b[i++] = r>>>8 & ff
    b[i++] = r>>>16 & ff
    b[i++] = r>>>24 & ff
    
    return if not fmt? then unparse(b) else b

uuid.parse = parse
uuid.unparse = unparse
uuid.BufferClass = BufferClass

if module?
    module.exports = uuid;
else
    # In browser? Set as top-level function
    if window?
        window.Uuid = window.exports = uuid
    else
        this.uuid = uuid
