             ())
           ((  ) )                         _____ _                     
          ( )(  ) )                       / ____| |                    
      _ (.( ) .)(.( )) _                 | |    | |__   ___   ___ ___  
    (  ( ).( ) (.)( ).)  )               | |    | '_ \ / _ \ / __/ _ \ 
    |`-..___________ ..-'|               | |____| | | | (_) | (_| (_) |
    \                   /                 \_____|_| |_|\___/ \___\___/ 
     |                  ;---.
     |                  (__  \           | |         | |       (_)     
     |                  |  )  )          | |     __ _| |_ ___   _ ___  
     |                  | /  /           | |    / _` | __/ _ \ | / __| 
     |                   (  /            | |___| (_| | ||  __/_| \__ \ 
     /                  \ _/             |______\__,_|\__\___(_) |___/ 
    |                    |                                    _/ |     
     `-..____________..-'                                    |__/      
                                                     

## Chocolate - Full stack Node.js framework

Chocolate is an experimental and isomorphic Node.js webapp framework built using Coffeescript. 

It includes :

 - **Chocolate Studio** -- an **online IDE** (with Coffeescript, Javascript, Css and Markdown support)

 - **Locco** -- the Chocolate protocol : so, what, where, how...

 - **Chocolate playground** -- an online and immediate **playground** for Coffeescript, Chocokup and Doccolate

 - **Chocokup** -- a 100% pure CoffeeScript templating language that helps build web user interfaces (based on Coffeekup)

 - **Chocodown** -- Chocokup-aware port of Markdown (based on Showdown)

 - **Specolate** -- a behavior/test driven development tool (based on Jasmine) that works client and server side

 - **Doccolate** -- an online documentation editing tool (based on Docco)

 - **Chocodash** -- toobox for javascript object identity, types, serialization and asynchronous calls and signals management

 - **liteJq** -- a lite jQuery-compatible library

 - **Chocoss** -- a Css framework

 - **ChocoDB** -- a kind of nosql database running on SQLite

 - a basic **source control** with Git

 -  **NewNotes** -- a promising note taking tool

Chocolate integrates:

 > [Node.js](http://nodejs.org) - [Coffeescript](http://coffeescript.org) - [Ace](http://ace.ajax.org) - [Docco](http://jashkenas.github.com/docco/) - [Coffeekup](http://coffeekup.org) - [Jasmine](http://pivotal.github.com/jasmine) - [Reactor](https://github.com/fynyky/reactor.js) - [Highlight.js](http://softwaremaniacs.org/soft/highlight/en) - [Showdown](https://github.com/coreyti/showdown) - [Ccss](https://github.com/aeosynth/ccss) - [Git](http://git-scm.com) - [Impress](http://bartaz.github.com/impress.js/#/bored)

&nbsp;

---

## Version

**Chocolate v0.0.12 - (2015-03-30)**

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


See history in **CHANGELOG.md** file

&nbsp;

---

## <a name="Choco-Summary"></a> Summary

 - [Demo](#Choco-Demo)
 - [Installation](#Choco-Installation)
 - [Use it](#Choco-UseIt)
   - [Log on](#Choco-UseIt-LogOn)
   - [Log off](#Choco-UseIt-LogOff)
   - [Enter Chocolate Studio](#Choco-UseIt-Enter)
   - [Web access to source files and functions](#Choco-UseIt-Source)
   - [Locco main operations](#Choco-UseIt-Locco)
 - [Chocolate Studio](#Choco-Studio)
   - [Autocomplete and snippets](#Choco-Automplete)
   - [Spec, Doc, Lab, Help and Notes panels](#Choco-Studio-panels)
 - [The Lab](#Choco-Lab)
 - [How to write Modules](#Choco-WriteModules)
 - [ChocoDB](#Choco-DB)
 - [Chocodash](#Choco-Dash)
   - [Javascript type management](#Choco-Dash-Type)
   - [Better than Class with Prototypes](#Choco-Dash-Prototype)
   - [Defaulting properties](#Choco-Dash-Defaults)
   - [Reactive services with Signals](#Choco-Dash-Reactive)
   - [Asynchronous calls made easy](#Choco-Dash-Async)
   - [Javascript object serialization](#Choco-Dash-Stringify)
   - [Uuid](#Choco-Dash-Uuid)
 - [Debugate](#Choco-Debugate)
 - [Chocokup](#Choco-Chocokup)
   - [Usage](#Choco-Chocokup-Usage)
     - [Chocokup.Document](#Choco-Chocokup-Document)
     - [Chocokup.Panel](#Choco-Chocokup-Panel)
   - [Reference](#Choco-Chocokup-Reference)
 - [Chocoss](#Choco-Chocoss)
 - [Locco](#Choco-Locco)
   - [Protocol operations](#Choco-Locco-operations)
   - [Interface](#Choco-Locco-Interface)
   - [Interface.Web](#Choco-Locco-Interface-Web)
 - [Specolate](#Choco-Specolate)
   - [Usage](#Choco-Specolate-Usage)
 - [Doccolate](#Choco-Doccolate)
 - [litejQ](#Choco-litejQ)
 - [Newnotes](#Choco-Newnotes)
   - [Newnotes-Usage](#Choco-Newnotes-Usage)
   - [Impress.js with Newnotes !](#Choco-Newnotes-Impress)
   - [Reference](#Choco-Newnotes-Reference)
 - [Road Map](#Choco-RoadMap)
 - [License](#Choco-License)

&nbsp;

---

## <a name="Choco-Demo"></a> Demo [⌂](#Choco-Summary)

There is a non-writable demo at : <https://demo.chocolatejs.org/>

---

## <a name="Choco-Installation"></a> Installation [⌂](#Choco-Summary) 

This procedure was tested as **root** on Debian 6.0

### Prerequisites

Chocolate needs Node.js. If you need to install it, here is a procedure to:

**Install Node.js**

    apt-get update
    apt-get install python
    apt-get install git-core curl build-essential openssl libssl-dev
    mkdir -p /tmp/build/node
    cd /tmp/build/node
    git clone https://github.com/joyent/node.git .
    git checkout v0.10.0 #Try checking nodejs.org for what the stable version is
    ./configure --openssl-libpath=/usr/lib/ssl
    make
    make install

**Make node modules accessible everywhere**

 -- In /etc/profile, append :
 
    export NODE_PATH="/usr/local/lib/node_modules"

&nbsp;

You can use start, stop and monitor Chocolate's daemon if you:

**Install Upstart, Monit and Sudo**

    apt-get install upstart
    apt-get install monit
    apt-get install sudo

&nbsp;

Chocolate also needs:

**Other prerequisites**

    apt-get install openssl
    apt-get install git
    apt-get install sqlite3
    apt-get install libsqlite3-dev

&nbsp;

### Install Chocolate:

    npm install -g chocolate

&nbsp;

**Create Chocolate user to start Chocolate daemon**

    useradd chocolate
    mkdir /home/chocolate
    usermod -d /home/chocolate -s /bin/bash chocolate

**Run chocomake to create myapp**

    cd /home/chocolate
    chocomake myapp

Answer asked questions to create a self-signed SSL certificate.

**Change chocolate files owner**

    cd /home
    chown -R chocolate:chocolate chocolate

&nbsp;

**Install Chocolate as daemon**

    vi /etc/init/chocolate.conf

        #!upstart
        description "Chocolate node.js server"
    
        start on startup
        stop on shutdown
    
        script
        exec sudo -u chocolate -i /usr/local/lib/node_modules/coffee-script/bin/coffee /usr/local/lib/node_modules/chocolate/server/monitor.coffee /home/chocolate/myapp 2>&1 >> /var/log/node.log
        end script

    chmod 755 /etc/init/chocolate.conf

**Install Monit to supervise the upstart daemon**

    vi /etc/monit/conf.d/chocolate.conf

        #!monit
        set logfile /var/log/monit.log
         
        check host nodejs with address 127.0.0.1
            start program = "/sbin/start chocolate"
            stop program = "/sbin/stop chocolate"
            if failed port 8026 type TCPSSL protocol HTTP
                request /
                with timeout 10 seconds
                then restart
         
     # unless it it's configured
     # please configure monit and then edit /etc/default/monit
     # and set the "startup" variable to 1 in order to allow
     # monit to start

    vi /etc/monit/monitrc

    # remove comment on line :
    #   set daemon  120           # check services at 2-minute intervals 
     
    /etc/init.d/monit start

**Reboot**

Please **reboot** to activate Upstart and Monit...

**Run chocolate**

    start chocolate

&nbsp;

---

## <a name="Choco-UseIt"></a> Use it [⌂](#Choco-Summary)

Chocolate runs on your server and responds to https requests on port 8026

You can change port number in /etc/init/chocolate.conf where you add the **port** parameter after  `/home/chocolate/myapp` at line:

    exec sudo -u chocolate -i /usr/local/lib/node_modules/coffee-script/bin/coffee /usr/local/lib/node_modules/chocolate/server/monitor.coffee /home/chocolate/myapp 80 2>&1 >> /var/log/node.log

You can also use a simple Http server by specifying options in the config.coffee file:

    exports.http_only = yes
    exports.port = 80

### <a name="Choco-UseIt-LogOn"></a> Log on [⌂](#Choco-Summary)

You defined a master key when using chocomake to create myapp.

You enter that key at: 

    https://myserver:8026/-/server/interface?register_key

### <a name="Choco-UseIt-LogOff"></a> Log off [⌂](#Choco-Summary) 

To logoff go to : 

    https://myserver:8026/-/server/interface?forget_keys

### <a name="Choco-UseIt-Enter"></a> Enter Chocolate Studio [⌂](#Choco-Summary) 

To enter Chocolate Studio, go to: 

    https://myserver:8026/-/server/studio

There you can create, modify, move and commit source files

### <a name="Choco-UseIt-Source"></a> Web access to source files and functions [⌂](#Choco-Summary) 

You access a file directly in the browser:

To display `default.coffee` as raw text

    https://myserver:8026/default?how=raw

To display `default.coffee` as documentation text (docco)

    https://myserver:8026/default?how=help

To edit `default.coffee`

    https://myserver:8026/default?how=edit

To run `default.spec.coffee` specs (if you create it)

    https://myserver:8026/default?so=eval

### <a name="Choco-UseIt-Locco"></a> Locco main operations [⌂](#Choco-Summary) 

Requests to Chocolate server follow theses rules (the [Locco](#Choco-Locco) protocol main operations):

**https**

By default, Chocolate uses Https:

Http requests are redirected to https  
Https server is located (by default) at port 8026  
Http server is located at port Https+1 (8027)

You can specify options in data/config.coffee file:

    exports.http_only = yes or no
    exports.port = <main port number>
    exports.key = <key filename>
    exports.cert = <cert filename>

**Chocolate system services and files**

They are accessible at:

    https://myserver:8026/-/server...
    https://myserver:8026/-/general...

**Your app services and files**

They are at:

    https://myserver:8026/mydir/myservice...

**Default service in source file**

If your source file exports an `interface` function (ie. in default.coffee):

    exports.interface = () -> 
        'Hello world!'    

Then it is called when you request that file with no parameter:

    https://myserver:8026/default
    
returns a web page with

    Hello world!

You can use the [Interface.Web](#Choco-Interface-Web) service with [Chocokup](#Choco-Chocokup) to produce your Html page :

    Interface = require 'chocolate/general/locco/interface'
    exports.interface = 
        new Interface.Web ->
            div 'Hello world #{world}!' for world in [1..5]

&nbsp;

---

## <a name="Choco-Studio"></a> Chocolate Studio [⌂](#Choco-Summary) 

A sweet web app development environment.

It displays your source files and browse through directories, has a search in files service.  
It has a panel that displays log messages.  
It can also list and open source file commited versions.

You can create, move, rename and delete files.

The central panel has the code editor.
It has syntax highlighting for Coffeescript, Javascript, CSS and Markdown.

<a name="Choco-Automplete"></a>
### <a name="Choco-Studio"></a> Autocomplete and Snippets [⌂](#Choco-Summary) 

It has a basic automplete feature that, by pressing CTRL+SPACE keys, 
proposes you a list of words collected from your file. 

It also has snippets that will expand code from a shortcut:  
in an HTML file, html5+CTRL+SPACE will become: 
    
        <!DOCTYPE html>
        <html>
            <head>
                <meta http-equiv="content-type" content="text/html; charset=utf-8" />
                <title>`substitute(Filename('', 'Page Title'), '^.', '\u&', '')`</title>
                meta
            </head>
            <body>
                body
            </body>
        </html>

Then you can move to *meta* and *body* section by pressing the TAB key.

Currently there are Coffeescript, Javascript, CSS and HTML snippets in the editor.

<a name="Choco-Studio-panels"></a>
### Spec, Doc, Lab, Help and Notes panels [⌂](#Choco-Summary) 

The central panel can also split to display the associated spec file (see [Specolate](#Choco-Specolate))  
or the source file in help mode (see [Doccolate](#Choco-Doccolate))
or the [Lab](#Choco-Lab) that can be used to test Coffeescript or Chocodown code.

The help panel lists some usefull resources. Links will be opened in the central panel.

The [Notes](#Choco-Newnotes) panel allows you to write and save some notes.

**Usage**

    https://myserver:8026/-/server/studio

**Source**

    https://myserver:8026/-/server/studio?how=raw

**Editor shrotcuts**

    https://github.com/ajaxorg/ace/wiki/Default-Keyboard-Shortcuts

&nbsp;

---

## <a name="Choco-Lab"></a> The Lab [⌂](#Choco-Summary) 

The Lab helps you write your code and test cases, syntax...

**Coffeescript Lab**

When you type Coffescript code in the Lab editor, it is immediately translated in Javascript.  
You can use this service to learn Coffeescript but also to verify that your code will do what you expect it should.

Beside beeing translated in Javascript it is also immediately executed.  
And you can see the result in the terminal panel.

But more... when you display the **Debug** panel you can see your variables values through code execution!  
This service is inspired by Bret Victor's [lecture](http://vimeo.com/36579366) (Inventing on priciples).

Copy the following code in the Coffeescript Lab with the Debug panel:

        binarySearch = (key, array) ->
            low = 0
            high = array.length-1
        
            while (low <= high)
                mid = Math.floor((low + high) / 2)
                value = array[mid]
        
                if value > key
                    high = mid - 1
                else if value < key
                    low = mid + 1
                else
                    return mid
            return -1
        
        result = binarySearch 'f', ['a', 'b', 'c', 'd', 'e','f']

Then change the `'f'` to something else and see the Debug panel change in live!

This service is experimental but it has been really useful to me.

**Chocodown Lab**

Literate  programming...

Chocodown panel lets you write Markdown, Chocokup and Coffeescript code that will be 
immediately translated to html and javascript!

But more... when you display the **Dom** panel you can see immmediately the result!

Basicaly, this panel is a Markdown editor, but you can insert code blocks by using
the **#** and the **!** signs followed by the language you want to use:
html, css, javascript, coffeescript, chocokup.

When you use the # sign, Chocodown displays and highlights the following code.  
When you use the ! sign, it executes the code.  
And you can use both **#!**

Copy the following code in the Chocokup Lab with the Dom panel:
    
    ### Here is a basic Chocodown sample:
    
    **Css code**
    
        #! css
        #chocodown-demo .header,
        #chocodown-demo .footer {
            border: 1px solid grey;
            background: maroon;
            color: white;
            text-align: center;
        }
    
    **Chocokup code**
    
        #! chocokup
        panel "#chocodown-demo", ->
            header -> 'header'
            footer -> 'footer'
            body ->
                for i in [0..3] 
                    button "#{i}"
    
    **Coffeescript code**
    
        #! coffeescript
        
        buttons = document.querySelectorAll '#chocodown-demo button'
        for button in buttons
            addEvent = button.addEventListener ? button.attachEvent
            addEvent.call button, "click", -> 
                alert "I'm button #" + @innerhtml


And see...

Then change **[0.\.3]** to **[0.\.6]** and see the result...

&nbsp;

---

## <a name="Choco-WriteModules"></a> How to write Modules [⌂](#Choco-Summary) 

You can create a module by pressing the `Create` button. 
It will create a module with the name you provide in the currently displayed folder.
If you dont put a suffix the the filename, it will create a Coffescript file with .coffee suffix.

Supported file types are: .coffee, .js, .html, .css, .md

If you have asset files you want to be downloadable from the web (like images or js libraries), 
put them in the `/static` folder.

It is supposed that you will put modules that run only in the **node.js** environment in the `/server` folder.
Modules that run only in the browser will go int the `/client` folder, 
and modules that can run in both environment will be put in `/general` folder.

If you put .coffee or .js files in the `/client` or `/general` folder, 
they will be compiled if .coffee and copied to the `/static/lib` folder 
and will be downloadable by your javascript client code (using the provided require function).

If you create a general module (that can work on server and in browser), you will need to write something like the following code:

    class MyGeneralModule
        constructor: ->
            ...
        
    _module = window ? module
    _module.exports = MyGeneralModule

The exported function `interface`, if present in your module, is used to return an [Interface.Web](#Choco-Interface-Web) object or an html content if someone calls that module with no parameter:

i.e., in module `mymodule.coffee`:

    exports.interface = ->
        '<div>Hello</div>'
        
or

    Interface = require 'chocolate/general/locco/interface'
    exports.interface = 
        new Interface.Web -> div 'Hello'

Will display `Hello` when called with `https://myserver/mymodule`

You can write module that runs on server with functions that you can call directly from the browser like this:

    exports.say_hello = (who = 'you', where = 'Paris') ->
        'hello ' + who + ' in ' + where

This function can be called like this:

`https://myserver/mymodule?say_hello` and display `hello you in Paris`  
`https://myserver/mymodule?say_hello&me` and display `hello me in Paris`  
`https://myserver/mymodule?say_hello&me&London` and display `hello me in London`  
`https://myserver/mymodule?say_hello&where=Madrid` and display `hello you in Madrid`  
`https://myserver/mymodule?say_hello&who=me&where=Madrid` and display `hello me in Madrid`  

Those function can declare a system parameter `__` which contains:

      .appdir: application directory
      .datadir: application data directory
      .session: session object to store user's session data
      .request: HTTP request object
      .response: HTTP response object

i.e.:

    exports.check_appdir = (__) ->
        "Application directory is:" + __.appdir

Instead of a javascript function you can call a Locco Interface:

    Interface = require 'chocolate/general/locco/interface'
    exports.say_hello = new Interface
        defaults:
            who: 'you'
            where: 'Paris'
        action: ->
            'hello ' + @bin.who + ' in ' + @bin.where


&nbsp;

---

## <a name="Choco-DB"></a> ChocoDB [⌂](#Choco-Summary) 

ChocoDB is intended to be *a kind of* nosql database running on SQLite.

Currently, you can use it to store javascript objects in database and retrive them by id.
Functions, Dates and circular references can also be saved and retrieved.

A query language is on its way...

Here is an example taken from the /server/reserve spec file:

        
        var _ = require 'chocolate/general/chocodash'
        var Sample;
        
        Sample = (function() {
          function _Class(title, uuid) {
            this.title = title;
            this.uuid = uuid != null ? uuid : _.Uuid();
            this.list = [10, 11, 12, 13];
            this.list.extended = 'an extension';
            this.items = [
              {
                one: 123,
                two: 345
              }
            ];
            this.values = {
              boolean: true,
              number: 1.23
            };
            this.struct = {
              object: {
                name: 'object in struct',
                value: 'ok'
              }
            };
            this.test_func = {
              add: function(x, y) {
                return x + y;
              }
            };
            this.date = {
              creation: new Date(),
              modified: new Date()
            };
          }
        
          return _Class;
        
        })();
        
        var sample = new Sample('test');
        var sub_uuid = _.Uuid();
        sample.struct.object.uuid = sub_uuid;
        
        var chocodb = new Reserve.Space();
        chocodb.write(sample, function() {
          chocodb.read(sample.uuid, function (error, data) {
            // data.title === 'test';
            // data.values.boolean === true;
            // data.date.creation.toString() === sample.date.creation.toString()
        
            chocodb.read(sub_uuid, function (error, data) {
                // data.object.name === 'object in struct';
            });
          });
        });

&nbsp;

---

## <a name="Choco-Dash"></a> Chocodash [⌂](#Choco-Summary) 

Chocodash is a small library that includes javascript utilities:

### <a name="Choco-Dash-Type"></a> _.Type, _.type [⌂](#Choco-Summary) 

`_.type` returns the type of an object

        _type({}) === '[object Object]'

`_.Type` provides a Type enumeration

        _type({}) === _.Type.Object
    
        _.Type = 
            Object: '[object Object]'
            Array: '[object Array]'
            Boolean: '[object Boolean]'
            Number: '[object Number]'
            Date: '[object Date]'
            Function: '[object Function]'
            Math: '[object Math]'
            String: '[object String]'
            Undefined: '[object Undefined]'
            Null: '[object Null]'
    
### <a name="Choco-Dash-Prototype"></a> _.prototype [⌂](#Choco-Summary) 

`_.prototype` makes it easy to create a Javascript prototype

following the classical class way:

*Coffeescript:*

        Service = _.prototype 
            add: (a,b) -> a+b
            sub: (a,b) -> a-b
            
*Javascript:*

        Service = _.prototype({
          add: function(a, b) {
            return a + b;
          },
          sub: function(a, b) {
            return a - b;
          }
        });

or the mixin way:

*Coffeescript:*

        Service = _.prototype()
        Service.use ->
            @add = (a,b) -> a+b
            @sub = (a,b) -> a-b

*Javascript:*

        Service = _.prototype();
        
        Service.use(function() {
          this.add = function(a, b) {
            return a + b;
          };
          return this.sub = function(a, b) {
            return a - b;
          };
        });

Then use your prototype to create javascript objects:

        sevr = new Service();
        expect(serv instanceof Service).toBe(true);
        expect(serv.add(1,1)).toBe(2);

You can define a prototype initializer by using the `constructor` keyword:

*Coffeescript:*

        Service = _.prototype 
            constructor: (@name) ->
        
        serv = new Service "MyDoc"
        expect(serv.name).toBe "MyDoc"

*Javascript:*

        Service = _.prototype({
          constructor: function(name) {
            this.name = name;
          }
        });
        
        serv = new Service("MyDoc");
        
        expect(serv.name).toBe("MyDoc");

You can also create a prototype by adopting/copying  
another prototype's beahaviour and adding new functions:

*Coffeescript:*

        MoreMath = ->
            @multiply = (a,b) -> a * b
            @divide = (a,b) -> a / b
            
        CopiedService = _.prototype adopt:Service, use:MoreMath
        cop = new CopiedService
        
        expect(cop.add 2,2).toBe 4
        expect(cop.multiply 3,3).toBe 9

*Javascript:*

        MoreMath = function() {
          this.multiply = function(a, b) {
            return a * b;
          };
          return this.divide = function(a, b) {
            return a / b;
          };
        };
        
        CopiedService = _.prototype({
          adopt: Service,
          use: MoreMath
        });
        
        cop = new CopiedService;
        
        expect(cop.add(2, 2)).toBe(4);
        expect(cop.multiply(3, 3)).toBe(9);

You can finally create a prototype by inheriting
another prototype's beahaviour and adding new functions 
that can access parent's overriden function:

*Coffeescript:*

        InheritedService = _.prototype 
            inherit:Service
            use: -> @sub = (a,b) -> a + ' - ' + b + ' = ' + _.super @, a,b
        
        inh = new InheritedService
        expect(inh.add 2,2).toBe 4
        expect(inh.sub 2,2).toBe "2 - 2 = 0"
     
*Javascript:*

        InheritedService = _.prototype({
          inherit: Service,
          use: function() {
            return this.sub = function(a, b) {
              return a + ' - ' + b + ' = ' + _.super(this, a, b);
            };
          }
        });
        
        inh = new InheritedService;
        
        expect(inh.add(2, 2)).toBe(4);
        expect(inh.sub(2, 2)).toBe("2 - 2 = 0");

### <a name="Choco-Dash-Defaults"></a> _.defaults [⌂](#Choco-Summary) 

`_.defaults` ensure default values are set on an object

Set default values if not set:

        o = _.defaults({first:1}, {second:2});
        
        expect(o.first).toBe(1);
        expect(o.second).toBe(2);

Set default values on sub-object if not set and preserve other values:

        o = _.defaults({second:{sub1:'sub1'}}, {first:2, second:sub2:'sub2'});
        
        expect(o.first).toBe(2);
        expect(o.second.sub1).toBe('sub1');
        expect(o.second.sub2).toBe('sub2');

### <a name="Choco-Dash-Reactive"></a> _.Signal, _.Observer, _.Publisher [⌂](#Choco-Summary) 

Here are Chocolate's **reactive** services.

**_.signal** represents a value which can be observed

Signals are objects representing observed values. They are read by executing the `value()` function with no arguments.  
They are set by executing the `value()` function with a signal definition as the only argument.

    a = new _.Signal(1);
    b = new _.Signal(function(){ a.value() });
    expect(a.value()).toEqual(1);
    expect(b.value()).toEqual(1);
        
    a.value(2);
    expect(a.value()).toEqual(2);
    expect(b.value()).toEqual(2);
    
    
**_.Observer** reports signal changes

Observers are defined in a manner similar to Signals

The primary differences of observers are:

 - they have no value to read
 - they cannot be observed themselves
 - they are notified only after signals have all been updated

They are called upon Signal change:

        a = new _.Signal(1);
        b = null;
        c = new _.Observer(function(){ b = a.value() });
        expect(b).toEqual(1);
        
        a.value(2);
        expect(b).toEqual(2);
    

Together, Signals and Observers form a directed acyclic graph.
Signals form the root and intermediate nodes of the graph, while Observers form the leaf nodes in the graph.

When a signal is updated, it propagates its changes through the graph.
Observers are updated last after all affected signals have been updated.
From the perspective of observers, all signals are updated atomically and instantly .


**_.Publisher** reports basic signal changes to one-to-many reporters.
They use one internal pair of Signal and Observer
    

        asyncFunc = function() {
          var publisher = new _.Publisher;
          
          var callback = function() {
            return publisher.notify('done');
          };
          doAsyncStuff(callback);
          
          return publisher;
        };
        
        asyncFunc().subscribe(function(answer) { // do something when notified });

### <a name="Choco-Dash-Async"></a> _.serialize, _.parallelize [⌂](#Choco-Summary) 

Really simple tools to help manage asynchronous calls serialization.

You can change this javascript code:

        db.createOrGetTable(function(table) {
          return table.insertRow(row, function() {
            return db.select(query(function(rows) {
              return console.log(rows.count);
            }));
          });
        });

to this code:

        _.serialize(function(defer, local) {
          defer(function(next) {
            return db.createOrGetTable(function(table) {
              local.table = table;
              return next();
            });
          });
          defer(function(next) {
            return local.table.insertRow(row, function() {
              return next();
            });
          });
          defer(function(next) {
            return db.select(query(function(rows) {
              local.rows = rows;
              return next();
            }));
          });
          return defer(function() {
            return console.log(local.rows.count);
          });
        });

or in Coffeescript, this code:

        db.createOrGetTable (table) ->
            table.insertRow row,  ->
                db.select query (rows) ->
                    console.log rows.count
                    
to this code:

        _.serialize (defer, local) ->
            defer (next) -> db.createOrGetTable (table) -> local.table = table; next()
            defer (next) -> local.table.insertRow row,  -> next()
            defer (next) -> db.select query (rows) -> local.rows = rows; next()
            defer -> console.log local.rows.count



It helps you mix synchronous and asynchronous, iterative and recursive code, 
in a **simple** way with **no new concept** to learn.
    
Here is an example taken from /general/chocodash spec file:

        var _, end, start, time1, time2, time3, aync_func;

        aync_func = function(duration, cb) {
          return setTimeout((function() {
            return cb(new Date().getTime());
          }), duration);
        };

        _ = require('chocolate/general/chocodash');
        
        start = new Date().getTime();
        time1 = time2 = time3 = end = null;
        
        _.serialize(function(defer) {
        
          defer(function(next) {
            return aync_func(250, function(time) {
              time1 = time;
              return next();
            });
          });
        
          defer(function(next) {
            return aync_func(150, function(time) {
              time2 = time;
              return next();
            });
          });
        
          defer(function(next) {
            return aync_func(350, function(time) {
              time3 = time;
              return next();
            });
          });
        
          defer(function() {
            // expect(time1 - start).toBeGreaterThan(250 - 5);
            // expect(time2 - start).toBeGreaterThan(400 - 5);
            // expect(time3 - start).toBeGreaterThan(750 - 5);
            // expect(end - start).toBeLessThan(10);
          });
          
          end = new Date().getTime();
        });
        
### <a name="Choco-Dash-Stringify"></a> _.stringify, _.parse [⌂](#Choco-Summary) 

`_.stringify` transforms a javascript object in a string that can be parsed back as an object

You can stringify every property of an object, even a function or a Date:

        o = {
            u: void 0,
            n: null,
            i: 1,
            f: 1.11,
            s: '2',
            b: true,
            add: function(a, b) { return a + b; },
            d: new Date("Sat Jan 01 2011 00:00:00 GMT+0100")
        };

        s = _.stringify o
        expect(s).toBe "{u:void 0,n:null,i:1,f:1.11,s:'2',b:true,add:function (a, b) {\n          return a + b;\n        },d:new Date(1293836400000)}"


`_.parse` transforms a stringified javascript object back to a javascript object

        a = _.parse "{u:void 0,n:null,i:1,f:1.11,s:'2',b:true,add:function (a, b) {\n          return a + b;\n        },d:new Date(1293836400000)}"

        expect(a.u).toBe undefined
        expect(a.n).toBe null
        expect(a.i).toBe 1
        expect(a.f).toBe 1.11
        expect(a.s).toBe '2'
        expect(a.b).toBe yes
        expect(a.add(1,1)).toBe 2
        expect(a.d.valueOf()).toBe new Date("Sat Jan 01 2011 00:00:00 GMT+0100").valueOf()
        
### <a name="Choco-Dash-Uuid"></a> _.Uuid [⌂](#Choco-Summary) 

`_.Uuid` helps to generate RFC4122(v4) UUIDs, and also non-RFC compact ids

        Uuid() // produces a string like "88a8814c-fd78-44cc-b4c1-dbff3cc63abd"
        
        expect(Uuid.parse("49A15746135C4DEDAB55B2C5F74BD5BB").toString()).toBe([73, 161, 87, 70, 19, 92, 77, 237, 171, 85, 178, 197, 247, 75, 213, 187].toString());

&nbsp;

---

## <a name="Choco-Debugate"></a> Debugate [⌂](#Choco-Summary) 

Debugate is really basic tool to help profile and log code execution.

Here is a sample taken from the /general/debugate spec file:

        var Debug = require('chocolate/general/debugate'), f1;
        
        f1 = function(cb) {
          return setTimeout((function() {
            return cb(new Date().getTime());
          }), 250);
        };
        
        Debugate.profile.start('Test time spent');
        
        f1(function(time) {
          Debugate.profile.end('Test time spent');
          
          // expect(Debugate.profile.spent('Test time spent').time).toBeGreaterThan((250 - 5) * 1000);
          // expect(Debugate.profile.spent('Test time spent').time).toBeLessThan((250 + 5) * 1000);
        });

&nbsp;

---

## <a name="Choco-Chocokup"></a> Chocokup [⌂](#Choco-Summary) 

Chocokup is derived from [Coffeekup](http://coffeekup.org) which is a templating engine for node.js and browsers that lets you to write your html templates in 100% pure CoffeeScript.

What Chocokup adds is the "Panel orientation" missing from html which is page oriented.

Chocokup introduces few new tags:

 - panel
 - box

and modifies some already existing tags:

 - body
 - header
 - footer

Using a pure Coffeescript syntax, you can write this:

    panel proportion:"served", ->
        panel "aside left"
        panel "main"
        panel "aside right"

which translates into:

    <div class="space">
      <div class="space service horizontal left">
        <div class="space">aside left</div>
      </div>
      <div class="space service horizontal served center">
        <div class="space">main</div>
      </div>
      <div class="space service horizontal right">
        <div class="space">aside right</div>
      </div>
    </div>
    
and displays as a main panel with a left and a right service panels.

You can also write Css code using Chocokup:

    panel "#calc", ->
        button "##{id()}", i for i in [9..0]
        button '+' ; button '-'
        button '.by3', '='           
            
    css ->
        width = 160
        nbColumn = 3
        
        box: ->
            border: '1px solid black'
            width: width + 'px'
            minHeight: '20px'
            textAlign: 'center'
            whiteSpaceCollapse: 'collapse'
            
        '#calc':
            box:on
            
        button:
            width: width / nbColumn - 4
            height: width / nbColumn - 4
            
        'button.by3':
            width: width 

This will display a basic Calculator 

&nbsp;

### <a name="Choco-Chocokup-Usage"></a> Usage [⌂](#Choco-Summary) 

#### <a name="Choco-Chocokup-Document"></a> Chocokup.Document [⌂](#Choco-Summary) 

In a Coffeescript source file (ie. : mypage.coffee),  
insert an `interface` function that returns a new `Chocokup.Document`
        
    Chocokup = require 'chocolate/general/chocokup'
    
    exports.interface = ->
        new Chocokup.Document 'Chocolate - Wep Apps with a sweet taste', theme:'writer'->
            body ->
                "Welcome to Chocolatejs.org !"

            
Then open a web browser and open that page: ie. https://myserver/mypage

Chocokup documents include the Eric Meyer's reset CSS. 

You can select few `themes`:

 - reset: (default) Eric Meyer's reset CSS
 - paper: reset CSS + traditional CSS values
 - writer: paper CSS + classic Blog CSS values
 - coder: paper CSS + developer Blog CSS values

#### <a name="Choco-Chocokup-Panel"></a> Chocokup.Panel [⌂](#Choco-Summary) 

If you only want to build a partial document, you can use `Chocokup.Panel`

    Chocokup = require 'chocolate/general/chocokup'
    
    kup = ->
        text "Welcome to Chocolatejs.org !"
        
    exports.interface = ->
        new Chocokup.Panel(kup).render()

### <a name="Choco-Chocokup-Reference"></a> Reference [⌂](#Choco-Summary) 

Read the complete Chocokup reference in Chocolate Studio Chocokup help panel.


&nbsp;

---

## <a name="Choco-Chocoss"></a> Chocoss [⌂](#Choco-Summary) 

Chocoss is a Css templating system currently being developed inside Chocokup

Five simple reset types and a static grid system are added to Chocokup fluid panel system.

The reset types are:

 - reset: the Eric Meyer's Css Reset. Reset things like default line heights, margins and font sizes of headings, and so on...
 - basic: apply `reset` and redefine basic styles.
 - paper: apply `basic` and add margins
 - writer: general blog type reset based on `paper`
 - coder: developer blog type reset based on `paper`

&nbsp;

---

## <a name="Choco-Locco"></a> Locco [⌂](#Choco-Summary) 

Locco is the Chocolate protocol. It helps manage data, workflows and interfaces.

### <a name="Choco-Locco-operations"></a>Protocol operations [⌂](#Choco-Summary) 

- **`so`** indicates the action type.

    - **`do`**:  execute an exported function in source file  
        - parameters can be specified by name or by position
    - **`move`**: 
        - if **`what`** is specified:  
        move **`what`** file's content to **`where`** file  
        - otherwise, if Http request is a **POST** request then:  
        move POST message data to **`where`** file  
        
    - **`eval`**: run the **where** file associated spec: ie. default.spec.coffee for default.coffee
    - **`go`**: default action. Load **where** file and execute interface function.

- **`what`** adds a precision on the action object (usualy its pathname).
- **`where`** tells where the action should take place: a pathname
- **`how`** asks for a special type of respond if available (web, raw, help).
    - **`web`**: default. responds as an html document
    - **`raw`**: responds as plain text
    - **`help`**: responds as an html Docco help file
    - **`edit`**: responds as an html source web editor

- a **`backdoor_key`** key can be specified to have system access

        https://myserver/!/my_backdoor_key/myworld/myfolder
            
Usage:

        https://myserver/myworld/myfolder?so=move&what=/myworld/mydocument
           Moves /myworld/mydocument file to /myworld/myfolder
           so = move
           what = /myworld/mydocument
           where = /myworld/myfolder
           how = web (by default) - will return an answer as html.

        https://myserver/myworld/myfolder
           Go to /myworld/myfolder file, 
             load it and execute **interface** function if exists,
             otherwise open file in editor
           so = go (by default)
           what = undefined
           where = /myworld/myfolder
           how = web (by default) - will return an answer as html.

        https://myserver/myworld/myfolder?myFunc&myParamValue
           Go to /myworld/myfolder file, 
             load it and execute **myFunc** function if exists, with myParamValue param
             otherwise returns empty page
           so = do (by default when request has parameters)
           what = myFunc
           where = /myworld/myfolder
           how = web (by default) - will return an answer as html.

### <a name="Choco-Locco-Interface"></a>Interface [⌂](#Choco-Summary) 

Locco Interface is a javascript protoype that provides the following services:

**Rules** enforcement:

 - default values : ensures that default values are set
 - security control : ensures current user has access rights
 - values validation control : ensures values are valid before proceeding
 - steps execution: execute asynchronous preparation steps before main action

**Action** execution:

 - execute interface main action
 - returns synchronously or asynchronously an Interface.Reaction
 
When Chocolate workflow service receives a request, it loads the corresponding module.
If the module has an property named `interface` which is an instance of Locco `Interface`,
it submits the provided parameters and the system context (__) in a `bin` to the interface:
        
        Interface = require 'chocolate/general/locco/interface'
        exports.interface = new Interface
            defaults:
                who: 'you'
                where: 'Paris'
            action: ->
                'hello ' + @bin.who + ' in ' + @bin.where

`Interface` service makes explicit what you have to deal with when you create an interface.

### <a name="Choco-Locco-Interface-Web"></a>Interface.Web [⌂](#Choco-Summary) 

An `Interface.Web` service makes it easy to build a web interface component.

You just declare an interface where the `action` is some Chocokup code that can access data stored in the provided `bin`.
That interface can embed other `Interface.Web` modules:

        welcome_user = new Interface.Web
                defaults:
                    welcome_message: -> 'Welcome'
                    
                    login_panel: new Interface.Web
                        rules:
                            defaults:
                                login: -> 'Login'
                                signin: -> 'Sign in'
                        action: (bin = @bin) ->
                            a href:'#', bin.login
                            a href:'#', bin.signin
        
                action: (bin = @bin) ->
                    if bin.__.session.user?.has_signed_in
                        span bin.welcome_message
                        span bin.__.session.user.name
                    else
                        login_panel bin.login_panel.bin


&nbsp;

---

## <a name="Choco-Specolate"></a> Specolate [⌂](#Choco-Summary) 

Specolate is a client and server side behavior/test driven development tool.

It uses [Jasmine](http://pivotal.github.com/jasmine), a great behavior-driven development framework for testing JavaScript code.

### <a name="Choco-Specolate-Usage"></a> Usage [⌂](#Choco-Summary) 

Something interesting is that it runs your specs in the server **and** in the browser contexts.

You only have add, at the begining of your spec file:

### Server only module

    unless window?
        describe ...

### Browser only module

    if window?
        describe ...

### General module

    Newnotes = require './newnotes'
    
    describe 'Newnotes', ->
        it 'creates, then lists a basic todo', ->
            newnotes = new Newnotes
            newnotes.add 'do first'
            newnotes.add 'do after'
            expect([todo.title for todo in newnotes.list()].join(',')).toEqual 'do first,do after'

&nbsp;

---

## <a name="Choco-Doccolate"></a> Doccolate [⌂](#Choco-Summary) 

**Docco** is a literate-programming-style
documentation generator. It produces html that displays your comments
alongside your code.

**Doccolate** is a modified version of Docco that can be used on demand both on client and server side.
It supports Coffeescript, Javascript, CSS and Markdown file formats.

You can use it by clicking on the **Doc** button while a source file is opened. 
Then you will immediately see if your source is well documented. Source modifications are reflected on the fly!

Source comments are passed through
[Markdown](http://daringfireball.net/projects/markdown/syntax), and code is
passed through [Highlight](http://softwaremaniacs.org/wiki/doku.php/highlight.js:highlight.js) syntax highlighting.

Documented version of your source files can be displayed directly in the browser 
by using the `how=help` Http parameter: `https://myserver/mymodule?how=help`

&nbsp;

---

## <a name="Choco-litejQ"></a> litejQ [⌂](#Choco-Summary) 

**Litejq** is a lite jQuery-compatible library introduced to be Chocolate client-side scripts foundation.

It knows:

> Core

>> $.ready, $.noConflict, $.type, $.isArray, $.isWindow, $.isPlainObject, $.each, $.map, $.extend, .get, .each, .splice, .map

> Ajax

>> $.ajax, $.get, $.post, $.getJson, $.param

> Query: 

>> .filter, .find, .parent, .parents, .siblings, .children, .first, .last, .closest

> Event:

>> $.Event, $.now, .on, .off, .bind, .unbind, .delegate, .undelegate

> Style:

>> .addClass, .removeClass, .toggleClass, .hasClass, .css

> Dom:

>> .text, .html, .append, .prepend, .replaceWith, .empty, .attr, .removeAttr, .data, .removeData, .val, .show, .hide, .height, .width, .offset, .remove

&nbsp;

---

## <a name="Choco-Newnotes"></a> Newnotes [⌂](#Choco-Summary) 

Newnotes is a note taking tool that helps memorize and get things done.

*Things* are structured-text with each level thought as shortest-long-title.
Each *thing* input has a date and a time stamp.

You can use it to manage notes / todo lists / oulines.

**New item/sub-item**

You can create a new item with the same attributes than the previous (use Ctrl-Return).
You can also create sub-items with the indent/outdent function (use Tab and Shift-Tab)

**Tagging attributes**

You can modify the item attributes using the selectors.

Dimensions :

 - Priority: Now, Tomorrow, Later, Done
 
 - Scope: Me, Household, Family, Friends, Community, Business, State, Public
 
 - Action: Explore, Memorize, Learn, Teach, Do, Control, Delegate, Relax
 
 - Intention: Know, Use, Make, Manage

 - Wish: No wish, Identity, Hobbies, Education, Religion, Leisure

 - Need: No need, Food, Health, Clothing, Equipment, Housing
 
 - Share: No share, Communication, Partnership, Work, Banking, Insurance

### <a name="Choco-Newnotes-Usage"></a> Usage [⌂](#Choco-Summary) 

You can use it directly inside Chocolate Studio in the Notes panel, 
but also directly and fullscreen at: `https://myserver/-/server/newnotes`

### <a name="Choco-Newnotes-Impress"></a> Impress.js with Newnotes ! [⌂](#Choco-Summary) 

You can display a Newnotes branch with impress.js: `https://myserver/-/server/newnotes?my-branch-title&as=impress`

### <a name="Choco-Newnotes-Reference"></a> Reference [⌂](#Choco-Summary) 

Read the complete Newnotes reference in Chocolate Studio Newnotes help panel.

&nbsp;

---

## <a name="Choco-RoadMap"></a> Road Map [⌂](#Choco-Summary) 

Chocolate is currently (2014/04) an experiment that needs to be completed and polished:

 - user management
 - responsive user interface services
 - data management: offline and online synchronization
 - robust live coffeescript (and javascript) in lab tab
 - link source context to notes in Newnotes
 - ...

&nbsp;

---

## <a name="Choco-License"></a> License [⌂](#Choco-Summary) 
    
    MIT License
    
    Chocolate is a simple webapp framework built on Node.js using Coffeescript
    Copyright (c) 2013, Jean-Claude Levy
    
    Permission is hereby granted, free of charge, to any person
    obtaining a copy of this software and associated documentation
    files (the "Software"), to deal in the Software without
    restriction, including without limitation the rights to use,
    copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the
    Software is furnished to do so, subject to the following
    conditions:
    
    The above copyright notice and this permission notice shall be
    included in all copies or substantial portions of the Software.
    
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
    EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
    OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
    NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
    HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
    WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
    FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
    OTHER DEALINGS IN THE SOFTWARE.
