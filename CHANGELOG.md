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
- incorrected Monit sample to supervise the upstart daemon
- update client libraries:
  - coffescript: 1.6.2
  - jasmine: 1.3.1
  - ace: build 2013-03-14
- .js documents don't always work in editor

##v0.0.1 (2013-03-24)

----------------

Initial public release

