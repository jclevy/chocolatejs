appdir = process.argv[2]
port = process.argv[3]
if parseInt(appdir) > 0 then port = appdir; appdir = undefined
port = parseInt(port) if port? and parseInt(port) > 0
World = require('./workflow').start(appdir, port)
