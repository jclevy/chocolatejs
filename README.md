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

 - **Chocolate Studio** -- an **online IDE** (with Coffeescript, Javascript, Css, Json, and Markdown support)

 - **Locco** -- the Chocolate protocol : so, what, where, how...

 - **LateDB** -- a kind of database running in-memory and logged to disk

 - **Chocokup** -- a 100% pure CoffeeScript templating language that helps build web user interfaces (based on Coffeekup)

 - **Chocodown** -- Chocokup-aware port of Markdown (based on Showdown)

 - **Chocolate Lab** -- an online and immediate **Lab** playground where you write, transpile and/or test code between Javascript and Coffeescript and also between Html and Chocokup...

 - **Specolate** -- a behavior/test driven development tool (based on Jasmine) that works client and server side

 - **Doccolate** -- an online documentation editing tool (based on Docco)

 - **Chocodash** -- toolbox with javascript object identity, types, serialization and asynchronous calls and signals management

 - **liteJq** -- a lite jQuery-compatible library

 - **liteLorem** -- a basic lorem (fake words, sentences and images) library

 - an automatic **free SSL certificate** service with Let's Encrypt

 - a simple **reverse proxy** service

 - a basic **source control** with Git

 - **Chocoss** -- a Css framework

 -  **NewNotes** -- a promising note taking tool

