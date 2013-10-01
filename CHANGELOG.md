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

