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

