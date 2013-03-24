Chocokup = require '../chocokup'

helpers =
        web_control : (type, args...) ->
            { id_class, attributes, content } = verify args...
            
            id_class = "#" + (id = "ijax_wc_" + @webcontrol_index++) if not id_class?
            
            (attributes ?= {})['ijax-ui-type'] = type
            
            tag type, id_class, attributes, content

        button : -> web_control 'button', arguments...
    
class Ui extends Chocokup
    @helpers[k] = v for own k,v of helpers

class Ui.Document extends Chocokup.Document
    @helpers[k] = v for own k,v of helpers
    @manifest = 
        cache : """
        /static/mootools/mootools-core-uncompressed.js
        /static/coffee-script/coffee-script.js
        /static/ijax/ijax.js
        """
        
    body_template: ->
        script src:"/static/mootools/mootools-core-uncompressed.js", type:"text/javascript", charset:"utf-8"
        script src:"/static/coffee-script/coffee-script.js", type:"text/javascript", charset:"utf-8" if @params?.with_coffee
        script src:"/static/ijax/ijax.js", type:"text/javascript", charset:"utf-8"
       
        text "#{@content}"

        coffeescript -> 
            window.addEvent 'domready', Intentware.Ui.bindElements

class Ui.Panel extends Chocokup.Panel
    @helpers[k] = v for own k,v of helpers

_module = window ? module
_module.exports = { Ui }
window?.Intentware.Ui = Ui
