_ = require './chocodash'
Chocokup = require './chocokup'
Highlight = require './highlight'
Chocodown = require './chocodown'

Newnotes = class
    @kup: ->
        id = Newnotes.panels.length
        
        @params.taste ?= ''
        
        style """
        #newnotes-#{id}-note-panel > div {
            line-height:1.1em;
        }
        
        #newnotes-#{id}-note-panel code {
            display: inline-block;
            margin-left: 24px;
        }
        
        #newnotes-#{id}-note-panel ul {
            margin-left: 0;
            padding-left: 1em;
        }
        
        #newnotes-#{id}-filter-list-body {
            margin: 10px;
            font-size: 0.8em;
            line-height: 1.4em;
        }
        
        #newnotes-#{id}-note-panel li.note {
            list-style: none;
            line-height: 1.5em;
        }
        
        #newnotes-#{id}-note-panel li {
            list-style: disc;
            list-style-position: inside;
            line-height: 1.15em;
        }
    
        #newnotes-#{id}-note-panel li, #newnotes-#{id}-filter-list-body div {
            cursor: pointer;
            padding: 0.4em 0;
        }
        
        #newnotes-#{id}-note-panel li.compacted {
            overflow: hidden;
        }
        
        #newnotes-#{id}-note-panel li.compacted p,
        #newnotes-#{id}-note-panel li.compacted p + * {
            display:none;
        }
        
        #newnotes-#{id}-note-panel > .fullscreen-narrow {
            font-size:1.4em;
        }
        
        #newnotes-#{id}-list-panel {
            margin: 0;
            padding: 1em;
        }

        #newnotes-#{id}-note-panel select {
            font-size: 0.8em;
        }
        
        #newnotes-#{id}-filter-input {
            width: 60%;
            padding: 4px 10px 4px;
            font-style: italic;
            border: none;
            font-size: 12px;
            -moz-border-radius: 12px;
            -webkit-border-radius: 12px;
            -moz-box-shadow: inset 1px 1px 2px #bbb;
            -webkit-box-shadow: inset 1px 1px 2px #bbb;
            box-shadow: inset 1px 1px 2px #bbb;
            color: #999;
        }

        #{unless @params.inherit_selected_class then '#newnotes-' + id + '-note-panel li.selected {background-color:rgba(0,0,0,0.1);}' else ''}
        
        .newnotes-priority-Now {
            color:red;
        }
        .newnotes-priority-Tomorrow {
            color:gold;
        }
        .newnotes-priority-Later {
            color:skyblue;
        }
        .newnotes-priority-Done {
            color:lawngreen;
        }
        .newnotes-filtered {
            background-color: gold;
            color: black;
        }
        
        #newnotes-#{id}-note-panel .leather, #newnotes-#{id}-note-panel .leather a, #newnotes-#{id}-note-panel .leather select  {
            background-color: #262626;
            color: rgb(165, 164, 151);
            text-shadow: 0 1px 3px rgba(171, 128, 112, 0.5) , 0 -2px 4px rgb(0, 0, 0);
            font-size: 14pt;
            font-family: Comic Sans MS;
        }
        #newnotes-#{id}-note-panel .leather select  {
            font-size: 0.8em;
        }
        #newnotes-#{id}-note-panel .leather a {
            border: 1px solid rgb(26, 23, 23);
            border-radius: 8px;
            padding: 0px 10px 0px 8px;
            box-shadow: inset 2px 2px 12px rgb(19, 17, 17);
            text-decoration:none;
        }
        #newnotes-#{id}-note-panel .leather > .sizer {
            border: 1px dashed rgba(60, 66, 53, 1);
            outline: 1px dashed rgba(171, 128, 112, 0.7);
            margin: 6px;
        }
        #newnotes-#{id}-note-panel .stitch > .sizer {
            margin: 6px;
        }

        #newnotes-#{id}-note-panel .paper {
            background-color: rgb(245, 242, 209);
            color: rgb(85, 78, 76);
            text-shadow: none;
            border-right: 6px double rgb(202, 195, 181);
            border-top-right-radius: 10px;
            border-bottom-right-radius: 10px;
            border-left: 2px solid rgb(119, 118, 112);
            font-size: 12pt;
            border-bottom: 1px solid black;
            background: -webkit-linear-gradient(top, rgb(228, 228, 228) 0%, rgb(245, 242, 209) 8%) 0 57px;
            background: -moz-linear-gradient(top, rgb(228, 228, 228) 0%, rgb(245, 242, 209) 8%) 0 57px;
            background: linear-gradient(top, rgb(228, 228, 228) 0%, rgb(245, 242, 209) 8%) 0 57px;
            -webkit-background-size: 100% 30px;
            -moz-background-size: 100% 30px;
            -ms-background-size: 100% 30px;
            background-size: 100% 30px;
            background-position-y: 12px;
            background-attachment: local;
        }
        
        #newnotes-#{id}-note-panel .paper.disconnected {
            background: rgb(219, 219, 219);
        }

        #newnotes-#{id}-note-panel .white-paper {
            background-color: rgb(247, 246, 232);
            border-radius: 14px;
            padding: 10px;
            color: rgb(85, 78, 76);
            text-shadow: none;
            font-size: 12pt;
            background: -webkit-linear-gradient(top, rgb(228, 228, 228) 0%, rgb(247, 246, 232) 8%) 0 57px;
            background: -moz-linear-gradient(top, rgb(228, 228, 228) 0%, rgb(247, 246, 232) 8%) 0 57px;
            background: linear-gradient(top, rgb(228, 228, 228) 0%, rgb(247, 246, 232) 8%) 0 57px;
            -webkit-background-size: 100% 30px;
            -moz-background-size: 100% 30px;
            -ms-background-size: 100% 30px;
            background-size: 100% 30px;
            background-position-y: 12px;
            background-attachment: local;
        }"""

        style @params.code_css
        
        css_class = @params.box_css_class ? ''
        css_class = '.' + css_class if css_class isnt ''
        
        newnotes_list = -> body "#newnotes-#{id}-list-main", -> box '#.' + css_class, -> body "#newnotes-#{id}-list-body.paper", -> ul "#newnotes-#{id}-list-panel", ''
        
        newnotes_filter = ->
            div ->
                a href:'#', onclick:"Newnotes.panels[#{id}].stop_filter();", 'Find'
                text ' : '
                input "#newnotes-#{id}-filter-input", onkeyup:"Newnotes.panels[#{id}].on_key_filter(this);", onfocus:"Newnotes.panels[#{id}].on_filter_focus(this);"
                a href:'#', onclick:"Newnotes.panels[#{id}].init_filter();", 'Clear'

        newnotes_filter_list = (options) ->
            hidden = if options?.hidden then '.hidden' else ''
            body "#newnotes-#{id}-filter-list-main" + hidden, -> box '#.' + css_class, -> body "#newnotes-#{id}-filter-list-body.white-paper", ->

        newnotes_search = -> 
            add_selector = (name) =>
                select "#newnotes-#{id}-search-#{name.toLowerCase()}-select" + css_class, onchange:"Newnotes.panels[#{id}].on_search_option_selected('#{name}', this);", ''
            span '#', ->
                text 'Pin' ; select "#newnotes-#{id}-pin-mode" + css_class, onchange:"Newnotes.panels[#{id}].on_pin_mode_changed(this);", -> option 'on' ; option 'off'
                span ': '
                span "#newnotes-#{id}-pin-list", -> 'None'
                a href:'#', onclick:"Newnotes.panels[#{id}].pin();", '+'
            add_selector name for own name of Newnotes.Dimensions

        newnotes_note_action = ->
            div -> 
                a href:'#', onclick:"Newnotes.panels[#{id}].move(-1);", '▲'
                a href:'#', onclick:"Newnotes.panels[#{id}].dent('out');", '◄'
                a href:'#', onclick:"Newnotes.panels[#{id}].home();", 'Home'
                a href:'#', onclick:"Newnotes.panels[#{id}].new();", 'New'
                a href:'#', onclick:"Newnotes.panels[#{id}].sort();", 'Sort'
                a href:'#', onclick:"Newnotes.panels[#{id}].dent('in');", '►'
                a href:'#', onclick:"Newnotes.panels[#{id}].move(1);", '▼'
                
            div ->
                a href:'#', onclick:"Newnotes.panels[#{id}].open();", 'Develop'
                a href:'#', onclick:"Newnotes.panels[#{id}].close();", 'Open'
                a href:'#', onclick:"Newnotes.panels[#{id}].toggle();", 'Toggle'
                a href:'#', onclick:"Newnotes.panels[#{id}].compact();", 'Compact'
                a href:'#', onclick:"Newnotes.panels[#{id}].expand();", 'Expand'                

        newnotes_note_attributes = ->
            add_selector = (name) => select "#newnotes-#{id}-#{name.toLowerCase()}-select" + css_class, onchange:"Newnotes.panels[#{id}].on_option_selected('#{name}', this);", ''
            add_selector name for own name of Newnotes.Dimensions

        newnotes_note_input = ->
            span -> (if @params.use_ace then panel else textarea)("#newnotes-#{id}-note-text-input", style:'background-color:white;width:0;height:0;', 'data-ace-theme':@params.ace_theme, '')

        newnotes_note_history = ->
            div "#newnotes-#{id}-history-body", ->

        newnotes_note_memory = ->
            div "#newnotes-#{id}-note-memory", -> 
                text ' '

        newnotes_note_message = ->
            body "#newnotes-#{id}-note-message", -> 
               text ' '

        newnotes_log_buttons = (options) ->
            div style:(if options?.float is yes then "float:right;" else ""), ->
                input "#newnotes-#{id}-note-logoff.hidden", type:'button', onclick:"Newnotes.panels[#{id}].logoff();", value:'Logoff', style:"background-color:green; color:white;"
                input "#newnotes-#{id}-note-logon.hidden", type:'button', onclick:"Newnotes.panels[#{id}].switch_login(true);", value:'Logon', style:"background-color:red; color:white;"

        panel "#newnotes-#{id}-login-panel.hidden", ->
            form ->
                text 'Enter your key: '
                input "#newnotes-#{id}-login-key", type:'password', ''
                input type:'submit', onclick:"Newnotes.panels[#{id}].register_key(); return false;", value:'Enter'

        panel "#newnotes-#{id}-note-panel", ->
            body "#.#{@params.taste}", ->
                switch @params.taste
                    when 'fullscreen-wide'
                        @params.in_list = yes
                        box  "#.leather", -> box  "#.stitch", -> panel proportion:'served', ->
                            panel ->
                                header by:5, ->
                                    newnotes_filter()
                                    newnotes_search()
                                    newnotes_note_memory()
                                body ->
                                    newnotes_filter_list()
                            box -> panel ->
                                newnotes_list()
                            panel ->
                                header by:10, ->
                                    newnotes_log_buttons float:yes
                                    newnotes_note_action()
                                    newnotes_note_attributes()
                                body ->
                                    panel proportion:'half-served', orientation:'vertical', ->
                                        panel -> newnotes_note_history()
                                        panel -> newnotes_note_message()
                        newnotes_note_input()
                    when 'fullscreen-narrow'
                        @params.in_list = yes
                        panel '#.hidden', ->
                            newnotes_search()
                            newnotes_note_memory()
                        box  "#.leather", -> box  "#.stitch", -> panel ->
                            header -> newnotes_filter()
                            body ->
                                panel proportion:'half-served', orientation:'vertical', ->
                                    box -> panel ->
                                        newnotes_filter_list hidden:yes
                                        newnotes_list()
                                    panel ->
                                        header by:2, ->
                                            newnotes_note_action()
                                        footer -> newnotes_log_buttons()
                                
                        panel '#.hidden', ->
                            newnotes_note_attributes()
                        newnotes_note_input()
                    else
                        @params.in_list = no
                        panel orientation:'vertical', proportion:'half-served', ->
                            panel -> 
                                header by:3, -> 
                                    body ->
                                        newnotes_filter()
                                        newnotes_search()
                                        newnotes_note_memory()
                                newnotes_filter_list hidden:yes
                                newnotes_list()
                            panel ->
                                header by:3, ->
                                    box -> body ->
                                        newnotes_note_action()
                                        newnotes_note_attributes()
                                body -> box '#.' + css_class, -> body -> newnotes_note_input(yes)
                            
            script '_id = ' + id + ';' + '_url = ' + JSON.stringify(@params.url) + ';' + '_in_list = ' + @params.in_list + ';' + '_has_keyboard = ' + @params.has_keyboard + ';' + '_use_ace = ' + @params.use_ace + ';'  + '_standalone = ' + @params.standalone + ';'
            coffeescript ->
                Newnotes.panels.push new Newnotes.HtmlPanel new Newnotes, _id, _url, _in_list, _has_keyboard, _use_ace, _standalone

    @Dimensions: 
        Priority:
            values: ['Now', 'Tomorrow', 'Later', 'Done']

        Scope:
            values: ['Me', 'Household', 'Family', 'Friends', 'Community', 'Business', 'State', 'Public']
            node: 'free'
        
        Action:
            values: ['Explore', 'Memorize', 'Learn', 'Teach', 'Discuss', 'Do', 'Control', 'Delegate', 'Relax']
            node: 'free'
        
        Intention:
            values: ['Know', 'Use', 'Make', 'Manage']
            node: 'free'
        
        Wish:
            values: ['No wish', 'Identity', 'Hobbies', 'Education', 'Religion', 'Leisure']
            node: 'free'
        
        Need:
            values: ['No need', 'Food', 'Health', 'Clothing', 'Equipment', 'Housing']
            node: 'free'
                
        Share:
            values: ['No share', 'Communication', 'Partnership', 'Work', 'Finance', 'Insurance']
            node: 'free'
    
    @HtmlPanel: class
        constructor: (@newnotes, @id, @url, @in_list, @has_keyboard, @use_ace, @standalone) ->
            @editor = new class
                get: ->
                    if @use_ace then @_.getSession().getValue() else @_.get 'value'
                set: (value) ->
                    if @use_ace then @_.getSession().setValue(value) else @_.set 'value', value
                focus: ->
                    @_.focus()
                    if @use_ace then @_.selectAll() else @_.select()
                clear: ->
                    @current_id = undefined
                    @tree_states = {}
                    @tree_navigate = {}
                    
                current_id: undefined
                tree_states: {}
                tree_navigate : {}
                exporting: no
                modified: no
                waiting: no
                editing: no
                
                DOMEvent.defineKeys
                    '36': 'home'
                    '35': 'end'
            
            if @use_ace
                @editor.use_ace = yes
                @editor._ = ace.edit "newnotes-#{@id}-note-text-input"
                @editor._.setShowPrintMargin false
                @editor._.renderer.setShowGutter false
                input_box = document.id("newnotes-#{@id}-note-text-input")
                ace_theme = input_box.attributes['data-ace-theme']?.value
                @editor._.setTheme ace_theme if ace_theme?
                Mode = require('ace/mode/markdown').Mode
                @editor._.getSession().setMode new Mode()
                @editor._.getSession().on 'change', (e) =>
                    return unless @editor.editing
                    @[if @editor.current_id? then 'save' else 'add'] not @in_list
                @editor._.on 'focus', (e) =>
                    @editor.editing = yes if @editor._.container.getStyle('width') isnt '0px'
                @editor._.on 'blur', (e) =>
                    @editor.editing = no
                @editor._.getSession().setUseWrapMode yes
                @editor._.getSession().setWrapLimitRange null, null
            
                commands = @editor._.commands
                commands.addCommand
                    name: "save_or_add"
                    bindKey:
                        win: "Return", mac: "Return"
                    exec: (editor) =>
                        document = editor.getSession().getDocument()
                        last_row = document.getLength() - 1
                        last_col = document.getLine(last_row).length
                        range = editor.getSelectionRange()
                        if not @editor.editing or range.isEnd last_row, last_col then @new()
                        else @editor._.insert '\n'
                            
                    
                commands.addCommand
                    name: "save_or_add_prev"
                    bindKey:
                        win: "Alt-Return", mac: "Alt-Return"
                    exec: => @new(before:on)
                    
                commands.addCommand
                    name: "export"
                    bindKey:
                        win: "Ctrl-S", mac: "Command-S"
                    exec: => @export()
                    
                commands.addCommand
                    name: "filter"
                    bindKey:
                        win: "Ctrl-F", mac: "Command-F"
                    exec: => @focus_filter()
                    
                commands.addCommand
                    name: "indent"
                    bindKey: 
                        win: "Tab", mac: "Tab"
                    exec: (editor) =>
                        range = editor.getSelectionRange()
                        if range.isStart 0,0 then @dent 'in'; editor.focus()
                        else editor.indent()
                    multiSelectAction: "forEach"
                    
                commands.addCommand
                    name: "outdent"
                    bindKey: win: "Shift-Tab", mac: "Shift-Tab"
                    exec: (editor) => 
                        range = editor.getSelectionRange()
                        if range.isStart 0,0 then @dent 'out'; editor.focus()
                        else editor.blockOutdent()
                    multiSelectAction: "forEach"
                    
                commands.addCommand
                    name: "home"
                    bindKey: win: "Home", mac: "Home"
                    exec: (editor, args) => @home(); editor.focus()

                commands.addCommand
                    name: "gotoleft"
                    bindKey: win: "Left", mac: "Left|Ctrl-B"
                    exec: (editor, args) => 
                        if not @editor.editing then @modify() ; @editor.focus()
                        else editor.navigateLeft args.times
                    multiSelectAction: "forEach"
                    readOnly: yes

                commands.addCommand
                    name: "gotoright"
                    bindKey: win: "Right", mac: "Right|Ctrl-F"
                    exec: (editor, args) => 
                        if not @editor.editing then @modify() ; @editor.focus()
                        else editor.navigateRight args.times
                    multiSelectAction: "forEach"
                    readOnly: yes

                commands.addCommand
                    name: "golineup"
                    bindKey: win: "Up", mac: "Up|Ctrl-P"
                    exec: (editor, args) => 
                        range = editor.getSelectionRange()
                        if range.isStart 0,0 then @navigate(-1)
                        else editor.navigateUp args.times
                    multiSelectAction: "forEach"
                    readOnly: yes

                commands.addCommand
                    name: "golinedown"
                    bindKey: win: "Down", mac: "Down|Ctrl-N"
                    exec: (editor, args) =>
                        document = editor.getSession().getDocument()
                        last_row = document.getLength() - 1
                        last_col = document.getLine(last_row).length
                        range = editor.getSelectionRange()
                        if range.isEnd last_row, last_col then @navigate(1)
                        else editor.navigateDown args.times
                    multiSelectAction: "forEach"
                    readOnly: yes
                    
                commands.addCommand
                    name: "movelineup"
                    bindKey: win: "Ctrl-Up", mac: "Ctrl-Up"
                    exec: (editor, args) => @move(-1); editor.focus(); yes

                commands.addCommand
                    name: "movelinedown"
                    bindKey: win: "Ctrl-Down", mac: "Ctrl-Down"
                    exec: (editor, args) => @move(1); editor.focus(); yes

                commands.addCommand
                    name: "compact"
                    bindKey: win: "Ctrl-Shift-Up", mac: "Ctrl-Shift-Up"
                    exec: (editor, args) => @open(); editor.focus(); yes

                commands.addCommand
                    name: "expand"
                    bindKey: win: "Ctrl-Shift-Down", mac: "Ctrl-Shift-Down"
                    exec: (editor, args) => @close(); editor.focus(); yes

                commands.addCommand
                    name: "clear_filter"
                    bindKey: win: "Esc", mac: "Esc"
                    exec: (editor, args) => @clear_filter(); editor.focus()

                commands.addCommand
                    name: "togglepriority_or_split_node_or_newline"
                    bindKey: win: "Ctrl-Return", mac: "Ctrl-Return"
                    exec: (editor, args) =>
                        if not @editor.editing then @toggle_priority(); editor.focus()
                        else
                            document = editor.getSession().getDocument()
                            last_row = document.getLength() - 1
                            last_col = document.getLine(last_row).length
                            range = editor.getSelectionRange()
                            if not range.isEnd(last_row, last_col) then @split(); editor.focus()
                            else @editor._.insert '\n'

                commands.addCommand
                    name: "toggle_or_newline"
                    bindKey: win: "Shift-Return", mac: "Shift-Return"
                    exec: (editor, args) =>
                        document = editor.getSession().getDocument()
                        last_row = document.getLength() - 1
                        last_col = document.getLine(last_row).length
                        range = editor.getSelectionRange()
                        if range.isStart(0,0) and range.isEnd(last_row, last_col)
                            @toggle()
                            @list()
                            editor.focus()
                            yes
                        else @editor._.insert '\n'

                commands.addCommand
                    name: "pin"
                    bindKey: win: "Ctrl-Shift-Return", mac: "Ctrl-Shift-Return"
                    exec: (editor, args) => 
                        if not @editor.editing then @pin(); editor.focus()

            else
                @editor.use_ace = no
                @editor._ = document.id("newnotes-#{@id}-note-text-input")
                @editor._.addEvent 'keyup', (e) =>
                    return unless @editor.editing
                    @[if @editor.current_id? then 'save' else 'add'] no
                @editor._.addEvent 'focus', (e) =>
                    @editor.editing = yes if @editor._.container.getStyle('width') isnt '0px'
                @editor._.addEvent 'blur', (e) =>
                    @editor.editing = no
                    @list()
                @editor._.container = @editor._
                @editor._.container.dispose()

            start = =>
                @check_connected()
                setInterval ( => @check_connected() ), 1 * 60 * 1000
                
                @reload()
                
            #Check if a new cache is available on page load.
            cache = window.applicationCache
            if @standalone
                window.addEventListener 'load', (e) ->
                    cache.addEventListener 'updateready', (e) ->
                        if cache.status is cache.UPDATEREADY
                            # Browser downloaded a new app cache.
                            # Swap it in and reload the page to get the new hotness.
                            cache.swapCache()
                            window.location.reload()
                        else
                            # Manifest didn't changed. Nothing new to server.
                    , no
                    cache.addEventListener 'cached', ((e) -> start()), no
                    cache.addEventListener 'noupdate', ((e) -> start()), no
                    cache.addEventListener 'error', ((e) -> start()), no
                , no
            else start()
            
        current_get : -> @newnotes.data.by.id[@editor.current_id]
        
        current_set : (id) ->
            @editor.current_id = id
            @newnotes.path = []
            if id?
                note = @newnotes.data.by.id[id]
                @newnotes.path.push id
                while (note = note.parent)? then @newnotes.path.unshift note.uuid
        
        register_key : ->
            if @url?.register_key?
                new Request 
                    data: key:document.id("newnotes-#{@id}-login-key").value
                    noCache: yes
                    url: @url.register_key
                    onSuccess: (data) =>
                        @switch_login off
                        @check_connected()
                    onFailure: (xhr) ->
                        
                .post()
        
        logoff : ->
            if @url?.forget_keys?
                new Request
                    url: @url.forget_keys
                    noCache: yes
                    onSuccess: (data) => 
                        @switch_login on
                        @check_connected()
                    onFailure: (xhr) ->
                        
                .post()

        switch_login: (switched) =>
            if document.id("newnotes-#{@id}-#{if switched is on then 'login' else 'note'}-panel").hasClass 'hidden'
                document.id("newnotes-#{@id}-note-panel")["#{if switched is on then 'add' else 'remove'}Class"] 'hidden'
                document.id("newnotes-#{@id}-login-panel")["#{if switched is on then 'remove' else 'add'}Class"] 'hidden'
                @reload() unless switched

        data_modified_date: undefined
        
        get_data_modified_date: ->
            if @is_connected 
                new Request
                    url: @url.modified_date
                    noCache: yes
                    onSuccess: (responseText) => 
                            if responseText isnt ''
                                value = parseInt responseText
                                @data_modified_date ?= value
                                if value > @data_modified_date
                                    @data_modified_date = value
                                    window.location.reload()
                    onFailure: (xhr) ->
                .get()

        is_connected: false
        
        check_connected: ->
            switch_log = (switched) =>
                @is_connected = not switched
                document.id("newnotes-#{@id}-note-log#{if switched is on then 'on' else 'off'}").removeClass 'hidden'
                document.id("newnotes-#{@id}-note-log#{if switched is on then 'off' else 'on'}").addClass 'hidden'
                if @is_connected then setTimeout (=> @get_data_modified_date.call @), 100

                document.id("newnotes-#{@id}-list-body")[(if switched then 'add' else 'remove') + 'Class'] 'disconnected'
                
            if @url?.connected?
                new Request
                    url: @url.connected
                    noCache: yes
                    onSuccess: (data) ->
                        if data is "connected" then switch_log off else switch_log on
                    onFailure: (xhr) ->
                        switch_log on
                .get()
                                
        'new': (option) ->
            @remove_if_empty()
            note = @newnotes.add '', (if option?.at_end then undefined else @current_get()), (if option?.before then 0 else 1)
            @on_tagging_change note
            @current_set note.uuid
            @editor.set ''
            @on_note_modified()
            @modify()
            
        add: ->
            note = @newnotes.add @editor.get()
            @on_tagging_change note
            @current_set note.uuid
            @list()
            @on_note_modified()
        
    
        split: ->
            document = @editor._.getSession().getDocument()
            last_row = document.getLength() - 1
            last_col = document.getLine(last_row).length
            pos = @editor._.getCursorPosition()
            Range = require('ace/range').Range
            del_range = new Range pos.row, pos.column, last_row, last_col
            del_text = @editor._.getSession().getTextRange del_range
            
            this.editor._.getSession().remove del_range
            @new()
            this.editor._.setValue del_text

        sort: ->
            note = @current_get()
            @newnotes.sort note
            @list()
            @on_note_modified()
            
        dent: (direction) ->
            note = @current_get()
            parent = note.parent
            @newnotes[direction + 'dent'] note
            result = []
            result.push @on_tagging_change(note)
            result.push @on_tagging_change(parent, yes) if parent?
            unless yes in result 
                @list()
                @on_note_modified()
            
        move: (step) ->
            @newnotes.move @current_get(), step
            @list()
            @on_note_modified()
            
        remove_if_empty: ->
            note = @current_get()
            if note?.title is '' and note.subs.length is 0 
                @newnotes.remove note
                @on_tagging_change note
                @newnotes.path = []
                @on_note_modified()
                yes
            else
                no
                
        set_dimension: (option, value, note, dolist, propagate) ->
            dolist ?= yes
            propagate ?= yes
            if note?
                @save no, option, value, note
                @on_tagging_change note, undefined, no if propagate
                @on_note_modified()
                @list() if dolist
            @newnotes.dimensions[option].value = value
        
        toggle_priority: (item, index) ->
            id = if item? then item.attributes['data-uuid'].value else @current_get().uuid
            note = @newnotes.data.by.id[id]
            if note?.subs.length > 0 then return
            dimension = 'Priority'
            index ?= Newnotes.Dimensions.Priority.values.indexOf(note.dimensions[dimension]) + 1
            if index >= Newnotes.Dimensions[dimension].values.length then index = 0
            value = Newnotes.Dimensions[dimension].values[index]
            @set_dimension dimension, value, note
            document.id("newnotes-#{@id}-#{dimension.toLowerCase()}-select").value = value
            @on_note_modified()
            @list()
            @editor.focus()
            
        save: (dolist, option, value, note) ->
            note ?= @current_get()
            unless option?
                @newnotes.modify note, @editor.get()
            else
                @newnotes.modify note, option, value
            @list() if dolist isnt no
            @on_note_modified() unless window.event.type is 'click'

        load: (callback) ->
            if @url?.load?
                new Request.JSON
                    url: @url.load
                    onSuccess: (data) =>
                        if data?
                            for own uuid, note of data.by.id
                                data.by.id[uuid] = Newnotes.Note.create note
                                
                            for own uuid, note of data.by.id
                                Newnotes.Note.awake note, data

                            data.by.root[i] = data.by.id[uuid] for uuid, i in data.by.root
                            data.by[name][key][i] = data.by.id[uuid] for uuid, i in data.by[name][key] for own key of data.by[name] for own name of Newnotes.Dimensions

                            @newnotes.data = data
                            if data.by.root.length is 0 then @newnotes.add 'new Note !'
                            callback?()

                    onFailure: (xhr) ->
                .get()
        
        reload: ->
            @load =>
                @list()
                @fill_search_selector()
                for own name of Newnotes.Dimensions
                    document.id("newnotes-#{@id}-#{name.toLowerCase()}-select").set 'html', @html_options "#{name}"
                @editor._.resize()
                @editor.focus()
                
        export: ->
            if @remove_if_empty() then @list()
            
            data = Newnotes.new_data()

            for own uuid, note of @newnotes.data.by.id
                data.by.id[uuid] = note.export()

            data.by.root.push item.uuid for item in @newnotes.data.by.root
            (data.by[name][key] ?= []).push item.uuid for item in @newnotes.data.by[name][key] for own key of @newnotes.data.by[name] for own name of Newnotes.Dimensions
            
            if @url?.save?
                @editor.exporting = yes
                new Request.JSON
                    url: @url.save
                    onSuccess: => 
                        @editor.exporting = no
                        @data_modified_date = undefined
                        setTimeout (=> @get_data_modified_date.call @), 100
                    onFailure: (xhr) ->
                .post JSON.stringify data

        display_message: (message) ->
            new Element('div').set('html', ('<p>' + new Date().toString 'dd/MM/yyyy HH:mm:ss')  + '<br/>&nbsp;&nbsp;' + message + '</p>').inject document.id("newnotes-#{@id}-note-message"), 'top'

        list: ->
            kup =  ->
                nav = @params.editor.tree_navigate
                nav.previous = nav.current = nav.next = undefined
                
                kup = (selection) ->
                    selection ?= @params.selection
                    
                    if @params.filter.text?
                        if selection.filtered.first? 
                            if @params.filter.last_filter isnt @params.filter.text
                                @params.editor.current_id = @params.filter.first = selection.filtered.first
                                @params.filter.last_filter = @params.filter.text
                    else
                        if @params.filter.last_filter? then @params.filter.last_filter = @params.filter.first = undefined
                    
                    regexp = new RegExp(@params.filter.text, 'ig') if @params.filter.text?
                    
                    for item, index in selection
                        if @params.editor.current_id is undefined then @params.editor.current_id = item.note.uuid
                        @params.editor.tree_states[item.note.uuid] ?= node:no, closed:(if item.note.subs.length > 0 then yes else no), compacted:(if item.filtered then no else yes)
                        selected = @params.editor.current_id is item.note.uuid
                        state = @params.editor.tree_states[item.note.uuid]
                        
                        if state.new_closed_state?
                             @params.editor.new_closed_subs_state = state.new_closed_state
                        if state.new_compacted_state?
                             @params.editor.new_compacted_subs_state = state.new_compacted_state
                        
                        if @params.editor.new_closed_subs_state?
                            state.closed = if state.new_closed_state? then no else @params.editor.new_closed_subs_state
                        if @params.editor.new_compacted_subs_state?
                            state.compacted = @params.editor.new_compacted_subs_state

                        is_compacted = no
                        str_title = item.note.title
                        str_content = undefined
                        if state.compacted
                            compacted_title = Newnotes.Note.compact_title item.note, with_content:yes
                            str_title = compacted_title.title
                            str_content = compacted_title.content
                            is_compacted = compacted_title.is_compacted
                            
                        str_title = new Chocodown.converter().makeHtml str_title
                        
                        if str_title[0..2] is '<p>' then str_title = str_title[3..]
                        if str_title[-4..] is '</p>' then str_title = str_title[...-4]
                        
                        if str_content?
                            str_content = new Chocodown.converter().makeHtml str_content
                            
                            if str_content[0..2] is '<p>' then str_content = str_content[3..]
                            if str_content[-4..] is '</p>' then str_content = str_content[...-4]
                        
                        if item.filtered then str_title = str_title.replace regexp, "<span class='newnotes-filtered'>$&</span>"
                        state.filtered = item.filtered
                        
                        if item.subs.filtered.exists then state.closed = false
                            
                        state.node = (item.note.subs.length > 0)
                        
                        if item.filtered or not @params.filter.text?
                            nav.next = item.note.uuid unless nav.next? or not nav.current?
                            nav.current = item.note.uuid if selected
                            nav.previous = item.note.uuid unless nav.current?
                        
                        bullet = if state.node then (if state.closed then '+' else '-') else '>'
                        bullet_char = if item.subs.length > 0 then '•' else '●'
                        priority = if item.note.dimensions.Priority? then "<span class='newnotes-priority-#{item.note.dimensions.Priority}'>#{bullet_char}</span>" else ''
                        
                        classes = ['note']
                        classes.push 'selected' if selected
                        classes.push 'compacted' if is_compacted
                        
                        li 'class': classes.join(' '), 'data-uuid':item.note.uuid, onclick:"Newnotes.panels[#{@params.id}].modify(this);", -> 
                            span 'data-uuid':item.note.uuid, onclick:"Newnotes.panels[#{@params.id}].toggle(this);Newnotes.panels[#{@params.id}].modify(this, {no_focus:true});window.event.stopPropagation();", bullet
                            span 'data-uuid':item.note.uuid, onclick:"Newnotes.panels[#{@params.id}].toggle_priority(this);Newnotes.panels[#{@params.id}].modify(this, {no_focus:true});window.event.stopPropagation();", (' ' + priority)
                            text '  ' + str_title
                            if is_compacted then a href:'#', 'data-uuid':item.note.uuid, onclick:"Newnotes.panels[#{@params.id}].expand(this);", '...'
                            p '  ' + str_content if str_content?
                            
                        if item.subs.length > 0 and not state.closed then ul -> kup.call @, item.subs
                        
                        if state.new_closed_state?
                            state.new_closed_state = @params.editor.new_closed_subs_state = undefined
                        if state.new_compacted_state?
                            state.new_compacted_state = @params.editor.new_compacted_subs_state = undefined
                kup.call @
            
            is_editing = @editor.editing
            
            list_body = document.id("newnotes-#{@id}-list-body")
            list_panel = document.id("newnotes-#{@id}-list-panel")
            list_panel.setStyle 'display', ''
            list_panel.set 'html', new Chocokup.Panel({editor:@editor, id:@id, selection:@newnotes.select(undefined, @current_get()), filter:@newnotes.filter}, kup).render()
            
            @editor.editing = is_editing
            
            new_element = list_body.getElement "li[data-uuid=#{@editor.current_id}]"
            
            if new_element?
                while new_element.getPosition(list_body).y + new_element.getSize().y - 1 > list_body.getSize().y / 2 + new_element.getSize().y / 2
                    scroll_pos = list_body.getScroll().y
                    list_body.scrollTo 0, list_body.getScroll().y + (new_element.getPosition(list_body).y + new_element.getSize().y - list_body.getSize().y / 2 - new_element.getSize().y / 2)
                    if list_body.getScroll().y is scroll_pos then break
                    
                while new_element.getPosition(list_body).y + 1 < list_body.getSize().y / 2 - new_element.getSize().y / 2
                    scroll_pos = list_body.getScroll().y
                    list_body.scrollTo 0, list_body.getScroll().y - (list_body.getSize().y / 2 - new_element.getSize().y / 2 - new_element.getPosition(list_body).y)
                    if list_body.getScroll().y is scroll_pos then break
                
                if @in_list is no
                    @editor._.container.setStyle 'width', '100%'
                    @editor._.container.setStyle 'height', '100%'
                else
                    if is_editing
                        if @has_keyboard
                            @editor._.container.setStyle 'position', 'relative'
                            @editor._.container.setStyle 'left', '24px'
                            @editor._.container.setStyle 'top', '-14px'
                            @editor._.container.setStyle 'margin-bottom', '-19px'
                            @editor._.container.setStyle 'width', new_element.getSize().x - 30
                            line_count = 1 + ((@current_get().title.match /\n/g)?.length ? 0)
                            line_height = parseFloat(new_element.getComputedStyle('line-height'))
                            new_height = Math.max line_count * line_height , new_element.getSize().y
                            @editor._.container.setStyle 'height', "#{new_height}px"
                            new_element.setStyle 'height', "#{new_height}px"
                            @editor._.container.inject new_element, 'after'
                        else
                            list_panel.setStyle 'display', 'none'
                            @editor._.container.setStyle 'position', 'absolute'
                            @editor._.container.setStyle 'left', '0px'
                            @editor._.container.setStyle 'top', '0px'
                            @editor._.container.setStyle 'width', '100%'
                            @editor._.container.setStyle 'height', '100%'
                            @editor._.container.setStyle 'font-size', '1em'
                            @editor._.container.inject list_body, 'after'
                        new_element.setStyle 'overflow', 'hidden'
                        new_element.setStyle 'width', '20px'
                        new_element.setStyle 'height', '7px'
                        @editor._.resize() if @use_ace
                    else
                        if @use_ace
                            @editor._.container.setStyle 'position', 'absolute'
                            @editor._.container.setStyle 'left', 0
                            @editor._.container.setStyle 'top', 0
                            @editor._.container.setStyle 'width', 0
                            @editor._.container.setStyle 'height', 0
                            @editor._.container.inject new_element, 'after'
                        else @editor._.container.dispose()

        modify: (item, options) ->
            id = if item? then item.attributes['data-uuid'].value else @editor.current_id
            if id? and id is @editor.current_id or not @in_list
                @editor.editing = yes unless options?.no_focus 
            else
                @remove_if_empty()
            @current_set id
            note = @current_get()
            @editor.set note.title
            for own name of Newnotes.Dimensions
                value = note.dimensions[name]
                document.id("newnotes-#{@id}-#{name.toLowerCase()}-select").value = value
                @newnotes.dimensions[name].value = value
            @list()
            unless options?.no_focus then @editor.focus()
            
        open: (item) ->
            id = if item? then item.attributes['data-uuid'].value else @current_get()?.uuid
            
            if id?
                @editor.tree_states[id].new_closed_state = no
                @editor.tree_states[id].new_compacted_state = no
                @list()
            
        close: (item) ->
            id = if item? then item.attributes['data-uuid'].value else @current_get()?.uuid
            
            if id?
                note = @newnotes.data.by.id[id]
                @editor.tree_states[id].new_closed_state = yes
                @editor.tree_states[id].new_compacted_state = if note.subs.length > 0 then yes else no
                @list()
            
        expand: (item) ->
            id = if item? then item.attributes['data-uuid'].value else @current_get()?.uuid
            
            if id?
                @editor.tree_states[id].new_compacted_state = no
                @list()
            
        compact: (item) ->
            id = if item? then item.attributes['data-uuid'].value else @current_get()?.uuid
            
            if id?
                @editor.tree_states[id].new_compacted_state = yes
                @list()
                
        home: ->
            @switch_filter_list off
            @clear_filter()
            @clear_pin()
            @editor.clear()
            @list()
            @editor.focus()

        navigate: (step) ->
            dest_id = @editor.tree_navigate[if step > 0 then 'next' else 'previous']
            item = document.id("newnotes-#{@id}-list-body").getElement "li[data-uuid=#{dest_id}]" if dest_id?
            ( @editor.editing = no ; @modify item; ) if item?
            
        toggle: (item) ->
            id = if item? then item.attributes['data-uuid'].value else @current_get().uuid
            note = @newnotes.data.by.id[id]
            if @editor.tree_states[id]?.node 
                @editor.tree_states[id].closed = not @editor.tree_states[id].closed
            else
                @editor.tree_states[id].compacted = not @editor.tree_states[id].compacted
            @list()
                
        focus_filter: ->
            item = document.id "newnotes-#{@id}-filter-input"
            item.focus()
        
        clear_filter: ->
            item = document.id "newnotes-#{@id}-filter-input"
            item.value = ''            
            @filter item
            @list()
            
        init_filter: ->
            @clear_filter()
            @focus_filter()
            
        stop_filter: ->
            @newnotes.filter.text = undefined
            @list()
            
        start_filter: ->
            item = document.id "newnotes-#{@id}-filter-input"
            if item.value isnt @newnotes.filter.text and item.value isnt ""
                @newnotes.filter.text = item.value
                @list()

        filter: (item) ->
            @newnotes.filter.set if item.value isnt '' then item.value else undefined
            @current_set undefined if item.value isnt ''
            @filter_list()
            @list()
            
        filter_list: ->
            kup = ->
                kup = (selection) ->
                    selection ?= @params.selection
                    for item, index in selection
                        if item.filtered
                            str = item.note.title
                            regexp = new RegExp( @params.filter.text, "ig" )
                            while match = regexp.exec str
                                i = match.index
                                len = @params.filter.text.length
                                close_size = 40
                                trail_left = if i - close_size > 0 then '...' else ''
                                trail_right = if i + len + close_size < str.length then '...' else ''
                                close_left  = str.substr (if trail_left is '' then 0 else  i - close_size), (if trail_left is '' then i else  close_size)
                                close_right = str.substr i + len, close_size
                                found = str.substr i, len
                                div 'data-uuid':item.note.uuid, onclick:"Newnotes.panels[#{@params.id}].go(this);", -> trail_left + close_left + "<span class='newnotes-filtered'>" + found + "</span>" + close_right + trail_right
                        if item.subs.length > 0 then kup.call @, item.subs
                kup.call @
                    
            list_body = document.id("newnotes-#{@id}-filter-list-body")
            list_body.set 'html', new Chocokup.Panel({editor:@editor, id:@id, selection:@newnotes.select(), filter:@newnotes.filter}, kup).render()
        
        go: (item) ->
            @switch_filter_list off
            @start_filter()
            id = if item? then item.attributes['data-uuid'].value else @current_get().uuid
            # @clear_pin()
            @current_set id
            # @pin yes
            @list()
            @editor.focus()
        
        clear_pin: ->
            @newnotes.clear_pin()
            document.id("newnotes-#{@id}-pin-list").set 'html', 'None'
            @current_set undefined
            @filter_list()
            @list()

        pin: (force) ->
            @newnotes.pin @current_get(), force
            @on_pinned()

        unpin: (item) ->
            id = if item? then item.attributes['data-uuid'].value else @current_get().uuid
            note = @newnotes.data.by.id[id]
            @newnotes.unpin note
            @on_pinned()

        on_note_modified: ->
            if @editor.waiting then @editor.modified = yes ; return
            
            check = =>
                if @editor.modified or @editor.exporting
                    @editor.modified = false
                    setTimeout check, 3000
                else 
                    @export()
                    @editor.waiting = no
                    
            @editor.waiting = yes
            setTimeout check, 3000

        on_key_filter: (item) ->
            event = undefined
            key = if window.event? then (event = new DOMEvent window.event).key else ''
            switch key
                when 'up' then @navigate -1
                when 'down' then @navigate 1
                when 'esc' then @clear_filter(); @editor.focus()
                when 'home' then @home()
                when 'enter' then if event.shift and event.control then @pin(); @clear_filter(); @editor.focus();
                else 
                    if item.value.length >= 3 or item.value.length is 0 then @filter item
        
        switch_filter_list: (switched) ->
            list = document.id "newnotes-#{@id}-list-main"
            filter_list = document.id "newnotes-#{@id}-filter-list-main"
            
            if (if (switched) then filter_list else list).hasClass 'hidden'
                filter_list["#{if switched then 'remove' else 'add'}Class"] 'hidden'
                list["#{if switched then 'add' else 'remove'}Class"] 'hidden'

        on_filter_focus: ->
            @switch_filter_list on
            @start_filter()
            
        on_pinned: ->
            html = (new Chocokup id:@id, selected:@newnotes.pinned.selected, -> for note, i in @params.selected then text(if i > 0 then ', ' else ''); a href:"#", 'data-uuid':note.uuid, onclick:"Newnotes.panels[#{@params.id}].unpin(this);", (if note.title.length > 8 then note.title.substr(0, 5) + '...' else note.title)).render {format:false}
            document.id("newnotes-#{@id}-pin-list").set 'html', if html is '' then 'None' else html
            @current_set undefined
            @filter_list()
            @list()
            @editor.focus()
            
        on_pin_mode_changed: (item) ->
            @newnotes.pinned.mode = item.value
            @current_set undefined
            @filter_list()
            @list()
            @editor.focus()
            
        on_option_selected: (option, select, note, level) ->
            level ?= 0
            note ?= @current_get()
            if note?.subs.length > 0 
                unless Newnotes.Dimensions[option].node is 'free'
                    @set_dimension option, select.value, note, no, no
                    for sub in note.subs then @on_option_selected option, select, sub, level + 1
                    if level is 0 then @on_tagging_change(note, undefined, yes) ; @editor.focus()
                    return
            
            @set_dimension option, select.value, note, no, no
            if level is 0 then @on_tagging_change(note, undefined, yes) ; @editor.focus()
            
        on_search_option_selected: (option, select) ->
            @newnotes.dimensions[option].searched = select.value
            
            unless select.value is 'all'
                document.id("newnotes-#{@id}-#{option.toLowerCase()}-select").value = select.value 
                @newnotes.dimensions[option].value = select.value
            @current_set undefined
            @list()
            @filter_list()
            
            @editor.focus()
            
        on_tagging_change: (note, do_self, dolist) ->
            dolist ?= yes
            check = (note, check_self) =>
                modified = no
                parent = unless check_self then note.parent else note
                for own name, dimension of Newnotes.Dimensions
                    unless dimension.node is 'free'
                        index = dimension.values.length
                        if (list = parent?.subs)?
                            for item in list
                                item_index = dimension.values.indexOf item.dimensions[name]
                                if item_index < index
                                    value = item.dimensions[name]
                                    @newnotes.data.by[name][parent.dimensions[name]].erase parent
                                    parent.dimensions[name] = value
                                    (@newnotes.data.by[name][value] ?= []).push parent
                                    index = item_index
                                    modified = yes
                check parent if parent? and modified
                modified
                
            if modified = check note, do_self then @list() if dolist
            @fill_search_selector()
            modified
            
        html_options: (name, selected, count) ->
            (new Chocokup option:Newnotes.Dimensions[name].values, selected:selected, count:count ? false, by:@newnotes.data.by[name], -> for id in @params.option then option value:id, selected:(@params.selected is id), (id + if @params.count then (" (#{@params.by[id]?.length ? 0})") else '')).render()
            
        fill_search_selector: ->
            for own name of Newnotes.Dimensions
                selector = document.id("newnotes-#{@id}-search-#{name.toLowerCase()}-select")
                selector.set 'html', "<option value='all'>All</option>" + @html_options "#{name}", selector.value, yes

    @Note: class
        constructor: (@title, @parent, @dimensions, @uuid = _.Uuid()) ->
            @subs = []
            @date =
                creation: new Date()
                modified: new Date()
                
        @compact_title: (note, options) ->
            result = title: note.title, content: undefined, is_compacted:no
            
            line_break_index = note.title.indexOf '\n'
            if line_break_index <= 0 then line_break_index = 160
            if 0 < line_break_index < note.title.length
                result.title = note.title.substr 0, line_break_index
                result.content = note.title.substr line_break_index if options?.with_content
                result.is_compacted = yes
            
            result
        
        export: ->
            note = new Newnotes.Note @title, @parent, Newnotes.clone(@dimensions), @uuid
            note.parent = note.parent.uuid if note.parent?
            note.subs.push item.uuid for item in @subs
            note.date =
                creation: @date.creation
                modified: @date.modified
            note
        
        @create: (item) ->
            note = new Newnotes.Note item.title, item.parent, Newnotes.clone(item.dimensions), item.uuid
            note.subs[i] = uuid for uuid, i in item.subs
            note.date =
                creation: new Date Date.parse item.date.creation
                modified: new Date Date.parse item.date.modified
            note
            
        @awake: (item, data) ->
            item.parent = data.by.id[item.parent] if item.parent?
            item.subs[i] = data.by.id[uuid] for uuid, i in item.subs
            item

    @panels: []
    
    @create_panel: (options) ->
        options.has_keyboard = Browser.Platform.mac or Browser.Platform.win or Browser.Platform.linux
        options.use_ace = if ace and options.has_keyboard then yes else no
        options.code_css = Highlight.defaultCodeCSS 
        
        new Chocokup.Panel(options, Newnotes.kup).render()
        .stripScripts (scripts, html) ->
            document.id(options.element_id).set 'html', html
            Browser.exec scripts

    ## clone
    #
    # Basic deep clone function
    @clone: (object) ->
      return object unless object? and typeof object is "object"
      cloned = new object.constructor
      cloned[key] = Newnotes.clone object[key] for key of object
      cloned

    @new_data: ->
        data = 
            by:
                id : {}
                root: []
        data.by[name] = {} for own name of Newnotes.Dimensions
        data

    constructor: ->
        @path = []
        @filter = 
            text: undefined
            first: undefined
            last_filter: undefined
            set: (text) ->
                @text = text
                @first = @last_filter = undefined
        @pinned =
            mode: 'on'
            selected: []
            used: []
        @selection = []
        @dimensions = do ->
            dimensions = {}
            for own name, dimension of Newnotes.Dimensions
                dimensions[name] = 
                    value: dimension.values[0]
                    searched: 'all'
            dimensions
        @data = Newnotes.new_data()
                
    clear: ->
        @data = Newnotes.new_data()
        return

    add: (title, after, step = -1) ->
        parent = if @path.length > 0 then @data.by.id[@path.getLast()].parent else undefined
        note = new Newnotes.Note title, parent, (do => dimensions = {}; dimensions[k] = v.value for own k,v of @dimensions; dimensions)
        list = parent?.subs ? @data.by.root
        if after? then for item, index in list then if item is after then list.splice index+step, 0, note ; break
        else list.push note
        
        @data.by.id[note.uuid] = note
        for own name, dimension of @dimensions
            (@data.by[name][dimension.value] ?= []).push note
        
        note
    
    sort: (note) ->
        compare = (note1, note2) ->
            result = Newnotes.Dimensions.Priority.values.indexOf(note1.dimensions.Priority)
            result -= Newnotes.Dimensions.Priority.values.indexOf(note2.dimensions.Priority)
            result = note1.date.modified - note2.date.modified if result is 0
            return -1 if result < 0 
            return 1 if result > 0
        
        if note.subs.length > 0
            note.subs.sort compare
            for sub in note.subs then @sort sub
        
    modify: (note, option, value) ->
        if option? and not value?
            if note.title isnt option
                note.title = option
                note.date.modified = new Date()
            return
        
        if option? and value? 
            if note.dimensions[option] isnt value
                @data.by[option][note.dimensions[option]].erase note
                note.dimensions[option] = value
                (@data.by[option][note.dimensions[option]] ?= []).push note
                note.date.modified = new Date()
            return

    remove: (note) ->
        note.parent.subs.erase note if note.parent?
        delete @data.by.id[note.uuid]
        for own name, dimension of @dimensions
            @data.by[name][note.dimensions[name]].erase note
        @data.by.root.erase note unless note.parent
    
    move: (note, step) ->
        list = note.parent?.subs ? @data.by.root
        index = list.indexOf note
        new_index = index + step
        if 0 <= new_index < list.length
            list.erase note
            list.splice new_index, 0, note
            note.date.modified = new Date()

    indent: (note) ->
        list = note.parent?.subs ? @data.by.root
        for item in list
            if item is note then break else previous = item
        if previous?
            list.erase note
            previous.subs.push note
            note.parent = previous
            note.date.modified = new Date()

    outdent: (note) ->
        if note.parent?
            note.parent.subs.erase note
            
            parent = note.parent.parent
            list = parent?.subs ? @data.by.root
            for item, index in list then if item is note.parent then list.splice index+1, 0, note ; break
            note.parent = parent
            note.date.modified = new Date()

    is_inside: (item, parent) ->
        if item is parent then return yes
        else return @is_inside item.parent, parent if item.parent?
        return no

    pin: (note, force) ->
        if note in @pinned.selected and not force then return
        
        @pinned.selected.push note unless note in @pinned.selected
        
        for pinned, i in @pinned.used
            if @is_inside note, pinned
                @pinned.used.splice i, 1
                break;

        is_usable = yes
        for pinned in @pinned.used
            is_usable = no if @is_inside pinned, note
        @pinned.used.push note if is_usable

    unpin: (note) ->
        i = @pinned.used.indexOf note
        @pinned.used.splice i, 1 if i >= 0

        i = @pinned.selected.indexOf note
        @pinned.selected.splice i, 1 if i >= 0

        to_pin = []
        for item in @pinned.selected
            unless item in @pinned.used
                if @is_inside note, item then to_pin.push item

        @pin item, yes for item in to_pin
    
    clear_pin: ->
        @pinned.used = []
        @pinned.selected = []

    list: ->
        @selection = []

        for own id, note of @data.by.id then @selection.push note

        @selection

    select: (parent, current) ->
        selection = []
        selection.filtered =
            exists: no
            first: undefined
        
        subs =
            selection : undefined
            select: (note, current) =>
                subs.selection ? subs.selection = @select(note, current)
                
        regexp = new RegExp(@filter.text, 'ig') if @filter.text?
        
        list = parent?.subs ? (if @pinned.mode is 'on' and @pinned.used.length > 0 then @pinned.used else undefined) ? @data.by.root
        for note in list
            keep_note = yes
            subs.selection = undefined

            keep_note and= dimension.searched in [note.dimensions[name], 'all'] for own name, dimension of @dimensions

            keep_note or= subs.select(note, current).length > 0
            
            keep_note = yes if note.uuid is current?.uuid
            
            if keep_note 
                filtered = not not note.title.match regexp if regexp?
    
                selection.filtered.first ?= if filtered then note.uuid else subs.select(note, current).filtered.first
                selection.filtered.exists or= filtered or subs.select(note, current).filtered.exists
                
                selection.push note:note, subs:subs.select(note, current), filtered:filtered 
    
        
        @selection = selection unless parent?
        selection

    @connected: ->
        "connected"
    
    @disconnected: ->
        "disconnected"

    @interface = (__) ->
        Newnotes.enter(__)
    
    @enter: (__) ->
        Chocokup = require './chocokup'
        stats = require('fs').statSync require.resolve '../general/newnotes.coffee'
        new Chocokup.App 'Newnotes', theme:'basic', with_coffee:yes, manifest:"/-/general/newnotes?manifest&how=manifest", appdir:__.appdir, ->
            style
                type:"text/css" 
                media:"screen"
                """
                body {
                    font-family:Lucida Console,Helvetica,monospace;
                    font-size:9pt;
                    background-color:white;
                    color:black;
                }
                a, select {
                    color:black;
                }
                """
            text '<script>_sofkey = ' + (if backdoor_key isnt '' then '"' + backdoor_key + '"' else 'null') + "; _appdir = '#{@params.appdir}';" + '</script>\n'
            script src:"/static/vendor/ace/ace.js", type:"text/javascript", charset:"utf-8"
            script src:"/static/vendor/ace/mode-coffee.js", type:"text/javascript", charset:"utf-8"
            script src:"/static/vendor/ace/mode-markdown.js", type:"text/javascript", charset:"utf-8"
            script src:"/static/vendor/ace/theme-chrome.js", type:"text/javascript", charset:"utf-8"
            script src:"/static/vendor/mootools/mootools-core-uncompressed.js", type:"text/javascript", charset:"utf-8"
            script src:"/static/lib/newnotes.js", type:"text/javascript", charset:"utf-8"
            
            body ->
                panel '#notes-panel', ''
                
            coffeescript ->
                sofkey = _sofkey
                window.addEvent 'domready', ->
                    window.addEvent 'resize', ->
                        # should do someting
                    
                    taste = if window.getSize().x < 640 then 'fullscreen-narrow' else 'fullscreen-wide'
                    load = '/' + (if sofkey? then '!/' + sofkey else '') + 'data/newnotes_data.json?how=raw'
                    save = '/' + (if sofkey? then '!/' + sofkey else '') + 'data/newnotes_data.json?so=move&how=raw'
                    connected = '/' + (if sofkey? then '!/' + sofkey else '') + '-/general/newnotes?connected&how=raw'
                    modified_date = '/' + (if sofkey? then '!/' + sofkey else '') + '-/server/file?getModifiedDate&' + 'data/newnotes_data.json&how=raw'
                    ping = '/' + (if sofkey? then '!/' + sofkey else '') + '-/ping?how=raw'
                    register_key = '/' + (if sofkey? then '!/' + sofkey else '') + '-/server/interface?register_key&how=raw'
                    forget_keys = '/' + (if sofkey? then '!/' + sofkey else '') + '-/server/interface?forget_keys&how=raw'
                    Newnotes.create_panel element_id:'notes-panel', url: {load, save, connected, modified_date, ping, register_key, forget_keys}, taste:taste, standalone:yes, ace_theme:'ace/theme/chrome'
    
    @manifest: (__) ->
        Chocokup = require './chocokup'
        
        to_cache = """
        #{Chocokup.App.manifest.cache}
        /static/vendor/ace/ace.js
        /static/vendor/ace/mode-coffee.js
        /static/vendor/ace/mode-markdown.js
        /static/vendor/ace/theme-chrome.js
        /static/lib/coffeekup.js
        /static/lib/chocokup.js
        /static/lib/chocodown.js
        /static/vendor/mootools/mootools-core-uncompressed.js
        /static/lib/newnotes.js
        /data/newnotes_data.json?how=raw
        """

        to_cache_list = []
        to_cache_list.push ((line.split '?')[0]).replace('/-', '') for line  in to_cache.split '\n'
        
        time_stamps_list = []
        fs = require('fs')
        for filename in to_cache_list
            stats = fs.statSync require.resolve '..' + filename
            time_stamps_list.push '#' + filename + ' : ' + stats.mtime.getTime()
        time_stamps = time_stamps_list.join '\n'
 
        """
        CACHE MANIFEST
        # v0.05.009
        # Files Timestamp
        #
        #{time_stamps}
        
        CACHE:
        #{to_cache}
        
        NETWORK:
        /static/lib/
        /-/ping
        /-/server/file?getModifiedDate
        
        FALLBACK:
        /-/general/newnotes?connected /-/general/newnotes?disconnected
        
        """

    #### This is experimental !!!
    @present: (where, as, type, __) ->
        if window? then return ''
        
        data = JSON.parse require('fs').readFileSync require.resolve('../' + __.datadir + '/newnotes_data.json')
        
        for uuid, note of data.by.id
            data.by.id[uuid] = Newnotes.Note.create note
        
        Chocodown.Chocokup ?= Chocokup
        Chocodown.Highlight ?= Highlight
        
        for own uuid, note of data.by.id
            Newnotes.Note.awake note, data
            
            str = new Chocodown.converter().makeHtml note.title
            if str[0..2] is '<p>' then str = str[3..]
            if str[-4..] is '</p>' then str = str[...-4]
            
            note.html_title = str
            
            title_compacted = Newnotes.Note.compact_title note, with_content:yes
            note.title_compacted = title_compacted.title
            note.html_title_content = new Chocodown.converter().makeHtml title_compacted.content if title_compacted.content?
            
        data.by.root[i] = data.by.id[uuid] for uuid, i in data.by.root
        data.by[name][key][i] = data.by.id[uuid] for uuid, i in data.by[name][key] for own key of data.by[name] for own name of Newnotes.Dimensions
        
        search = (what, note) ->
            if note.title is what
                return note
            else
                for sub in note.subs 
                    result = search what, sub
                    return result if result?
        
        for note in data.by.root
            result = search where, note
            if result?
                switch as 
                    when 'json'
                        data = Newnotes.new_data()
            
                        iterate = (uuid, note) ->
                            unless data.by.id[uuid]?
                                data.by.id[uuid] = note.export()
                                (data.by[name][key] ?= []).push uuid for own name, key of note.dimensions
                                
                                iterate sub.uuid, sub for own i, sub of note.subs
                        
                        data.by.root.push result.uuid
                        iterate result.uuid, result
                        
                        return JSON.stringify data
                    
                    when 'paper'
                        kup = ->
                            type = @params.type
                            
                            count_points = (note, level, css, sub_css) ->
                                if level is 0 
                                    div '.quiz.points', "Total points: #{iterate.quiz_total_point}"
                                else
                                    nb = note.subs.length
                                    
                                    return if css is '.leaf' or css is '.node' and sub_css is '.node'
                                    
                                    points = switch
                                        when nb is 0
                                            nbli = note.title.split('<br>').length
                                            switch
                                                when nbli < 6 then 1 
                                                when nbli < 11 then 2 
                                                else 5
                                        when nb < 4 then 0.5
                                        when nb < 8 then 1
                                        when nb < 12 then 1
                                        else 2
                                    div '.quiz.points', "#{points} point#{if points > 1 then 's' else ''}"
                                    iterate.quiz_total_point ?= 0
                                    iterate.quiz_total_point += points
                                                    
                            iterate = (note, level, css) ->
                                if (title = note.title)[0] is '$'
                                    for own uuid, sub of note.subs
                                        iterate sub, level + 1
                                    return
                                    
                                if title is '---'
                                    div style:"page-break-before:always", ->
                                    return

                                if title.substr(0,3) is '==='
                                    div '.note', title.substr 3                                
                                    return

                                li ".#{type}#{css}", -> 
                                    text note.html_title
                                    if note.subs?.length > 0 
                                        size = Math.max 16 - 2 * level, 12
                                        ul style:"font-size:#{size}pt", ->
                                            if level is 0 then sub_css = '.node'
                                            else sub_css = '.leaf' ; for own uuid, sub of note.subs then if sub.subs.length > 0 then sub_css = '.node'
                                            
                                            for own uuid, sub of note.subs
                                                iterate sub, level + 1, sub_css

                                            if type is 'quiz' then count_points note, level, css, sub_css
                                    else if type is 'quiz' and level > 0 then count_points note, level, css, ''

                                                    
                            iterate @params.note, 0, '.root'
                        
                        paper_html = new Chocokup.Panel(note:result, require:require, type:type, kup).render()
                        paper_kup = ->
                            style """
                            li.quiz.leaf, li.quiz.root {
                                list-style: none;
                            }
                            
                            li.quiz.node {
                                list-style: decimal;
                                margin-top: 1.5em;
                                margin-bottom: 1.5em;
                            }
                            
                            li.quiz.node ul, div.note {
                                margin-top: 0.6em;
                            }
                            
                            li.quiz.leaf:before {
                                content: '▢';
                            }
                            
                            div.quiz.points {
                                margin-top: 0.8em;
                                font-size: 0.75em;
                            }
                            
                            """
                            ul style:"font-size:20pt", ->
                                text "#{@params.paper_html}"
                                    
                        return new Chocokup.Panel({paper_html}, paper_kup).render()
                        
                    when 'impress'
                        kup = ->
                            class impress
                                x: 0
                                y: 0
                                z: 0
                                rx: 0
                                ry: 0
                                rz: 0
                                s: 1
                                
                                stepped: {}
                                
                                defaults:
                                    move: undefined
                                    rotate: undefined
                                    scale: undefined
                                    css: 
                                        'slide-style':
                                            how: 'to'
                                            value:'slide'
                                        'overflow':
                                            how: 'to'
                                            value: 'none'
                                
                                step: ->
                                    for own so, _so of @defaults when _so?
                                        switch so
                                            when 'move', 'rotate'
                                                for own what, _what of _so 
                                                    @[so] what, _what.how, _what.value unless @stepped["#{so}-#{what}"]
                                            when 'scale'
                                                @scale _so.how, _so.value unless @stepped["scale"]
                                        
                                    @stepped = {}
                                    @
                                                    
                                        
                                set: (so, what, how, value) ->
                                    unless so? and what? and how? then return
                                    
                                    _so = @defaults[so] ?= {}
                                    
                                    if value? 
                                        _so[what] = {how, value}
                                    else
                                        _so = {how:what, value:how}
                                        
                                move: (what, how, value) ->
                                    @stepped["move-#{what}"] = yes
                                    @[what] = (if value? then parseInt value else 0) + switch how
                                        when 'to' then 0
                                        when 'by' then @[what]
                                        else 0
                                        
                                rotate: (what, how, value) ->
                                    @stepped["rotate-#{what}"] = yes
                                    @['r' + what] = (if value? then parseInt value else 0) + switch how
                                        when 'to' then 0
                                        when 'by' then @['r' + what]
                                        else 0
                                        
                                scale: (how, value) ->
                                    @stepped["scale"] = yes
                                    @['s'] = (if value? then parseInt value else 0) + switch how
                                        when 'to' then 0
                                        when 'by' then @['s']
                                        else 0
                            
                            newnotes = 
                                impress: new impress()
                                shell: 'impress'
                            
                            @params.returns.defaults = newnotes.impress.defaults
                                
                            iterate = (note, level) ->
                                if (title = note.title)[0] is '$'
                                    exit = yes
                                    lines = (title.replace /^\$\s*/, '').split '\n'
                                    for line in lines when line.search(/\S/) isnt -1 
                                        splits = line.split ' '
                                        si = 0
                                        tool = splits[si++]
                                        
                                        unless tool in ['impress'] then tool = newnotes.shell; si = 0
                                        
                                        exit = no
                                        
                                        switch tool 
                                            when 'impress'
                                                switch command = splits[si++] 
                                                    when 'default' then newnotes.impress.set splits[si++], splits[si++], splits[si++], splits[si++]; exit = yes
                                                    when undefined then newnotes.shell = tool; exit = yes
                                                    else 
                                                        if (so = newnotes.impress[command])? then so.call? newnotes.impress, splits[si++], splits[si++], splits[si++]; exit = yes
                                    
                                    if exit 
                                        for own uuid, sub of note.subs
                                            iterate sub, level + 1
                                        return
                                
                                switch level
                                        when 0
                                            for own uuid, sub of note.subs
                                                iterate sub, level + 1
                                                
                                        when 1
                                            {x, y, z, rx, ry, rz, s, defaults} = newnotes.impress.step()
                                            div class:"step #{defaults.css['slide-style'].value.split('.').join(' ')}", 'data-scale':s, 'data-x':x, 'data-y':y, 'data-z':z, 'data-rotate-x':rx, 'data-rotate-y':ry, 'data-rotate-z':rz, ->
                                                section ->
                                                    h2 note.title_compacted
                                                    text note.html_title_content if note.html_title_content?
                                                        
                                            for own uuid, sub of note.subs
                                                iterate sub, level + 1
                                                
                                        when 2
                                            {x, y, z, rx, ry, rz, s, defaults} = newnotes.impress.step()
                                            div class:"step #{defaults.css['slide-style'].value.split('.').join(' ')}", 'data-scale':s, 'data-x':x, 'data-y':y, 'data-z':z, 'data-rotate-x':rx, 'data-rotate-y':ry, 'data-rotate-z':rz, style:'overflow-y:' + defaults.css['overflow'].value, ->
                                                header html5:yes, ->
                                                    h1 note.title_compacted
                                                section ->
                                                    text note.html_title_content if note.html_title_content?
                                                    if note.subs.length > 0 
                                                        size = Math.max 40 - 4 * (level+1), 10
                                                        ul style:"font-size:#{size}pt",  -> for own uuid, sub of note.subs
                                                            iterate sub, level + 1
                                        else
                                            li -> 
                                                text note.html_title
                                                if note.subs.length > 0 
                                                    size = Math.max 40 - 4 * (level+1), 10
                                                    ul style:"font-size:#{size}pt", -> for own uuid, sub of note.subs
                                                        iterate sub, level + 1
                                         
                            iterate @params.note, 0

                        returns = {}

                        impress_html = new Chocokup.Panel(note:result, returns:returns, kup).render()
                        
                        impress_kup = ->
                            text """
                                <html>
                                <head>
                                    <meta charset="utf-8" />
                                    <title>#{@params.where}</title>
                                    <style>

                                    .step {
                                        position: relative;
                                        width: 1160px;
                                        padding: 40px;
                                        margin: 20px auto;
                                    
                                        -webkit-box-sizing: border-box;
                                        -moz-box-sizing:    border-box;
                                        -ms-box-sizing:     border-box;
                                        -o-box-sizing:      border-box;
                                        box-sizing:         border-box;
                                    
                                        font-family: 'PT Serif', georgia, serif;
                                        font-size: 36px;
                                        line-height: 1.5;
                                    }
                                    
                                    .step code {
                                        font-size: 28;
                                    }
                                    
                                    .impress-enabled .step {
                                        margin: 0;
                                        opacity: #{@params.css?['inactive-opacity']?.value ? 0};
                                    
                                        -webkit-transition: opacity 1s;
                                        -moz-transition:    opacity 1s;
                                        -ms-transition:     opacity 1s;
                                        -o-transition:      opacity 1s;
                                        transition:         opacity 1s;
                                    }
                                    
                                    .impress-enabled .step.active { opacity: 1 }    

                                    .slide {
                                        display: block;
                                    
                                        width: 1160px;
                                        height: 700px;
                                        padding: 0px 60px;
                                    
                                        background-color: rgb(245, 240, 245);
                                        border: 1px solid rgba(0, 0, 0, .3);
                                        border-radius: 20px 60px;
                                        box-shadow: 0 10px 50px rgba(255, 255, 205, .6);
                                    
                                        color: rgb(70, 70, 70);
                                        text-shadow: 0 2px 2px rgba(0, 0, 0, .1);
                                    }
                                    
                                    .slide.compact {
                                        font-size: 32;
                                        line-height: 1;
                                    }
                                    
                                    .slide.wide {
                                        height: 850px;
                                    }
                                    
                                    .slide pre {
                                        text-align: left;
                                        font-family: 'Droid Sans Mono', Courier;
                                        padding: 10px 20px;
                                        background: rgba(255, 0, 0, 0.05);
                                        -webkit-border-radius: 8px;
                                        -khtml-border-radius: 8px;
                                        -moz-border-radius: 8px;
                                        border-radius: 8px;
                                        border: 1px solid rgba(255, 0, 0, 0.2);
                                    }
                                    
                                    a {
                                        color: inherit;
                                        text-decoration: none;
                                        padding: 0 0.1em;
                                        background: rgba(255,255,255,0.5);
                                        text-shadow: -1px -1px 2px rgba(100,100,100,0.9);
                                        border-radius: 0.2em;
                                    
                                        -webkit-transition: 0.5s;
                                        -moz-transition:    0.5s;
                                        -ms-transition:     0.5s;
                                        -o-transition:      0.5s;
                                        transition:         0.5s;
                                    }
                                    
                                    a:hover,
                                    a:focus {
                                        background: rgba(255,255,255,1);
                                        text-shadow: -1px -1px 2px rgba(100,100,100,0.5);
                                    }
                                    
                                    body {
                                        color:#eee;
                                        background: url('data:image/jpeg;base64,/9j/4AAQSkZJRgABAgAAZABkAAD/7AARRHVja3kAAQAEAAAAWwAA/+4ADkFkb2JlAGTAAAAAAf/bAIQAAQEBAQEBAQEBAQIBAQECAgEBAQECAgICAgICAgMCAgICAgIDAwMDBAMDAwQEBQUEBAYGBgYGBwcHBwcHBwcHBwEBAQECAgIEAwMEBgUEBQYHBwcHBwcHBwcHBwcHBwcHBwcHBwcHBwcHBwcHBwcHBwcHBwcHBwcHBwcHBwcHBwcH/8AAEQgD6AAQAwERAAIRAQMRAf/EAG8AAQEBAQEBAAAAAAAAAAAAAAMCAQQACgEBAQEBAQAAAAAAAAAAAAAAAAECAwQQAAICAQQCAQQCAwADAAAAAAECEQMAMUESBCFRE2Fx0TLBUvCBobEiQhEBAQEBAQEAAAAAAAAAAAAAABEBAhIh/9oADAMBAAIRAxEAPwD4YEoCPy5TGgz15y57pBYjMVDSRtmqkaLEZuIYEjYZKDSgI/PlPoffGYteShUfkDPoHGYu6UOjEqrAkbYqRodGYqGBYajCiShUcuDPoZMwUnXVH5hp1gYzAgdCSoaWG2XNFK6MxUNLbgYqCTrqjlw0+gdpyZgpOuEfnM/1H3y+UpQ6MxUMCw2y0aLEZioaWG2UHX11R+cz/UZPKqTrqjlwZ9D1OXOYpFdGYqGlhqMZqNDozFQ3/sNstWjTrqjlwSfQP1yZzNFV9da35gzrA++SM0odGYqGlhqBlGixGYqrSw2yEGnXCPzmf6jKKTrqj8wZj9QcRSB0ZioaWGowKWxGYqGkjUZao0661vz5TH6jJmFbX1lSwvyn0v3wlKHrdiisCw1GKlUtlbMVVgWGwwCr6y12Fw0+h98hqq+stdnMGYmB9/rmosMtlbMVVpYajCtFlbMVVgWGo84qDr6y12cwxMfqCPfs5IKTqqjl+ROsD1OEpRYjsVDgsNRgUtlbMVVgWGowQVfWWt+fImJ4j74gqvrLW/MNIH6jKsMtlbMUV5IwKWytmKq0sNhORBJ1VR+YaYniDtgqq+stdnMNMTxHqcpSrZWzFFaWGoxEjVsRmKq0sNRlA19Za7OYYmJ4j1OVaqvrLW/MMTE8QdpyRSrYjMVDSw1GKilsRmKhpYajDQq+utb8wZ9D1OIkanXWt+YJPoffNZypQ6MxUNJGowKV0ZioYFhqMVBJ1lR+YM68RkzEq066o5cEn0PWTMSkDozFQ0sNstGh0ZioaSNRlINOuqPzBn0PWXOSqr66o/MGf6jJDdIrozFA0sNQM1U0i2VsxVWBYajM1RV9Va3LhpH/AMr6yG7W19Za7OYYnWAdpy5hulWytmKq0sNQMYNFiMxVWkjbNZuJBp1hW/PlPpT9cznP1d1adUVvzDE6wPU5MxaVbK2YorSRqP8ANc1Ui1srZiqtLDbIga+stdnMMTrA++Iu62vrLXZzDT/URl8pTLZWzFVaWG2Mg1bK2YorSw1A/jLVHX1VrfnyJjRY021zOYlXX1Frs5hiYnise/ZwFW2p2KK8sNh/BwNW6t2KK8sNRlA1dVa7PkDExPFY0n64gqvqLXZ8gYmJ4r6n2cZhSrbW7FFcFhqMtFrbW7lFslxqB+d8lUNXTWqw2BiYnipgRP1xhuqq6a1W/IHJieK+p9nfIU63VO5rVwXGoH5wNW6p2KK4LLqMqAq6aVW/IGJieKnafrviLW1dNarTYGJ14r6nLCnW2p2ZFcFl1AyotbqndkVwzLPj7eveZI56uklVptDEjzxWNPzlKurpJVabAxOvBTtIjyd8yp1uqd2RXDONRhFLfS7mtXBcagfwd8RAU9FabflDkxPBCNJ8eTv4wVtPRSm35eZMTwWNJ8eTv4yldCX02Oa0cM66j7etskRSX02Oa0sDOuo/B3ypHNT0Upu+UOWAngpGk+PJ3xV3VU9BKbvlDkgTwWNJ8eTvirroS+mxzWlgZxqB+cJGpfS7tWtgZ11Uf55yLHNR0Upu+UOTE8FI0nxrv4y7o2nopTcbQ5aJ4qdp9nfJVdCX0u7VpYGddQMDUvpsc1pYGddQMDno6CU3fKHLa8F9T7O+KNp6CU3G0OW14KRpPjXfCV0JfS7tWlgZxqPx7wNS+qx2rSwM4mQJ/wBwcDno6CU3fKHLRPBSNJG+DdbR0Epu+UOTxngCNJ9nKm66E7FVjmtHBddvO3o74hGp2KbHNa2BnXYT/wA2OCOajoJTd8octE8FI0nx5O+DdbR0Upu+UOWAngpGk+PJ3wbroS+mxzWlgZ11X8e8I1OxTY5rSwM66gT/AM94I5qeglN3yhy0TwUjSfHk74Xdep6KU3fKHLRPBSNJ8eTvg3XSnYpsc1pYGddQP4O+Ejydil3NaWBnXUef+HfBHNR0Upu+UOSBPBSNJ8eTvhd16nopTd8octE8FI0nx5O+DddKdimxzWlgZxqPP/DhIxOxTY7VpYC66j7ejvkWOenoJTb8octE8EIiJ8eTvlKyjopTd8ocsBPFI0kbnfIbrpTsU2Oa0sBddR/5g74Er2KbHNaWBnXVR9PWxwsc9PRSm42hywX9V9T7O+BlHRSm75g5aJ4rGk/XfLo6E7FNjmtHDOsyB/GQYnYpsc1rYC41Uf8AYwrnp6KU3G0OWieKkaT7O+N0ZT0UpuNoctrwUjSfZ3xR0J2KXc1pYGddQP494Hk7FLu1a2BnXUD+PeEc1PRSm75Q5aJ4r6nx5O+WpWU9FKbvlDlonisaT7O+KV0p2KbHatHBddV87eveIMTsUu5rSwM66gTt694SOanopTd8ocsBPBY0nx5O+KtZT0kpt+UOWAngvqRGu/jFV0L2KbHatbAXGo/HvIkSvYqdzWrgsNQP4xGo56eklNvyBy0TxX1PjXfLRNPTWm35QxIE8FO0+Nd8B1vqd2RbAXXUD+DhUrfU7lFcFl1UZUBT1Eqt+UMTH6KdpxFTV1EqtNgYnXivqfrvgp1uqdyiuCy6gYqMW6p3KK4LDUfjJVgKuotVvyBi2vFTtP1wVNXUWq02BiYnisaT48nItdC31O5RXBYaj8YRC31O5RXlhqP88ZTQVdVarPkDExPBfU/XfEN1NfVWuz5AxMfqp2nEKZbq2YorgsNvxlqMW6t2KK8sNh+clA19Va7PkDTE8V9T9cisq6y128wxMTxUj/WuEMt1bMUV5YbfjAhbkZiqtLbj8ZfgGvrrXZz5TEwIxnIyvrrW/PlMaDJmBFtrZiqtLDbNUjFtrZiiuCw2zKwVfWWuzmGmJhfvkKivrrXZzDk6wD9cuclKLq2YqrAsNRjBAtRmKhgWGoGazcQSddUfnyn0MznMWsr6y12fIGJ1gYzClW2tmKKwLDUYpEi6tmKhpI1GEga6FrsLhiY0H3+uIekpQEfmDP8AUepy5yu6QWIxKhpI1GXNxIwWIzFQ0sNRmaDShUfmDPoesmYtSlCo5efsPviKUWIWKBpYbDGakQLUZuIaWGuaagkpVHLgn6D1kzkYlCo5cGfQ9TkikFiMxVWlhqMehi21sxUMCw1GSlFX11rcuGn0PU5Iia+utdhfkT/UessTdMtqMxRWBYagZRK21sxVWlhqMiQVfWWuzmGJ1gepyLusr6y12cw0x+q+pyU3TLbWzFFaWGowkQttbMVVwWG2VoVfXWuzmGmJ4j1/vAivrrW/PlMTxHrECrbWzFFaWG2KVi21sxRXlhqMlQNfXWuzmGJieI++Qqa+utdhcNI8wPU5YpRbWzFVaWGwwRK2ozFVeWGoyqJOuqOX5ExMD1iCa+utdnMNOvEffJiEW2tmKqwLDYYKwW1sxVWlhqMiBr6612Fw0+h9/rgqa+utdnMNP9R6yxootRiVVgWGoyolbUZiqtLDUYqjroVH5hpj9R6nJBNdCo/PkTGgyM0otRmKhpYbDLVSLUZiqtJGoyIJKFR+YaY/UZRKUCt+cz6H/MZilFiM3BWBI1H2wJFiMSqtJGoy1RJQqPzBn0Pvkzn6MroWty4adYHqck+oQWIzFVYFhtlzRi2ozFVaSNRkqCroCOXDE6wMmYVKULW5fkT6H3xmKVbEZuKtJG2KiRahbirCRqMKNKFrfnJP9QcmYRKUKjlwxPoesRogsRmKq0sNRlGCxGYqrSRtioNKFRy4M+h98mYMShUfmDMaDESlWxGYqGlhqMtGCxGbirSRtipBV0BH58pj9RjOV9PJQEflymNBjOTeiCxGYqGkjbLUjwsRmKhpI2xSDSgI/LlMaDJnK708lAR+XKY0GM5N0gsRmKhpI2y1I8LEZioaSNsUg0oCPz5TGgyZyu9PJQEflymNBjOTeiCxGYqGkjbLUj//2Q%3D%3D') repeat-x #0C0D10;
                                    }
                                    
                                    #{@params.code_css}
                                    
                                    .source_code {
                                        font-size: 0.7em;
                                        line-height: 1em;
                                    }
                                    
                                    .slide pre.source_code {color: #252519;}
                                    .slide pre.source_code a {color: #444;}
                                    
                                    </style>
                                </head>
                                <body>
                                    <div id="impress">
                                        #{@params.impress_html}
                                    </div>
                                    <script>
                                    </script>
                                    <script>
                                    /**
                                     * impress.js
                                     *
                                     * impress.js is a presentation tool based on the power of CSS3 transforms and transitions
                                     * in modern browsers and inspired by the idea behind prezi.com.
                                     *
                                     *
                                     * Copyright 2011-2012 Bartek Szopka (@bartaz)
                                     *
                                     * Released under the MIT and GPL Licenses.
                                     *
                                     * ------------------------------------------------
                                     *  author:  Bartek Szopka
                                     *  version: 0.5.3
                                     *  url:     http://bartaz.github.com/impress.js/
                                     *  source:  http://github.com/bartaz/impress.js/
                                     */
                                    
                                    /*jshint bitwise:true, curly:true, eqeqeq:true, forin:true, latedef:true, newcap:true,
                                             noarg:true, noempty:true, undef:true, strict:true, browser:true */
                                    
                                    // You are one of those who like to know how thing work inside?
                                    // Let me show you the cogs that make impress.js run...
                                    (function ( document, window ) {
                                        'use strict';
                                        
                                        // HELPER FUNCTIONS
                                        
                                        // `pfx` is a function that takes a standard CSS property name as a parameter
                                        // and returns it's prefixed version valid for current browser it runs in.
                                        // The code is heavily inspired by Modernizr http://www.modernizr.com/
                                        var pfx = (function () {
                                            
                                            var style = document.createElement('dummy').style,
                                                prefixes = 'Webkit Moz O ms Khtml'.split(' '),
                                                memory = {};
                                            
                                            return function ( prop ) {
                                                if ( typeof memory[ prop ] === "undefined" ) {
                                                    
                                                    var ucProp  = prop.charAt(0).toUpperCase() + prop.substr(1),
                                                        props   = (prop + ' ' + prefixes.join(ucProp + ' ') + ucProp).split(' ');
                                                    
                                                    memory[ prop ] = null;
                                                    for ( var i in props ) {
                                                        if ( style[ props[i] ] !== undefined ) {
                                                            memory[ prop ] = props[i];
                                                            break;
                                                        }
                                                    }
                                                
                                                }
                                                
                                                return memory[ prop ];
                                            };
                                        
                                        })();
                                        
                                        // `arraify` takes an array-like object and turns it into real Array
                                        // to make all the Array.prototype goodness available.
                                        var arrayify = function ( a ) {
                                            return [].slice.call( a );
                                        };
                                        
                                        // `css` function applies the styles given in `props` object to the element
                                        // given as `el`. It runs all property names through `pfx` function to make
                                        // sure proper prefixed version of the property is used.
                                        var css = function ( el, props ) {
                                            var key, pkey;
                                            for ( key in props ) {
                                                if ( props.hasOwnProperty(key) ) {
                                                    pkey = pfx(key);
                                                    if ( pkey !== null ) {
                                                        el.style[pkey] = props[key];
                                                    }
                                                }
                                            }
                                            return el;
                                        };
                                        
                                        // `toNumber` takes a value given as `numeric` parameter and tries to turn
                                        // it into a number. If it is not possible it returns 0 (or other value
                                        // given as `fallback`).
                                        var toNumber = function (numeric, fallback) {
                                            return isNaN(numeric) ? (fallback || 0) : Number(numeric);
                                        };
                                        
                                        // `byId` returns element with given `id` - you probably have guessed that ;)
                                        var byId = function ( id ) {
                                            return document.getElementById(id);
                                        };
                                        
                                        // `$` returns first element for given CSS `selector` in the `context` of
                                        // the given element or whole document.
                                        var $ = function ( selector, context ) {
                                            context = context || document;
                                            return context.querySelector(selector);
                                        };
                                        
                                        // `$$` return an array of elements for given CSS `selector` in the `context` of
                                        // the given element or whole document.
                                        var $$ = function ( selector, context ) {
                                            context = context || document;
                                            return arrayify( context.querySelectorAll(selector) );
                                        };
                                        
                                        // `triggerEvent` builds a custom DOM event with given `eventName` and `detail` data
                                        // and triggers it on element given as `el`.
                                        var triggerEvent = function (el, eventName, detail) {
                                            var event = document.createEvent("CustomEvent");
                                            event.initCustomEvent(eventName, true, true, detail);
                                            el.dispatchEvent(event);
                                        };
                                        
                                        // `translate` builds a translate transform string for given data.
                                        var translate = function ( t ) {
                                            return " translate3d(" + t.x + "px," + t.y + "px," + t.z + "px) ";
                                        };
                                        
                                        // `rotate` builds a rotate transform string for given data.
                                        // By default the rotations are in X Y Z order that can be reverted by passing `true`
                                        // as second parameter.
                                        var rotate = function ( r, revert ) {
                                            var rX = " rotateX(" + r.x + "deg) ",
                                                rY = " rotateY(" + r.y + "deg) ",
                                                rZ = " rotateZ(" + r.z + "deg) ";
                                            
                                            return revert ? rZ+rY+rX : rX+rY+rZ;
                                        };
                                        
                                        // `scale` builds a scale transform string for given data.
                                        var scale = function ( s ) {
                                            return " scale(" + s + ") ";
                                        };
                                        
                                        // `perspective` builds a perspective transform string for given data.
                                        var perspective = function ( p ) {
                                            return " perspective(" + p + "px) ";
                                        };
                                        
                                        // `getElementFromHash` returns an element located by id from hash part of
                                        // window location.
                                        var getElementFromHash = function () {
                                            // get id from url # by removing `#` or `#/` from the beginning,
                                            // so both "fallback" `#slide-id` and "enhanced" `#/slide-id` will work
                                            return byId( window.location.hash.replace(/^#\\/?/,"") );
                                        };
                                        
                                        // `computeWindowScale` counts the scale factor between window size and size
                                        // defined for the presentation in the config.
                                        var computeWindowScale = function ( config ) {
                                            var hScale = window.innerHeight / config.height,
                                                wScale = window.innerWidth / config.width,
                                                scale = hScale > wScale ? wScale : hScale;
                                            
                                            if (config.maxScale && scale > config.maxScale) {
                                                scale = config.maxScale;
                                            }
                                            
                                            if (config.minScale && scale < config.minScale) {
                                                scale = config.minScale;
                                            }
                                            
                                            return scale;
                                        };
                                        
                                        // CHECK SUPPORT
                                        var body = document.body;
                                        
                                        var ua = navigator.userAgent.toLowerCase();
                                        var impressSupported = 
                                                              // browser should support CSS 3D transtorms 
                                                               ( pfx("perspective") !== null ) &&
                                                               
                                                              // and `classList` and `dataset` APIs
                                                               ( body.classList ) &&
                                                               ( body.dataset ) &&
                                                               
                                                              // but some mobile devices need to be blacklisted,
                                                              // because their CSS 3D support or hardware is not
                                                              // good enough to run impress.js properly, sorry...
                                                               ( ua.search(/(iphone)|(ipod)|(android)/) === -1 );
                                        
                                        if (!impressSupported) {
                                            // we can't be sure that `classList` is supported
                                            body.className += " impress-not-supported ";
                                        } else {
                                            body.classList.remove("impress-not-supported");
                                            body.classList.add("impress-supported");
                                        }
                                        
                                        // GLOBALS AND DEFAULTS
                                        
                                        // This is were the root elements of all impress.js instances will be kept.
                                        // Yes, this means you can have more than one instance on a page, but I'm not
                                        // sure if it makes any sense in practice ;)
                                        var roots = {};
                                        
                                        // some default config values.
                                        var defaults = {
                                            width: 1024,
                                            height: 768,
                                            maxScale: 1,
                                            minScale: 0,
                                            
                                            perspective: 1000,
                                            
                                            transitionDuration: 1000
                                        };
                                        
                                        // it's just an empty function ... and a useless comment.
                                        var empty = function () { return false; };
                                        
                                        // IMPRESS.JS API
                                        
                                        // And that's where interesting things will start to happen.
                                        // It's the core `impress` function that returns the impress.js API
                                        // for a presentation based on the element with given id ('impress'
                                        // by default).
                                        var impress = window.impress = function ( rootId ) {
                                            
                                            // If impress.js is not supported by the browser return a dummy API
                                            // it may not be a perfect solution but we return early and avoid
                                            // running code that may use features not implemented in the browser.
                                            if (!impressSupported) {
                                                return {
                                                    init: empty,
                                                    goto: empty,
                                                    prev: empty,
                                                    next: empty
                                                };
                                            }
                                            
                                            rootId = rootId || "impress";
                                            
                                            // if given root is already initialized just return the API
                                            if (roots["impress-root-" + rootId]) {
                                                return roots["impress-root-" + rootId];
                                            }
                                            
                                            // data of all presentation steps
                                            var stepsData = {};
                                            
                                            // element of currently active step
                                            var activeStep = null;
                                            
                                            // current state (position, rotation and scale) of the presentation
                                            var currentState = null;
                                            
                                            // array of step elements
                                            var steps = null;
                                            
                                            // configuration options
                                            var config = null;
                                            
                                            // scale factor of the browser window
                                            var windowScale = null;        
                                            
                                            // root presentation elements
                                            var root = byId( rootId );
                                            var canvas = document.createElement("div");
                                            
                                            var initialized = false;
                                            
                                            // STEP EVENTS
                                            //
                                            // There are currently two step events triggered by impress.js
                                            // `impress:stepenter` is triggered when the step is shown on the 
                                            // screen (the transition from the previous one is finished) and
                                            // `impress:stepleave` is triggered when the step is left (the
                                            // transition to next step just starts).
                                            
                                            // reference to last entered step
                                            var lastEntered = null;
                                            
                                            // `onStepEnter` is called whenever the step element is entered
                                            // but the event is triggered only if the step is different than
                                            // last entered step.
                                            var onStepEnter = function (step) {
                                                if (lastEntered !== step) {
                                                    triggerEvent(step, "impress:stepenter");
                                                    lastEntered = step;
                                                }
                                            };
                                            
                                            // `onStepLeave` is called whenever the step element is left
                                            // but the event is triggered only if the step is the same as
                                            // last entered step.
                                            var onStepLeave = function (step) {
                                                if (lastEntered === step) {
                                                    triggerEvent(step, "impress:stepleave");
                                                    lastEntered = null;
                                                }
                                            };
                                            
                                            // `initStep` initializes given step element by reading data from its
                                            // data attributes and setting correct styles.
                                            var initStep = function ( el, idx ) {
                                                var data = el.dataset,
                                                    step = {
                                                        translate: {
                                                            x: toNumber(data.x),
                                                            y: toNumber(data.y),
                                                            z: toNumber(data.z)
                                                        },
                                                        rotate: {
                                                            x: toNumber(data.rotateX),
                                                            y: toNumber(data.rotateY),
                                                            z: toNumber(data.rotateZ || data.rotate)
                                                        },
                                                        scale: toNumber(data.scale, 1),
                                                        el: el
                                                    };
                                                
                                                if ( !el.id ) {
                                                    el.id = "step-" + (idx + 1);
                                                }
                                                
                                                stepsData["impress-" + el.id] = step;
                                                
                                                css(el, {
                                                    position: "absolute",
                                                    transform: "translate(-50%,-50%)" +
                                                               translate(step.translate) +
                                                               rotate(step.rotate) +
                                                               scale(step.scale),
                                                    transformStyle: "preserve-3d"
                                                });
                                            };
                                            
                                            // `init` API function that initializes (and runs) the presentation.
                                            var init = function () {
                                                if (initialized) { return; }
                                                
                                                // First we set up the viewport for mobile devices.
                                                // For some reason iPad goes nuts when it is not done properly.
                                                var meta = $("meta[name='viewport']") || document.createElement("meta");
                                                meta.content = "width=device-width, minimum-scale=1, maximum-scale=1, user-scalable=no";
                                                if (meta.parentNode !== document.head) {
                                                    meta.name = 'viewport';
                                                    document.head.appendChild(meta);
                                                }
                                                
                                                // initialize configuration object
                                                var rootData = root.dataset;
                                                config = {
                                                    width: toNumber( rootData.width, defaults.width ),
                                                    height: toNumber( rootData.height, defaults.height ),
                                                    maxScale: toNumber( rootData.maxScale, defaults.maxScale ),
                                                    minScale: toNumber( rootData.minScale, defaults.minScale ),                
                                                    perspective: toNumber( rootData.perspective, defaults.perspective ),
                                                    transitionDuration: toNumber( rootData.transitionDuration, defaults.transitionDuration )
                                                };
                                                
                                                windowScale = computeWindowScale( config );
                                                
                                                // wrap steps with "canvas" element
                                                arrayify( root.childNodes ).forEach(function ( el ) {
                                                    canvas.appendChild( el );
                                                });
                                                root.appendChild(canvas);
                                                
                                                // set initial styles
                                                document.documentElement.style.height = "100%";
                                                
                                                css(body, {
                                                    height: "100%",
                                                    overflow: "hidden"
                                                });
                                                
                                                var rootStyles = {
                                                    position: "absolute",
                                                    transformOrigin: "top left",
                                                    transition: "all 0s ease-in-out",
                                                    transformStyle: "preserve-3d"
                                                };
                                                
                                                css(root, rootStyles);
                                                css(root, {
                                                    top: "50%",
                                                    left: "50%",
                                                    transform: perspective( config.perspective/windowScale ) + scale( windowScale )
                                                });
                                                css(canvas, rootStyles);
                                                
                                                body.classList.remove("impress-disabled");
                                                body.classList.add("impress-enabled");
                                                
                                                // get and init steps
                                                steps = $$(".step", root);
                                                steps.forEach( initStep );
                                                
                                                // set a default initial state of the canvas
                                                currentState = {
                                                    translate: { x: 0, y: 0, z: 0 },
                                                    rotate:    { x: 0, y: 0, z: 0 },
                                                    scale:     1
                                                };
                                                
                                                initialized = true;
                                                
                                                triggerEvent(root, "impress:init", { api: roots[ "impress-root-" + rootId ] });
                                            };
                                            
                                            // `getStep` is a helper function that returns a step element defined by parameter.
                                            // If a number is given, step with index given by the number is returned, if a string
                                            // is given step element with such id is returned, if DOM element is given it is returned
                                            // if it is a correct step element.
                                            var getStep = function ( step ) {
                                                if (typeof step === "number") {
                                                    step = step < 0 ? steps[ steps.length + step] : steps[ step ];
                                                } else if (typeof step === "string") {
                                                    step = byId(step);
                                                }
                                                return (step && step.id && stepsData["impress-" + step.id]) ? step : null;
                                            };
                                            
                                            // used to reset timeout for `impress:stepenter` event
                                            var stepEnterTimeout = null;
                                            
                                            // `goto` API function that moves to step given with `el` parameter (by index, id or element),
                                            // with a transition `duration` optionally given as second parameter.
                                            var goto = function ( el, duration ) {
                                                
                                                if ( !initialized || !(el = getStep(el)) ) {
                                                    // presentation not initialized or given element is not a step
                                                    return false;
                                                }
                                                
                                                // Sometimes it's possible to trigger focus on first link with some keyboard action.
                                                // Browser in such a case tries to scroll the page to make this element visible
                                                // (even that body overflow is set to hidden) and it breaks our careful positioning.
                                                //
                                                // So, as a lousy (and lazy) workaround we will make the page scroll back to the top
                                                // whenever slide is selected
                                                //
                                                // If you are reading this and know any better way to handle it, I'll be glad to hear about it!
                                                window.scrollTo(0, 0);
                                                
                                                var step = stepsData["impress-" + el.id];
                                                
                                                if ( activeStep ) {
                                                    activeStep.classList.remove("active");
                                                    body.classList.remove("impress-on-" + activeStep.id);
                                                }
                                                el.classList.add("active");
                                                
                                                body.classList.add("impress-on-" + el.id);
                                                
                                                // compute target state of the canvas based on given step
                                                var target = {
                                                    rotate: {
                                                        x: -step.rotate.x,
                                                        y: -step.rotate.y,
                                                        z: -step.rotate.z
                                                    },
                                                    translate: {
                                                        x: -step.translate.x,
                                                        y: -step.translate.y,
                                                        z: -step.translate.z
                                                    },
                                                    scale: 1 / step.scale
                                                };
                                                
                                                // Check if the transition is zooming in or not.
                                                //
                                                // This information is used to alter the transition style:
                                                // when we are zooming in - we start with move and rotate transition
                                                // and the scaling is delayed, but when we are zooming out we start
                                                // with scaling down and move and rotation are delayed.
                                                var zoomin = target.scale >= currentState.scale;
                                                
                                                duration = toNumber(duration, config.transitionDuration);
                                                var delay = (duration / 2);
                                                
                                                // if the same step is re-selected, force computing window scaling,
                                                // because it is likely to be caused by window resize
                                                if (el === activeStep) {
                                                    windowScale = computeWindowScale(config);
                                                }
                                                
                                                var targetScale = target.scale * windowScale;
                                                
                                                // trigger leave of currently active element (if it's not the same step again)
                                                if (activeStep && activeStep !== el) {
                                                    onStepLeave(activeStep);
                                                }
                                                
                                                // Now we alter transforms of `root` and `canvas` to trigger transitions.
                                                //
                                                // And here is why there are two elements: `root` and `canvas` - they are
                                                // being animated separately:
                                                // `root` is used for scaling and `canvas` for translate and rotations.
                                                // Transitions on them are triggered with different delays (to make
                                                // visually nice and 'natural' looking transitions), so we need to know
                                                // that both of them are finished.
                                                css(root, {
                                                    // to keep the perspective look similar for different scales
                                                    // we need to 'scale' the perspective, too
                                                    transform: perspective( config.perspective / targetScale ) + scale( targetScale ),
                                                    transitionDuration: duration + "ms",
                                                    transitionDelay: (zoomin ? delay : 0) + "ms"
                                                });
                                                
                                                css(canvas, {
                                                    transform: rotate(target.rotate, true) + translate(target.translate),
                                                    transitionDuration: duration + "ms",
                                                    transitionDelay: (zoomin ? 0 : delay) + "ms"
                                                });
                                                
                                                // Here is a tricky part...
                                                //
                                                // If there is no change in scale or no change in rotation and translation, it means there was actually
                                                // no delay - because there was no transition on `root` or `canvas` elements.
                                                // We want to trigger `impress:stepenter` event in the correct moment, so here we compare the current
                                                // and target values to check if delay should be taken into account.
                                                //
                                                // I know that this `if` statement looks scary, but it's pretty simple when you know what is going on
                                                // - it's simply comparing all the values.
                                                if ( currentState.scale === target.scale ||
                                                    (currentState.rotate.x === target.rotate.x && currentState.rotate.y === target.rotate.y &&
                                                     currentState.rotate.z === target.rotate.z && currentState.translate.x === target.translate.x &&
                                                     currentState.translate.y === target.translate.y && currentState.translate.z === target.translate.z) ) {
                                                    delay = 0;
                                                }
                                                
                                                // store current state
                                                currentState = target;
                                                activeStep = el;
                                                
                                                // And here is where we trigger `impress:stepenter` event.
                                                // We simply set up a timeout to fire it taking transition duration (and possible delay) into account.
                                                //
                                                // I really wanted to make it in more elegant way. The `transitionend` event seemed to be the best way
                                                // to do it, but the fact that I'm using transitions on two separate elements and that the `transitionend`
                                                // event is only triggered when there was a transition (change in the values) caused some bugs and 
                                                // made the code really complicated, cause I had to handle all the conditions separately. And it still
                                                // needed a `setTimeout` fallback for the situations when there is no transition at all.
                                                // So I decided that I'd rather make the code simpler than use shiny new `transitionend`.
                                                //
                                                // If you want learn something interesting and see how it was done with `transitionend` go back to
                                                // version 0.5.2 of impress.js: http://github.com/bartaz/impress.js/blob/0.5.2/js/impress.js
                                                window.clearTimeout(stepEnterTimeout);
                                                stepEnterTimeout = window.setTimeout(function() {
                                                    onStepEnter(activeStep);
                                                }, duration + delay);
                                                
                                                return el;
                                            };
                                            
                                            // `prev` API function goes to previous step (in document order)
                                            var prev = function () {
                                                var prev = steps.indexOf( activeStep ) - 1;
                                                prev = prev >= 0 ? steps[ prev ] : steps[ steps.length-1 ];
                                                
                                                return goto(prev);
                                            };
                                            
                                            // `next` API function goes to next step (in document order)
                                            var next = function () {
                                                var next = steps.indexOf( activeStep ) + 1;
                                                next = next < steps.length ? steps[ next ] : steps[ 0 ];
                                                
                                                return goto(next);
                                            };
                                            
                                            // Adding some useful classes to step elements.
                                            //
                                            // All the steps that have not been shown yet are given `future` class.
                                            // When the step is entered the `future` class is removed and the `present`
                                            // class is given. When the step is left `present` class is replaced with
                                            // `past` class.
                                            //
                                            // So every step element is always in one of three possible states:
                                            // `future`, `present` and `past`.
                                            //
                                            // There classes can be used in CSS to style different types of steps.
                                            // For example the `present` class can be used to trigger some custom
                                            // animations when step is shown.
                                            root.addEventListener("impress:init", function(){
                                                // STEP CLASSES
                                                steps.forEach(function (step) {
                                                    step.classList.add("future");
                                                });
                                                
                                                root.addEventListener("impress:stepenter", function (event) {
                                                    event.target.classList.remove("past");
                                                    event.target.classList.remove("future");
                                                    event.target.classList.add("present");
                                                }, false);
                                                
                                                root.addEventListener("impress:stepleave", function (event) {
                                                    event.target.classList.remove("present");
                                                    event.target.classList.add("past");
                                                }, false);
                                                
                                            }, false);
                                            
                                            // Adding hash change support.
                                            root.addEventListener("impress:init", function(){
                                                
                                                // last hash detected
                                                var lastHash = "";
                                                
                                                // `#/step-id` is used instead of `#step-id` to prevent default browser
                                                // scrolling to element in hash.
                                                //
                                                // And it has to be set after animation finishes, because in Chrome it
                                                // makes transtion laggy.
                                                // BUG: http://code.google.com/p/chromium/issues/detail?id=62820
                                                root.addEventListener("impress:stepenter", function (event) {
                                                    window.location.hash = lastHash = "#/" + event.target.id;
                                                }, false);
                                                
                                                window.addEventListener("hashchange", function () {
                                                    // When the step is entered hash in the location is updated
                                                    // (just few lines above from here), so the hash change is 
                                                    // triggered and we would call `goto` again on the same element.
                                                    //
                                                    // To avoid this we store last entered hash and compare.
                                                    if (window.location.hash !== lastHash) {
                                                        goto( getElementFromHash() );
                                                    }
                                                }, false);
                                                
                                                // START 
                                                // by selecting step defined in url or first step of the presentation
                                                goto(getElementFromHash() || steps[0], 0);
                                            }, false);
                                            
                                            body.classList.add("impress-disabled");
                                            
                                            // store and return API for given impress.js root element
                                            return (roots[ "impress-root-" + rootId ] = {
                                                init: init,
                                                goto: goto,
                                                next: next,
                                                prev: prev
                                            });
                                    
                                        };
                                        
                                        // flag that can be used in JS to check if browser have passed the support test
                                        impress.supported = impressSupported;
                                        
                                    })(document, window);
                                    
                                    // NAVIGATION EVENTS
                                    
                                    // As you can see this part is separate from the impress.js core code.
                                    // It's because these navigation actions only need what impress.js provides with
                                    // its simple API.
                                    //
                                    // In future I think about moving it to make them optional, move to separate files
                                    // and treat more like a 'plugins'.
                                    (function ( document, window ) {
                                        'use strict';
                                        
                                        // throttling function calls, by Remy Sharp
                                        // http://remysharp.com/2010/07/21/throttling-function-calls/
                                        var throttle = function (fn, delay) {
                                            var timer = null;
                                            return function () {
                                                var context = this, args = arguments;
                                                clearTimeout(timer);
                                                timer = setTimeout(function () {
                                                    fn.apply(context, args);
                                                }, delay);
                                            };
                                        };
                                        
                                        // wait for impress.js to be initialized
                                        document.addEventListener("impress:init", function (event) {
                                            // Getting API from event data.
                                            // So you don't event need to know what is the id of the root element
                                            // or anything. `impress:init` event data gives you everything you 
                                            // need to control the presentation that was just initialized.
                                            var api = event.detail.api;
                                            
                                            // KEYBOARD NAVIGATION HANDLERS
                                            
                                            // Prevent default keydown action when one of supported key is pressed.
                                            document.addEventListener("keydown", function ( event ) {
                                                if ( event.keyCode === 9 || ( event.keyCode >= 32 && event.keyCode <= 34 ) || (event.keyCode >= 37 && event.keyCode <= 40) ) {
                                                    event.preventDefault();
                                                }
                                            }, false);
                                            
                                            // Trigger impress action (next or prev) on keyup.
                                            
                                            // Supported keys are:
                                            // [space] - quite common in presentation software to move forward
                                            // [up] [right] / [down] [left] - again common and natural addition,
                                            // [pgdown] / [pgup] - often triggered by remote controllers,
                                            // [tab] - this one is quite controversial, but the reason it ended up on
                                            //   this list is quite an interesting story... Remember that strange part
                                            //   in the impress.js code where window is scrolled to 0,0 on every presentation
                                            //   step, because sometimes browser scrolls viewport because of the focused element?
                                            //   Well, the [tab] key by default navigates around focusable elements, so clicking
                                            //   it very often caused scrolling to focused element and breaking impress.js
                                            //   positioning. I didn't want to just prevent this default action, so I used [tab]
                                            //   as another way to moving to next step... And yes, I know that for the sake of
                                            //   consistency I should add [shift+tab] as opposite action...
                                            document.addEventListener("keyup", function ( event ) {
                                                if ( event.keyCode === 9 || ( event.keyCode >= 32 && event.keyCode <= 34 ) || (event.keyCode >= 37 && event.keyCode <= 40) ) {
                                                    switch( event.keyCode ) {
                                                        case 33: // pg up
                                                        case 37: // left
                                                        case 38: // up
                                                                 api.prev();
                                                                 break;
                                                        case 9:  // tab
                                                        case 32: // space
                                                        case 34: // pg down
                                                        case 39: // right
                                                        case 40: // down
                                                                 api.next();
                                                                 break;
                                                    }
                                                    
                                                    event.preventDefault();
                                                }
                                            }, false);
                                            
                                            // delegated handler for clicking on the links to presentation steps
                                            document.addEventListener("click", function ( event ) {
                                                // event delegation with "bubbling"
                                                // check if event target (or any of its parents is a link)
                                                var target = event.target;
                                                while ( (target.tagName !== "A") &&
                                                        (target !== document.documentElement) ) {
                                                    target = target.parentNode;
                                                }
                                                
                                                if ( target.tagName === "A" ) {
                                                    var href = target.getAttribute("href");
                                                    
                                                    // if it's a link to presentation step, target this step
                                                    if ( href && href[0] === '#' ) {
                                                        target = document.getElementById( href.slice(1) );
                                                    }
                                                }
                                                
                                                if ( api.goto(target) ) {
                                                    event.stopImmediatePropagation();
                                                    event.preventDefault();
                                                }
                                            }, false);
                                            
                                            // delegated handler for clicking on step elements
                                            document.addEventListener("click", function ( event ) {
                                                var target = event.target;
                                                // find closest step element that is not active
                                                while ( !(target.classList.contains("step") && !target.classList.contains("active")) &&
                                                        (target !== document.documentElement) ) {
                                                    target = target.parentNode;
                                                }
                                                
                                                if ( api.goto(target) ) {
                                                    event.preventDefault();
                                                }
                                            }, false);
                                            
                                            // touch handler to detect taps on the left and right side of the screen
                                            // based on awesome work of @hakimel: https://github.com/hakimel/reveal.js
                                            document.addEventListener("touchstart", function ( event ) {
                                                if (event.touches.length === 1) {
                                                    var x = event.touches[0].clientX,
                                                        width = window.innerWidth * 0.3,
                                                        result = null;
                                                        
                                                    if ( x < width ) {
                                                        result = api.prev();
                                                    } else if ( x > window.innerWidth - width ) {
                                                        result = api.next();
                                                    }
                                                    
                                                    if (result) {
                                                        event.preventDefault();
                                                    }
                                                }
                                            }, false);
                                            
                                            // rescale presentation when window is resized
                                            window.addEventListener("resize", throttle(function () {
                                                // force going to active step again, to trigger rescaling
                                                api.goto( document.querySelector(".active"), 500 );
                                            }, 250), false);
                                            
                                        }, false);
                                            
                                    })(document, window);
                                    
                                    // THAT'S ALL FOLKS!
                                    //
                                    // Thanks for reading it all.
                                    // Or thanks for scrolling down and reading the last part.
                                    //
                                    // I've learnt a lot when building impress.js and I hope this code and comments
                                    // will help somebody learn at least some part of it.
                                    </script>
                                    <script>impress().init();</script>
                                </body>
                                </html>
                                """
                                
                        return new Chocokup.Panel({where, impress_html, css:returns.defaults.css, code_css:Highlight.defaultCodeCSS}, impress_kup).render()
                                
                    else
                        kup = ->
                            iterate = (note, level) ->
                                if (title = note.title)[0] is '$'
                                    for own uuid, sub of note.subs
                                        iterate sub, level + 1
                                    return
                                    
                                switch level
                                    when 0
                                        for own uuid, sub of note.subs
                                            iterate sub, level + 1
                                    when 1
                                        div class:'slide transitionSlide', id:'id_' + note.uuid, ->
                                            section class:'middle', ->
                                                h2 note.title_compacted
                                                img ->
                                                text note.html_title_content if note.html_title_content?
                                                    
                                        for own uuid, sub of note.subs
                                            iterate sub, level + 1
                                    when 2
                                        div class:'slide', id:'id_' + note.uuid, style:'overflow-y:auto', ->
                                            header html5:yes, ->
                                                h1 note.title_compacted
                                            section ->
                                                text note.html_title_content if note.html_title_content?
                                                if note.subs.length > 0 
                                                    size = Math.max 30 - 4 * (level+1), 10
                                                    ul class:'bullets', style:"font-size:#{size}pt",  -> for own uuid, sub of note.subs
                                                        iterate sub, level + 1
                                    else
                                        li -> 
                                            text note.html_title
                                            if note.subs.length > 0 
                                                size = Math.max 30 - 4 * (level+1), 10
                                                ul style:"font-size:#{size}pt", -> for own uuid, sub of note.subs
                                                    iterate sub, level + 1
                                                    
                            iterate @params.note, 0
                            
                        slides_html = new Chocokup.Panel(note:result, kup).render()
                        
                        slides_kup = ->
                            text """
                              <html>
                              <head>
                                <meta charset="utf-8" />
                                <meta http-equiv="X-UA-Compatible" content="IE=Edge;chrome=1" />
                                <title>#{@params.where}</title>
                                <link href="http://fonts.googleapis.com/css?family=Droid+Sans|Droid+Sans+Mono" rel="stylesheet" type="text/css" />
                                <link id="prettify-link" href="http://slides.html5rocks.com/src/prettify/prettify.css" rel="stylesheet" disabled />
                                <link href="http://slides.html5rocks.com/css/moon.css" class="theme" rel="stylesheet" />
                                <link href="http://slides.html5rocks.com/css/sand.css" class="theme" rel="stylesheet" />
                                <link href="http://slides.html5rocks.com/css/sea_wave.css" class="theme" rel="stylesheet" />
                                <link href="http://slides.html5rocks.com/css/default.css" class="theme" rel="stylesheet" media="screen"  />
                                <link href="http://slides.html5rocks.com/css/common.css" rel="stylesheet" media="screen" />
                                <style>
                                  .slide li, .slide p {
                                    font-size: 28px;
                                    line-height: 1em;
                                  }
                                  .slide li {
                                    list-style-type: disc;
                                  }
                                  .slide pre {
                                    margin: 0.5em 0;
                                    font-family: 'Droid Sans Mono';
                                    font-size: 20px;
                                  }
                            
                                  .slide code {
                                    font-family: 'Droid Sans Mono';
                                    font-size: 90%;
                                  }
                                </style>
                              </head>
                              <body>
                                <nav id="helpers">
                                  <button title="Previous slide" id="nav-prev" class="nav-prev">←</button> 
                                  <button title="Jump to a random slide" id="slide-no">5</button> 
                                  <button title="Next slide" id="nav-next" class="nav-next">→</button>
                                  <menu>
                                    <button type="checkbox" data-command="toc" title="Table of Contents" class="toc">TOC</button>
                                    <!-- <button type="checkbox" data-command="resources" title="View Related Resources">?</button> -->
                                    <button type="checkbox" data-command="notes" title="View Slide Notes">✏</button>
                                    <button type="checkbox" data-command="source" title="View slide source">↻</button>
                                    <button type="checkbox" data-command="help" title="View Help">?</button>
                                  </menu>
                                </nav>
                                <div class="presentation">
                                  <div id="presentation-counter">Loading...</div>
                                  <div class="slides">
                                    <div class="slide" id="landing-slide">
                                      <style>
                                        #landing-slide p {
                                          font-size: 35px;
                                        }
                                        p#disclaimer-message {
                                          font-size: 20px;
                                        }
                                      </style>
                                      <section class="middle">
                                        <p>This presentation is an HTML5 website</p>
                                        <p>Press <span id="left-init-key" class="key">&rarr;</span> key to advance.</p>
                                        <p id="disclaimer-message">Having issues seeing the presentation? Read the <a href="http://slides.html5rocks.com/disclaimer.html">disclaimer</a></p>
                                      </section>
                                      <aside class="note">
                                        <section>
                                          Welcome! (This field is for presenter notes and commentary.)
                                        </section>
                                      </aside> 
                                    </div>
                                    <div class="slide" id="controls-slide">
                                      <header>Slides controls</header>
                                      <style>
                                        #controls-slide li, #controls-slide p {
                                          font-size: 32px;
                                        }
                                        #controls-slide .key {
                                          bottom: 2px;
                                        }
                                      </style>
                                      <section>
                                        <ul>
                                          <li><span class="key">&larr;</span> and <span class="key">&rarr;</span> to move around.</li>
                                          <li><span class="key">Ctrl/Command</span> and <span class="key">+</span> or <span class="key">-</span> to zoom in and out if slides don’t fit.</li>
                                          <li><span class="key">S</span> to view page source.</li>
                                          <li><span class="key">T</span> to change the theme.</li>
                                          <li><span class="key">H</span> to toggle syntax highlight.</li>
                                          <li><span class="key">N</span> to toggle speaker notes.</li>
                                          <li><span class="key">3</span> to toggle 3D effect.</li>
                                          <li><span class="key">0</span> to toggle help.</li>
                                        </ul>
                                      </section>
                                    </div>
                                    <div class="slide" id="table-of-contents">
                                      <header><h1>Today, we will cover...</h1></header>
                                      <style>
                                        #toc-list > li {
                                          font-size: 26px;
                                          line-height: 33px;
                                          opacity: 0.85;
                                        }
                                        #toc-list > li:hover {
                                          opacity: 1;
                                        }
                                        #toc-list a {
                                          border-bottom: 0;
                                        }
                                        #toc-list a:hover{
                                          border-bottom: 2px solid #3f3f3f;
                                        }
                                        #toc-list img {
                                          vertical-align: middle;
                                          margin-left: 15px;
                                        }
                                      </style>
                                      <section>
                                        <ul id="toc-list">
                                        </ul>
                                      </section>
                                    </div>
                                    #{@params.slides_html}
                            
                                  </div> <!-- slides -->
                                  <div id="speaker-note" class="invisible" style="display: none;">
                                  </div> <!-- speaker note -->
                                  <aside id="help" class="sidebar invisible" style="display: hidden;">
                                    <table>
                                      <caption>Help</caption>
                                      <tbody>
                                        <tr>
                                          <th>Move Around</th>
                                          <td>&larr;&nbsp;&rarr;</td>
                                        </tr>
                                        <tr>
                                          <th>Source File</th>
                                          <td>s</td>
                                        </tr>
                                        <tr>
                                          <th>Change Theme</th>
                                          <td>t</td>
                                        </tr>
                                        <tr>
                                          <th>Syntax Highlight</th>
                                          <td>h</td>
                                        </tr>
                                        <tr>
                                          <th>Speaker Notes</th>
                                          <td>n</td>
                                        </tr>
                                        <tr>
                                          <th>Toggle 3D</th>
                                          <td>3</td>
                                        </tr>
                                        <tr>
                                          <th>Help</th>
                                          <td>0</td>
                                        </tr>
                                      </tbody>
                                    </table>
                                  </aside>
                                </div> <!-- presentation -->
                            
                                <!--[if lt IE 9]>
                                <script 
                                  src="http://ajax.googleapis.com/ajax/libs/chrome-frame/1/CFInstall.min.js">
                                </script>
                                <script>CFInstall.check({ mode: "overlay" });</script>
                                <![endif]-->
                            
                                <script src="http://slides.html5rocks.com/src/prettify/prettify.js" onload="prettyPrint();" defer></script>
                                <script src="http://slides.html5rocks.com/js/utils.js"></script>
                              </body>
                            </html>
                            """
                            
                        return new Chocokup.Panel({where, slides_html}, slides_kup).render()
        
        return
        
_module = window ? module
_module[if _module.exports? then "exports" else "Newnotes"] = Newnotes
