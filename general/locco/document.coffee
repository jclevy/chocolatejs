_ = require '../../general/chocodash'
Data = require '../../general/locco/data'

Document = _.prototype
    constructor: (o) ->
        if not o?.uuid? then o = new Data
        
        materialize = (o, root, parent) ->
            if not o? or typeof o isnt 'object'
                return o
            
            idoc = if not parent? then root else new o.constructor()
            
            for own key of o
                idoc[key] = materialize o[key], root, if o.matter then idoc else parent
            
            # set document matter parent
            idoc.parent = parent if idoc.uuid? and parent?

            # register intentional document in local world
            Data.register idoc
            
            if parent?
                # register access by name inside document
                if idoc.name?
                    parent.members ?= {}
                    member = parent.members[idoc.name]
                    if member?
                        if _.type(member) is _.Type.Array
                            member.push idoc
                        else
                            parent.members[idoc.name] = [member, idoc]
                    else
                        parent.members[idoc.name] = idoc
                # register access by index inside document if no name 
                else if idoc.uuid?
                    (parent.items ?= []).push idoc
                    
            
            return idoc
            
        return materialize o, @

_module = window ? module
if _module.exports? then _module.exports = Document else window.Locco?.Document = Document
