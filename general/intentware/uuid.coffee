#     uuid.js
#
#     Copyright (c) 2010-2012 Robert Kieffer
#     MIT License - http://opensource.org/licenses/mit-license.php

_global = this

# Unique ID creation requires a high quality random # generator.  We feature
# detect to determine the best RNG source, normalizing to a function that
# returns 128-bits of randomness, since that's what's usually required
_rng = undefined

# Node.js crypto-based RNG - http://nodejs.org/docs/v0.6.2/api/crypto.html
#
# Moderately fast, high quality
if typeof (require) is "function"
    try
        _rb = require("crypto").randomBytes
        _rng = _rb and ->
            _rb 16
        
if not _rng and _global.crypto and crypto.getRandomValues
# WHATWG crypto-based RNG - http://wiki.whatwg.org/wiki/Crypto
#
# Moderately fast, high quality
    _rnds8 = new Uint8Array(16)
    _rng = whatwgRNG = ->
        crypto.getRandomValues _rnds8
        _rnds8
      
unless _rng
# Math.random()-based (RNG)
#
# If all else fails, use Math.random().  It's fast, but is of unspecified
# quality.
    _rnds = new Array(16)
    _rng = ->
        i = 0
        r = undefined

        while i < 16
            r = Math.random() * 0x100000000  if (i & 0x03) is 0
            _rnds[i] = r >>> ((i & 0x03) << 3) & 0xff
            i++
        _rnds

# Buffer class to use
BufferClass = (if typeof (Buffer) is "function" then Buffer else Array)

# Maps for number <-> hex string conversion
_byteToHex = []
_hexToByte = {}
i = 0

while i < 256
    _byteToHex[i] = (i + 0x100).toString(16).substr(1)
    _hexToByte[_byteToHex[i]] = i
    i++
    
    
# **`parse()` - Parse a UUID into it's component bytes**
parse = (s, buf, offset) ->
    i = (buf and offset) or 0
    ii = 0
    buf = buf or []
    s.toLowerCase().replace /[0-9a-f]{2}/g, (oct) ->
      buf[i + ii++] = _hexToByte[oct]  if ii < 16 # Don't overflow!

    # Zero out remaining bytes if string was short
    buf[i + ii++] = 0  while ii < 16
    buf

# **`unparse()` - Convert UUID byte array (ala parse()) into a string**
unparse = (buf, offset) ->
    i = offset or 0
    bth = _byteToHex
    bth[buf[i++]] + bth[buf[i++]] + bth[buf[i++]] + bth[buf[i++]] + "-" + bth[buf[i++]] + bth[buf[i++]] + "-" + bth[buf[i++]] + bth[buf[i++]] + "-" + bth[buf[i++]] + bth[buf[i++]] + "-" + bth[buf[i++]] + bth[buf[i++]] + bth[buf[i++]] + bth[buf[i++]] + bth[buf[i++]] + bth[buf[i++]]


# **`v1()` - Generate time-based UUID**
#
# Inspired by https://github.com/LiosK/UUID.js
# and http://docs.python.org/library/uuid.html

# random #'s we need to init node and clockseq
_seedBytes = _rng()

# Per 4.5, create and 48-bit node id, (47 random bits + multicast bit = 1)
_nodeId = [_seedBytes[0] | 0x01, _seedBytes[1], _seedBytes[2], _seedBytes[3], _seedBytes[4], _seedBytes[5]]

# Per 4.2.2, randomize (14 bit) clockseq
_clockseq = (_seedBytes[6] << 8 | _seedBytes[7]) & 0x3fff

# Previous uuid creation time
_lastMSecs = 0
_lastNSecs = 0

