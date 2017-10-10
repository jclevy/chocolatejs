Document = require './document'

configs = {}

config = (datadir, options) ->
    return unless datadir?
    
    options ?= {}
    {name, reload} = options
    name ?= 'app'
    reload ?= false

    check_config_module = (configuration) ->
        # check if we have a config.coffee in data folder and and merge it into `app.config.json`
        try 
            config_pathname = '../' + datadir + '/config'
            delete require.cache[require.resolve config_pathname]
            config_module = require config_pathname
        if config_module?
            should_save = off
            for key, value of config_module 
                unless should_save then should_save = not configuration.get(key)?
                configuration.put key, value
            if should_save then configuration.save()
        
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

config.debug = (onoff) ->
    unless typeof onoff is 'boolean' then onoff = onoff is 'true'
    configs.app?.set 'debug', onoff
    if onoff is on
        port: configs.app?.get('debug_port') ? "8081"
        protocol: if configs.app?.get('http_only') is on then 'http' else 'https'
    else {}
    
module.exports = config

