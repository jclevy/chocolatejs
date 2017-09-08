## v0.0.25 - (2017-09-08)

--------------

NEW FEATURES

 - added relational-like services in `lateDB`, with insert, join and query capabilities

        db.tables.create 'colors'
        db.tables.insert 'colors', id:1, name:'white'
        db.tables.insert 'colors', id:2, name:'black'
        
        db.tables.create 'brands'
        db.tables.insert 'brands', id:1, name:'Mercedes'
        
        db.tables.create 'cars'
        db.tables.insert 'cars', id:1, name:'SLK 200', color_id:1, brand_id:1
        db.tables.insert 'cars', id:2, name:'SL 600', color_id:2, brand_id:1
        
        lines = db.tables.query
            select: 'cars.brands(*)'
            sort:['name']
        
        lines = db.tables.query 'Car',
            filter: (line, keys, tableName) -> 
                line.name.indexOf('SL') isnt 0

 - added basic gzip compression support (`"compression": true`, in app.config.json file) on https(s) responses for text/plain, text/html, text/javascript and application/json requests accepting gzip response


UPDATES
 - updated LateDB section in README.md
 - updated Locco Interface section in README.md

 - in `general/latedb`: 
   - the `load` function is made synchronous so that data is made available immediately
   - added an alternative `update` usage to copy an object in the database
    
            db.update
                'key 1': 'data 1'
                'key 2': 'data 2'
                , (data) -> for k,v of data then @[k] = v
        
 - in `server\reserve`:
   - breaking changes in usage that provide lateDB's services through `reserve`'s services
   - a `constants` service is now available as a `space` property
     - this service requires a `data/constant` js or coffee file that returns an object
 - in `general/locco/interface`: 
   - client-side Interface.Web `actor`'s property initialized to main `actor` when this interface does not already belong to an actor
   - `space` is a new property available in `Interface`'s `this` object alognside `bin/props`, that gives access `space`'s lateDB services (`db` and `constants`)
 - in `general/chocodash`: `_.prototype` service now accepts `use` an object instead of a function to add some definitions in the prototype
 - in `server/monitor` set `process.env.HOME = @appdir ; process.env.USER = @user` if an user is specified when starting the app (`--user`)
 - in `client/litejq`, default datatype for `$.get` is now `guess` that will accept `xml, json, script, text, html`
 - updated coffee-script to 1.12.6
 - updated back ws to 0.8.1
 - breaking changes in `server/reserve` usage
 - removed sqlite3 from Chocolate's dependencies

FIXED BUGS

 - in `server/monitor`: `build_lib_package` was not working anymore due to a recent change in `normalize` impacting `readDirDownSync`
 - in `general/locco/interface`: `props` and `keys` were lost in sub-interfaces but `bin` was not lost
 - in `server/file` : 
  - `moveFile` was normalizing destination path before giving it to `writeToFile`
  - convert to string results returned by the `grep` command as it may be Buffer instead of String


## v0.0.24 - (2017-05-17)

--------------

NEW FEATURES

 - `chocolatejs` can now handle proxying websockets

UPDATES

 - better console.log redirection if using `log.inFile` parameter in `data/app.config.json` config file
 - updated README.md with LateDB section
 - updated microtime to 2.1.3
 - updated ws to 2.3.1

FIXED BUGS

 - in `general/interface`, the review method was missing the `actor` property in its `this` context
 - in `server/workflow`, an empty json string result was not handled correctly

## v0.0.23 - (2017-05-07)

--------------

NEW FEATURES

 - added `general/lateDB`: a very simple database system.
  
    `lateDB` provides you an in-memory javascript space that you can modify with an `update` method

            db.update('key': { op: func, data: some_data });
            
    i.e. (in Coffeescript):
    
            db.update 'result':
                op: (data) -> (@log ?= []).push data
                data: "done"
    
    or in Javascript:
    
            db.update({
              'result': {
                op: function(data) {
                  return (this.log != null ? this.log : this.log = []).push(data);
                },
                data: "done"
              }
            });
    
    will store in the database
    
            {result:{log:['done']}}
    
    `result` is the key parameter which defines a `section`/`table`/`bucket` name, in which you want to store some data
    It contains an `op` field which provides a function to execute on `this` location, and a `data` field which should contain the `data` to provide to the `op` function.
    
    What the `update` service do is that it records the `op` method and the `data` provided in a `log.db` file which will be reloaded and executed next time your app will be restarted.
    
    Your `op` and `data` should rather not produce object oriented data (using the prototyping chain), unless those objets provides a `stringify` method which should write a javascript code in the `log.db` file that will re-create the oject.
    
    And voilà, that's bascially all...

 - in `server/interface`:
   - the `__` context parameter sent to invoked module services now contains:
     - a `websocket` that can be used to send some message to the client when a websocket connection has been established (i.e. when `locco Workspace` is running client-side)
     - a `console` object with a `log` method that will route the log message to the default `console` and to the client through the `websocket` that may be present in the `context` object

