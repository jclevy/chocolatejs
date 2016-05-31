Document = require './document'

configs = {}

module.exports = (datadir, options) ->
    return unless datadir?
    
    options ?= {}
    {name, reload} = options
    name ?= 'app'
    reload ?= false

    check_config_module = (config) ->
        # check if we have a config.coffee in data folder and and merge it into `app.config.json`
        try 
            config_pathname = '../' + datadir + '/config'
            delete require.cache[require.resolve config_pathname]
            config_module = require config_pathname
        if config_module?
            should_save = off
            for key, value of config_module 
                unless should_save then should_save = not config.get(key)?
                config.put key, value
            if should_save then config.save()
        
    if reload and configs[name]?
        configs[name].reload()
        check_config_module configs[name]
        return configs[name]  
    else 
        return configs[name] ? do ->
            Document.datadir ?= datadir
            configs[name] = new Document.Cache async:off, filename:"#{name}.config.json", indent:4, autosave:off
            check_config_module configs[name]
            configs[name]
