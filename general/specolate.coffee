_exports = if window? then window.Specolate = {} else module.exports

log = []
available = true
finished = true

class Specolate
    @html_reporter: (module_filename, options, callback) ->
        if available then Specolate.report module_filename, options, callback
        needs_refresh = if not finished then '<head>\n<meta http-equiv="refresh" content="1">\n</head>' else ''
        available = finished
        
        result = '<html>\n' + needs_refresh + '\n<body>\n'
        for line in log
            result += '<div>' + line.replace(/\ /g, '&nbsp;') + '</div>'
        result += '</body>\n</html>'

    @json_reporter: (module_filename, options, callback) ->
        if available 
            event = Specolate.report module_filename, options, if callback? then (-> available = finished; callback arguments...) else undefined
            event?.on 'end', ->
                available = finished
            event
        else ''
        
    @get_extension = (path) ->
        if (path = path.substr(1 + path.lastIndexOf '/')).indexOf('.') is -1 then '' else '.' + path.split('.')[-1..][0]

    @get_spec_filename = (path) ->
        return '' if path is ''
        return path.replace ext, '.spec' + ext if (ext = Specolate.get_extension path) not in ['', '.']
        return path + '.spec'
        
    @inspect: (reporter, module_filename, options, callback) ->
        if (report = Specolate[reporter + '_reporter'])? then report module_filename, options, callback

    @report: (module_filename, options, callback) ->
        if not finished then return ''

        host = window ? {__:options}
        
        event = null
        log = []
        log.failedCount = 0
        log.totalCount = 0
        available = false
        finished = false
        
        specolate_filename = Specolate.get_spec_filename module_filename

        reporter =
            log: () ->
            
            reportSpecStarting: (runner) ->
            
            reportRunnerStarting: (runner) ->
            
            reportSuiteResults: (suite) ->
            
            reportSpecResults: (spec) ->
            
            reportRunnerResults: (runner) ->
                for suite in runner.suites()
                    specResults = suite.results()
                    path = []
                    while (suite)
                        path.unshift suite.description
                        suite = suite.parentSuite
        
                    description = path.join '.'
                    
                    spaces = (' ' for i in [0...2 * path.length]).join ''
    
                    one_log = []
                    one_log.push spaces + 'spec : ' + description
        
                    for spec in specResults.items_
                        if spec.description
                            one_log.push spaces + '  it ' + spec.description + ': '
                            for result, i in spec.items_
                                one_log[-1..] = one_log[-1..] + (if i>0 then ',' else '') + ' '  + result.message
                                log.failedCount += 1 unless result.passed_
                                log.totalCount += 1
    
                    log.push one_log...

                _log = [
                        'results : ' + log.failedCount + ' failed out of ' + log.totalCount
                        ''
                        'started at ' + new Date()
                        ''
                        'finished at ' + new Date()
                ]
                _log[3..-2] = log
                count = failed:log.failedCount, total:log.totalCount
                
                log = _log
                finished = true

                cache = if window? then window.modules else require.cache
                for own k of cache when k.indexOf('.spec') isnt -1
                    delete cache[k]
                    cache[k] = null

                result = log:log, count:count
                if callback? then callback result else process.nextTick -> event?.emit 'end', result
                
                runner.suites().length = 0
        try
            unless window?
                vm = require('vm')
                context = vm.createContext({reporter, host})
                for own k,v of global then context[k] = v
                context.module = module
                context.require = require
                context.global = context
                context.global.global = context
                event = vm.runInContext """
                    var Events, event, k;
                    Events = require('events');
                    event = new Events.EventEmitter;
                    host.jasmine = require('jasmine-node');
                    try { require('#{specolate_filename}'); } catch (_error) {}
                    host.jasmine.getEnv().reporter = reporter;
                    host.jasmine.getEnv().__ = host.__;
                    host.jasmine.getEnv().execute();
                    event;
                    """, context, specolate_filename
            else
                require '../' + specolate_filename, use_cache: off
                host.jasmine.getEnv().reporter = reporter;
                host.jasmine.getEnv().execute()
        catch error
            finished = true
            result = log:['','','', error.stack], count: failed:1, total:1
            if callback? then callback result else process.nextTick -> event?.emit 'end', result
                            
        return event
    
    @has_finished: ->
        finished

_exports.inspect = Specolate.inspect
