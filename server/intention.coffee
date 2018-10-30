#### System Intentions

# What we do when our process exits :
# we will callback functions we registered
on_exit_callbacks = []
on_exit = ->
    callback() for callback in on_exit_callbacks
    process.exit()

# We first register ourself to receive system termination signals
process.on 'SIGINT', -> on_exit()
process.on 'SIGTERM', -> on_exit()

# on windows, we do not receive termination signals, so we wait for 'exit' message to call our exit callbacks
if process.platform is 'win32'
    rl = require('readline').createInterface(
        input: process.stdin
        output: process.stdout)
    rl.on 'SIGINT', ->
        process.emit 'SIGINT'
        return
    rl.on 'close', ->
        process.emit 'SIGINT'
        return

# `callbackOnFinal` registers callbacks to call when Process exists
exports.callbackOnFinal = (callback) ->
    index = on_exit_callbacks.indexOf callback
    on_exit_callbacks.push callback if index is -1

# `unregisterCallbackOnFinal` unregisters callbacks that would have been called when Process exists
exports.unregisterCallbackOnFinal = (callback) ->
    index = on_exit_callbacks.indexOf callback
    if index >= 0 then on_exit_callbacks.splice index, 1