UPDATES

 - in `locco/chocodash`: 
  - `_.cell` and `_.observe` are added as functional equivalent to object oriented _.Signal and _.Observer
  - removed `helpers` option from `_.Signal` service
  - `_.stringify` 
      - has now  3 optional modes:
         - `json` :  returns a JSON stringification
         - `js` :  (which is default mode) returns a javascript string to recreate the given object
         - `full` : same as `js` mode, but treats `Array` objects as full object and stringifies values by keys instead of by indexes
      - has a `write` option to define a function that will receive every chunk of string generated during the stringify operation,  
        It can be used to store those string to a file or the send them to a stream. By default it should return the given string.
      - has a `strict` option to tell wether `_.stringify` accepts a user typed object. If not it throws an error.

 - in `server/studio`:
  - list of opened files is now saved in `localStorage`. Those files are reload automaticaly next tile `studio` is opened
  - in `opened files panel`, you can now click on directory entries to go directly there
  - the login toggle button will now display a yellow color when the app is restarting
  - the `dark`theme is now more grey and not brown anymore.
  - a `*` symbol is now also added to the file name displayed in the editor's file selector when the file was modified 

 - in `server/monitor`:
  - the restart service now throttle the requests to 1 per second to avoid unnecessary restarts when few files are generated/rebuilt on a save

FIXED BUGS

 - in `server/studio`
  - errors were not properly displayed in lab execution panel
  - `Specolate` service was crashing when an error was occuring in server side tested code due to a relative pathname of the tested file
 
 - in `general/chocokup`
  - a `box`, `panel`, `header` or `footer` followed by a string was not displaying that string in the produced html

 - in `server/workflow`, better management of `region` to define a system command
 
 - in `server/file`, reorganized code, normalize, resolve and region management (system and app)

 - in `general/newnotes`, put needed resource files for `present` service, inside `/static/vendor/slides`

## v0.0.22 - (2017-03-07)

--------------

NEW FEATURES

 - in `data/app.config.json`, `log` parameters are added :
    - `inFile` (true or false) tells Chcolate to redirect log functions output to `data/chocolate.log` file
    - `timestamp` (true or false) tells Chcolate to add a timestamp to every Console output

            "log": {
                "inFile": true,
                "timestamp": true
            }
    
    - `rewrite` an array of rewrite rules :
    
        `rule`: a regular expression  
        `replace`: a string to replace what will be found by the regular expression
    
            "rewrite": [
                {"rule": "/(.+)_(.+)_(.+)_(.+)", "replace":"/?Library=$1&Book=$2&Chapter=$3&Verse=$4"}
            ]

UPDATES

 - in `app.config.json`'s `proxy` section, you can now specify:
  - a domain port redirection

            "proxy": {
                "lestencrypt": true,
                "redirect": {
                    "mydomain.com": "mydomain.fr"
                }
            }
    
      will redirect mydomain.net requests to mydomain.com port

  - a domain for the proxy service itself:

            "proxy": {
                "lestencrypt": true,
                "proxy_domain": {
                    "proxy.mydomain.com"
                }
            }
            
  - to log proxy events:

            "proxy": {
                "log": true,
            }

 - in `server/monitor`, you can now specify a user to run your `monitor` and app processes.  

        coffee monitor --user myappuser 

   NOTE: this will only work if you start `server/monitor` with a privileged account
   
 - in `server/interface`:
   - now provides the HTTP response object to the called service in the `__` context parameter
   - does not return anymore the `props` property as an alias to the `bin` property in `Interface.Reaction` response to a web request, which was an unnecessary duplicate. When using an `Interface.Actor` clientside, it puts back the `props` property as an alias to the `bin` property.

 - in `server/studio`, does not give results from `node_modules` subdirectories anymore
 - in `data/app.config.json` the`display_errors` parameter is renamed `displayErrors`
 - `http-proxy` node-module upgraded to v1.16.2
 - `logConsoleAndErrors` does not have a `timestamp` parameter anymore as it is managed by the`app.config.json` `timestamp` parameter

FIXED BUGS

 - in `server/studio`, search/grep service was somehow broken
 - in `server/workflow`, 
  - send a response when a proxy error occurs and don't create unnecessary proxy handlers
  - `http` redirection to `https` now includes the requested url
 - in `server/file` `logConsoleAndErrors` service was broken. It should work now. `unlogConsoleAndErrors` was added.


## v0.0.21 - (2017-02-02)

--------------

NEW FEATURES

 - in `data/app.config.json`: `display_errors` parameter tells Chocolate to display errors (or not) on the rendered web page

