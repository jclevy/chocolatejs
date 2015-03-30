# Adapted from the Spludo Framework.
# Copyright (c) 2009-2010 DracoBlue, http://dracoblue.net/
# 
# Licensed under the terms of MIT License. For the full copyright and license
# information, please see the LICENSE file in the root folder.

child_process = require('child_process')
Fs = require 'fs'
Util = require 'util'
Path = require 'path'
File = require './file'
Chokidar = require 'chokidar'
Debugate = require '../general/debugate' 

monitor_server = new class
    process: null
    compile_process: {}
    restarting: false
    appdir: null
    logging: no

    "log": (msg) ->
        Debugate.log msg if this.logging

    "exit": ->
        self = this
        self.log 'CHOCOLATEJS: terminate child process'
        self.process?.kill()
        check = ->
            # if child process exited we can also exit
            # otherwise we wait...
            unless self.process? 
                self.log 'CHOCOLATEJS: exit'
                setTimeout (-> process.exit()), 100
                
        check()
        setInterval check, 100
        

    "restart": ->
        this.restarting = true
        this.log 'CHOCOLATEJS: Stopping server for restart'
        this.process.kill()

    "start": ->
        process.chdir __dirname + '/..'
        this.appdir =  process.argv[2]
        this.port =  process.argv[3]
        
        self = this
        
        process.on 'uncaughtException', (err) ->
            Fs.createWriteStream((this.appdir ? '.' ) + '/data/uncaught.err', {'flags': 'a'}).write new Date() + '\n' + err.stack + '\n\n'
            
        process.on 'SIGTERM', -> self.exit()

        this.log 'CHOCOLATEJS: Starting server'
        this.watchFiles()

        args = []
        args.push this.appdir if this.appdir?
        args.push this.port if this.port?
        this.process = child_process.spawn("coffee", ['server/server.coffee'].concat args)

        this.process.stdout.addListener 'data', (data) ->
            process.stdout.write(data)

        this.process.stderr.addListener 'data', (data) ->
            Util.log(data)

        this.process.addListener 'exit', (code) ->
            self.log 'CHOCOLATEJS: Child process exited: ' + code
            self.process = null

            if self.restarting
                self.restarting = false
                self.unwatchFiles()
                self.start()
                
    "watchFiles": ->
        self = this
        
        curdir = if this.appdir? then this.appdir else '.'
        
        filter = (path) ->
            if path.search(/^\.[^\.\/]+/) isnt -1 then return yes
            for folder in ['static']
                if path is folder then return yes
            stats = Fs.statSync path
            if stats.isDirectory() then return no
            for suffix in ['.js', '.coffee']
                if path.substr(path.length - suffix.length, suffix.length) is suffix then return no
            return yes

        on_add = (file) -> on_event 'add', file
        on_change = (file) -> on_event 'change', file           
        on_event = (event, file) ->
            
            
            if File.hasWriteAccess curdir
            
                build = (file, curdir) ->
                    static_lib_dirname = curdir + '/static/lib'
                    file_ext = Path.extname file
                    file_base = Path.basename file, file_ext
                    file_rel_path = Path.dirname(file).substr folder.length for folder in [curdir + '/client/', curdir + '/general/'] when file.indexOf(folder) is 0
                    file_path = static_lib_dirname + '/' + (if file_rel_path isnt '' then file_rel_path + '/' else '')
                    File.ensurePathExists file_path
                    file_js_name = file_path + file_base + '.js'
                    add_js_file_to_git = not Fs.existsSync file_js_name
                    switch file_ext
                        when '.coffee' 
                            command = "coffee"
                            params = ['-c', '-o', file_path, file]
                        when '.js'
                            command = "cp"
                            params = [file, file_js_name]
                        else
                            command = param = undefined
                        
                    if command? then do (file, file_base, file_js_name, add_js_file_to_git) ->
                        self.compile_process[file] = child_process.spawn command, params
                        self.compile_process[file].addListener 'exit', (code) ->
                            child_process.exec 'git add ' + file_js_name if add_js_file_to_git
                            if file_rel_path.indexOf('locco') is 0 and file_base.indexOf('.spec') is -1 then build_lib_package()
                            delete self.compile_process[file]
                        
                    build_lib_package = ->
                        bundle_filename = 'locco.js'
                        files = File.readDirDownSync static_lib_dirname
                        files = (file.substr(static_lib_dirname.length + 1) for file in files)
                        bundle_file = ''
                        bundle_known_files = {
                            'locco/intention.js'
                            'locco/data.js'
                            'locco/action.js'
                            'locco/document.js'
                            'locco/workflow.js'
                            'locco/interface.js'
                            'locco/actor.js'
                            'locco/reserve.js'
                            'locco/prototype.js'
                        }

                        put = (pathname) ->
                            try
                                file_content = Fs.readFileSync static_lib_dirname + '/' + pathname
                                bundle_file += 
                                    """
                                if (typeof window !== "undefined" && window !== null) { window.previousExports = window.exports; window.exports = {} };
                                #{file_content}
                                if (typeof window !== "undefined" && window !== null) { window.modules['#{pathname.replace ".js", ""}'] = window.exports; window.exports = window.previousExports };
                                
                                
                                """

                        sort = (a,b) ->
                            name = (path) ->
                                if (i = path.lastIndexOf '.') >= 0 then path[0...i] else path
                            if name(a) > name(b) then 1 else if name(a) < name(b) then -1 else 0
    
                        for own filename of bundle_known_files then put filename
                        for filename in files.sort(sort) when bundle_known_files[filename] is undefined and filename.indexOf('locco') is 0 and filename.indexOf('.spec') is -1 and filename isnt bundle_filename then put filename
                            
                        Fs.writeFileSync static_lib_dirname + '/' + bundle_filename, bundle_file                    
            
                file = curdir + '/' + file if curdir is '.'
                if (file.indexOf(curdir + '/client/') is 0 or file.indexOf(curdir + '/general/') is 0) then build file, curdir

            self.log 'CHOCOLATEJS: Restarting because of ' + event + ' file at ' + file
            
            setTimeout (-> self.restart()), 1000

        this.watcher = Chokidar.watch curdir, ignored: filter, persistent: yes, ignoreInitial:yes
        this.watcher.on 'add', on_add
        this.watcher.on 'change', on_change
        

    "unwatchFiles": ->
        this.watcher.close()

monitor_server.start()