Chocolate integrates:

 > [Node.js](http://nodejs.org) - [Coffeescript](http://coffeescript.org) - [Ace](http://ace.ajax.org) - [Letsencrypt](https://github.com/Daplie/node-letsencrypt) - [Http-proxy](https://github.com/nodejitsu/node-http-proxy) - [Jasmine](http://pivotal.github.com/jasmine) - [Reactor](https://github.com/fynyky/reactor.js)
 >
 > [Coffeekup](http://coffeekup.org) - [Showdown](https://github.com/coreyti/showdown) - [Highlight.js](http://softwaremaniacs.org/soft/highlight/en) - [Docco](http://jashkenas.github.com/docco/) - [Ccss](https://github.com/aeosynth/ccss) - [Git](http://git-scm.com) - [Impress](http://bartaz.github.com/impress.js/#/bored)

&nbsp;

---

## Version

**Chocolate v0.0.29 - (2018-10-30)**
---

NEW FEATURES

 - Windows compatibility: now `Chocolate` can run on Windows.
   - a `bin/chocomake.bat` has been added to create Chocolate projects on Windows systems
   - few modifications have been made on core code to make Chocolate compatible with `Node.js` on Winodws platform
   - current limitations on Windows:
     - `File.hasWriteAccess` always returns `true`
     - Chocolate's debug service does not work yet
 - `server/file`: 
   - added `getGitStatus` service that returns the current Git status for current Git repository
   - added `getFileDiff` service that returns the current file's Git diff
 - `server/studio`: added `Diff` and `Status` tabs to display Git status for current app and Git diff for current file
 - added `server/monitor.js` and `server/server.js`, so that one can start `Chocolate` using classical Node.js command
 
UPDATES

 - `general/chocokup`: added `.overflow` rule to chocokup's css to overflow-auto to a DOM element
 - `server/interface`: 
   - added `pwa_worker` request type using `?how=pwa_worker` this request returns a `text/javascript` file the the browser
   - added `masterInterfaces.exclude` sub-section in `app.config.json` file to tell the `masterInterfaces` service to bypass any file which name starts with one of the prefixes given in `masterInterfaces.exclude`'s array
   - `create_hash` service now through a web interface
 - `server/file`: update list of searchable files suffixes in `grep`:

        '.coffee', '.js', '.css', '.scss', '.json', '.txt', '.md', '.markdown', '.ck', '.chockup', '.log'


FIXED BUGS
 - `server/file`: `resolve_repo` now resolve to to closest parent to have a `.git` folder

---

**Chocolate v0.0.28 - (2018-10-08)**
--------------

NEW FEATURES

 - `general/litelorem`: added basic `lorem` service that can generate `word`, `sentence`, `paragraph`, `image`, `face`
 
    lorem.word(): generates one word
    
    lorem.words(count): generates `count` words
    
    lorem.sentence(): generates one sentence (5 to 10 words each), starting with an upper case and ending with a point.
    
    lorem.sentences(count): generates `count` sentences
    
    lorem.paragraph(): generates one paragraph (10 to 20 sentences each), separated by a newline char (\\n)
    
    lorem.paragraphs(count): generates `count` paragraphs
    
    lorem.image(): generates a random image (400x200px)
    
    lorem.image(width:200, height:300): generates a random image (200x400)
    
    lorem.image(type:'arch'): generates a random architecture image. Type can be: `animals`, `arch`, `nature`, `people`, `tech`
    
    lorem.image(type:'people', color:'sepia'): generates a random people image in sepia (with sepia a `type` has to be provided). 
    
    lorem.image(color:'grayscale'): generates a random image in gray scale.
    
    lorem.image(blur:true): generates a random blurred image (with blurred image no `type` can be provided).
    
    lorem.image(gravity:'east'): generates a random image cropped to the east if image is wider than high (with gravity image no `type` can be provided). Gravity can be `north`, `east`, `south`, `west`, `center`

 - `general/chocokup`: added lorem service as a native keyword in Chocokup

        e.g.: 
            
    >  div lorem.words(4)   
    >  
    >   `<div>volutpat odio facilisis mauris</div>`
                    
    >  div lorem.sentences(2)
    >  
    >   `<div>Malesuada bibendum arcu vitae elementum curabitur vitae nunc. Nec sagittis aliquam malesuada bibendum arcu vitae elementum.</div>  `
                    
    >  p para for para in lorem.paragraphs(2).split('\n')
    >  
    >   `<p>Vitae tortor condimentum lacinia quis vel. Dignissim sodales ut eu sem integer vitae. Arcu vitae elementum curabitur vitae nunc sed velit dignissim sodales. Facilisis leo vel fringilla est ullamcorper. Felis donec et odio pellentesque. Sem integer vitae justo eget. Dignissim diam quis enim lobortis. Pellentesque diam volutpat commodo sed egestas egestas fringilla phasellus faucibus. Elementum curabitur vitae nunc sed velit dignissim sodales ut. Sodales ut eu sem integer. Velit dignissim sodales ut eu sem integer. Ut eu sem integer vitae justo. Nec sagittis aliquam malesuada bibendum arcu. Lobortis scelerisque fermentum dui faucibus in ornare. Volutpat odio facilisis mauris sit amet massa vitae tortor. Odio tempor orci dapibus ultrices in iaculis nunc sed augue.</p>`  
    >   `<p>Magna fermentum iaculis eu non. Malesuada bibendum arcu vitae elementum curabitur vitae nunc sed velit. Eu sem integer vitae justo eget magna fermentum iaculis eu. Tempor orci dapibus ultrices in iaculis nunc sed augue lacus. Quis enim lobortis scelerisque fermentum dui faucibus in ornare. Nulla facilisi etiam dignissim diam quis enim lobortis. Odio tempor orci dapibus ultrices in iaculis nunc sed. Fringilla urna porttitor rhoncus dolor purus non enim. Ut aliquam purus sit amet luctus venenatis lectus magna fringilla. Orci dapibus ultrices in iaculis nunc sed augue. Sed velit dignissim sodales ut eu sem integer vitae justo. Congue eu consequat ac felis donec.</p>`
    >
    
    >  img src:lorem.image()
    >
    >   `<img src="https://picsum.photos/400/200?cache=4801568232095026" />`
                
    >  img src:lorem.face('woman')
    >  
    >   `<img src="https://randomuser.me/api/portraits/women/43.jpg" />`
    

 - `general/chocodash`: added `_.slugify` service that converts a string to version that is compatible with URL
 - `.ck`, `.chocokup` files can be served from `static` folder so that you can write an Html-like file using `Chocokup`

UPDATES

 - `server/interface`: `masterInterface` can now manage page interface defined by a simple function that returns a string
 - `server/interface`: `defaultExchange` now has an `extension` parameter to set an extension name if `defaultExchange` service is inside
 - `server/interface` and `general/locco/interface`: modified the `review` service to enable embedded interface to act as access controller for tha MasterItem interface
 - updated formidable to v1.2.1

FIXED BUGS
 - `server/monitor`: added the `.scss` file's folder to the `includePaths` Sass compiler command so that other `scss` files present in the same folder could be found by the compiler.
 - `server/interface`: `masterInterface` was not found if placed in an application's extension folder

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
 - [LateDB](#Late-DB)
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
 - [liteLorem](#Choco-liteLorem)
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

This procedure was tested as **root** on Debian 8.0

### Prerequisites

Chocolate needs Node.js (from v0.10.22 to latest).

**Install Node.js (v6.x)**

    apt-get update
    apt-get upgrade
    apt-get install curl
    curl -sL https://deb.nodesource.com/setup_6.x | bash -
    apt-get install -y nodejs

**Make node modules accessible everywhere**

You can use start, stop and monitor Chocolate's app with PM2 service:

**Install PM2**

    npm install -g pm2

&nbsp;

Chocolate also needs:

**Other prerequisites**

    apt-get install g++
    apt-get install git
        
    npm install -g coffee-script
    
&nbsp;

### Install Chocolate:

    npm install -g --unsafe-perm chocolate

&nbsp;

**Run chocomake to create myapp**

    cd /home
    chocomake myapp

Answer asked questions to create a self-signed SSL certificate.

&nbsp;

**Install Chocolate in PM2**

    su - myapp

**Start 'myapp'**

    pm2 start coffee --name="myapp" -- /usr/lib/node_modules/chocolate/server/monitor.coffee /home/myapp
        
    pm2 save
    pm2 startup
    ctrl+d
    -- then execute the command that was displayed

**To stop, start or restart 'myapp'**

    pm2 stop myapp
    pm2 start myapp
    pm2 restart myapp


&nbsp;

---

## <a name="Choco-UseIt"></a> Use it [⌂](#Choco-Summary)

Chocolate runs on your server and responds to https requests on port 8026

You can change port number in the `pm2 start` command where you append the **port** parameter:

    pm2 start coffee --name="myapp" -- /usr/lib/node_modules/chocolate/server/monitor.coffee /home/myapp 8081

You can also use a simple Http server by specifying options in the `/home/myapp/data/app.config.json` file:

    http_only: true
    port: 80

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

You can specify options in `data/app.config.json` file:

    http_only: true or false
    port: <main port number>
    key: <key filename>
    cert: <cert filename>

**Let's Encrypt SSL certificate**

You can use [Let's Encrypt](https://letsencrypt.org/) free SSL certificate service directly in your Chocolate app:

First configure Let's Encrypt's service in `data/app.config.json`:

    "letsencrypt": {
        "domains": [ "yourdomain.com" ],
        "email": "you@yourdomain.com",
        "agreeTos": true,
        "production": true,
    }
            
You can put `false` in `production` parameter to test certificate generation. The generated certificates should appear in `data/letsencrypt/live/yourdomain` folder

Your certificate will then be renewed and the app restarted, automatically after approximately 90 days

But there is more: you can put many domains in the same certificate 

    "domains": [ "yourdomain.com", "theirdomain.com", "ourdomain.com" ]

Finally, you **have** to explicitly add an entry with `yourdomain` prefixed with `www` if you want to support it:
 
    "domains": [ "yourdomain.com", "www.yourdomain.com" ]

**Reverse Proxy service**

There is a simple Reverse Proxy service that you can configure in `data/app.config.json`:

    "proxy": ['yourdomain.com', 'theirdomain.com', 'ourdomain.com']
            
Then `Chocolate` will forward request for those domains to local processes/apps awaiting requests on your proxy app port + 10
    
So if your proxy app is on `8026` port then `yourdomain.com` will be on `8036`, `theirdomain.com` will be on `8046`...

And if you also use `Chocolate`'s `letsencrypt` feature, you'll only have to set:

            "proxy": true
            
and `Chocolate` will use the domains defined in
    
            "letsencrypt": {
                "domains": [ "yourdomain.com" ],
                ...

**Javascript Bundle service**

You can define Javascript bundles to be build when source files are saved.  
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
        
**Chocolate system services and files**

They are accessible (if you registered the master key) at:

    https://myserver:8026/-/server...
    https://myserver:8026/-/general...

**Your app services and files**

They are at:

    https://myserver:8026/myservice...
    https://myserver:8026/mydir/myservice...

**Default service in source file**

If your source file exports an `interface` function (ie. in `default.coffee`):

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
            div "Hello world #{world}!" for world in [1..5]

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

The Lab helps you write your code and test cases, syntax and also translate between Javascript and Coffeescript and also between Html and Chocokup...

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

**Javascript Lab**

But you can also select the Javascript mode where your Javascript code will be immediately executed and also translated to Coffeescript!

**Chocodown Lab**

Literate  programming...

Chocodown panel lets you write Markdown, Chocokup and Coffeescript code that will be 
immediately translated to html and javascript!

But more... when you display the **Dom** panel you can see immmediately the result!

Basically, this panel is a Markdown editor, but you can insert code blocks by using
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

**Html Lab**

But you can also select the Html mode where your Html code will be immediately rendered and also translated to Coffeekup/Chocokup!

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

You can also directly export an [Interface.Web](#Choco-Interface-Web) object

    Interface = require 'chocolate/general/locco/interface'
    module.exports = 
        new Interface.Web -> div 'Hello'

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
        render: ({who, where}) ->
            'hello ' + who + ' in ' + where


&nbsp;

---

## <a name="Late-DB"></a> LateDB [⌂](#Choco-Summary) 

`lateDB` provides you an in-memory javascript space that you can modify with an `update` method

        var lateDB = require('chocolate/general/latedb');
        db = lateDB();

### lateDB.update with one key, one data and one operation

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

### lateDB.update (many key/data pairs and one operation)

        db.update({ 'key 1': 'data 1', 'key 2': 'data 2' }, func);

i.e. (in Coffeescript):

        db.update
            'key 1': 'data 1'
            'key 2': 'data 2'
            , (data) -> for k,v of data then @[k] = v

i.e (in Javascript):

        db.update({
          'key 1': 'data 1',
          'key 2': 'data 2'
        }, function(data) {
          var k, v;
          for (k in data) {
            v = data[k];
            this[k] = v;
          }
        });    

will basicaly copy an object in the database

        {"key 1": "data 1", "key 2", "data 2"}

### lateDB.update (many key/operation pairs and one data)

        db.update({ data_key_1: 'data value 1', 'data_key_2': 'data value 2' }, {key_1: func_1, key_2:func_2});

i.e. (in Coffeescript):

        db.update {name:'doe', firstname:'john'},
            'UpperCase': (data) -> for k, v of data then @[k] = v.toString().toUpperCase()
            'TwoLetters': (data) -> for k, v of data then @[k] = v.toString().substr(0,2)

i.e (in Javascript):

        db.update({
          name: 'doe',
          firstname: 'john'
        }, {
          'UpperCase': function(data) {
            var k, v;
            for (k in data) {
              v = data[k];
              this[k] = v.toString().toUpperCase();
            }
          },
          'TwoLetters': function(data) {
            var k, v;
            for (k in data) {
              v = data[k];
              this[k] = v.toString().substr(0, 2);
            }
          }
        });    

will put an object in the database in two different places with two different functions

        {
            "UpperCase": {name:'DOE', firstname:'JOHN'},
            "TwoLetters": {name:'do', firstname:'jo'}
        }
        
And voilà, that's bascially all...

Oh, there is one thing more...

## LateDB().tables

LateDB provides relational-like services with insert, join and query capabilities:

### count tables

        db.tables.count()
    
### create table

The table's name uses the plural form of the entity's name. You can specify both, separated by a slash `/`. 
If you just provide one name, it will be used as the table's name, it will be supposed to be of plural form, and it's last letter will be removed to form the corrsponding entity's name.

In the following line, the table's name will be `categories` and the corresponding entity's name will be `category`

        db.tables.create 'categories/category'
        table = db "tables.categories"
        expect(table.entity_name).toBe('category')
        expect(table.alias).toBe('Category_')

In the following line, the table's name will be `colors` and the corresponding entity's name will be `color`

        db.tables.create 'colors'
        table = db "tables.colors"
        expect(table.entity_name).toBe('color')
        expect(table.alias).toBe('Color_')

        db.tables.create 'brands'
        table = db "tables.brands"
        expect(table.entity_name).toBe('brand')
        
        db.tables.create 'cars'
        table = db "tables.cars"
        expect(table.entity_name).toBe('car')

### insert data

Primary key has to be called `id`

        db.tables.insert 'colors', id:1, name:'white'
        db.tables.insert 'colors', id:2, name:'black'
        db.tables.insert 'colors', id:3, name:'red'
        
        expect(db('tables.colors')[0].id).toBe 1
        expect(db('tables.colors')[2].name).toBe 'red'

        db.tables.insert 'brands', id:1, name:'Mercedes'
        db.tables.insert 'brands', id:2, name:'BMW'
        db.tables.insert 'brands', id:3, name:'Toyota'
        db.tables.insert 'brands', id:4, name:'Honda'

        expect(db('tables.brands')[1].id).toBe 2
        expect(db('tables.brands')[3].name).toBe 'Honda'

Primary key `ìd` can be given by LateDB

        id = db.tables.id 'colors'
        db.tables.insert 'colors', id:id, name:'grey'

        expect(db('tables.colors').lines[id].name).toBe 'grey'
        
### automatic index creation

        expect(db('tables.colors').index.id[1].id).toBe 1
        expect(db('tables.colors').index.id[3].name).toBe 'red'

### update a line in a table

        db.tables.update 'brands', id:3, name:'Toyota Motors'

        expect(db('tables.brands').lines[3].name).toBe 'Toyota Motors'

### delete a line in a table

        db.tables.delete 'cars', id:7

        expect(db('tables.cars').lines[7]).toBe undefined

### insert data with foreign keys

Foreign keys' name have to end with `_id` and use the sigular version of the table's name which is it's corresponding entity's name.

        db.tables.insert 'cars', id:1, name:'SLK 200', color_id:1, brand_id:1
        db.tables.insert 'cars', id:2, name:'SL 600', color_id:2, brand_id:1
        db.tables.insert 'cars', id:3, name:'BMW Série 2 Cabriolet', color_id:2, brand_id:2
        db.tables.insert 'cars', id:4, name:'BMW Série 3 Berline', color_id:3, brand_id:2
        db.tables.insert 'cars', id:5, name:'Toyota Prius', color_id:1, brand_id:3
        db.tables.insert 'cars', id:6, name:'Toyota Aygo', color_id:3, brand_id:3
        db.tables.insert 'cars', id:7, name:'Honda Accord', color_id:2, brand_id:4
        db.tables.insert 'cars', id:8, name:'Honda Jazz', color_id:1, brand_id:4

        expect(db('tables.cars')[3].id).toBe 4
        expect(db('tables.cars')[4].name).toBe 'Toyota Prius'
        expect(db('tables.cars')[7].color_id).toBe 1

### query a table

You can directly query using the table's name and sort cars in reverse order

        lines = db.tables.query 'cars', sort: ['name':-1]

        expect(lines.length).toBe 8
        expect(lines[4].name).toBe 'Honda Jazz'

### query a table and filter using a function

        lines = db.tables.query 'cars', (o) -> o.name is 'Honda Jazz'

        expect(lines.length).toBe 1
        expect(lines[0].id).toBe 8

### register a query to use it later

You register a query by giving it a name and a definition. 
The name is composed by three parts:  Entity-name\_Number-of-parameters\_Query-name

The third part, the query name, is optional. If no table is specified in the query definition, the Entity_name is used to specify the table name.

In the following example, we register a query on entity `Color` with no parameter and no definition. So it will retrieve all lines in `colors` table.

        db.tables.register 'Color_0':{}
        lines = db.tables.query 'Color'
        
        expect(lines.length).toBe 3
        expect(lines[2].name).toBe 'red'
    
### register a query with a `filter` using an indexed foreign key field

When you query a registered query, you have to provide the entity name, an array containing the paramters and an optional query name.

        lines = db.tables.query 'Car', [1], 'byColor'
        
In the following example, we query the `cars` table with one parameter named `color` in the `keys` array which will receive the value `1`, and will target the `color_id` field in the `cars` table:

        db.tables.register 
            'Car_1_byColor': 
                filter: 
                    keys: ['color']
                    clauses: ['color'] 
        lines = db.tables.query 'Car', [1], 'byColor'
        
        expect(lines.length).toBe 3
        expect(lines[1].name).toBe 'Toyota Prius'
        
Specifying `color` in the `clauses` array tells the query service to look for the value `1` in the following fields wether they exist or not:

 - the indexed foreign key `color_id`
 - the indexed field `color`
 - the non indexed field `color`

So you can query a non indexed field in the same way:

        db.tables.register 
            'Car_1_byName': 
                filter: 
                    keys: ['name']
                    clauses: ['name']
        lines = db.tables.query 'Car', ['SL 600'], 'byName'
        
        expect(lines.length).toBe 1
        expect(lines[0].id).toBe 2

### query directly without registration with `entity name` and `keys`

You can provide directly the query definition instead of the name of a previously registered query:

        lines = db.tables.query 'Car', [2],
            filter: 
                keys: ['brand']
                clauses: ['brand'] 

        expect(lines.length).toBe 2
        expect(lines[1].name).toBe 'BMW Série 3 Berline'

### query and sort results

        lines = db.tables.query 'Car', sort: ['name']

        expect(lines.length).toBe 8
        expect(lines[4].name).toBe 'SL 600'

### query and sort cars in reverse order'

        lines = db.tables.query 'Car', sort: ['name':-1]

        expect(lines.length).toBe 8
        expect(lines[4].name).toBe 'Honda Jazz'

### query with a join and sort cars on multiple fields

Use the `select` clause in the query definition to define a join between tables.

Simply put a dot between tables' name to define a n -> 1 relationship: 

        cars.brands
        
will join `cars` and `brands` on 
    
        cars.brand_id = brands.id 
        
This will work if the `cars` table has a `brand_id` field.

You can also specify which field you want to take in each table. Simply put the fileds' name in parenthesis just after the table's name.
If you don't specify fields' name, no field will be selected. To select all fields, put a star `*`

If the same field name is selected in two different tables the second one will have prepended it's table's name and a dot.

        lines = db.tables.query
            select: 'cars(*).brands(name)'
            sort: ['brands.name', 'name':-1]

        expect(lines.length).toBe 8
        expect(lines[4].name).toBe 'SLK 200'

### query by using an operator in the filter's clauses

Currently, you can only use the `ìs` and `isnt` operators.

        lines = db.tables.query 'Car', [2],
            filter: 
                keys: ['brand']
                clauses:['brand', {field:'color_id', oper:'isnt', value:2}]

        expect(lines.length).toBe 1
        expect(lines[0].name).toBe 'BMW Série 3 Berline'

### query by using a user defined function as a filter

The filter function you provide will receive three parameters: the `line` to accept or not, the `keys` received as the query parameters and the line's table name. The function shoul return `true` if the line is accepted or `no` if it is rejected.

        lines = db.tables.query 'Car',
            filter: (line, keys, tableName) -> 
                line.name.indexOf('SL') isnt 0

        expect(lines.length).toBe 6
        expect(lines[0].name).toBe 'BMW Série 2 Cabriolet'


### query with a join and select fields using a function

When you want to define a 1 -> n join, you have to put the table on the right side of the relationship inside brackets `[]`

In the following example

        colors.[cars]
        
will join `colors` and `cars` on 
    
        colors.id = cars.color_id 

In this example, no field is specified in the select clause, but the `map.add` clause defines a function that receives an `output` object and an `input` object. You just have to copy what you need from the `input` to the `output`.
In the `input` object, every field is prefixed by its corresponding table's name.

        lines = db.tables.query 'Car',
            select: 'colors.[cars].brands'
            filter:
                clauses: [field:'colors.id', oper:'is', value:2]
            map:
                add: (o, i) ->
                    o.id = i['cars.id']
                    o.name = i['cars.name']
                    o.brand = i['brands.name']

        expect(lines.length).toBe 3
        expect(lines[0].name).toBe 'SL 600'
        expect(lines[2].brand).toBe 'Honda'

There is also a `map.remove` clause that can be used to remove fields from the selected ones (i.e. if you use the star `*` in the `select` clause.

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

Chocokup also provides a basic `lorem` service that can generate `word`, `sentence`, `paragraph`, `image` and `face`.
    
`lorem.word`, `lorem.words`, `lorem.sentence`, `lorem.sentences`, `lorem.paragraph`, `lorem.paragraphs` generate text and so can be used anywhere a text is expected.
    
>   e.g.: div src:lorem.sentences(3) 

`lorem.image` and `lorem.face` generate an url that can be used in a `ìmg` tag as its `src` property value.
    
>   e.g.: img src:lorem.image('woman') 
    
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
             load and renderit if it's an Interface or execute **interface** function if exists,
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

**Steps** execution:

  - execute asynchronous preparation steps before 'render' function. `steps` function returns `this.respond.later`.

**Render** execution:

 - execute interface's 'render' function ('action' is an available synonym for 'render')
 - returns synchronously or asynchronously an Interface.Reaction
 
When Chocolate workflow service receives a request, it loads the corresponding module.
If the module has an property named `interface` which is an instance of Locco `Interface`,
it submits the provided parameters and the system context (__) in a `bin` to the interface:
        
        Interface = require 'chocolate/general/locco/interface'
        exports.interface = new Interface
            defaults:
                who: 'you'
                where: 'Paris'
            render: ->
                'hello ' + @bin.who + ' in ' + @bin.where

`Interface` service makes explicit what you have to deal with when you create an interface.

### <a name="Choco-Locco-Interface-Web"></a>Interface.Web [⌂](#Choco-Summary) 

An `Interface.Web` service makes it easy to build a web interface component.

You just declare an interface where the `render` is some Chocokup code that can access data stored in the provided `bin`.
That interface can embed other `Interface.Web` modules:

        welcome_user = new Interface.Web
            defaults:
                welcome_message: -> 'Welcome'
            use: ->
                login_panel: new Interface.Web
                    defaults:
                        login: -> 'Login'
                        signin: -> 'Sign in'
                    render: ({login, signin}) ->
                        a href:'#', login
                        a href:'#', signin
                
            render: ({__, welcome_message})->
                if __.session.user?.has_signed_in
                    span welcome_message
                    span __.session.user.name
                else
                    login_panel @bin.login_panel.bin

If you want to declare, in the `defaults` or `use` sections, an object that contains cyclical cross references, you have to create it with the `new` keyword or to put it in an array. 
This way the `Interface.Web` will not look endlessly inside your `defaults` (or `use`) section for `Interface.Web` objects.

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

## <a name="Choco-liteLorem"></a> liteLorem [⌂](#Choco-Summary) 

liteLorem is a basic lorem (fake words, sentences and images) library that can be used anywhere and that is included in chocokup
    
    lorem.word(): generates one words
    
    lorem.words(count): generates `count` words
    
    lorem.sentence(): generates one sentence (5 to 10 words each), starting with an upper case and ending with a point.
    
    lorem.sentences(count): generates `count` sentences
    
    lorem.paragraphs(): generates one paragraph (10 to 20 sentences each), separated by a newline char (\\n)
    
    lorem.paragraphs(count): generates `count` paragraphs
    
    lorem.image(): generates a random image (400x200px)
    
    lorem.image(width:200, height:300): generates a random image (200x400)
    
    lorem.image(type:'arch'): generates a random architecture image. Type can be: `animals`, `arch`, `nature`, `people`, `tech`
    
    lorem.image(type:'people', color:'sepia'): generates a random people image in sepia (with sepia a `type` has to be provided). 
    
    lorem.image(color:'grayscale'): generates a random image in gray scale.
    
    lorem.image(blur:true): generates a random blurred image (with blurred image no `type` can be provided).
    
    lorem.image(gravity:'east'): generates a random image cropped to the east if image is wider than high (with gravity image no `type` can be provided). Gravity can be `north`, `east`, `south`, `west`, `center`

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

Chocolate is still currently (2016/05) an experimental framework that needs to be completed and polished, so I'm working on:

 - user interface generation using locco/interface and chocokup
 - data storage using server/document and/or server/reserve
 - putting this framework live on a real use case
 - ...

&nbsp;

---

## <a name="Choco-License"></a> License [⌂](#Choco-Summary) 
    
    MIT License
    
    Chocolate is a simple webapp framework built on Node.js using Coffeescript
    Copyright (c) 2011-2016, Jean-Claude Levy
    
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