UPDATES

 - in locco/interface's Interface.Web : 
  - introducing Interface.Web.Global objets that will be automatically copied from one props/bin to sub-interface's bin 
  - only Interface.Web and Interface.Web.Global objects are copied from one props/bin to sub-interface's bin
 
 - in server/interface: 
  - don't add missing html/body tags in response if request is an Ajax call (headers['x-requested-with'] is 'XMLHttpRequest') 
  - add `what` in context passed to invoked module service

 - in server/workflow: Session::addKey and Session::removeKey were added to allow you to add or remove access keys from the Session's keychain 

FIXED BUGS

 - in `server/interface`'s `cook` service, we now trim cookies' key and value in case the client put spaces there
 - in `general/chocodash`'s `clone` service, don't return the original object if only one parameter is provided (target object to receive cloned values not provided), but return the cloned object as expected

## v0.0.20-1 - (2016-11-28)

--------------

NEW FEATURES

 - Added `Javascript` code execution and `Javascript` to `Coffeescript` conversion services in the `Lab` panels
   (thanks to js2coffee.js library)
 
 - Added `Html` code rendering and `Html` to `Coffekup`/`Chocokup` conversion services in the `Lab` panels
   (thanks to htmlkup.coffee library)

 - locco protocol and Interface allows a `redirect` url to be specified and used to generate an HTTP 303 response
        
        service = new Interface
            check -> ...        # if the `check` function returns false 
            redirect: 'login'   # the interface will return an HTTP 303 redirect to the `login` page

 - `monitor.coffee` service now allows you to define Javascript bundles to be build when source files are saved.  
    If you have some client side Coffeescript/Javascript files (in Client or General folders) with the same prefix (or in the same subfolder), they can be bundled in the same file.

    In the `app.config.json` file, add a `build:{bundles:[]}` section, with the following parameters:
    
        filename: the name for the output bundle file
        prefix: the prefix used in (or the path to) every file to put in the bundle
        known_files: an array of files' path, that have to be put in that precise order in the bundle
        with_modules: true or false, to put in the bundle the necessary code to make those files required by the Chocolate's require service
        
        "build": {
            "bundles": [
                {
                    "filename": "locco.js",
                    "prefix": "locco",
                    "known_files": {
                        "locco/intention.js": true,
                        "locco/data.js": true,
                        "locco/action.js": true,
                        "locco/document.js": true,
                        "locco/workflow.js": true,
                        "locco/interface.js": true,
                        "locco/actor.js": true,
                        "locco/reserve.js": true,
                        "locco/prototype.js": true
                    },
                    "with_modules": true
                }
            ]
        }

UPDATES

 - `this` and `bin` available in Locco/Interface's `defaults` and `check` functions

FIXED BUGS

 - `Chocodown` does not insert unnecessary `<p>` tag anymore when it translates `Chocokup` block (`<<<`) or `Coffeescript` block (`{{{`)

## v0.0.19 - (2016-10-06)

--------------

NEW FEATURES

 - `letsencrypt` renewal service now works automaticaly

 - `Single Page Application` can be easily created using `locco/actor`
  
> Create a new service `myservice.coffee`, in which you will define a function that will return an actor that can work both client and server sides :
            
            MyService = ->
                _ = require 'chocolate/general/chocodash'
                Interface = require 'chocolate/general/locco/interface'
                Actor = require 'chocolate/general/locco/actor'
                
                _.prototype inherit:Actor.Web,                   # make your service inherit from Actor.Web
            
                    ping: new Interface.Remote -> "pong"         # use Interface.Remote to have your interface work client and server side 
            
                    login: new Interface.Remote -> @transmit @actor.users, 'login' # in the Interface render code you can use @transmit to delegate the interface handling to another Actor's interface
                    
                    main: new Interface.Web.Html ->              # your actor's interface called main will be used as the default interface
                        # ...
                        # my css and html code written using Chocokup
                        # ...
                        coffeescript: ->
                            # send a message server side when the login button is clicked
                            
                            $("#loginButtonId").on "click", (e) ->
                                loginInfos = login:$("#login").val(), pwd:$("#password").val()
                                self.login.submit(login_infos).subscribe (result) ->
                                    {name} = result.props
                                    if name?
                                        # ...
                            
> Then the server side only services:
            
            Users = _.prototype inherit:Actor,
            
                constructor: ->
                    # @usersDb = ... whatever method you want to store your users' data
            
                login: new Interface ->
                    {login, pwd} = @props
            
                    # user = @actor.usersDb.get login, pwd
                    # ...
            
                logged: new Interface ->
                    # ...
                
> Then the server main interface:
            
            module.exports = _.prototype inherit: _.prototyper(MyService),
                constructor: ->
                    @options = 
                        filename: __filename     # required to have the page's manifest file being managed automatialy
                        name: 'My Service'           # the title displayed by the client window
                        script: """
                                                 # whatever client scripts needed...
                            """
                        stylesheet: """
                                                 # whatever css files needed...
                            """
                     
                    @users = new Users


