if window?
    window.modules = intentware: window.exports = window.Intentware = {}

    # Simple and temporary Require function
    window.Intentware._require = window.require
    window.require = -> exports