# See https://github.com/broofa/node-uuid for API details
v1 = (options, buf, offset) ->
    i = buf and offset or 0
    b = buf or []
    
    options = options or {}
    
    clockseq = (if options.clockseq? then options.clockseq else _clockseq)
    
    # UUID timestamps are 100 nano-second units since the Gregorian epoch,
    # (1582-10-15 00:00).  JSNumbers aren't precise enough for this, so
    # time is handled internally as 'msecs' (integer milliseconds) and 'nsecs'
    # (100-nanoseconds offset from msecs) since unix epoch, 1970-01-01 00:00.
    msecs = (if options.msecs? then options.msecs else new Date().getTime())
    
    # Per 4.2.1.2, use count of uuid's generated during the current clock
    # cycle to simulate higher resolution clock
    nsecs = (if options.nsecs? then options.nsecs else _lastNSecs + 1)
    
    # Time since last uuid creation (in msecs)
    dt = (msecs - _lastMSecs) + (nsecs - _lastNSecs) / 10000
    
    # Per 4.2.1.2, Bump clockseq on clock regression
    clockseq = clockseq + 1 & 0x3fff  if dt < 0 and not options.clockseq?
    
    # Reset nsecs if clock regresses (new clockseq) or we've moved onto a new
    # time interval
    nsecs = 0  if (dt < 0 or msecs > _lastMSecs) and not options.nsecs?
    
    # Per 4.2.1.2 Throw error if too many uuids are requested
    throw new Error("uuid.v1(): Can't create more than 10M uuids/sec")  if nsecs >= 10000
    
    _lastMSecs = msecs
    _lastNSecs = nsecs
    _clockseq = clockseq
    
    # Per 4.1.4 - Convert from unix epoch to Gregorian epoch
    msecs += 12219292800000
    
    # `time_low`
    tl = ((msecs & 0xfffffff) * 10000 + nsecs) % 0x100000000
    b[i++] = tl >>> 24 & 0xff
    b[i++] = tl >>> 16 & 0xff
    b[i++] = tl >>> 8 & 0xff
    b[i++] = tl & 0xff
    
    # `time_mid`
    tmh = (msecs / 0x100000000 * 10000) & 0xfffffff
    b[i++] = tmh >>> 8 & 0xff
    b[i++] = tmh & 0xff
    
    # `time_high_and_version`
    b[i++] = tmh >>> 24 & 0xf | 0x10 # include version
    b[i++] = tmh >>> 16 & 0xff
    
    # `clock_seq_hi_and_reserved` (Per 4.2.2 - include variant)
    b[i++] = clockseq >>> 8 | 0x80
    
    # `clock_seq_low`
    b[i++] = clockseq & 0xff
    
    # `node`
    node = options.node or _nodeId
    n = 0

    while n < 6
        b[i + n] = node[n]
        n++
        
    (if buf then buf else unparse(b))



# **`v4()` - Generate random UUID**

# See https://github.com/broofa/node-uuid for API details
v4 = (options, buf, offset) ->
    # Deprecated - 'format' argument, as supported in v1.2
    i = buf and offset or 0
    
    if typeof (options) is "string"
      buf = (if options is "binary" then new BufferClass(16) else null)
      options = null
    options = options or {}
    
    rnds = options.random or (options.rng or _rng)()
    
    # Per 4.4, set bits for version and `clock_seq_hi_and_reserved`
    rnds[6] = (rnds[6] & 0x0f) | 0x40
    rnds[8] = (rnds[8] & 0x3f) | 0x80
    
    # Copy bytes to buffer, if provided
    if buf
        ii = 0

        while ii < 16
            buf[i + ii] = rnds[ii]
            ii++

    buf or unparse(rnds)
    

# Export public API
uuid = v4
uuid.v1 = v1
uuid.v4 = v4
uuid.parse = parse
uuid.unparse = unparse
uuid.BufferClass = BufferClass

if typeof define is "function" and define.amd
    # Publish as AMD module
    define ->
        uuid
else if typeof (module) isnt "undefined" and module.exports
    # Publish as node.js module
    module.exports = uuid
else
    # Publish as global (in browsers)
    _previousRoot = _global.Uuid
    
    # **`noConflict()` - (browser only) to reset global 'uuid' var**
    uuid.noConflict = ->
        _global.Uuid = _previousRoot
        uuid

    _global.Uuid = _global.exports = uuid
    

uuid.isUuid = (value) ->
    if value? and Object.prototype.toString.apply value is '[object String]' and value.length is 36
        parsed = parse value
        unparsed = unparse parsed
        return value is unparsed
    else if Buffer.isBuffer(value)
        return value.length is 16
    else 
        return false