UPDATES
 
 - can now serve `.pdf` files in `static` folder
 - in locco/interface, data given to an interface service, like  the `render` function, is accessible through an object named `bin`.
  
   Now, you can use  `props` as a synonym to `bin`
   
          myService = new Interface.Web
              defaults: ->
                  title: 'home'
              render: ->
                  div this.props.title
     
   or 
     
          myService = new Interface.Web { title: 'home' }, -> div @props.title
    
   or it is still possible to use `bin`
          
          myService = new Interface.Web { title: 'home' }, -> div @bin.title
    
   The data returned by the Interface also has now a `props` property that can be used as a synonym to `bin`
   
          myInterface.submit(params).subscribe (result) ->
              {name} = result.props
              ...
  
FIXED BUGS

 - in chocokup/coffeekup: a markup with an attribute starting with a point (like style '.mycssclass {color:white}' was wrongly interpreted as an html class id
 - in package.json: works with letsencrypt module version 1.4.4 only
 - in chocodash: Publisher with no subscriber will save notified values until a reporter has subscribed
 - 

## v0.0.18 - (2016-06-21)

--------------

NEW FEATURES

 - add .chocokup files support
  - Chocokup files are `html` files written with a Coffeescript syntax
  - Using `Code` and `Doc` panel side-by-side you can design Html page easily
  - When you save a `.chocokup` file in the `client` folder, it is immediately converted to an `html` file in the `static/lib` folder

UPDATES
 
 - text written in `Coffeescript` or `Chocodown` Lab panels are saved in local storage, so you can get them back on page reload
 - updated Ace to package April.16.2016

FIXED BUGS

 - in `coffeekup.coffee`: when a tag has only one attribute and this attributes starts with a dot then it is correctly interpreted as a css class declaration
  
     `i '.icon'` is now correctly translated to `<i class="icon"> ` instead of `<i>.icon</i>`

## v0.0.17 - (2016-06-08)

--------------

NEW FEATURES

 - Free SSL certificate generation using `letsencrypt` service!
  - configure in `data/app.config.json`:

            "letsencrypt": {
                "domains": [ "yourdomain.com" ],
                "email": "you@yourdomain.com",
                "agreeTos": true,
                "production": true,
            }
            
  - put `false` in `production` parameter to test certificate generation
  - generated certificate should appear in `data/letsencrypt/live/yourdomain` folder
  - your certificate will be renewed and the app restarted, automatically after approximately 90 days
  - you can put many domains in the same certificate `"domains": [ "yourdomain.com", "theirdomain.com", "ourdomain.com" ]`
  - you **have** to explicitly add an entry with `yourdomain` prefixed with `www` if you want to support it
 
      `"domains": [ "yourdomain.com", "www.yourdomain.com" ]`

 - Reverse proxy simple service
  - configure in `data/app.config.json`:

            "proxy": ['yourdomain.com', 'theirdomain.com', 'ourdomain.com']
            
  - `Chocolate` will forward request for those domains to local processes/apps awaiting requests on your proxy app port + 10  
    so if your proxy app is on `8026` port then `yourdomain.com` will be on `8036`, `theirdomain.com` will be on `8046`...
  - if you also use `Chocolate`'s `letsencrypt` feature, you only have to set:

            "proxy": true
            
     and `Chocolate` will use the domains defined in
    
            "letsencrypt": {
                "domains": [ "yourdomain.com" ],
                ...
                
                
UPDATES

 - in `data/app.config.json` :
  - `port_https` and `port_https` can be defined in `data/app.config.json` and will be used if present when starting the app
  - When `port_https` and `port_https` are not defined in config file but `port` is then `port` will be used as port for `https` and `port+1` for `http`

 - in `server.file`:
  - `logConsoleAndErrors` now add a timestamp on every log entry in `chocolate.log`

## v0.0.16 - (2016-05-31)

--------------

NEW FEATURES

 - `server/config` module is added to manage config files, instead of being defined the `data/config.coffee` file. 
  - Configuration will now be done inside `data/app.config.json` file
  - When `Chocolate` finds a `data/config.coffee` file it copies it's content in `data/app.config.json` if the keys are not already existing ther.
  - So after running once, you can safely remove the `data/config.coffee` file or only parts of it, if it's better for you.
  - If you keep `data/config.coffee` alongside the new `data/app.config.json`, then configurations done in `data/app.config.json` will be overridden by those done in `data/config.coffee`
  - as the `config` module is available in __ params of locco/interface service, you can not anymore directly access config key/values, but you will have to use the `get` method of the `config` object
   
                myservice = new Interface ({__}) -> 
                    configValue = __.config.get 'configKey'


UPDATES

 - in `locco/interface`:
  - `this` in `check` and `locks` function is now defined to `{bin, document:@document, 'interface':@}`
 
 - in server/document:
  - add `throttle` option in Cache and Structure class to define time to wait between successive `hibernate` calls
  - add `reload` method in Cache class to reload the cache from file
  - add `save` method in Cache class to put save the cache to file
  - add `clone` method in Cache class to clone an object from the cache
  - add `set` method in Cache class to put a new value to cache and immediately hibernate the cache
  - add `update` method to allow the update of many keys at once syncing from an optional external store and saving updates on file immediately

 - in `general/chocodash`:
  - add `_.Cuid` generator from Eric Elliott
  - allow `_.throttle` to receive no options parameter, `_.throttle -> #do something max once a second`

 - in `general/coffeekup`:
  - coffeekup id generator replaced by the Cuid generator from Eric Elliott

 - in `server/interface`:
   - access to the `client`, `general` and `server` folders is now restricted
     - as a standard user you can only call functions called `interface` in modules of those folders
     - other functions defined in modules of those folders are accessible only from other modules on the server
     - a user with the `sofkey` can access every function in those modules
 
 - in `server/monitor`:
  - now also restarts the app when a file with suffix `.config.json` is modified

 - in `data/config` or now in `data/app.config.json`, if you add a default page handler to which redirect unkonwn pages, you have to use an Array and not a Function to pass value as a key index:

        before:
            exports.defaultExchange = where:'demo', what:'showme', params: name: -> 0
        
        now:
            exports.defaultExchange = where:'demo', what:'showme', params: name: [0]

    - `where`: module name you want to call for every unknown page
    - `what`: function name in the module do call (if omitted the module itself will be called)
    - `params`: params to pass to the function. If the param value is an array, then the value(s) in the array will be used as key index(es) to the original params. 0 is the page path and 1...N are the querystring parameters' value

FIXED BUGS

 - in locco/interface:
  - `TypeError: Object true has no method 'call'` in Interface.Web.submit 
 
 - in server/document:
  - bug in asynchronous hibernate (typo)

 - in general/coffeekup:
  - attributes with `undefined`, `null` and `false` values are not rendered anymore
 
 - in server/file:
  - `logConsoleAndErrors` now works better on consecutive calls to `console` functions like `console.log`

## v0.0.15 - (2016-05-18)

--------------

NEW FEATURES

 - in server/studio:
  - new snippets availble for Locco and Chocodash:

            # Require Locco Interface
            snippet locco_require_interface
            
            # Locco full Interface
            snippet locco_interface_full
            
            # Locco full Interface.Web.Html
            snippet locco_interface_html_full
            
            # Locco standard Interface.Web.Html
            snippet locco_interface_html_standard
            
            # Locco minimal Interface.Web.Html
            snippet locco_interface_html_minimal
            
            # Chocodash require
            snippet require_chocodash
            
            # Chocodash async or flow
            snippet chocodash_async_or_flow

  - you can add user defined snippets in data/config.coffee

            exports.snippets:
                coffee:"""
                # New Service Page
                snippet service_page
                \tInterface = require 'chocolate/general/locco/interface'
                \tmodule.exports = new Interface.Web.Html
                \t\tdefaults: ->
                \t\trender: ->
                """
 - in data/config, you can add a default page handler to which redirect unkonwn pages

            exports.defaultExchange = where:'demo', what:'showme', params: name: -> 0
            
    - `where`: module name you want to call for every unknown page
    - `what`: function name in the module do call (if omitted the module itself will be called)
    - `params`: params to pass to the function. If the param value is a function, then the returned value will be used as a key index to the original params. 0 is the page path and 1...N are the querystring parameters' value
                

UPDATES

 - in server/interface:
  - you can now directly export an Interface.Web object in a file module without the 'interface' attribute
            
            Interface = require 'chocolate/general/locco/interface'
            module.exports = 
                new Interface.Web -> div 'Hello'
            
        instead of 
                        
            Interface = require 'chocolate/general/locco/interface'
            exports.interface = 
                new Interface.Web -> div 'Hello'
  - config module available in __ params of locco/interface service

 - in locco/interface:
  - 'render' replaces 'action' in interface definition. 'action' stays available as a 'render' synonym
    
            html = new Interface.Web.Html
                action: ->
                    div 'Hello World'
        
        is equivalent to the new preferred syntax:
                
            html = new Interface.Web.Html
                render: ->
                    div 'Hello World'

  - 'check' replaces 'values' in interface definition. 'values' is not supported anymore

  - bin content becomes available in 'render' function arguments:
            
            demo = new Interface
                render: ->
                    {who, where} = @bin
            
            demo = new Interface
                render: (bin) ->
                    {who, where} = bin
            
            demo = new Interface
                render: ({who, where}) ->
            
            demo = new Interface ({who, where}) ->
    
  - 'defaults' can be passed as a param to an interface definition
 
            html = new Interface.Web.Html {menu}, -> menu()

  - Interface.Web code rewritten to manage naming collision in different module
 
  - in Interface.Web render function, this.keys is an array with the names of the values copied in this.bin

 - in locco/chocodash:
   - added _.clone function to enable object deep copy

FIXED BUGS

  - in locco/interface
    - review is done properly on Web interfaces just before de render function is called and not globally at begining
    - make available __ context in bin arguments of sub interfaces
    - make available locals (like _ and Chocokup) as local variable of sub interfaces

## v0.0.14 - (2016-05-09)

--------------

NEW FEATURES

 - added debug mode using node-inspector (add exports.debug = true in data/config.coffee then connect to http://myserver:8081/debug?ws=myserver:8081&port=5858
 - monitor.coffee, workflow.coffe: replace uncaughtException handling with a more general logging system serialized to a ./data/chocolate.log

 
UPDATES

 - in chocokup.coffee
   - added Chocockup.Html as an alias to Chocokup.Panel
   - support functions in coffeescript markup attributes
 - in locco/interface.coffee:
   - an Interface submit now has its steps function moved out review. So we have: review, steps and then action. 
     - 'review' is there to prepare the interface and check if we can use it
     - 'steps' is there to execute internal actions before responding to the request
     - 'action' is there to react to the submit
   - added Interface.Web.Html as an alias to Interface.Web.Panel
 - added 'exports.debug = false # http://myserver:8081/debug?ws=myserver:8081&port=5858' in chocomake to show debug option in new projects
 - added params in server/interface.coffee 'context' so params are also available in @bin.__ in a locco/interface
 - updated chokidar to v1.4.3
 - updated microtime to v2.1.1
 - updated sqlite3 to v3.1.3


FIXED BUGS

 - in locco/interface: values ans steps declaration were defaulted with _.defaults, but they are functions (so no more _.defaults on them)!
 - in chocokup.coffee: render attributes when an empty string is specified
 - in locco/interface.coffee: 
   - defaults in sub interfaces not handled properly
   - recursive interfaces not handled properly and reviewed infinitely
   - cleaned bin in Interface object before review'ing' it's content
 - in workflow.server: allow array arguments in request. Just have to repeat the &field=value


## v0.0.13-1 - (2016-04-13)

--------------

NEW FEATURES

 - Studio
  - added Login/Logoff indicator, switch and key input
  - added switch to toggle wrap mode on or off in editor
  - added Literate CoffeeScript support (use .litcoffee file type)
  - added Json file support in editor
  - added basic element creation support $('<tag/>') in liteJq
 - monitor.coffee: 
  - added memory param to define node.js --max-old-space-size param
  - added named params --appdir, --port, --memory

UPDATES

 - __ is a Chocolate context given to every remotely called exported module function 
 - __.appdir is relative path from Chocolate system directory to application directory
 - __.sysdir is relative path from application directory to Chocolate system directory
 - updated coffee-script to 1.9.1
 - server/Document.Cache: added async mode to access file and made it default mode

FIXED BUGS

 - corrected -webkit-overflow-scrolling:touch in Chocokup body CSS
 - static file now seen as 'app' if `how` query parameter isnt 'web' ; otherwise seen as 'static' even if with other params (can pass parameters to static files.)
 - correctly load CoffeeScript in chocodown.js if run server side on node.js
 - remove 'chocolate' from `require`d url if used to load Chocolate libs from static folder
 - File::moveFile was not working correctly anymore
 - Upload service was not working anymore - name attribute was missing on iframe
 - _.super can be called in _.prototype declared constructor

## v0.0.12 - (2015-03-30)

--------------

NEW FEATURES

Studio

 - introduced Light theme (now by default) white-grey/blue, that you can switch back (use the up right □ symbol) to Dark original chocolate theme
 - added a dropdown selector to help you switch between opened files
 - added a up right `close` button to give another place to close the currently opened file
 - added a up right `show invisible` button to show or hide the `space`, `tab` and `return` chars
 - added a CTRL-U/CMD-U shortcut to insert a UUID in the code

liteJq, server/Interface and server/Workflow

- Websocket is now supported (with with poling fallback) to allow message exchange between client and server in both size  

chocodown.js

- Turn {{ javascript }} and {{{ coffeescript }}} blocks into `script` blocks
- Turn <<< Chocokup >>> blocks into html blocks
 
locco/Document, locco/Workflow, locco/Interface, locco/Actor

- lot of work done but not yet ready

UPDATES

Locco

- Interface options don't need the `rules` keyword anymore. Just put `defaults`, `values`, `locks` before the `action` section. `rules` is not recognize now.

liteJq 

- taking care of javascript when inserting html block - eg: $('.myClass').html()
- added json-late format: json Chocolate format which allows to save functions, date... in json-like notation
- added `after` function that allows inserting after a DOM node

chocodash

 - added `_.isObject`: returns true if value is not a primitive
 - added `_.isBasicObject`: returns true if value constructor is {}.constructor
 - added `_.param`: transforms a javascript value to an url query parameter
 - added `_.extend`: copies values from an object to another object

Studio

- the opened files panel now keeps a link to the last 10 opened files (instead of 5)


## v0.0.11 - (2014-04-11)

--------------

UPDATES

Chocodash

- _.super was working only in a simple case

FIXED BUGS

Chocodash

- static/lib/chocodash.js was not correctly recompiled in v0.0.10

Locco

- Interface replaced @rules and @action by provided params in constructor instead of merging them


## v0.0.10 - (2014-04-07)

--------------

NEW FEATURES

Chocolate directory structure

- moved vendor libraries from /static to /static/vendor
- renamed **/general/intentware** folder to **/general/locco**  
  You **should** update references to this folder if you use it in your Chocolate application
- renamed **/static/ijax** folder to **/static/lib**  
  You **should** rename this folder if you have one in your Chocolate application
- renamed **/static/ijax/ijax.js** file to **/static/lib/locco.js**  
  You **should** rename this file if you have one in your Chocolate application

Locco Interface:

- introduce `Interface` service that manages security, defaults and values valid range
- `Interface.Web` to easily create web app interface with Chocokup

Chocokup:

- added the `id([value])` function to generate ids (added in coffeekup)

        button "##{id()}", i for i in [9..0]
  
- can pass parameters to embedded coffeescript block

        ids = clear: id()
        body -> button "##{ids.clear}", "clear"
        coffeescript {ids}, ->
            $ -> 
                $("##{ids.clear}").on "click", -> alert "clear"

- produced code is now not formatted (meaningfull whitespace problem).  
  Should use the `format` parameter.
- more isolated parameters: @__.content() instead of @content (idem for @body and @head) in kups
- Chocokup.App to include Chocodash, litejQ, Coffeescript, Locco
- Chocoss:
  - preparing Chocokup Css Framework 
  - added Eric Meyer's Reset CSS v2.0  
  - introduced Css themes: reset(default), paper, writer, coder

Chocodash:

 - renamed Chocoflow into Chocodash
 - started to move javascript utilities into Chocodash:
   - \_.type, \_.Type, \_.defaults, \_.serialize, \_.parallelize, \_.stringify, \_.parse
   - \_.Signal, \_.Observer and \_.Publisher implement reactive programing services (from Reactor.js)
   - add Class-like service with \_.protoype (with inherit, adopt and use)
   - \_.Uuid:
     - added an interface in Uuid so that /-/general/locco/uuid displays a new Uuid

Chocodown:

- adds the formatChocokup option in Chocodown.converter

Coffeekup:

- added the `id` helper function that will return an incremental id
- Locco now independent from Mootools (works with litejQ or jquery) 

Studio

- in Chocodown panel, you can specify wether you want embedded Chocokup code to produce formatted HTML
- Specolate has a better error handling
- console.log is now copied in Studio message box

FIXED BUGS

- header and footer when not in a Chocokup Panel work as standard HTML5 tags
- renamed internal Coffeekup 'data' variable to '__data' to avoid colisions
- display error produced in Interface.exchangeSimple when user has sofkey privileges
- removed Chocokup **title** helper. Now **title** works as a standard html tag
- added Chocokup Core Css in Chocodown Lab view
- added `panel` css class to Chocokup panels so it can be styled
- removed useless `div` in Chocokup panels
- Chocolate's module loader is more robust
- server/interface forget-key renamed to forget-keys

UPDATES

- updated coffee-script to 1.7.1
- updated Ace to package March.08.2014


## v0.0.9 - (2013-12-04)

--------------

NEW FEATURES

- **litejQ** : a lite jQuery-compatible library (9kb compressed and gziped) 
  aimed at replacing Mootools in Chocolate and becoming its client-side scripts foundation.
- with Chocodown
 - inline tests: open litejQ documentation (/general/docs/doc-litejq.md) 
   and open the doccolate panel (Doc) to see the `check` function working
- in Locco:
 - can call a function in a sub-object inside a module  
  `https//myserver/mymodule?MyObject.function?param1&param2`
 - params can be unnamed and numeric when calling a function inside a module  
  `https//myserver/mymodule?add?123&9872`
- in Studio:
 - can change debug evaluation column width by pressing +/- buttons 
- in Newnotes:
 - create a new note by pressing Return 
 - when editing, create a new note by pressing Return if cursor at the end
 - when editing, insert a newline with Ctrl + Return or Shift + Return or press only return if not at note's end
 - toggle a note by pressing Shift-Return
 - toggle note priority by pressing Ctrl-Return when not editing
 - insert a new note before a note with Alt + Return
 - split a note in two notes with Ctrl-Shift-Return when editing

FIXED BUGS

- static files can be created or deleted through studio interface in an app
- deleting a file was copying it in default.coffee!
- can pass parameters to static files. They were seen as 'app' instead of 'static' if with params
- don't execute debug compilation in coffeescript lab when debug panel is hidden
- problem in debug panel with multiple empty strings ('')
- chocokup css helper did not understand @media clause

UPDATES

- updated Newnotes documentation
- updated Ace to package 12.02.2013


## v0.0.8 - (2013-10-01)

--------------

NEW FEATURES

- Basic **autocomplete and snippets** services introduced in editor
- First step in **ChocoDB** : write and read Javascript object in database
- Added Chocoflow: basic **serialize** and parallelize services
- Added a basic **profiling** tool to Debugate
- Synchronize editor view with Documentation (Docco) view
- Changed Locco **test** command to the more appropriate **eval**

FIXED BUGS

- synchronisation problems removed in Coffeescript Lab debug panel
- make Specolate unit tests work better client side (force module loading and clean)
- force resize editor view when switching between horizontal and vertical side-by-side

UPDATES

- updated Ace to package 07.31.2013
- updated node-sqlite3 to 2.1.17
- updated coffee-script to 1.6.3

 
## v0.0.7 - (2013-07-10)

--------------

NEW FEATURES

- Newnotes: add automatic refresh on remote change
- Chocokup: add Css support (write Css with Coffeescript syntax) 
- Chocodown: add .chocodown .cd support in Studio
- Chocodown: add .chocodown .cd support as static file type

FIXED BUGS

- replace div with iframe for Doccolate panel in studio
- removed a bug introduced in v0.0.6 (alert in Coffeescript debug mode)

UPDATES

- add Css support for Chocokup sample in README.md


## v0.0.6 - (2013-07-01)

--------------

NEW FEATURES

- Replaced *Chocokup lab* by **Chocodown lab** (literate style web dev using Markdown)
- Enhanced *Debug Lab* display : vertical scroll sync between Coffescript and Debug panels
- Updated Help to introduce Chocodown
- Updated ReadMe to replace Chocokup Lab with Chocodown Lab section

FIXED BUGS

- Column alignment for values fixed in Lab with Coffeescript debug mode


## v0.0.5 - (2013-06-24)

--------------

NEW FEATURES

- allow binary file in Locco 'move' verb
- now specolate specs receive system context variable in jasmine.getEnv().__
- allow file basic upload
- allow list and open every file type

FIXED BUGS

- replace static strings in the Lab before Debug so that = and [ dont break
- clean File.coffee code to allow all file types
- reintroduced javascript execution in Chocokup lab (it disappeared with iframe usage)

UPDATES

- updated Ace to package 06.04.2013

## v0.0.4 - (2013-05-03)

--------------

NEW FEATURES

- simplified and enhanced Chocokup use in Chocodown : use `! chocokup` and `#! chocokup` in `code` block to execute Chocokup or to highlight and then execute Chocokup code
- added JSON output type in Newnotes.Present (`as` parameter can be: paper, impress or json). It helps export Newnotes branches.
- added `keypass` parameter inconfig.coffee file to enable master key (sofkey) bypass ; enable demonstration mode when used with access restriction on files

FIXED BUGS

- enhanced monitor.config to wait for child process to exit on SIGTERM before exiting ourself so that Upstart can cleanly stop us
- Specolate did not work serverside because jasmine-node module was missing from package.json
- Specolate was no working with appdir module specs and with nonexistent module

## v0.0.3 (2013-04-19)

--------------

NEW FEATURES

- Html support added in Studio
- Nice interface to register/unregister access keys
- Make Chocokup playgroud/sanbox independant in an iFrame
- Make Git history follow files renames
- Add file Rename/Delete services

FIXED BUGS

- make Http only Chocolate server really work!
- make ?how=edit use file type to set correct Ace language parser
- files could not be saved in static folder - static was only available to read file
- locals variable can be declared in Chocokup param and not only in Chocokup.render
- helpers variable can be declared in Chocokup to  provides helpers functions or sub-templates to a main template
- clear Coffeescript JS panel when ther is an error
- added __ parameter documentation

## v0.0.2 (2013-04-05)

--------------

NEW FEATURES

- better Bootstrap compatibility with Chocokup
- http only webapp - use config.coffee file with exports.http_only = yes
- move port, key and cert parameters in config.coffee
- better Chocokup and General error info returned by Chocolate

FIXED BUGS

- cpu to 100% with fresh project
- editing code in lab panel is very laggy
- 'body' does not work in chocokup when not used in panel
- 'static' folder missing
- incorrect Monit sample to supervise the upstart daemon
- update client libraries:
  - coffescript: 1.6.2
  - jasmine: 1.3.1
  - ace: build 2013-03-14
- .js documents don't always work in editor

##v0.0.1 (2013-03-24)

----------------

Initial public release

