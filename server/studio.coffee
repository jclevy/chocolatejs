# **Immediate** programing environment

Chocokup = require '../general/chocokup'
Doccolate = require '../general/doccolate'

exports.interface = (__) ->
    exports.enter(__)
    
exports.enter = (__) ->
    new Chocokup.App 'Chocolate Studio', with_coffee:yes, doccolate_style:Doccolate.options.default_style, snippets:__.config.get('snippets'), ->
        style
            type:"text/css" 
            media:"screen"
            """
            .choco_title {
                font-family: Times new roman;
                font-size: 17px;
                font-style: italic;
            }
            body {
                font-family:Lucida Console,monospace;
                font-size:9pt;
                line-height: 12pt;

            }
            a.selected {
                border-bottom: 1px double;
            }
            li.selected {
                background-color:rgba(0,0,0,0.1);
            }
            .blurred {
                -webkit-filter: blur(3px);
                -moz-filter: blur(3px);
                -o-filter: blur(3px);
                -ms-filter: blur(3px);
                filter: blur(3px);
            }
            .chocoblack code,
            .chocomilk code {
                font-size: 12px;
                padding: 0 0.2em;
                border: 1px solid #262836;
                background: rgb(248, 248, 248);
                display: inline-block;
                -webkit-box-shadow: 0 0 4px rgb(92, 75, 68);
                -moz-box-shadow: 0 0 4px rgb(92, 75, 68);
                -o-box-shadow: 0 0 4px rgb(92, 75, 68);
                box-shadow: 0 0 4px rgb(92, 75, 68);  
                padding: 2px 4px;
                border-bottom-left-radius: 7px;
                border-top-right-radius: 8px;
            }
            .panel.frame > .sizer {
                outline: inherit;
            }
            .white {
                background-color: rgba(255, 255, 255, 1);
                color: rgba(0, 0, 0, 0.6);
            }
            .white .sizer {
                outline: none;
            }
            .chocomilk {
                background-color:rgb(245, 242, 232);
                border: 2px solid rgba(255, 204, 0, 0.3);
                color: rgb(92, 75, 68);
            }
            .chocomilk a, .chocomilk select {
                color: rgb(92, 75, 68);
            }
            .white-background {
                background-color: white;
            }
            .transparent-background {
                background-color: transparent;
            }
            .round.frame > .sizer {
                font-size: 9pt;
                line-height: 12pt;
            }
            .padded {
                padding: 8px;
            }
            .darkTheme .ace_editor.dimmed .ace_scroller {
                background-color: dimgrey;
            }
            .lightTheme .ace_editor.dimmed .ace_scroller {
                background-color: lightgrey;
            }
            .bite_style {
                height: 7px;
                width: 7px;
                border-right: 1px solid white;
                border-bottom: 1px solid white;
            }
            
            .ace_editor {
                height: 100%;
            }

            #editor .ace_text-layer, #editor .ace_gutter {
                font-size: 9pt;
            }
            #specolate-panel-editor .ace_text-layer, #specolate-panel-editor .ace_gutter {
                font-size: 9pt;
            }
            #experiment-script-panel-editor .ace_text-layer, #experiment-markup-panel-editor .ace_text-layer,
            #notes-panel .ace_text-layer {
                font-size: 9pt;
                line-height: 12pt;
                font-weight: normal;
            }
            #help-panel .body {
                padding: 12px;
            }
            #help-panel h1 {
                font-size: 1.9em;
            }
            #help-panel h2 {
                font-size: 1.1em;
            }
            #help-panel h3 {
                font-size: 1.05em;
            }
            #notes-panel .panel .paper {
                font-size: 11pt;
            }
            #source_select {
                border: none;
                vertical-align: middle;
            }
            #source_close, #source_exec {
                border: 1px solid;
                padding: 0px 3px;
                cursor:pointer;
            }
            
            #toggle-login {
                color: red;
            }

            #toggle-login.logged {
                color: green;
            }
            
            #toggle-login.checking, #toggle-debug.checking {
                color: yellow;

                animation: blink-animation 1s steps(5, start) infinite;
                -webkit-animation: blink-animation 1s steps(5, start) infinite;
            }
            @keyframes blink-animation {
                to {
                    visibility: hidden;
                }
            }
            @-webkit-keyframes blink-animation {
                to {
                    visibility: hidden;
                }
            }
            #toggle-debug {
                color: green;
            }
            
            #toggle-debug.debugging {
                color: red;
            }
            
            #input-login {
                line-height: 2em;
            }

            /* darkTheme */
            body.darkTheme {
                background-color:#1a1c24;
                color:#eaeaea;
            }
            .darkTheme #header > .panel {
                border-bottom: 1px solid #171717;
            }
            .darkTheme .header, .darkTheme .footer {
                background-color: #323244;
                color: #eaeaea;
                border-top: 1px solid #080808;
            }
            .darkTheme a, .darkTheme select {
                color:#eaeaea;
                font-weight: normal;
            }
            .darkTheme .sizer {
                line-height: 2em;
                border-left: 2px solid #262836;
                margin: 1px;
                outline: 1px solid #262836;
                border-bottom-left-radius: 8px;
                border-top-right-radius: 9px;
            }
            .darkTheme .chocoblack {
                background-color: #1a1c24;
            }
            .darkTheme .round.frame {
                padding: 6px 6px;
                border-radius: 6px;
                margin: 3px 3px;
            }
            .darkTheme .round.frame > .sizer {
                width: 98%;
                height: 98%;
                top: 1%;
                left: 1%;
                border-style:none;
            }
            .darkTheme .frame.white.round, .darkTheme .frame.chocomilk.round {
                -webkit-box-shadow: inset 0 0 20px #080706;
                -moz-box-shadow: inset 0 0 20px #080706;
                -o-box-shadow: inset 0 0 20px #080706;
                box-shadow: inset 0 0 20px #080706;    
            }
            .darkTheme .white {
                border: 2px solid rgba(119, 110, 73, 0.3);
            }
            .darkTheme .grey {
                background-color: #191919;
                border: 2px solid #202020;
            }
            .darkTheme #source_select {
                background-color: #4c433e;
                color: #eaeaea;
            }
            .darkTheme #source_close, .darkTheme #source_exec {
                border-color: #eaeaea;
                color: #eaeaea;
            }
            
            /* lightTheme */
            body.lightTheme {
                background-color: #FBFBFB;
                color: #0E0E0E;
            }
            .lightTheme .header, .lightTheme .footer {
                background-color: #DAE1EC;
                color: #46423D;
                border-top: 1px solid;
            }
            .lightTheme a, .lightTheme select {
                color: #312E29;
                font-weight: normal;
            }            
            .lightTheme .sizer {
                border-right: 1px solid #C0C0C0;
            }
            .lightTheme .round.frame > .sizer > .panel {
                padding: 4px;
            }
            .lightTheme .grey {
                background-color: #F3F3F3;
            }
            .lightTheme #documentation-panel, .lightTheme #experiment-panel {
                border-top: 1px solid #C0C0C0;
            }
            .lightTheme #source_select {
                background-color: #FBFBFB;
                color: #0E0E0E;
            }
            .lightTheme #source_close, .lightTheme #source_exec {
                border-color: #424242;
                color: #424242;
            }
            """
        style -> 
            text @params.doccolate_style
        
        snippets = coffee :  """
            # Require Locco Interface
            snippet locco_require_interface
            \tInterface = require 'chocolate/general/locco/interface'\n
            # Locco full Interface
            snippet locco_interface_full
            \tnew Interface${1:.Web.Html | .Web.App | .Web.Document | .Remote}
            \t\tdefaults: -> ${2}
            
            \t\tlocks: -> ${3}
            
            \t\tcheck: (${4}) -> 
            \t\t\t${5:# body...}
            
            \t\tsteps: (${6:$2}) -> 
            \t\t\t${7:# body...}
            
            \t\trender: (${8:$2}) ->
            \t\t\t${9:# body...}
            # Locco full Interface.Web.Html
            snippet locco_interface_html_full
            \tnew Interface.Web.Html
            \t\tdefaults: -> ${1}
            
            \t\tlocks: -> ${2}
            
            \t\tcheck: (${3}) -> 
            \t\t\t${4:# body...}
            
            \t\tsteps: (${5}) -> 
            \t\t\t${6:# body...}
            
            \t\trender: (${7}) ->
            \t\t\t${8:# body...}
            # Locco standard Interface.Web.Html
            snippet locco_interface_html_standard
            \tnew Interface.Web.Html (-> ${1}), ${2}->
            \t\t${3:# body...}
            # Locco minimal Interface.Web.Html
            snippet locco_interface_html_minimal
            \tnew Interface.Web.Html ->
            \t\t${1:# body...}
            # Chocodash require
            snippet require_chocodash
            \t_ = require 'chocolate/general/chocodash'\n
            # Chocodash async
            snippet chocodash_async_or_flow
            \t_.flow (run) ->
            \t\trun (end) ->
            \t\t\t${1:end() | end.later}
            """

        text "<script>_ = Chocodash; _ide = {}; _sofkey = #{if backdoor_key isnt '' then '"' + backdoor_key + '"' else 'null'};</script>\n"
        text "<script>_ide.snippets = {studio:{applied:{}, modes:#{JSON.stringify(snippets)}}, user:{applied:{}, modes:#{if @params.snippets then JSON.stringify @params.snippets else '{}'}}}</script>" 
        script src:"/static/vendor/ace/ace.js", type:"text/javascript", charset:"utf-8"
        script src:"/static/vendor/ace/ext-searchbox.js", type:"text/javascript", charset:"utf-8"
        script src:"/static/vendor/ace/ext-language_tools.js", type:"text/javascript", charset:"utf-8"
        script src:"/static/vendor/ace/snippets/coffee.js", type:"text/javascript", charset:"utf-8"
        script src:"/static/vendor/ace/snippets/javascript.js", type:"text/javascript", charset:"utf-8"
        script src:"/static/vendor/ace/snippets/json.js", type:"text/javascript", charset:"utf-8"
        script src:"/static/vendor/ace/snippets/css.js", type:"text/javascript", charset:"utf-8"
        script src:"/static/vendor/ace/snippets/text.js", type:"text/javascript", charset:"utf-8"
        script src:"/static/vendor/ace/snippets/html.js", type:"text/javascript", charset:"utf-8"
        script src:"/static/vendor/ace/snippets/markdown.js", type:"text/javascript", charset:"utf-8"
        script src:"/static/vendor/ace/mode-coffee.js", type:"text/javascript", charset:"utf-8"
        script src:"/static/vendor/ace/mode-javascript.js", type:"text/javascript", charset:"utf-8"
        script src:"/static/vendor/ace/mode-json.js", type:"text/javascript", charset:"utf-8"
        script src:"/static/vendor/ace/mode-css.js", type:"text/javascript", charset:"utf-8"
        script src:"/static/vendor/ace/mode-scss.js", type:"text/javascript", charset:"utf-8"
        script src:"/static/vendor/ace/mode-text.js", type:"text/javascript", charset:"utf-8"
        script src:"/static/vendor/ace/mode-html.js", type:"text/javascript", charset:"utf-8"
        script src:"/static/vendor/ace/mode-markdown.js", type:"text/javascript", charset:"utf-8"
        script src:"/static/vendor/ace/theme-coffee.js", type:"text/javascript", charset:"utf-8"
        script src:"/static/vendor/ace/theme-coffee_white.js", type:"text/javascript", charset:"utf-8"
        script src:"/static/lib/doccolate.js", type:"text/javascript", charset:"utf-8"
        script src:"/static/lib/js2coffee.js", type:"text/javascript", charset:"utf-8"
        script src:"/static/lib/htmlkup.js", type:"text/javascript", charset:"utf-8"
        script src:"/static/vendor/datejs/date.js", type:"text/javascript", charset:"utf-8"
        script src:"/static/vendor/mootools/mootools-core-uncompressed.js", type:"text/javascript", charset:"utf-8"
        script src:"/static/lib/newnotes.js", type:"text/javascript", charset:"utf-8"

        body '.lightTheme', ->
            panel ->
                header '#header', ->
                    panel proportion:'served', ->
                        panel -> 
                            span '#.choco_title.float-margin-left', 'Chocolate.js'
                        panel -> 
                            select '#source_select.hidden', onchange:'_ide.open_file()', ''
                            span '.float-right', -> 
                                span '#source_exec.hidden', onclick:'_ide.exec_file()', '↗'
                                text '&nbsp;&nbsp;'
                                span '#source_close.hidden', onclick:'_ide.close_file()', 'x'
                            a '#switch-wrap.float-margin-right', title:'Switch wrap mode', style:'font-size: 9pt;text-decoration: none;', href:"#", onclick:"_ide.switchWrap();", -> '↩'
                            a '#switch-invisible.float-margin-right', title:'Switch invisible caracters display', style:'font-size: 9pt;text-decoration: none;', href:"#", onclick:"_ide.switchInvisible();", -> '...'
                        panel ->
                            input '#input-login.float-margin-right.hidden', type:'password', onchange:'_ide.register_key()', ''
                            a '#toggle-login.float-margin-right', title:'Login/Logoff', style:'font-size: 15pt;text-decoration: none;', href:"#", onclick:"_ide.toggleLogin();", -> '•'
                            a '#toggle-debug.float-margin-right', title:'Debug/Run', style:'font-size: 13pt;text-decoration: none;', href:"#", onclick:"_ide.toggleDebug();", -> '▣'
                            a '#toggle-fullscreen.float-margin-right', title:'Switch fullscreen', style:'font-size: 15pt;text-decoration: none;', href:"#", onclick:"_ide.toggleFullscreen();", -> '«»'
                            a '#switch-panel.float-margin-right', title:'Switch side by side display', style:'font-size: 9pt;text-decoration: none;', href:"#", onclick:"_ide.switchScreens();", -> '|||'
                            a '#switch-theme.float-margin-right', title:'Switch theme', style:'font-size: 9pt;text-decoration: none;', href:"#", onclick:"_ide.switchTheme();", -> '□'
                body ->
                    panel '#main-panel', proportion:'served', ->
                        panel ->
                            footer ->
                                panel proportion:'third', ->
                                    box -> a '#do-file-create', href:"#", onclick:"_ide.create_file();", -> 'Create'    
                                    box -> a '#do-git-commit', href:"#", onclick:"_ide.commit_to_git();", -> 'Commit'    
                                    box -> 
                                        a '#do-file-upload', href:"#", onclick:"_ide.upload_file('ask');", -> 
                                            text 'Upload'
                                        form "#form-file-upload", action:"", method:"post", enctype:"multipart/form-data", target:"frame-file-upload", ->
                                            input "#input-file-upload", name:"input-file-upload", type:'file', onchange:"_ide.upload_file('send');"
                                        iframe "#frame-file-upload", name:"frame-file-upload", ->
                            body ->
                                panel proportion:'third', orientation:'vertical', ->
                                    panel ->
                                        header -> box 'Opened files'
                                        body ->
                                            box '#.chocoblack.round', -> body '#open_files_list', ''
                                    panel -> 
                                        header -> 
                                            panel proportion:"half", orientation:"horizontal", ->
                                                box -> a '#toggle-search', href:"#", onclick:"_ide.toggleNavigatePanel('search');", -> 'Search'
                                                box -> a '#toggle-browse.selected', href:"#", onclick:"_ide.toggleNavigatePanel('browse');", -> 'Browse'
                                        body ->
                                            panel '#studio-search-panel.hidden', ->
                                                panel ->
                                                    header -> input "#search_in_file_input", size:"70%", onchange:"_ide.search_in_files(this.value);", ->
                                                    body ->
                                                        box '#.chocoblack.round', -> body '#studio-search', ->
                                            panel '#studio-browse-panel', -> 
                                                box '#.chocoblack.round', -> body ->
                                                    div ->
                                                        text '/'
                                                        span '#current_dir', ->
                                                    div '#dir_content', style:'margin-left:4px;', ->
                                    panel ->
                                        header -> box 'Log'
                                        footer ->
                                            panel proportion:'third', ->
                                                box -> a '#do-file-rename', href:"#", onclick:"_ide.rename_file();", -> 'Rename'    
                                                box -> a '#do-file-move', href:"#", onclick:"_ide.move_file();", -> 'Move'
                                                box -> a '#do-file-delete', href:"#", onclick:"_ide.delete_file();", -> 'Delete'
                                        body ->
                                            panel '#studio-messages-panel', -> 
                                                box '#.chocoblack.round', -> body '#studio-messages', ->
                        panel ->
                            footer ->
                                panel proportion:'third', ->
                                    box -> a '#toggle-source.selected', href:"#", onclick:"_ide.toggleMainPanel('source');", -> 'Code'
                                    panel proportion:'third', ->
                                        box -> a '#toggle-shared', href:"#", onclick:"_ide.toggleMainPanel('shared');", -> 'Code & Lab'                                
                                        box -> a '#toggle-specolate', href:"#", onclick:"_ide.toggleMainPanel('specolate');", -> 'Spec'
                                        box -> a '#toggle-doccolate', href:"#", onclick:"_ide.toggleMainPanel('doccolate');", -> 'Doc'
                                    box -> a '#toggle-experiment', href:"#", onclick:"_ide.toggleMainPanel('experiment');", -> 'Lab'
                            body ->
                                panel '#main-display', proportion:'half', orientation:'vertical', ->
                                    panel '#main-editor.expand', ->
                                        panel '#editor', ''
                                    panel '#main-tabs.shrink', ->
                                        panel '#experiment-panel', proportion:'half-served', orientation:'vertical', ->
                                            panel proportion:'half', ->
                                                panel ->
                                                    footer ->
                                                        panel proportion:'half', ->
                                                            box -> 
                                                                a '#toggle-coffeescript.selected', href:"#", onclick:"_ide.toggleExperimentPanel('coffeescript');", -> 'Coffeescript'
                                                                text ' / '
                                                                a '#toggle-javascript', href:"#", onclick:"_ide.toggleExperimentPanel('javascript');", -> 'Javascript'
                                                            box -> 
                                                                a '#toggle-chocodown', href:"#", onclick:"_ide.toggleExperimentPanel('chocodown');", -> 'Chocodown'                                                        
                                                                text ' / '
                                                                a '#toggle-html', href:"#", onclick:"_ide.toggleExperimentPanel('html');", -> 'Html'
                                                    body -> 
                                                        box '#experiment-script-panel-main.chocoblack.round', -> panel '#experiment-script-panel-editor', ''
                                                        box '#experiment-markup-panel-main.chocoblack.round.hidden', -> panel '#experiment-markup-panel-editor', ''
                                                panel ->
                                                    panel '#experiment-script-transpiled', ->
                                                        footer ->
                                                            panel proportion:'half', ->
                                                                box -> a '#toggle-script-output.selected', href:"#", onclick:"_ide.toggleExperimentPanel('script-output');", -> 
                                                                    span '#label-javascript-output', 'Javascript'
                                                                    span '#label-coffeescript-output.hidden', 'Coffeescript'
                                                                box -> 
                                                                    panel "#toggle-debug-panel", proportion:'half-served', ->
                                                                        panel ->
                                                                            a '#toggle-debug', href:"#", onclick:"_ide.toggleExperimentPanel('debug');", -> 'Debug'
                                                                        panel proportion:'half', ->
                                                                            panel ->
                                                                                a href:"#", title:"Reduce column width", onclick:"_ide.changeDebugColWidth(-1);", -> '-'
                                                                            panel ->
                                                                                a href:"#", title:"Increase column width",  onclick:"_ide.changeDebugColWidth(1);", -> '+'                                                        
                                                        body ->
                                                            panel '#experiment-script-output-panel-main', -> 
                                                                box '#.white.round', -> body '#experiment-script-output-panel.source-code.dl-s-default', ->
                                                            panel '#experiment-debug-panel-main.hidden', -> 
                                                                box '#.chocoblack.round', -> panel '#experiment-debug-panel.source-code', ''
                                                    panel '#experiment-markup-transpiled.hidden', ->
                                                        footer ->
                                                            panel proportion:'half', ->
                                                                box -> 
                                                                    panel proportion:'half-served', ->
                                                                        panel ->
                                                                            a '#toggle-markup-output.selected', href:"#", onclick:"_ide.toggleExperimentPanel('markup-output');", -> 
                                                                                span '#label-chocodown-output', 'Html'
                                                                                span '#label-html-output.hidden', 'Chocokup'
                                                                        panel '#experiment-markup-options', proportion:'half', ->
                                                                            panel ->
                                                                                a href:"#", title:"Indented Chocokup", onclick:"_ide.toggleFormatChocokup(true);", -> '↘'
                                                                            panel ->
                                                                                a href:"#", title:"Raw Chocokup", onclick:"_ide.toggleFormatChocokup(false);", -> '→'
                                                                box -> a '#toggle-dom', href:"#", onclick:"_ide.toggleExperimentPanel('dom');", -> 'Dom'                                                        
                                                        body ->
                                                            panel '#experiment-markup-output-panel-main', -> 
                                                                box '#.white.round', -> body '#experiment-markup-output-panel.source-code', ->
                                                            panel '#experiment-dom-panel-main.hidden', -> 
                                                                box '#.white.round', -> panel '#.padded', -> 
                                                                    iframe '#experiment-dom-panel.expand.fullscreen.white-background', frameborder:'0', ->
                                            panel -> box '#.grey.round', -> body '#experiment-run-panel.source-code', ''
                                        panel '#documentation-panel.hidden', -> 
                                            box '#.white.round', -> 
                                                iframe '#documentation-doccolate-panel.expand.fullscreen.transparent-background', frameborder:'0', ->
                                        panel '#specolate-panel.hidden', proportion:'half-served', orientation:'vertical', -> 
                                            panel ->
                                                header ->
                                                    panel 'Spec'
                                                    box -> a '#run-specolate.float-margin-right', href:"#", onclick:"_ide.run_specolate();", -> 'Run'
                                                body ->
                                                    box '#specolate-panel-main.chocoblack.round', -> panel '#specolate-panel-editor', ''
                                            panel -> box '#.grey.round', -> body '#specolate-result-panel.source-code', ''
                                            iframe '#specolate-run-panel.hidden', src:'/-/server/studio?iframe_body', ->
                                panel '#help-display.hidden', proportion:'full', ->
                                    header ->
                                        panel '#help-title', -> ''
                                        panel '#doclosehelpdisplay', -> a '#close-help-display.float-margin-right', style:'text-decoration: none;', href:"#", onclick:"_ide.close_help_panel();", -> 'x'
                                    body ->
                                        panel '#help-display-body', ->
                        panel ->
                            footer ->
                                panel proportion:'third', ->
                                    box -> a '#toggle-git.selected', href:"#", onclick:"_ide.toggleServicesPanel('git');", -> 'Git'
                                    box -> a '#toggle-notes', href:"#", onclick:"_ide.toggleServicesPanel('notes');", -> 'Notes'
                                    box -> a '#toggle-help', href:"#", onclick:"_ide.toggleServicesPanel('help');", -> 'Help'                                
                            body ->
                                panel '#git-panel', ->
                                    panel proportion:'half', orientation:'vertical', ->
                                        panel '#git-code.expand', ->
                                            box '#.chocoblack.round', -> body '#code-git-history', ->
                                        panel '#git-spec.shrink', ->
                                            header -> box -> 'Spec'
                                            body ->
                                                box '#.chocoblack.round', -> body '#spec-git-history', ->
                                panel '#notes-panel.hidden', ''

                                panel '#help-panel.hidden', ->
                                    panel ->
                                        header '#.inline', ->
                                            panel proportion:'third', ->
                                                box -> a '#toggle-help-chocolate.selected', href:"#", onclick:"_ide.toggleHelpPanel('chocolate');", -> 'Chocolate'
                                                box -> a '#toggle-help-coffeescript', href:"#", onclick:"_ide.toggleHelpPanel('coffeescript');", -> 'Coffeescript'
                                                box -> a '#toggle-help-chocokup', href:"#", onclick:"_ide.toggleHelpPanel('chocokup');", -> 'Chocokup'
                                        header '#.inline', ->
                                            panel proportion:'third', ->
                                                box -> a '#toggle-help-specolate', href:"#", onclick:"_ide.toggleHelpPanel('specolate');", -> 'Specolate'
                                                box -> a '#toggle-help-doccolate', href:"#", onclick:"_ide.toggleHelpPanel('doccolate');", -> 'Doccolate'
                                                box -> a '#toggle-help-newnotes', href:"#", onclick:"_ide.toggleHelpPanel('newnotes');", -> 'Newnotes'
                                        header '#.inline', ->
                                            panel proportion:'third', ->
                                                box -> a '#toggle-help-chocodown', href:"#", onclick:"_ide.toggleHelpPanel('chocodown');", -> 'Chocodown'
                                                box -> a '#toggle-help-litejq', href:"#", onclick:"_ide.toggleHelpPanel('litejq');", -> 'litejQ'
                                                box -> a '#toggle-help-node', href:"#", onclick:"_ide.toggleHelpPanel('node');", -> 'Node'                                    
                                        body '#.with-3-headers', ->
                                            footer -> panel '#help-selector-panel.hidden', ->
                                                select '#help-selector', onchange:"_ide.select_help_panel(true);", ->
                                            body ->
                                                box '#.chocomilk.round', -> panel ->
                                                    iframe '#help-frame-panel.expand fullscreen', frameborder: '0', ->

        coffeescript ->
            sofkey = _sofkey
            editor = lab_markup_editor = debug_editor = lab_script_editor = specolate_editor = null
            ace_theme = if $(document.body).hasClass('lightTheme') then 'ace/theme/coffee_white' else 'ace/theme/coffee'
            debug_experiment_sync = null
            sources =
                opened : []
                # codes : { path, doc, from_history , modified, modifiedDate }
                codes : {}
                specs : {}
                current : ''
                available : {}
                searched: {}
                isOpening : false
            frames =
                help : {}
            codeMode = 'opened'
            debugColumnWidth = 7
            formatChocokup = off
            
            console_log = console.log
            console.log = (text) ->
                _ide.display_message text
                console_log.apply console, arguments
            
            translate = (text) -> text
            
            # Display opened source files list
            _ide.get_extension = (path) ->
                    if (path = path.substr(1 + path.indexOf '/')).indexOf('.') is -1 then '' else '.' + path.split('.')[-1..][0]

            _ide.get_basename = (path) ->
                path.split('/')[-1..][0]
            
            _ide.is_spec_file = (path) ->
                suffix = '.spec'
                index = path.lastIndexOf '.'
                index = path.length if index < 0
                result = path.substr(index - suffix.length, suffix.length)  is '.spec'
                result = path.substr(index) is '.spec' unless result
                result
            
            _ide.get_spec_filename = (path) ->
                return '' if path is ''
                return path.replace ext, '.spec' + ext if (ext = _ide.get_extension path) isnt ''
                return path + '.spec'
                
            _ide.has_spec_file = (path) ->
                item = sources.codes[path]
                return item.has_spec_file if item?
                false
            
            _ide.get_current_dir = ->
                if (dir = document.id('current_dir').get 'text') is '' then '.' else dir

            _ide.iframe_infos = (iframe) ->
                doc = (iframe.contentDocument || iframe.contentWindow.document)
                doc_element = doc.documentElement || doc.body.parentNode || doc.body
                win = iframe.contentWindow
                scroll = 
                    if win.pageXOffset isnt undefined 
                        doc:win, attr: x:'pageXOffset', y:'pageYOffset'
                    else
                        doc:doc_element, attr: x:'scrollLeft', y:'scrollTop'
                
                scrollX = scroll.doc[scroll.attr.x]
                scrollY = scroll.doc[scroll.attr.y]
                
                {win, doc, doc_element, scrollX, scrollY}
                
            _ide.iframe_write = (iframe, text, scroll) ->
                
                {doc, win, scrollX, scrollY} = _ide.iframe_infos iframe
                
                iframeDoc = doc
                iframeDoc.open()
                iframeDoc.write text
                iframeDoc.close()
                
                unless scroll?
                    win.scrollTo scrollX, scrollY
                else
                    _ide.iframe_scrollTo iframe, scroll.left , scroll.top, scroll.elemW, scroll.elemH
            
            _ide.iframe_scrollTo = (iframe, x, y, elemW, elemH) ->
                {doc, doc_element, scrollX, scrollY} = _ide.iframe_infos iframe

                container = doc.getElementById('docco_container') ? doc_element
                
                ratioX = (container.clientWidth - doc.body.clientWidth) / elemW
                ratioY = (container.clientHeight - doc.body.clientHeight) / elemH
                
                new_scrollX = if x < 0 or elemW < 0 then scrollX else x * ratioX
                new_scrollY = if y < 0 or elemH < 0 then scrollY else y * ratioY
                
                iframe.contentWindow.scrollTo new_scrollX, new_scrollY

            _ide.display_message = (message) ->
                new Element('div').set('html', ('<p>' + new Date().toString translate 'dd/MM/yyyy HH:mm:ss')  + '<br/>&nbsp;&nbsp;' + message + '</p>').inject document.id('studio-messages'), 'top'
                
            _ide.display_help_panel = (name, path) ->
                path = '' if path is '-'
                
                _ide.toggleMainDisplay 'help' if path isnt ''
                
                selected_frame = frames.help[path]?.frame
                for own help_path, help of frames.help
                    if help.frame isnt selected_frame then help.frame.addClass 'hidden' else help.frame.removeClass 'hidden'
                    
                document.id('help-title').set 'text', path
                
                document.id('help-display-body').adopt (frames.help[path] = name: name, frame: new Element('iframe', src:path, frameborder:0, class:'expand fullscreen white-background')).frame unless selected_frame or path is ''
                
                help_selector = document.id('help-selector')
                help_selector.empty()
                (help_selector.adopt new Element 'option', selected:(if path is help_path then on else off), value: help_path, text: help.name) for own help_path, help of frames.help
                document.id('help-selector-panel')[(if help_selector.length <= 1 then 'add' else 'remove') + 'Class'] 'hidden'
                
            _ide.select_help_panel = (is_on_click) ->
                help_selector = document.id('help-selector')
                _ide.display_help_panel help_selector.getSelected().get('text')[0], help_selector.getSelected().get('value')[0]
                
            _ide.close_help_panel = ->
                
                path = document.id('help-title').get 'text'
                frames.help[path].frame.dispose()
                delete frames.help[path]
                
                new_help = {name: '', path: ''}
                for own path, help of frames.help then new_help = name: help.name, path: path
                _ide.display_help_panel new_help.name, new_help.path
                
                _ide.toggleMainDisplay 'main' if document.id('help-selector').length is 0

            _ide.display_opened_files_list = ->
                codes = []
                codes.push item for own item of sources.codes
                codes.sort()
                
                content = []
                current_steps = []
                for item in codes
                    steps = item.split '/'
                    for step, i in steps when i < steps.length-1
                        if step isnt current_steps[i]
                            current_steps = current_steps[0...i]
                            for j in [i...steps.length-1]
                                current_steps[j] = steps[j]
                                content.push "<div style='margin-top:4px;margin-left:#{j*8}px;'><a href='#' onclick=\"javascript:_ide.goto_dir('#{current_steps.join('/')}');\">#{steps[j]}</a></div>"
                    line = """<div style='margin-left:#{(steps.length-1)*8}px;'>"""
                    line += """<a href="#" onclick="javascript:_ide.close_file('#{item}');">x</a>&nbsp;"""
                    line += """<a href="#" onclick="javascript:_ide.save_file('#{item}');">*</a>&nbsp;""" if sources.codes[item].modified
                    line += """<a href="#" onclick="javascript:_ide.display_code_file('#{item}');">#{steps[steps.length-1]}</a>&nbsp;"""
                    line += """<a href="#" onclick="javascript:_ide.display_synchro_conflict_message('#{item}');">!</a>&nbsp;""" if sources.codes[item].has_synchro_conflict
                    if _ide.has_spec_file item
                        spec_item = _ide.get_spec_filename item
                        line += '['
                        line += """<a href="#" onclick="javascript:_ide.save_file('#{spec_item}');">*</a>&nbsp;""" if sources.specs[spec_item].modified
                        line += """<a href="#" onclick="javascript:_ide.display_code_file('#{item}'); _ide.toggleMainPanel('specolate')">spec</a>"""
                        line += ']&nbsp;'
                    line += "</div>"
                    content.push line
                document.id('open_files_list').set 'html', content  

            _ide.display_opened_files_select = ->
                codes = []
                codes.push item for own item of sources.codes
                codes.sort()

                content = []
                for item in codes
                    if_selected = if sources.current is item then ' selected="selected"' else ''
                    content.push "<option value='#{item}'#{if_selected}>/#{item + if sources.codes[item].modified then '*' else ''}</option>"
                
                selector = document.id('source_select').set 'html', content
                selector[(if content.length > 0 then 'remove' else 'add') + 'Class'] 'hidden'
                $$("#source_select > option[value='#{sources.current}']").setProperty 'selected', 'selected'

            _ide.has_modified_file = ->
                for path in [sources.codes, sources.specs]
                    for own k,v of path then if v.modified then return yes
                no
            
            _ide.switch_login = (switched) ->
                if not switched? 
                    document.id("toggle-login").removeClass('logged').addClass 'checking'
                    document.id("toggle-debug").addClass 'checking'
                else
                    document.id("toggle-login").removeClass 'checking'
                    document.id("toggle-debug").removeClass 'checking'
                    document.id("toggle-login")["#{if switched is on then 'add' else 'remove'}Class"] 'logged'
                    document.id("main-panel")["#{if switched is off then 'add' else 'remove'}Class"] 'blurred'
            
            _ide.sync_exec_windows = (count) ->
                for path, window_ of _ide.exec_file.paths when window_?
                    if count > 0
                        window_.document.body.innerHTML = """
                            <table style="font-size:120pt; width:100%; height:100%; text-align:center; vertical-align:middle">
                              <tr>
                                <td>#{count}</td>
                              </tr>
                            </table>
                            """
                    else
                        if window_.closed then delete _ide.exec_file.paths[path]
                        else _ide.exec_file path
                    
            _ide.check_connected = (timeout = 0) ->
                try_reconnect = not _ide.check_online.connected
                if timeout > 0 then _ide.switch_login()
                start = Date.now()
                new Request
                    url: (if sofkey? then '/!/' + sofkey else '') + '/-/server/studio?connected&how=raw'
                    noCache: yes
                    timeout: timeout
                    onSuccess: (data) ->
                        _ide.switch_login (_ide.check_online.connected = if data is "connected" then on else off)
                        _ide.sync_exec_windows() if try_reconnect and _ide.check_online.connected
                    onFailure: (xhr) ->
                        unless timeout > 0
                            _ide.switch_login (_ide.check_online.connected = off)
                    onTimeout: () ->
                        unless timeout > 0
                            _ide.switch_login (_ide.check_online.connected = off)
                .get()

            _ide.check_online = (timeout = 30000, delay = 1500) ->
                count = 0
                index = 0
                _ide.check_online.connected = off
                timer = setInterval ( -> 
                    index++
                    count += delay
                    if count < timeout and (index <= 1 or _ide.check_online.connected isnt yes) 
                        _ide.sync_exec_windows(index) ; _ide.check_connected delay 
                    else 
                        clearInterval timer
                ), delay
            
            _ide.register_key = ->
                new Request 
                    data: key:document.id("input-login").value
                    noCache: yes
                    url: (if sofkey? then '/!/' + sofkey else '') + '/-/server/interface?register_key&how=raw'
                    onSuccess: (data) =>
                        _ide.check_connected()
                        document.id("input-login").addClass('hidden').set 'value', ''

                    onFailure: (xhr) ->
                .post()

            _ide.logoff = ->
                new Request 
                    noCache: yes
                    url: (if sofkey? then '/!/' + sofkey else '') + '/-/server/interface?forget_keys&how=raw'
                    onSuccess: (data) =>
                        _ide.check_connected()
                    onFailure: (xhr) ->
                .post()
            
            _ide.debug = (onoff) ->
                new Request.JSON
                    noCache: yes
                    url: (if sofkey? then '/!/' + sofkey else '') + '/-/server/config?debug&' + onoff
                    onSuccess: ({protocol, port}) ->
                        if onoff
                            document.id("toggle-debug").addClass 'debugging'
                        else
                            document.id("toggle-debug").removeClass 'debugging'
                            _ide.check_online()

                        if onoff
                            _ide.debug.window = window.open "#{protocol}://#{window.location.hostname}:#{port}/debug?port=5858"
                        else
                            _ide.debug.window.close()
                    onFailure: (xhr) ->
                .get()
                
            _ide.goto_dir = (new_dir, callback) ->
                parent_dir = if (tmp_ = new_dir.split('/')[0...-1].join('/')) is '' then '.' else tmp_
                new Request.JSON
                    url: (if sofkey? then '/!/' + sofkey else '') + '/-/server/file?getDirContent&' + new_dir + '&how=raw'
                    onSuccess: (directory) ->
                        return if directory.error?
                        rel_new_dir = if new_dir is '.' then '' else new_dir + '/'
                        sources.available = {}
                        content = ["""<div><a href="#" onclick="javascript:_ide.goto_dir('#{parent_dir}');">..</a></div>""" if new_dir isnt '.']
                        for item in directory when item.name[0] isnt '.' # and (item.isDir or item.extension in ['.coffee', '.litcoffee', '.css', '.js', '.json', '.html', '.txt', '.markdown', '.md'])
                            unless _ide.is_spec_file item.name
                                content.push ('<div>' + """<a href="#" onclick="javascript:#{if item.isDir then '_ide.goto_dir' else '_ide.open_file'}('#{(if new_dir isnt '.' then (new_dir + '/') else '') + item.name}');">#{item.name}</a>""" + '</div>')
                            else sources.available[rel_new_dir + item.name.replace '.spec', '']?.has_spec_file = true
                            sources.available[rel_new_dir + item.name] = { name:item.name, extension:item.extension, modifiedDate:item.modifiedDate, has_spec_file:false } if item.isFile
                        document.id('dir_content').set 'html', content
                        document.id('current_dir').set 'text', if new_dir isnt '.' then new_dir else ''
                        callback?() 
                    onFailure: (xhr) ->
                        _ide.display_message "Error with _ide.goto_dir(#{new_dir}) : #{xhr.status}"
                        
                .get()

            _ide.load_file = (path, file, from_history) ->
                is_spec = _ide.is_spec_file path
                
                if not is_spec and not sources.codes[path]?
                    # Create or recycle an editor to display source file
                    if sources.opened.length >= 10
                        delete sources.codes[sources.opened[0]]
                        delete sources.opened[0]
                        sources.opened = sources.opened[1..]
                    
                    sources.opened.push path
                
                doc = _ide.create_session file, path
                item = sources.available[path] ? name:_ide.get_basename(path), extension:_ide.get_extension(path), modifiedDate:sources.searched[path]?.modifiedDate ? 0, has_spec_file:false
                sources[if is_spec then 'specs' else 'codes'][path] = { path, doc, from_history:from_history ? false, modified:from_history ? false, modifiedDate:item.modifiedDate, has_spec_file:item.has_spec_file }
                _ide.save_sources_opened()
                doc
                
            _ide.display_code_file = (path, overwrite) ->
                _ide.toggleMainDisplay 'main'
                
                editor.setSession if path is '' then _ide.create_session '' else sources.codes[path].doc
                document.id('source_exec')[(if path is '' then 'add' else 'remove') + 'Class'] 'hidden'
                document.id('source_close')[(if path is '' then 'add' else 'remove') + 'Class'] 'hidden'
                sources.current = path

                # Switch to Source display if current display is Experiment
                _ide.toggleMainPanel 'source' if document.id('toggle-experiment').hasClass 'selected'
                
                editor.focus()
                
                # Refresh file History panel if display file is not from History
                _ide.get_file_git_history path unless overwrite
                    
                _ide.on_file_status_changed()
                _ide.on_content_changed init:yes
                
                
                _ide.display_spec_file _ide.get_spec_filename path

                if path != ''  then $$("#source_select > option[value='#{path}']").setProperty 'selected', 'selected'
                    
                editor.getSession().on 'changeScrollTop', (scroll) ->
                    unless document.id('documentation-panel').hasClass 'hidden'
                        iframe = document.id('documentation-doccolate-panel')
                        _ide.iframe_scrollTo iframe, -1, scroll, -1, editor.getSession().getScreenLength() * editor.renderer.lineHeight - editor.renderer.scroller.clientHeight
                        
            _ide.display_spec_file = (path, overwrite) ->
                # Load spec file in editor if present
                item = sources.specs[path]
                unless item? then path = ''
                specolate_editor.setSession if path is '' then _ide.create_session '' else item.doc
                document.id('specolate-result-panel').set 'text', if path is '' or item.spec_run_result is undefined then '' else item.spec_run_result.join '\n'
                _ide.on_file_status_changed yes
                _ide.on_content_changed is_spec:yes, init:yes
                
            _ide.create_session = (source, path) ->
                EditSession = require("ace/edit_session").EditSession
                UndoManager = require("ace/undomanager").UndoManager
                mode = switch _ide.get_extension path ? ''
                    when '.coffee', '.chocokup', '.ck' then 'coffee'
                    when '.js' then 'javascript'
                    when '.json' then 'json'
                    when '.css' then 'css'
                    when '.scss' then 'scss'
                    when '.html' then 'html'
                    when '.txt' then 'text'
                    when '.markdown', '.md', '.chocodown', '.cd', '.litcoffee' then 'markdown'
                    else 'text'
                Mode = require("ace/mode/#{mode}").Mode                    
                doc = new EditSession source
                doc.setUndoManager new UndoManager()
                doc.setMode new Mode()
                snippetManager = require("ace/snippets").snippetManager
                snippetMode = require("ace/snippets/#{mode}")
                for type in ['studio', 'user']
                    if _ide.snippets[type].modes[mode]? and _ide.snippets[type].applied[mode] isnt on then snippetMode.snippetText += "\n#{_ide.snippets[type].modes[mode]}"
                snippetManager.unregister _ide.current_snippet
                _ide.current_snippet = snippetManager.parseSnippetFile(snippetMode.snippetText ? "")
                snippetManager.register _ide.current_snippet
                doc.setUseSoftTabs true
                if path? and path isnt ''
                    unless _ide.is_spec_file path
                        doc.on 'change', ->
                            source = sources.codes[sources.current]
                            if source?
                                if not source.modified
                                    source.modified = true
                                    sources.opened = (item for item in sources.opened when item isnt sources.current)
                                    _ide.on_file_status_changed()
                                    
                                _ide.on_content_changed init:yes
                            true
                    else
                        doc.on 'change', ->
                            sources.codes[sources.current].has_spec_file = yes
                            
                            source = sources.specs[_ide.get_spec_filename sources.current]
                            if source?
                                if not source.modified
                                    source.modified = true
                                    _ide.on_file_status_changed yes
                                    
                                _ide.on_content_changed is_spec:yes
                            true
                        
                doc
            
            _ide.create_file = ->
                cur_dir = _ide.get_current_dir()
                if filename = prompt translate("Current directory is /#{cur_dir}") + '\n\n' + translate "Enter a filename"
                    if _ide.get_extension(filename) is '' then filename += '.coffee'
                    new Request
                        url: '/' + (if sofkey? then '!/' + sofkey else '') + "#{cur_dir}/#{filename}?so=move&how=raw"
                        onSuccess: (responseText) ->
                            _ide.goto_dir cur_dir, ->
                                _ide.open_file "#{cur_dir}/#{filename}"
                                _ide.display_message translate "File #{cur_dir}/#{filename} was created"

                        onFailure: (xhr) ->
                            _ide.display_message "Error with _ide.create_file() : #{xhr.status}"
                    .get()
                    _ide.check_online()
                    return
                    
                    
            _ide.upload_file = (step) -> 
                cur_dir = _ide.get_current_dir()
                form = document.getElementById('form-file-upload')
                input = document.getElementById('input-file-upload')
                iframe = document.getElementById('frame-file-upload')
                on_iframe_load = -> _ide.upload_file 'done'
                filename = _ide.get_basename input.value.replace /\\/g, '/'
                switch step
                    when 'ask'
                        input.click()
                    when 'send'
                        if input.value isnt ''
                            iframe.addEvent 'load', on_iframe_load
                            form.action = '/' + (if sofkey? then '!/' + sofkey else '') + "#{cur_dir}/#{filename}?so=move&how=raw"
                            form.submit()
                    when 'done'
                        iframe.removeEvents 'load'
                        form.action = ''
                        input.value = ''
                        _ide.goto_dir cur_dir, ->
                            _ide.open_file "#{cur_dir}/#{filename}"
                            _ide.display_message translate "File /#{cur_dir}/#{filename} was uploaded"
                            
            _ide.move_file = ->
                cur_dir = _ide.get_current_dir()
                filename = _ide.get_basename sources.current
                if sources.current is "#{cur_dir}/#{filename}"
                    alert translate "This file is already in /#{cur_dir} directory"
                    return
                    
                if filename is '' or not _ide.will_close_file sources.current then return
                
                move_one = (source, dest, callback) ->
                    new Request
                        url: '/' + (if sofkey? then '!/' + sofkey else '') + "#{dest}?so=move&what=#{source}&how=raw"
                        onSuccess: (responseText) -> callback?()
                        onFailure: (xhr) -> _ide.display_message "Error with _ide.move_file.move_one() : #{xhr.status}"
                    .get()
                    _ide.check_online()
                    return

                if confirm translate("Current file is /#{sources.current}") + '\n\n' + translate "Confirm that you want to move this file to /#{cur_dir}"
                    source = sources.current
                    dest = cur_dir + '/' + filename
                    
                    if _ide.has_spec_file source then move_one _ide.get_spec_filename(source), _ide.get_spec_filename(dest)
                    
                    move_one source, dest, ->
                        _ide.close_file sources.current, yes
                        _ide.goto_dir cur_dir, ->
                            _ide.open_file "#{cur_dir}/#{filename}"
                            _ide.display_message translate "File /#{cur_dir}/#{filename} was moved to /#{cur_dir}"

            _ide.rename_file = ->
                cur_dir = _ide.get_current_dir()
                filename = previous_filename = _ide.get_basename sources.current
                    
                if filename is '' or not _ide.will_close_file sources.current then return
                
                rename_one = (source, dest, callback) ->
                    new Request
                        url: '/' + (if sofkey? then '!/' + sofkey else '') + "#{dest}?so=move&what=#{source}&how=raw"
                        onSuccess: (responseText) -> callback?()
                        onFailure: (xhr) -> _ide.display_message "Error with _ide.rename_file.rename_one() : #{xhr.status}"
                    .get()
                    _ide.check_online()
                    return

                if filename = prompt translate("Current file is /#{sources.current}") + '\n\n' + translate "Enter a new filename"
                    if _ide.get_extension(filename) is '' then filename += '.coffee'
                    source = sources.current
                    dest = cur_dir + '/' + filename
                    
                    if _ide.has_spec_file source then rename_one _ide.get_spec_filename(source), _ide.get_spec_filename(dest)
                    
                    rename_one source, dest, ->
                        _ide.close_file sources.current, yes
                        _ide.goto_dir cur_dir, ->
                            _ide.open_file "#{cur_dir}/#{filename}"
                            _ide.display_message translate "File /#{cur_dir}/#{previous_filename} was renamed to /#{filename}"

            _ide.delete_file = ->
                cur_dir = _ide.get_current_dir()
                filename = _ide.get_basename sources.current
                
                if filename is '' or not _ide.will_close_file sources.current then return
                
                delete_one = (source, callback) ->
                    new Request
                        url: '/' + (if sofkey? then '!/' + sofkey else '') + "?so=move&what=#{source}&how=raw"
                        onSuccess: (responseText) -> callback?()
                        onFailure: (xhr) -> _ide.display_message "Error with _ide.delete_file.delete_one() : #{xhr.status}"
                    .get()
                    _ide.check_online()
                    return
                    
                if confirm translate("Current file is /#{sources.current}") + '\n\n' + translate "Confirm that you want to DELETE this file"
                    source = sources.current
                    
                    if _ide.has_spec_file source then delete_one _ide.get_spec_filename(source)
                    
                    delete_one source, ->
                        _ide.close_file sources.current, yes
                        _ide.goto_dir cur_dir, ->
                            _ide.display_message translate "File /#{cur_dir}/#{filename} was deleted"

            _ide.open_file = (path, with_spec_file, callback) ->
                if sources.isOpening then return no
                unless path? then path = document.id("source_select").getSelected().get("value")[0]
                if path.substr(0,2) is './' then path = path.substr 2
                if sources.codes[path]? and not with_spec_file then _ide.display_code_file path; return;
                sources.isOpening = true
                
                new Request
                    url: '/' + (if sofkey? then '!/' + sofkey else '') + path + '?how=raw'
                    onSuccess: ->
                        doc = _ide.load_file path, @response.text
                        
                        on_spec_loaded = (code_path, loaded_path, text) ->
                            _ide.load_file loaded_path, text
                            _ide.display_code_file code_path
                            sources.isOpening = false
                            callback?()

                        sources.isOpening = true
                        spec_path = _ide.get_spec_filename path
                        if with_spec_file or _ide.has_spec_file path
                            new Request
                                url: '/' + (if sofkey? then '!/' + sofkey else '') + spec_path + '?how=raw'
                                onSuccess: -> 
                                    on_spec_loaded path, spec_path, @response.text
                                onFailure: (xhr) -> sources.isOpening = false ; _ide.display_message "Error with _ide.open_file.spec_file(#{path}) : #{xhr.status}"
                            .get()
                        else on_spec_loaded path, spec_path, ''
                        
                    onFailure: (xhr) -> sources.isOpening = false ; _ide.display_message "Error with _ide.open_file(#{path}) : #{xhr.status}"
                .get()
                
                yes
                
            _ide.exec_file = (path) ->
                unless path? then path = document.id("source_select").getSelected().get("value")[0]
                _ide.exec_file.paths ?= {}
                
                if not _ide.exec_file.paths[path]? or _ide.exec_file.paths[path].closed is yes
                    _ide.exec_file.paths[path] = window.open '/' + path
                else
                    _ide.exec_file.paths[path].location.reload()
                    
            _ide.will_close_file = (path) ->
                ask = (path) ->
                    confirm translate "File '#{path}' was modified.\n\nChanges will be lost.\nDo you confirm you want to continue ?"
                
                unless _ide.is_spec_file path
                    if sources.codes[path].modified 
                        return if ask(path) is no
                        
                spec_path = _ide.get_spec_filename path
                if sources.specs[spec_path]?.modified then return ask spec_path
                true

            _ide.close_file = (path, force) ->
                unless path? then path = document.id("source_select").getSelected().get("value")[0]
                if not (force or _ide.will_close_file path) then return no
                sources.opened = (item for item in sources.opened when item isnt path)
                delete sources.codes[path]
                
                if sources.current is path
                    files = (k for own k,v of sources.codes).sort()
                    _ide.display_code_file if files.length > 0 then files[files.length-1] else ''
                        
                _ide.on_file_status_changed()
                _ide.save_sources_opened()
                yes
                
            _ide.save_file = (path) ->
                path = sources.current if not path?
                is_spec = _ide.is_spec_file path 
                item = sources[if is_spec then 'specs' else 'codes'][path]

                if path is '' or not item.modified then return
                
                data = item.doc.getValue()
                
                if data? and (data isnt '')
                    myRequest = new Request.JSON
                        url: '/' + (if sofkey? then '!/' + sofkey else '') + path + '?so=move&how=raw'
                        onSuccess: (data) ->
                            item.modified = false
                            item.from_history = false
                            item.modifiedDate = data[0].modifiedDate
                            item.has_synchro_conflict = false
                            sources.opened.push sources.current unless is_spec

                            _ide.goto_dir _ide.get_current_dir()
                            _ide.get_file_git_history sources.current
                            _ide.on_file_status_changed is_spec
                            _ide.display_message translate "File #{path} was saved"
                            _ide.save_sources_opened()
                        onFailure: (xhr) ->
                            _ide.display_message "Error with _ide.save_file(#{path}) : #{xhr.status}"
                    myRequest.post data
                    _ide.check_online()
                return
                    
            _ide.save_spec_file = ->
                _ide.save_file _ide.get_spec_filename sources.current
            
            _ide.search_in_files = (pattern) ->
                    if pattern is '' then document.id("studio-search").set 'html', ''; return
                    
                    sources.searched = {}
                    new Request
                        url: (if sofkey? then '/!/' + sofkey else '') + '/-/server/file?grep&pattern=' + pattern + '&how=raw'
                        onSuccess: (responseText) ->
                            lines = []
                            infos = responseText.replace(/\.+\//g, '').split '\n'
                            for info in infos
                                item = info.split ' '
                                filename = item[0]
                                displayed_name = filename.replace /node_modules\/chocolate/g, '-'
                                continue if displayed_name.indexOf('-/node_modules') is 0 or displayed_name.indexOf('node_modules') is 0 
                                (sources.searched[filename]={}).modifiedDate = 1000 * parseInt item[1]
                                lines.push if filename.indexOf('.spec.coffee') >= 0 then "<a href=\"#\" onclick=\"javascript:_ide.open_file('#{filename.replace('.spec.coffee', '.coffee')}', true); _ide.toggleMainPanel('specolate')\">#{displayed_name}</a>" else "<a href=\"#\" onclick=\"javascript:_ide.open_file('#{filename}');\">#{displayed_name}</a>"
                            document.id("studio-search").set 'html', lines.join '<br/>'
                        onFailure: (xhr) ->
                            document.id("studio-search").set 'html', ''
                            _ide.display_message "Error with _ide.search_in_files() : #{xhr.status}"
                    .get()

            _ide.on_content_changed = (options) ->
                {is_spec, init} = options ?= {}
                _ide.run_doccolate(init) if not is_spec and document.id('toggle-doccolate').hasClass 'selected'

            _ide.on_file_status_changed = (is_spec) ->
                path = sources.current
                if is_spec then path = _ide.get_spec_filename path
                
                # Display the opened and modified files list
                _ide.display_opened_files_list()
                _ide.display_opened_files_select()
                
                one_editor = if is_spec then specolate_editor else editor
                item = if is_spec then sources.specs[path] else sources.codes[path]
                
                # Set grey background if already opened otherwise reset it
                if item?
                    one_editor.container[(if item.from_history then 'add' else 'remove') + 'Class']('dimmed')
                else
                    one_editor.container.removeClass 'dimmed'
                    
            _ide.get_file_modified_date = (path, callback) ->
                new Request
                    url: (if sofkey? then '/!/' + sofkey else '') + '/-/server/file?getModifiedDate&' + path + '&how=raw'
                    onSuccess: (responseText) -> callback?(parseInt responseText) if responseText isnt ''
                    onFailure: (xhr) -> _ide.display_message "Error with _ide.get_file_modified_date() : #{xhr.status}"
                .get()

            _ide.get_file_git_history = (path) ->
                code_git_history = document.id('code-git-history').set 'html', ''
                spec_git_history = document.id('spec-git-history').set 'html', ''
                if path is '' then return
                
                add_element = (item, history) ->
                    new Element('div').adopt([new Element('div', html:item.source + ' - ' + item.date.toString('dd/MM/yyyy HH:mm:ss')) , new Element('div', style:'margin-left:16px;margin-bottom:8px;', html:"""<a href="#" onclick="_ide.load_file_from_git_history('#{item.sha}', #{item.is_spec}, '#{item.name.renamed ? item.name.original}', '#{item.repo}')">#{item.message}</a>""")]).inject history, 'bottom'

                add_element {source:translate('local'), is_spec:no, date:new Date(sources.codes[sources.current].modifiedDate), sha:'', message:translate('Last saved version'), name:{original:path}, repo:'' }, code_git_history
                
                new Request.JSON
                    url: (if sofkey? then '/!/' + sofkey else '') + '/-/server/file?getAvailableCommits&' + path + '&how=raw'
                    onSuccess: (list) ->
                        for item in list then item.source = 'git'; item.is_spec = no; add_element item, code_git_history
                        
                        if not _ide.has_spec_file sources.current then return
                        
                        spec_filename = _ide.get_spec_filename path
                        add_element {source:translate('local'), is_spec:yes, date:new Date(sources.specs[spec_filename].modifiedDate), sha:'', message:translate('Last saved version'), name:{original:spec_filename}, repo:'' }, spec_git_history
                        
                        new Request.JSON
                            url: (if sofkey? then '/!/' + sofkey else '') + '/-/server/file?getAvailableCommits&' + spec_filename + '&how=raw'
                            onSuccess: (list) ->
                                for item in list then item.source = 'git'; item.is_spec = yes; add_element item, spec_git_history
                                
                            onFailure: (xhr) ->
                                _ide.display_message "Error with _ide.get_file_git_history(#{path}) : #{xhr.status}"
                        .get()
                        
                    onFailure: (xhr) ->
                        _ide.display_message "Error with _ide.get_file_git_history(#{path}) : #{xhr.status}"
                .get()
                
            _ide.load_file_from_git_history = (sha, is_spec, path, repo) ->
                if sources.isOpening then return
                if not _ide.will_close_file sources.current then return

                sources.isOpening = yes
                
                if is_spec then path = _ide.get_spec_filename path
                
                if sha is ''
                    url = (if sofkey? then '/!/' + sofkey else '') + '/-/server/file?load&' + path + '&how=raw'
                else
                    url = (if sofkey? then '/!/' + sofkey else '') + '/-/server/file?loadFromHistory&' + sha + '&' + path + '&' + repo + '&how=raw'
                new Request
                    url: url
                    onSuccess: () ->
                        path = sources.current
                        _ide.load_file path, @response.text, sha isnt ''
                        _ide[unless is_spec then 'display_code_file' else 'display_spec_file'] path, yes
                        
                        sources.isOpening = no
                    onFailure: (xhr) -> sources.isOpening = false ; _ide.display_message "Error with _ide.load_file_from_git_history(#{sha}) : #{xhr.status}"
                .get()
                    
            _ide.commit_to_git = ->
                if _ide.has_modified_file() then alert translate "There are modified file still opened. Please save or close them before commiting" ; return
                
                if message = prompt translate "Enter a message for your Git commit"
                    new Request
                        url: (if sofkey? then '/!/' + sofkey else '') + '/-/server/file?commitToHistory&message=' + message + '&repository=' + _ide.get_current_dir() + '&how=raw'
                        onSuccess: (responseText) ->
                            _ide.get_file_git_history sources.current
                            _ide.display_message translate "Files were commited to Git repository"
                        onFailure: (xhr) ->
                            _ide.display_message "Error with _ide.commit_to_git() : #{xhr.status}"
                    .get()

            _ide.resize_editors = ->
                editor.resize on
                lab_script_editor.resize on
                debug_editor.resize on
                lab_markup_editor.resize on
                specolate_editor.resize on

            _ide.toggleLogin = ->
                if document.id("toggle-login").hasClass 'logged' then _ide.logoff()
                document.id("input-login").removeClass('hidden').set 'value', ''
            
            _ide.toggleDebug = ->
                _ide.debug(not document.id("toggle-debug").hasClass 'debugging')
                
            _ide.toggleFullscreen = ->
                document.id('main-panel').toggleClass 'fullscreen'
                document.id('toggle-fullscreen').set 'text', if document.id('main-panel').hasClass('fullscreen') then '»«' else '«»'
                _ide.resize_editors()
            
            _ide.switchScreens = ->
                if document.id('main-editor').hasClass 'vertical'
                    document.id(name).removeClass cssClass for cssClass in ['vertical','top', 'bottom'] for name in ['main-editor', 'main-tabs'] 
                    document.id(name).addClass cssClass for cssClass in ['horizontal'] for name in ['main-editor', 'main-tabs'] 
                    document.id('main-editor').addClass ['left']
                    document.id('main-tabs').addClass ['right']
                else
                    document.id(name).removeClass cssClass for cssClass in ['horizontal','left', 'right'] for name in ['main-editor', 'main-tabs'] 
                    document.id(name).addClass cssClass for cssClass in ['vertical'] for name in ['main-editor', 'main-tabs'] 
                    document.id('main-editor').addClass ['top']
                    document.id('main-tabs').addClass ['bottom']
                    
                document.id('switch-panel').set 'text', if document.id('main-editor').hasClass('horizontal') then '≡' else '|||'
                document.id('switch-panel').setStyle 'font-size', if document.id('main-editor').hasClass('horizontal') then '16pt' else '9pt'
                _ide.resize_editors()
            
            _ide.switchTheme = ->
                lightTheme = $(document.body).hasClass 'lightTheme'
                $(document.body)[(if lightTheme then 'remove' else 'add') + 'Class'] 'lightTheme'
                $(document.body)[(if lightTheme then 'add' else 'remove') + 'Class'] 'darkTheme'
                document.id('switch-theme').set 'text', if $(document.body).hasClass('lightTheme') then '□' else '■'
                ace_theme = if $(document.body).hasClass('lightTheme') then 'ace/theme/coffee_white' else 'ace/theme/coffee'
                editor.setTheme ace_theme
                lab_script_editor.setTheme ace_theme
                debug_editor.setTheme ace_theme
                lab_markup_editor.setTheme ace_theme
                specolate_editor.setTheme ace_theme

            _ide.switchInvisible = ->
                editor.setShowInvisibles not editor.getShowInvisibles()
                
            _ide.switchWrap = ->
                wrapMode = editor.session.getUseWrapMode()
                document.id('switch-wrap').set 'text', if wrapMode is true then '↩' else '⟶'
                editor.session.setUseWrapMode not wrapMode
                editor.session.setWrapLimitRange null, null

            _ide.toggleMainDisplay = (what) ->
                if what is 'main'
                    document.id('help-display').addClass 'hidden'
                    document.id('main-display').removeClass 'hidden'
                else
                    document.id('help-display').removeClass 'hidden'
                    document.id('main-display').addClass 'hidden'
                
            _ide.toggleMainPanel = (what) ->
                _ide.toggleMainDisplay 'main'
                
                document.id(panel_id).removeClass css_class for panel_id in ['main-editor', 'main-tabs', 'git-code', 'git-spec'] for css_class in ['shrink', 'expand']
                
                css_class = 
                    switch what
                        when 'experiment' then editor : 'shrink', tabs: 'expand'
                        when 'source' then editor : 'expand', tabs: 'shrink'
                        else null
                                
                if css_class
                    document.id('main-editor').addClass css_class.editor
                    document.id('main-tabs').addClass css_class.tabs
                
                css_class = 
                    switch what
                        when 'specolate' then specolate : 'remove' , documentation : 'add', experiment: 'add'
                        when 'doccolate' then specolate : 'add' , documentation : 'remove', experiment: 'add'
                        else specolate : 'add' , documentation : 'add', experiment: 'remove'
                document.id('experiment-panel')[css_class.experiment + 'Class']('hidden')
                document.id('specolate-panel')[css_class.specolate + 'Class']('hidden')
                document.id('documentation-panel')[css_class.documentation + 'Class']('hidden')
                
                if what isnt 'specolate'
                    document.id('git-code').addClass 'expand'
                    document.id('git-spec').addClass 'shrink'
                
                document.id(item).removeClass('selected') for item in ['toggle-source', 'toggle-specolate', 'toggle-doccolate', 'toggle-experiment', 'toggle-shared']
                document.id('toggle-' + what).addClass 'selected'
                
                _ide.resize_editors()
                
                if what is 'doccolate' then _ide.run_doccolate yes
        
            _ide.toggleNavigatePanel = (what) ->
                list = ['search', 'browse']
                
                (document.id('studio-' + item + '-panel').addClass('hidden') unless document.id('studio-' + item + '-panel').hasClass('hidden')) for item in list
                document.id('studio-' + what + '-panel').removeClass('hidden')
                
                document.id('toggle-' + item).removeClass('selected') for item in list
                document.id('toggle-' + what).addClass 'selected'
                
                if what is 'search' then input = document.id('search_in_file_input'); input.focus(); input.select()
            
            _ide.insertUuid = () ->
                editor.insert Uuid()
                
            _ide.toggleExperimentPanel = (what) ->
                _ide.toggleMainDisplay 'main'
                
                return if _ide.experimentPanel_lastWhat is what
                
                _ide.experimentPanel_lastWhat = what
                
                css_class = 
                    switch what
                        when 'script-output' then debug : 'add', script_output: 'remove'
                        when 'debug' then debug : 'remove', script_output: 'add'
                        when 'coffeescript' then markup : 'add', script: 'remove', coffee:'add', js:'remove'
                        when 'javascript' then markup : 'add', script: 'remove', coffee:'remove', js:'add'
                        when 'chocodown' then markup : 'remove', script: 'add', chocodown:'remove', html:'add'
                        when 'html' then markup : 'remove', script: 'add', chocodown:'add', html:'remove'
                        when 'markup-output' then dom : 'add', markup_output: 'remove'
                        when 'dom' then dom : 'remove', markup_output: 'add'
                        
                if css_class.debug?
                    document.id('experiment-debug-panel-main')[css_class.debug + 'Class']('hidden')
                    document.id('experiment-script-output-panel-main')[css_class.script_output + 'Class']('hidden')
                    
                    document.id(item).removeClass('selected') for item in ['toggle-script-output', 'toggle-debug']
                    document.id('toggle-' + what).addClass 'selected'
                    _ide.compile_coffeescript_code()
                    lab_script_editor.focus()
                else 
                if css_class.markup?
                    document.id('experiment-script-panel-main')[css_class.script + 'Class']('hidden')
                    document.id('experiment-markup-panel-main')[css_class.markup + 'Class']('hidden')
                    document.id('experiment-markup-output-panel-main')[css_class.markup + 'Class']('hidden')
                    document.id('experiment-script-transpiled')[css_class.script + 'Class']('hidden')
                    document.id('experiment-markup-transpiled')[css_class.markup + 'Class']('hidden')
                    
                    document.id(item).removeClass('selected') for item in ['toggle-coffeescript', 'toggle-javascript', 'toggle-chocodown', 'toggle-html']
                    document.id('toggle-' + what).addClass 'selected'
                    
                    if css_class.coffee?
                        document.id('label-coffeescript-output')[css_class.coffee + 'Class']('hidden')
                        document.id('label-javascript-output')[css_class.js + 'Class']('hidden')
                        
                        if what in ['coffeescript', 'javascript']
                            lab_script_editor.getSession().setMode _ide.modes[what]
                            
                            _ide.experimentPanel_lastScript ?= 'coffeescript'
                            
                            if _ide.experimentPanel_lastScript isnt what
                                _ide.experimentPanel_lastScript = what
                                source = lab_script_editor.getSession().getValue()
                                dest = document.id('experiment-script-output-panel').get 'text'
                                lab_script_editor.getSession().setValue dest
                                document.id('experiment-script-output-panel').set 'html', Highlight.highlight('javascript', source).value
                                localStorage.setItem 'lab_last_experiment', what
                                localStorage.setItem 'lab_script_editor_language', what
                                localStorage.setItem 'lab_script_editor_content', dest
                                
                                document.id('toggle-debug-panel')["#{if what is 'javascript' then 'add' else 'remove'}Class"] 'hidden'
                                if what is 'javascript'
                                    document.id('experiment-debug-panel-main').addClass 'hidden'
                                    document.id('experiment-script-output-panel-main').removeClass 'hidden'
                                    document.id('toggle-script-output').addClass 'selected'
                                    document.id('toggle-debug').removeClass 'selected'
                        
                    if css_class.chocodown?
                        document.id('label-chocodown-output')[css_class.chocodown + 'Class']('hidden')
                        document.id('label-html-output')[css_class.html + 'Class']('hidden')

                        if what in ['chocodown', 'html']
                            lab_markup_editor.getSession().setMode _ide.modes[if what is 'chocodown' then 'coffeescript' else 'html']
                            
                            _ide.experimentPanel_lastMarkup ?= 'chocodown'
                            
                            if _ide.experimentPanel_lastMarkup isnt what
                                _ide.experimentPanel_lastMarkup = what
                                source = lab_markup_editor.getSession().getValue()
                                dest = document.id('experiment-markup-output-panel').get 'text'
                                if what is 'chocodown' and dest isnt '' then dest = '<<<\n' + dest + '\n>>>'
                                lab_markup_editor.getSession().setValue dest
                                document.id('experiment-markup-output-panel').set 'text', source
                                localStorage.setItem 'lab_last_experiment', what
                                localStorage.setItem 'lab_markup_editor_language', what
                                localStorage.setItem 'lab_markup_editor_content', dest
                        
                    lab_script_editor.resize on
                    debug_editor.resize on
                    lab_markup_editor.resize on                    
                else 
                if css_class.markup_output?
                    document.id('experiment-markup-output-panel-main')[css_class.markup_output + 'Class']('hidden')
                    document.id('experiment-dom-panel-main')[css_class.dom + 'Class']('hidden')
                    
                    document.id(item).removeClass('selected') for item in ['toggle-markup-output', 'toggle-dom']
                    document.id('toggle-' + what).addClass 'selected'
                    lab_markup_editor.focus()

            _ide.toggleServicesPanel = (what) ->
                list = ['git', 'notes', 'help']
                
                (document.id(item + '-panel').addClass('hidden') unless document.id(item + '-panel').hasClass('hidden')) for item in list
                document.id(what + '-panel').removeClass('hidden')
                
                document.id('toggle-' + item).removeClass('selected') for item in list
                document.id('toggle-' + what).addClass 'selected'
                
                switch what 
                    when 'help'
                        if (k for own k of frames.help).length > 0 then _ide.toggleMainDisplay 'help'
                        if  document.id('toggle-help-chocolate').hasClass('selected') and 
                            _ide.iframe_infos(document.id('help-frame-panel')).doc.body.innerHTML.trim() is '' then _ide.toggleHelpPanel 'chocolate'
                    when 'notes'
                        if document.id('notes-panel').get('html') is ''
                            load_url = '/' + (if sofkey? then '!/' + sofkey else '') + 'data/newnotes_data.json?how=raw'
                            save_url = '/' + (if sofkey? then '!/' + sofkey else '') + 'data/newnotes_data.json?so=move&how=raw'
                            Newnotes.create_panel element_id:'notes-panel', url: {load:load_url, save:save_url}, box_css_class:'chocoblack.round', inherit_selected_class:yes, ace_theme:ace_theme, standalone:no

            _ide.toggleHelpPanel = (what) ->
                list = ['chocolate', 'coffeescript', 'chocokup', 'specolate', 'doccolate', 'newnotes', 'litejq', 'node', 'chocodown']
                
                document.id('toggle-help-' + item).removeClass('selected') for item in list
                document.id('toggle-help-' + what).addClass 'selected'
                
                request = new Request
                    url: (if sofkey? then '/!/' + sofkey else '') + "/-/general/docs/doc-#{what}.md?how=raw"
                    onSuccess: ->
                        style = '<style>' + Chocokup.Css.coder + '\n' + Chocokup.Css.core + '</style>'
                        _ide.iframe_write document.id("help-frame-panel"), style + (Doccolate.generate what + '.md', @response.text).replace new RegExp('(\<a target="_blank" href=")(https://)(.*?)"', 'g'), '<a href="#" onclick="javascript:parent._ide.display_help_panel(this.text, \'$2$3\'); return false;"'
                        
                    onFailure: (xhr) -> _ide.display_message "Error with _ide.toggleHelpPanel() : #{xhr.status}"
                .get()

            _ide.toggleCodeMode = (mode, scope, size) ->
                isCommentRow = (row) ->
                    tokens = editor.session.getTokens(row)
                    for token in tokens
                        if /^comment/.test(token.type)
                            return true
                        else 
                            if not /^text/.test(token.type)
                                return false
                    false
                
                toggleCode = (start, end) ->
                    range = editor.selection.getRange()
                    range.start.column = 0; range.start.row = start;
                    range.end.column = editor.session.doc.getLine(end - 1).length; range.end.row = end - 1
                    if not range.isEmpty() then editor.session.addFold '...', range
                    end + 1
                
                if scope is 'full'
                    if codeMode is 'opened'
                        start = 0; end = 0; catched = false
                        for i in [0...editor.session.doc.getLength()]
                            if isCommentRow(i) is (mode is 'comment')
                                if (size is 'line') and catched
                                    end += 1
                                else if end > start
                                    start = end = toggleCode start, end
                                else 
                                    start = end += 1
                                
                                catched = true
                            else 
                                end += 1
                                catched = false
                                
                        if end > start then toggleCode start, end
                        codeMode = 'closed'
                    else
                        range = editor.selection.getRange()
                        range.start.column = 0; range.start.row = 0
                        end = editor.session.doc.getLength() - 1
                        range.end.column = editor.session.doc.getLine(end).length; range.end.row = end
                        folds = editor.session.getFoldsInRange range
                        if folds.length > 0 then editor.session.removeFolds folds
                        codeMode = 'opened'
                else
                    range = editor.selection.getRange()
                    start = range.start.row; end = start
                    fold = editor.session.getFoldAt range.start.row, range.start.column
                    if fold
                        if range.isEmpty() then editor.session.expandFold fold
                    else
                        if isCommentRow start
                            while isCommentRow(start) then start = end += 1
                        while (start >= 0) and not isCommentRow(start - 1) then start += -1
                        while (end + 1 < editor.session.doc.getLength()) and not isCommentRow(end + 1) then end += 1
                        if end + 1 > start
                            toggleCode start, end + 1
                            editor.selection.setSelectionRange start, start
            
            _ide.run_doccolate = (init) ->
                doit = ->
                    style = '<style>' + Chocokup.Css.core + '</style>'
                    _ide.iframe_write document.id('documentation-doccolate-panel'),
                        (if sources.current isnt '' then style + Doccolate.generate sources.current, editor.getSession().getValue() else ''), 
                        (if init? then left:editor.getSession().getScrollLeft(), top:editor.getSession().getScrollTop(), elemW:-1, elemH:editor.getSession().getScreenLength() * editor.renderer.lineHeight - editor.renderer.scroller.clientHeight else undefined)
                        
                setTimeout doit, 100

            _ide.error_message = (error) ->
                line = if (info = error.location)? then '\n' + "at line:" + info.first_line + ", column:" + info.first_column + " (Coffeescript)" else ''
                error + line
                
            _ide.run_code = ->
                selection = editor.getSelectionRange()
                if selection.start.row is selection.end.row and selection.start.column is selection.end.column then selection = null
                code = if selection then editor.getSession().doc.getTextRange(selection) else editor.getSession().getValue()
                lab_script_editor.getSession().setValue code
                code = "wrap_func = ->\n  " + code.replace(/\n/g, "\n  ") + "\nreturn wrap_func()"
                result = null ; error = null
                try
                    compiled = CoffeeScript.compile code
                    result = eval compiled
                catch error
                    result = _ide.error_message error
                
                _ide.toggleMainPanel 'shared' unless document.id('toggle-shared').hasClass 'selected'
                lab_script_editor.focus()
                document.id('experiment-run-panel').set 'text', result

            _ide.run_specolate = ->
                if _ide.run_specolate.running then return
                
                _ide.run_specolate.running = on
                
                onSuccess = (list) ->
                    sources.specs[_ide.get_spec_filename sources.current].spec_run_result = list
                    document.id('specolate-result-panel').set 'text', list.join '\n'
                    document.id('specolate-run-panel').contentWindow.location.reload()
                    _ide.run_specolate.running = off
                
                onFailure = ->
                    document.id('specolate-run-panel').contentWindow.location = '/-/server/studio?iframe_body'
                    _ide.run_specolate.running = off
                
                try
                    document.id('specolate-run-panel').contentWindow.Specolate.inspect 'json', sources.current.replace(/node_modules\/chocolate\//g, ''), {}, (result) -> 
                        list = []
                        client_result = result
                        if client_result.count.total > 0 
                            client_result.log[0] = translate 'In browser :'
                            client_result.log[1] =           '------------'
                            list = client_result.log;
                        
                        request = new Request.JSON
                            url: '/' + (if sofkey? then '!/' + sofkey else '') + "#{sources.current}?so=eval&how=raw"
                            onSuccess: (server_result) ->
                                if server_result.count.total > 0 
                                    server_result.log[0] = translate 'On server :'
                                    server_result.log[1] =           '-----------'
                                    server_result.log.unshift('') if client_result.count.total > 0
                                    list = list.concat server_result.log
                                
                                list.unshift ''
                                list.unshift translate "#{client_result.count.failed + server_result.count.failed} failed out of #{client_result.count.total + server_result.count.total}"
                                onSuccess list
                                
                            onFailure: (xhr) -> 
                                _ide.display_message "Error with _ide.run_specolate() : #{xhr.status}"
                                onFailure()
                        .get()
                catch
                    onFailure()
                    
            _ide.changeDebugColWidth = (delta) ->
                if debugColumnWidth + delta > 3
                    debugColumnWidth += delta
                    _ide.compile_coffeescript_code()
            
            _ide.saveInLocalStorage = _.throttle (section, value) -> localStorage.setItem section, value
                    
            _ide.compile_coffeescript_code = ->
                source = lab_script_editor.getSession().getValue()
                _ide.saveInLocalStorage 'lab_script_editor_content', source
                no_debug = document.id('experiment-debug-panel-main').hasClass 'hidden'
                
                debug_core = (lines) -> """
                __debug__evals__ = []
                dbg = []
                __debug__indent__lines__ = {}
                __debug__indent__loop__ = 0
                __debug__indent__curline__ = -1
                
                __debug__token__col__size__ = 0
                
                __debug__spaces__ = (count) ->
                    (' ' for i in [0...count]).join ''
                
                __debug__loop__force__exit__ = no
                __debug__loop__modified__ = undefined
                __debug__loop__counts__ = []
                
                __debug__enter__loop__ = (line) -> 
                    __debug__loop__modified__ = undefined
                    __debug__loop__counts__[line] = undefined
                
                __debug__set__current__loop__ = (line) ->
                    if __debug__loop__modified__ is no 
                        if __debug__loop__counts__[line] is undefined
                            __debug__loop__counts__[line] = 0
                        else
                            __debug__loop__counts__[line] += 1
                    
                        if __debug__loop__counts__[line] >= 10
                            __debug__loop__force__exit__ = yes; return no
                        
                    __debug__loop__modified__ = no
                    
                    if __debug__indent__lines__[line] is undefined
                        __debug__indent__lines__[line] = __debug__indent__loop__
                    
                    return yes
                        
                __debug__keep__ = (line, current_value, operator, token, new_value) ->
                    if __debug__loop__force__exit__ then return new_value
                    
                    if __debug__indent__curline__ >= line 
                        __debug__indent__loop__ += 1
                        
                    __debug__indent__curline__ = line

                    if current_value? and operator?
                        value = switch operator
                            when '+=' then current_value + new_value
                            when '-=' then current_value - new_value
                            when '*=' then current_value * new_value
                            when '/=' then current_value / new_value
                            when '&=' then current_value & new_value
                            when '|=' then current_value | new_value
                            when 'and=' then current_value and new_value
                            when 'or=' then current_value or new_value
                            else new_value
                    else
                        value = new_value
                    
                    value = '' + value
                    value = value.replace(/\\n/g, '↲').substr(0, 50) + (if value.length > 50 then '...' else '')
                    
                    #if __debug__evals__[line] is undefined
                    #    if __debug__evals__.length <= line then for i in [__debug__evals__.length .. line] 
                    #        __debug__evals__.push align:0, tokens:[], values:{}
                    
                    item = __debug__evals__[line]
                    
                    if item.values[token] is undefined
                        item.tokens.push token
                        item.values[token] = []
                    item.values[token][__debug__indent__loop__] = value
                    dbg.push token + '[' + __debug__indent__loop__ + '] = ' + value

                    if __debug__indent__loop__ is 0 or item.values[token][__debug__indent__loop__ - 1] isnt value then __debug__loop__modified__ = yes

                    new_value
                    
                __debug__display__cell__ = (value, max) ->
                    text = value.toString()
                    len = text.length
                    text = text.substr(0,max-3) + if len > max-3 then '...' else ''
                    text += (' ' for i in [0...max - text.length]).join ''
                
                __debug__display__evals__ = ->
                    lines = []
                    for item in __debug__evals__
                        var_names = item.tokens.join ', '
                        var_values = []
                        
                        for token in item.tokens
                            for value, i in item.values[token]
                                var_values[i] = [] unless var_values[i]?
                                var_values[i].push value
                        for values, i in var_values then var_values[i] = var_values[i].join ', '
                        var_values = (' ' + __debug__display__cell__(value, #{debugColumnWidth}) + ' |' for value, index in var_values).join ''
                        
                        lines.push if var_names isnt '' then (__debug__display__cell__(var_names, 14) + ' = ' + var_values + '\n') else '\n'
                    
                    return lines.join('\\n')
                    
                for [0...#{lines.length}] then __debug__evals__.push align:0, tokens:[], values:{}

                \n"""
                
                unless no_debug
                    removed_quotes = []
                    prepared = source.replace /([^\\])("""|'''|"|')([\S\s]*?)([^\\])(\2?)/g, (match, p1, p2, p3, p4, p5, offset) ->
                        removed_quotes[offset] = p2 + p3 + p4 + p5
                        p1 + "'quote#{offset}'"
    
                    lines = prepared.split '\n'
                    
                    debugged = debug_core lines
    
                    indent = 0
                    loop_entered = no
                    loop_entered_at_line = undefined
                    
                    for line, line_num in lines
                        index = last_index = rindex = quote_index = 0
                        
                        new_indent = line.search /\S/
                        
                        debugged_insert = (code) -> debugged += ((' ' for i in [0...new_indent]).join '') + code + '\n'
                        
                        if new_indent > indent and line_num > 0 and loop_entered then debugged_insert "unless __debug__set__current__loop__ #{loop_entered_at_line} then break"
                        if new_indent >= 0 then indent = new_indent
                        
                        if line.search(/^\s*\b(for|while|until)\b/) >= 0 then debugged_insert "__debug__enter__loop__ #{line_num}" ; loop_entered = yes ; loop_entered_at_line = line_num
                        else if new_indent >= 0 then loop_entered = no
    
                        line = line.replace /\breturn\b/g, 'return __debug__keep__ ' + line_num + ', ' + null + ', ' + null + ', "->", ' if line.indexOf('return') >= 0
                        while rindex >= 0
                            rindex = line.indexOf '=', index
                            if rindex >= 0
                                if line[rindex + 1] is '=' then index = rindex + 2; continue
                                if line[rindex - 1] in ['<', '>', '!', '='] then index = rindex + 1; continue
                                operator = '='
                                lindex = -1
                                step = 1
                                if rindex > 0
                                    mindex = rindex
                                    while mindex > 0 and (line[mindex-1] in ['}', ']', ' ', '?', '*', '/', '-', '+', '&', '|'] or
                                          line.substr(rindex - 3, 3) is ' or' or
                                          line.substr(rindex - 4, 4) is ' and')
                                        char = line[mindex-1]
                                        mindex = switch char
                                            when '}' then line.lastIndexOf '{', mindex
                                            when ']' then line.lastIndexOf '[', mindex
                                            when 'r' then mindex - 2
                                            when 'd' then mindex - 3
                                            else mindex - 1
                                        switch char 
                                            when '}' then
                                            when ']' then
                                            when 'r' then step += 2 ; rindex += -2
                                            when 'd' then step += 3 ; rindex += -3
                                            else step += 1 ; rindex += -1
                                        operator = switch char 
                                            when '*', '/', '-', '+', '&', '|' then char + '='
                                            when 'r' then 'or='
                                            when 'd' then 'and='
                                            else operator
    
                                    for looked in ['(', '[', '\n', ' ', ';']
                                        if (lio = line.lastIndexOf looked, mindex-1) > lindex then lindex = lio
    
                                    lindex += 1 if lindex >= 0
                                if lindex < 0 then lindex = 0
                                variable = line.substring lindex, rindex
                                debugged += line.substring(last_index, rindex + step) + ' __debug__keep__ ' + line_num + ', ' + variable + ', "' + operator + "\", __debug__quote__start__#{quote_index}" + variable + "__debug__quote__end__#{quote_index++}, "
                                last_index = index = rindex + step
                        debugged += line.substring(last_index) + '\n'
                    
                    debugged = debugged.replace /'quote(\d+)'/g, (match, p1) ->
                        removed_quotes[p1]
    
                    debugged = debugged.replace /__debug__quote__start__(\d+)([\S\s]*?)__debug__quote__end__\1/g, (match, p1, p2) ->
                        '"' + p2.replace(/([^\\])"/g, '$1\\"') + '"'
                
                result = undefined
                error = undefined

                if source.search(/\S/) is -1 
                    result = ''
                    document.id('experiment-script-output-panel').set 'html', ''
                    debug_editor.setValue ''
                else
                    displayDebugged = (value) ->
                        scrollTop = debug_editor.getSession().getScrollTop()
                        debug_editor.setValue value ? ('' for [0...lines.length]).join('\n'), -1
                        debug_editor.getSession().setScrollTop scrollTop
                        
                    try
                        orig_compiled = CoffeeScript.compile source, bare: true
                        document.id('experiment-script-output-panel').set 'html', Highlight.highlight('javascript', orig_compiled).value
                    catch e
                        error = e
                        result = _ide.error_message error
                    
                    unless no_debug or error?
                        try
                            compiled = CoffeeScript.compile debugged, bare: true
                            result = eval compiled
                            if __debug__loop__force__exit__ then result = 'Inifite loop detected'
                            else result = eval orig_compiled
                            displayDebugged __debug__display__evals__()
                        catch e
                            error = e
                            result = _ide.error_message error
                            #debug_editor.setValue error.stack + '\n\ndebugged : \n' + debugged + '\n\ncompiled : \n' + compiled
                    else
                        try
                            result = eval orig_compiled
                        catch e
                            error = e
                            result = _ide.error_message error
                        
                document.id('experiment-run-panel').set 'text', result
            
            _ide.transpile_javascript_code = ->
                source = lab_script_editor.getSession().getValue()
                _ide.saveInLocalStorage 'lab_script_editor_content', source
                
                error = undefined
                try
                    transpiled = js2coffee.build(source).code
                    document.id('experiment-script-output-panel').set 'html', Highlight.highlight('coffeescript', transpiled).value
                catch e
                    error = e
                    result = _ide.error_message error.message

                unless error?
                    result = eval source

                document.id('experiment-run-panel').set 'text', result

            _ide.toggleFormatChocokup = (value) ->
                formatChocokup = value
                _ide.compile_chocodown_code()
                    
            _ide.compile_chocodown_code = ->
                source = lab_markup_editor.getSession().getValue()
                _ide.saveInLocalStorage 'lab_markup_editor_content', source
                try
                    html = new Chocodown.converter({formatChocokup}).makeHtml source
                    document.id('experiment-markup-output-panel').set 'text', html
                    html = "<html><head><head><style>#{Chocokup.Css.core}</style><body>#{html}</body></html>"
                    _ide.iframe_write document.id('experiment-dom-panel'), html
                    lab_markup_editor.focus()
                    document.id('experiment-run-panel').set 'text', ''

                catch error
                    document.id('experiment-run-panel').set 'text', error

            _ide.transpile_html_code = ->
                html = lab_markup_editor.getSession().getValue()
                _ide.saveInLocalStorage 'lab_markup_editor_content', html
                try
                    kup = htmlkup html
                    document.id('experiment-markup-output-panel').set 'text', kup
                    _ide.iframe_write document.id('experiment-dom-panel'), html
                    lab_markup_editor.focus()
                    document.id('experiment-run-panel').set 'text', ''

                catch error
                    document.id('experiment-run-panel').set 'text', error
                
                
            _ide.refresh_rate = 2 * 60 * 1000
            
            _ide.display_synchro_conflict_message = (path) ->
                alert translate "File /#{path} was modified inside and outside the editor. There is an unresolvable conflict."
            
            _ide.ping = ->
                new Request
                    url: "/-/ping?how=raw"
                    onSuccess: (responseText) -> 
                    onFailure: (xhr) -> _ide.display_message "Error with _ide.ping() : #{xhr.status}"
                .get()
                    
            _ide.keep_uptodate = ->
                _ide.check_connected()
                
                for own k, v of sources.codes
                    do should_we_reload = ->
                        path = k ; item = v
                        _ide.get_file_modified_date item.path, (new_modifiedDate) ->
                            if item.modifiedDate < new_modifiedDate
                                unless item.modified
                                    url = (if sofkey? then '/!/' + sofkey else '') + '/-/server/file?load&' + item.path + '&how=raw'
                                    new Request
                                        url: url
                                        onSuccess: () ->
                                            path = item.path
                                            doc = _ide.create_session @response.text, path
                                            sources.codes[path] = { path, doc, from_history:false , modified:false, modifiedDate: new_modifiedDate }
                                            if path in [sources.current, _ide.get_spec_filename sources.current] then _ide.display_code_file sources.current
                                            _ide.display_message translate "File /#{item.path} was modified outside the editor and reloaded"
                                        onFailure: (xhr) -> _ide.display_message "Error with _ide.keep_uptodate() : #{xhr.status}"
                                    .get()
                                else
                                    item.has_synchro_conflict = true
                                    _ide.display_opened_files_list()
                                    _ide.display_opened_files_select()
                                    _ide.display_message translate "File /#{item.path} was modified inside and outside the editor. There is an unresolvable conflict."
                
                # if no source file currently loaded, ping the server to keep the cookie alive
                if k is undefined then _ide.ping()
                
                setTimeout _ide.keep_uptodate, _ide.refresh_rate
                    
            _ide.save_sources_opened = ->
                localStorage.setItem 'studio_sources_opened', JSON.stringify({path, has_spec_file:sources.codes[path].has_spec_file, modifiedDate:sources.codes[path].modifiedDate} for path in sources.opened)
                
            window.addEvent 'domready', ->
                Request.implement processScripts: (text) -> text
                
                _ide.modes = {}
                        
                CoffeeScriptMode = require('ace/mode/coffee').Mode                    
                _ide.modes.coffeescript = new CoffeeScriptMode()
                
                JavaScriptMode = require('ace/mode/javascript').Mode                    
                _ide.modes.javascript = new JavaScriptMode()
                
                HtmlMode = require('ace/mode/html').Mode                    
                _ide.modes.html = new HtmlMode()
                
                MarkdownMode = require('ace/mode/markdown').Mode
                markdownMode = new MarkdownMode()
                
                TextMode = require('ace/mode/text').Mode                    
                textMode = new TextMode()

                LanguageTools = require('ace/ext/language_tools')
                
                snippetManager = require("ace/snippets").snippetManager
                snippetText = require('ace/snippets/text')
                _ide.current_snippet = snippetManager.parseSnippetFile snippetText.snippetText
                snippetManager.register _ide.current_snippet

                set_editor = (id, mode) ->
                    e = ace.edit id
                    try e.setScrollSpeed(2)
                    e.setShowPrintMargin no
                    e.setTheme ace_theme

                    e.getSession().setMode mode ? _ide.modes.coffeescript
                    e.getSession().setUseSoftTabs yes
                    e.setOptions
                        enableBasicAutocompletion: yes
                        enableSnippets: yes

                    e
                    
                editor = set_editor 'editor'
                
                lab_script_editor = set_editor 'experiment-script-panel-editor'

                past_script_language = _ide.experimentPanel_lastScript = localStorage.getItem('lab_script_editor_language')
                unless past_script_language? then _ide.experimentPanel_lastScript = 'coffeescript' ; localStorage.setItem('lab_script_editor_language', 'coffeescript')
                
                Acelang = require("ace/lib/lang")
                past_content = localStorage.getItem('lab_script_editor_content')
                if past_content 
                    lab_script_editor.insert past_content
                    service = if _ide.experimentPanel_lastScript is 'coffeescript' then _ide.compile_coffeescript_code else _ide.transpile_javascript_code
                    Acelang.delayedCall(service).schedule 200
                
                lab_script_editor.getSession().on 'change', ->
                    _ide.experimentPanel_lastScript ?= 'coffeescript'
                    service = if _ide.experimentPanel_lastScript is 'coffeescript' then _ide.compile_coffeescript_code else _ide.transpile_javascript_code
                    Acelang.delayedCall(service).schedule 200
                
                if _ide.experimentPanel_lastScript is 'javascript'
                    document.id('toggle-debug-panel').addClass 'hidden'

                debug_editor = set_editor 'experiment-debug-panel', textMode
                debug_editor.setReadOnly on
                    
                lab_script_editor.getSession().on 'changeScrollTop', (scroll) ->
                    if debug_experiment_sync is "debug" 
                        debug_experiment_sync = null
                    else  
                        debug_experiment_sync = "experiment"
                        debug_editor.getSession()['setScrollTop'] parseInt(scroll) || 0
                
                debug_editor.getSession().on 'changeScrollTop', (scroll) ->
                    if debug_experiment_sync is "experiment" 
                        debug_experiment_sync = null
                    else  
                        debug_experiment_sync = "debug"
                        lab_script_editor.getSession()['setScrollTop'] parseInt(scroll) || 0

                lab_markup_editor = set_editor 'experiment-markup-panel-editor', markdownMode
                lab_markup_editor.renderer.setShowGutter false
                
                past_markup_language = _ide.experimentPanel_lastMarkup = localStorage.getItem('lab_markup_editor_language')
                unless past_markup_language? then _ide.experimentPanel_lastMarkup = 'chocodown' ; localStorage.setItem('lab_markup_editor_language', 'chocodown')

                past_content = localStorage.getItem('lab_markup_editor_content')
                if past_content 
                    lab_markup_editor.insert past_content
                    service = if _ide.experimentPanel_lastMarkup is 'chocodown' then _ide.compile_chocodown_code else _ide.transpile_html_code
                    Acelang.delayedCall(service).schedule 350
                
                lab_markup_editor.getSession().on 'change', ->
                    _ide.experimentPanel_lastMarkup ?= 'chocodown'
                    service = if _ide.experimentPanel_lastMarkup is 'chocodown' then _ide.compile_chocodown_code else _ide.transpile_html_code
                    Acelang.delayedCall(service).schedule 350

                last_experiment = localStorage.getItem('lab_last_experiment')
                _ide.toggleExperimentPanel last_experiment unless last_experiment is 'coffeescript' or not last_experiment?

                specolate_editor = set_editor 'specolate-panel-editor'
                specolate_editor.getSession().on 'change', ->

                editor.focus()

                _ide.check_connected()
                setTimeout _ide.keep_uptodate, _ide.refresh_rate
                
                for _ in [editor, lab_script_editor, debug_editor, lab_markup_editor, specolate_editor]
                    do add_findnext_shortcut = (editor) ->
                        _.commands.addCommand
                            name: "find next"
                            bindKey:
                                win: "F3|Ctrl-G"
                            exec: -> _.findNext()
                            
                        _.commands.addCommand
                            name: "toggle_experiment_code"
                            bindKey:
                                win: "Alt-R", mac: "Alt-R"
                            exec: -> _ide.toggleMainPanel('source') ; editor.focus()
        
                commands = editor.commands
                commands.addCommand
                    name: "save"
                    bindKey:
                        win: "Ctrl-S",mac: "Command-S"
                    exec: -> _ide.save_file()
                commands.addCommand
                    name: "find in files"
                    bindKey:
                        win: "Ctrl-Shift-F",mac: "Command-Shift-F"
                    exec: -> _ide.toggleNavigatePanel('search')
                commands.addCommand
                    name: "insert uuid"
                    bindKey:
                        win: "Ctrl-U",mac: "Command-U"
                    exec: -> _ide.insertUuid()
                commands.addCommand
                    name: "find previous"
                    bindKey:
                        win: "Shift-F3|Shift-Ctrl-G"
                    exec: -> editor.findPrevious()
                commands.addCommand
                    name: "toggle code mode"
                    bindKey:
                        win: "Alt-Shift-R", mac: "Alt-Shift-R"
                    exec: -> _ide.toggleCodeMode 'comment', 'one', 'block'
                commands.addCommand
                    name: "toggle full one line code mode"
                    bindKey:
                        win: "Alt-Shift-U", mac: "Alt-Shift-U"
                    exec: -> _ide.toggleCodeMode 'comment', 'full', 'line'
                commands.addCommand
                    name: "toggle full code mode"
                    bindKey:
                        win: "Alt-Shift-I", mac: "Alt-Shift-I"
                    exec: -> _ide.toggleCodeMode 'comment', 'full', 'block'
                commands.addCommand
                    name: "toggle no comment mode"
                    bindKey:
                        win: "Alt-Shift-O", mac: "Alt-Shift-O"
                    exec: -> _ide.toggleCodeMode 'code', 'full', 'block'
                commands.addCommand
                    name: "run_code"
                    bindKey:
                        win: "Alt-R", mac: "Alt-R"
                    exec: -> _ide.run_code()

                commands = specolate_editor.commands
                commands.addCommand
                    name: "save"
                    bindKey:
                        win: "Ctrl-S",mac: "Command-S"
                    exec: -> _ide.save_spec_file()

                _ide.goto_dir '.', ->
                    saved_sources = JSON.parse localStorage.getItem 'studio_sources_opened'
                    
                    try_open = (source, count) ->
                        sources.available[source.path] = { name:_ide.get_basename(source.path), extension:_ide.get_extension(source.path), modifiedDate:source.modifiedDate, has_spec_file:source.has_spec_file }
                        
                        is_opening = _ide.open_file source.path, source.has_spec_file, ->
                            _ide.get_file_modified_date source.path, (modifiedDate) -> sources.codes[source.path].modifiedDate = modifiedDate

                        unless is_opening
                            count ?= 0
                            if count < 50 then count += 1; setTimeout (-> try_open source, count), 100
                        
                    if saved_sources?.length > 0 
                        for source in saved_sources then try_open source
                    
                    return
                

exports.connected = -> 'connected'

exports.iframe_body = ->
    panel = new Chocokup.App 'Specolate client runner', ->
        script src:"/static/vendor/jasmine/jasmine.js", type:"text/javascript", charset:"utf-8"
        script src:"/static/lib/specolate.js", type:"text/javascript", charset:"utf-8"
    panel.render()
