_ = require '../../general/chocodash'
Data = require '../../general/locco/data'

Document = _.prototype
    constructor: (definition) ->
        helpers = 
            set: (key, value) ->
                _.do.set @definition, key, value
                @value(@definition)
        
        for methodName in ["pop", "push", "reverse", "shift", "sort", "splice", "unshift"]
            helpers[methodName] = do (methodName) -> ->
                Array.prototype.unshift.call arguments, @definition
                result = _.do[methodName].apply null, arguments
                @value(@definition)
                result
                
        @signal = new _.Signal definition, helpers
    
    use: ->
        @set = (key, value) ->
            # _.do.set 
            @signal.set key, value
        
        @delete = (key) ->
            @signal.delete key
        
        @get = -> @signal.value()

        for methodName in ["pop", "push", "reverse", "shift", "sort", "splice", "unshift"]
            @[methodName] = do (methodName) -> ->
                output = @signal[methodName].apply @signal, arguments
                return output


_module = window ? module
if _module.exports? then _module.exports = Document else window.Locco ?= {} ; window.Locco.Document = Document
