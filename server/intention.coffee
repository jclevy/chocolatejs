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

# `callbackOnFinal` registers callbacks to call when Process exists
exports.callbackOnFinal = (callback) -> on_exit_callbacks.push callback