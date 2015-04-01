_ = require '../../general/chocodash'
Workflow = require '../locco/workflow'

# `TransientReserve` is a Reserve-like service available in browser. 
# It uses local service like localStorage to store data
TransientReserve = _.prototype
    use: ->
        all = {}

        @Space = 
            read: (uuid) -> all[uuid]
            write: (io) -> all[io.uuid] = io
            forget: (io) -> delete all[io.uuid]

# `Reserve` is used by a Worflow to permanentize actors and documents. 
Reserve = if module? then require "../../server/reserve" else new TransientReserve

_module = window ? module
if _module.exports? then _module.exports = Reserve else window.Locco ?= {} ; window.Locco.Reserve = Reserve