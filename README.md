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
                                                     

# Chocolate - Web Apps with a sweet taste

Chocolate is a simple webapp framework built on Node.js using Coffeescript. 

It includes :
   
 - an **online IDE** (with Coffeescript, Javascript, Css and Markdown support)

 - an online and immediate **playground** for Coffeescript, Chocokup and Doccolate

 - a basic **source control** with Git

 - **Chocokup** : an Html markup language that helps build web user interfaces using 100% pure CoffeeScript (based on Coffeekup)
 
 - **Specolate** : a client and server side behavior/test driven development tool (based on Jasmine)

 - **Doccolate** : an online documentation editing tool (based on Docco)

 -  **NewNotes** : a promising note taking tool

Chocolate integrates :

 - [Node.js](http://nodejs.org)
 - [Coffeescript](http://coffeescript.org)
 - [Ace](http://ace.ajax.org)
 - [Mootools](http://mootools.net)
 - [Docco](http://jashkenas.github.com/docco/)
 - [Coffeekup](http://coffeekup.org)
 - [Jasmine](http://pivotal.github.com/jasmine)
 - [Highlight.js](http://softwaremaniacs.org/soft/highlight/en)
 - [Showdown](https://github.com/coreyti/showdown)
 - [Git](http://git-scm.com)
 - [Impress](http://bartaz.github.com/impress.js/#/bored)

&nbsp;

## Version

Chocolate v0.0.3 - 2013/04/19

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

See history in **CHANGELOG.md** file

## Demo

There is a non-writable demo at : <https://demo.chocolatejs.org/>

## Installation

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

Then you can install Chocolate:

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



## Use it

Chocolate runs on your server and responds to https requests on port 8026

You can change port number in /etc/init/chocolate.conf where you add the **port** parameter after  `/home/chocolate/myapp` at line:

    exec sudo -u chocolate -i /usr/local/lib/node_modules/coffee-script/bin/coffee /usr/local/lib/node_modules/chocolate/server/monitor.coffee /home/chocolate/myapp 80 2>&1 >> /var/log/node.log

You can also use a simple Http server by specifying options in the config.coffee file:

    exports.http_only = yes
    exports.port = 80

### Log on

You defined a master key when using chocomake to create myapp.

You enter that key at: 

    https://myserver:8026/-/server/interface?register_key

### Log off

To logoff go to : 

    https://myserver:8026/-/server/interface?forget_key

### Enter Chocolate Studio

To enter Chocolate Studio, go to: 

    https://myserver:8026/-/server/studio

There you can create, modify, move and commit source files

### Web access to source files and functions

You access a file directly in the browser:

To display `default.coffee` as raw text

    https://myserver:8026/default?how=raw

To display `default.coffee` as documentation text (docco)

    https://myserver:8026/default?how=help

To edit `default.coffee`

    https://myserver:8026/default?how=edit

To run `default.spec.coffee` specs (if you create it)

    https://myserver:8026/default?so=test

### Locco: the Chocolate protocol

Requests to Chocolate server follow theses rules (the Locco protocol):

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

**Locco protocol operations**

- **`so`** indicates the action type.

    - **`do`**:  execute an exported function in source file  
        - parameters can be specified by name or by position
    - **`move`**: 
        - if **`what`** is specified:  
        move **`what`** file's content to **`where`** file  
        - otherwise, if Http request is a **POST** request then:  
        move POST message data to **`where`** file  
        
    - **`test`**: run the **where** file associated spec: ie. default.spec.coffee for default.coffee
    - **`go`**: default action. Load **where** file and execute interface function.

- **`what`** adds a precision on the action object (usualy its pathname).
- **`where`** tells where the action should take place: a pathname
- **`how`** asks for a special type of respond if available (web, raw, help).
    - **`web`**: default. responds as an Html document
    - **`raw`**: responds as plain text
    - **`help`**: responds as an Html Docco help file
    - **`edit`**: responds as an Html source web editor

- a **`backdoor_key`** key can be specified to have system access

        https://myserver/!/my_backdoor_key/myworld/myfolder
            
Usage:

        https://myserver/myworld/myfolder?so=move&what=/myworld/mydocument
           Moves /myworld/mydocument file to /myworld/myfolder
           so = move
           what = /myworld/mydocument
           where = /myworld/myfolder
           how = web (by default) - will return an answer as Html.

        https://myserver/myworld/myfolder
           Go to /myworld/myfolder file, 
             load it and execute **interface** function if exists,
             otherwise open file in editor
           so = go (by default)
           what = undefined
           where = /myworld/myfolder
           how = web (by default) - will return an answer as Html.

        https://myserver/myworld/myfolder?myFunc&myParamValue
           Go to /myworld/myfolder file, 
             load it and execute **myFunc** function if exists, with myParamValue param
             otherwise returns empty page
           so = do (by default when request has parameters)
           what = myFunc
           where = /myworld/myfolder
           how = web (by default) - will return an answer as Html.

&nbsp;

## Chocolate Studio

A sweet web app ide.

It displays your source files and browse through directories, has a search in files service.  
It has a panel that displays log messages.  
It can also list and open source file commited versions.

You can create and move files (but not rename or delete files ! I should add this...).

The central panel has the code editor.
It has syntax highlighting for Coffeescript, Javascript, CSS and Markdown.

This panel can split to display the associated spec file (see Specolate)  
or the source file in help mode (see Doccolate)
or the Lab that can be used to test Coffeescript or Chocokup code.

The help panel lists some usefull resources. Links will be opened in the central panel.

The Notes panel allows you to write and save some notes.

**Usage**

    https://myserver:8026/-/server/studio

**Source**

    https://myserver:8026/-/server/studio?how=raw

**Editor shrotcuts**

    https://github.com/ajaxorg/ace/wiki/Default-Keyboard-Shortcuts

&nbsp;

## The Lab

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

**Chocokup Lab**

Chocokup lets you write HTML templates using Coffeescript.

When you type Chocokup code in the Lab editor, it is immediately translated to HTML.  
But more... when you display the **Dom** panel you can see immmediately the result!

Copy the following code in the Chocokup Lab with the Dom panel:

    panel ->
      header -> 'header'
      footer -> 'footer'
      body ->
        for i in [0..3] 
          button "#{i}"

And see...

Then change **[0.\.3]** to **[0.\.6]** and see the result...

&nbsp;

## How to write Modules

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
they will be compiled if .coffee and copied to the `/static/ijax` folder 
and will be downloadable by your javascript client code (using the provided require function).

If you create a general module (that can work on server and in browser), you will need to write something like the following code:

    class MyGeneralModule
        constructor: ->
            ...
        
    _module = window ? module
    _module.exports = MyGeneralModule

The exported function `interface`, if present in your module, is used to return an HTML content if someone calls that module with no parameter:

i.e., in module `mymodule.coffee`:

    exports.interface = ->
        '<div>Hello</div>'

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
      .request: HTTP request object
      .response: HTTP response object

i.e.:

    exports.check_appdir = (__) ->
        "Application directory is:" + __.appdir

&nbsp;

## Chocokup

Chocokup is derived from [Coffeekup](http://coffeekup.org) which is a templating engine for node.js and browsers that lets you to write your HTML templates in 100% pure CoffeeScript.

What Chocokup adds is the "Panel orientation" missing from Html which is page oriented.

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

&nbsp;

### Usage

#### Chocokup.Document

In a Coffeescript source file (ie. : mypage.coffee),  
insert an `interface` function that returns a new `Chocokup.Document`
        
    Chocokup = require 'chocolate/general/chocokup'
    
    exports.interface = ->
        new Chocokup.Document 'Chocolate - Wep Apps with a sweet taste', ->
            body ->
                "Welcome to Chocolatejs.org !"

            
Then open a web browser and open that page: ie. https://myserver/mypage

#### Chocokup.Panel

If you only want to build a partial document, you can use `Chocokup.Panel`

    Chocokup = require 'chocolate/general/chocokup'
    
    kup = ->
        text "Welcome to Chocolatejs.org !"
        
    exports.interface = ->
        new Chocokup.Panel(kup).render()


### Reference

Read the complete Chocokup reference in Chocolate Studio Chocokup help panel.

&nbsp;

## Specolate

Specolate is a client and server side behavior/test driven development tool.

It uses [Jasmine](http://pivotal.github.com/jasmine), a great behavior-driven development framework for testing JavaScript code.

### Usage

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

## Doccolate

**Docco** is a literate-programming-style
documentation generator. It produces HTML that displays your comments
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

## Newnotes

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

### Usage

You can use it directly inside Chocolate Studio in the Notes panel, 
but also directly and fullscreen at: `https://myserver/-/server/newnotes`

### Impress.js with Newnotes !

You can display a Newnotes branch with impress.js: `https://myserver/-/server/newnotes?my-branch-title&as=impress`

### Reference

Read the complete Newnotes reference in Chocolate Studio Newnotes help panel.

&nbsp;

## Road Map

Chocolate is currently (2013/03) an experiment that needs to be completed and polished:

 - user management
 - security management
 - data management: offline and online synchronization
 - responsive user interface services
 - robust live coffeescript (and javascript) in lab tab
 - link source context to notes in Newnotes
 - ...

&nbsp;

## License
    
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