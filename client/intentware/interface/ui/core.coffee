Intentware = require '../../../../general/intentware/core'

if window?
    window.exports = Intentware.Ui
else return

# Defered elements from DOM to bind to an Ijax Ui class
defered_elements = []

exports.bindElements = ->
    # For each Ijax attribute
    for item in $$ '[ijax-ui-type]'
        options_root = {}
        
        for attribute in item.attributes 
            attribute_name_part = attribute.name.split '-'
            if attribute_name_part[0] is 'ijax'
                # Create an Ijax property in the Element
                ijax_attribute = options_root
                for index in [1...attribute_name_part.length]
                    ijax_attribute = ijax_attribute[attribute_name_part[index]] = if index is attribute_name_part.length - 1 then attribute.value else {}

        # Create an Ijax class instance for the DOM element
        item.ijax = new Intentware.Ui[options_root.ui.type.replace /\b[a-z]/g, (letter) -> letter.toUpperCase()] item, options_root