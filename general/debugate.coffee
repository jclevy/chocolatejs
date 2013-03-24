class Debugate
    @log: (what...) ->
        console.log 'DEBUG:', (""+x for x in what).join(' ')
        
    #log_in_file: ->
    #    require('fs').createWriteStream('./debug_git.err', {'flags': 'a'}).write((""+x for x in what).join(' ')  + '\n\n')

_module = window ? module
_module.exports = Debugate
_module.Debugate = Debugate if window?