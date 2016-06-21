# Chocokup

Coffeekup = require './coffeekup'
_ = require './chocodash'

class Chocokup
    constructor: (@params, @content) ->
        if @content is undefined
            @content = @params
            @params = undefined
    head_template: ->
        text "#{@__.body()}"
    body_template: ->
        text "#{@__.content()}"
        
    @helpers: class
        __verify : (args...) ->
            attributes = content = null
            id_class = ''
            for a in args
                switch typeof a
                    when 'function'
                        content = a
                    when 'object'
                        attributes = a
                    when 'number', 'boolean'
                        content = a
                    when 'string'
                        if args.length is 1
                            content = a
                        else
                            if a is args[0]
                                id_class = a
                            else
                                content = a 
    
            # return verified arguments
            {id_class, attributes, content}
                
        css : (param) ->
            compile = (rules, helpers) ->
                result = ''
                helpers ?= {}
            
                for own selector, pairs of rules
                    declarations = ''
                    nested = {}
                    
                    if selector.substr(0,6) is '@media'
                        result += "#{selector} {\n#{compile pairs, helpers}}\n"
                        continue
                
                    if typeof pairs is 'function'
                        helpers[selector] = pairs
                        continue
            
                    expand = (what, key, value) ->
                        if helpers[key]?
                            subs = helpers[key] value
                            delete what[key]
                            for k, v of subs
                                if k isnt key and helpers[k]?
                                    expand subs, k, v
                            for k, v of subs
                                what[k] = v
            
                    for own key, value of pairs
                        expand pairs, key, value
            
                    for own key, value of pairs
                        if typeof value is 'object'
                            children = []
                            split = key.split /\s*,\s*/
                            children.push "#{selector} #{child}" for child in split
                            nested[children.join ','] = value
                        else
                            key = key.replace /[A-Z]/g, (s) -> '-' + s.toLowerCase()
                            declarations += "  #{key}: #{value};\n"
            
                    declarations and result += "#{selector} {\n#{declarations}}\n"
            
                    result += compile nested, helpers
                    
                result
        
            style switch typeof param
                when 'function' then compile param()
                when 'object' then compile param
                else param.toString()

        panel : ->
            { id_class, attributes, content } = __verify arguments...
            
            new_id_class = 'panel'
            
            switch @__.proportion()
                when 'half', 'third', 'half-served'
                    if @__.orientation() is 'vertical'
                        new_id_class += """.#{@__.proportion()}.vertical"""
                        switch @__.panel_index()
                            when 1
                                new_id_class += '.top'
                            when 2
                                new_id_class += if @__.proportion() in ['half', 'half-served'] then '.bottom' else '.middle'
                            when 3
                                new_id_class += '.bottom'
                    else
                        new_id_class += """.#{@__.proportion()}.horizontal"""
                        switch @__.panel_index()
                            when 1
                                new_id_class += '.left'
                            when 2
                                new_id_class += if @__.proportion() in ['half', 'half-served'] then '.right' else '.center'
                            when 3
                                new_id_class += '.right'
                            
                when 'served'
                    if @__.orientation() is 'vertical'
                        new_id_class += '.service.vertical'
                        switch @__.panel_index() 
                            when 1
                                new_id_class += '.top'
                            when 2
                                new_id_class += '.served.center'
                            when 3
                                new_id_class += '.bottom'
                    else
                        new_id_class += '.service.horizontal'
                        switch @__.panel_index() 
                            when 1
                                new_id_class += '.left'
                            when 2
                                new_id_class += '.served.center'
                            when 3
                                new_id_class += '.right'
                
            panel_index_keep = @__.panel_index()
            proportion_keep = @__.proportion()
            orientation_keep = @__.orientation()

            @__.panel_index 1
            @__.panel_infos ?= []
            @__.panel_infos.push {} 
            
            @__.proportion 'none'
            @__.orientation 'none'
            
            if attributes?
                if attributes.coverage then new_id_class += (if new_id_class isnt '' then '.' else '') + 'screen-' + attributes.coverage 
                @__.proportion attributes.proportion if attributes.proportion?
                @__.orientation attributes.orientation if attributes.orientation?
                delete attributes.proportion
                delete attributes.orientation
                delete attributes.coverage
                
            id_class = new_id_class + (if id_class isnt '' then '.' else '') + id_class

            flush = -> 
                if (panel_info = @__.panel_infos[@__.panel_infos.length - 1]).footer_kept?
                    {id_class, attributes, content} = panel_info.footer_kept ; panel id_class, attributes, content ; panel_info.footer_kept = undefined

            content_ = if typeof content is "function" then => result = content.apply @ ; flush.apply @ ; result else content
            
            div id_class, attributes, content_
            
            @__.panel_index panel_index_keep + 1
            @__.proportion proportion_keep
            @__.orientation orientation_keep

            @__.panel_infos.pop()
            
        box : ->
            { id_class, attributes, content } = __verify arguments...
            
            id_class = 'frame' + (if id_class isnt '' then '.' else '') + id_class
            panel id_class, attributes, -> panel 'sizer', content

        header : ->
            { id_class, attributes, content } = __verify arguments...
            
            if not @__.panel_infos? or @__.panel_infos.length is 0 or attributes?.html5? then tag 'header', arguments...
            else
                panel_info = @__.panel_infos[@__.panel_infos.length - 1]
                panel_info.hasHeader = true
                id_class = 'header' + (if id_class isnt '' then '.' else '') + id_class
                if attributes?.by?
                    id_class += '.by-' + attributes.by
                    panel_info.header_by = attributes.by
                panel id_class, attributes, content

        footer : ->
            { id_class, attributes, content } = __verify arguments...
            
            if not @__.panel_infos? or @__.panel_infos.length is 0 or attributes?.html5? then tag 'footer', arguments...
            else
                panel_info = @__.panel_infos[@__.panel_infos.length - 1]
                panel_info.hasFooter = true
                id_class = 'footer' + (if id_class isnt '' then '.' else '') + id_class
                if attributes?.by?
                    id_class += '.by-' + attributes.by
                    panel_info.footer_by = attributes.by
                panel_info.footer_kept = {id_class, attributes, content}

        body : ->
            { id_class, attributes, content } = __verify arguments...
            
            if @__.panel_infos?.length > 0
                new_id_class = 'body'
                panel_info = @__.panel_infos[@__.panel_infos.length - 1]
                if panel_info.hasHeader isnt true then new_id_class += '.no-header'
                if panel_info.hasFooter isnt true then new_id_class += '.no-footer'
                if count = panel_info.header_by then new_id_class += ".with-#{count}-headers"
                if count = panel_info.footer_by then new_id_class += ".with-#{count}-footers"
                id_class = new_id_class + (if id_class isnt '' then '.' else '') + id_class
                                
                panel id_class, attributes, content
            else
                tag 'body', arguments...
                
    @register: (name, func) ->
        Chocokup.registered_kups ?= {}
        Chocokup.registered_kups[name] = func
        
    @unregister: (name) ->
        delete Chocokup.registered_kups[name] if Chocokup.registered_kups?

    render: (options) ->
        locals = options?.locals ? {}
        if @params?.locals? 
            locals[k] = v for k,v of @params.locals 
            delete @params.locals
        locals = { locals } if Object.prototype.toString.apply(locals) isnt '[object Object]'
        locals.backdoor_key = options?.backdoor_key
        locals.Chocokup = Chocokup
        locals._ = _

        bin = options?.bin ? {}
        if @params?.bin? 
            bin[k] = v for k,v of @params.bin 
            delete @params.bin
        
        __ = do ->
            _panel_index = 1
            panel_index = (val) ->
                if val is undefined then _panel_index else _panel_index = val
            
            _proportion = 'none'
            proportion = (val) ->
                if val is undefined then _proportion else _proportion = val
            
            _main_body_done = false
            main_body_done = (val) ->
                if val is undefined then _main_body_done else _main_body_done = val
            
            _orientation = 'none'
            orientation = (val) ->
                if val is undefined then _orientation else _orientation = val
            
            _title = undefined
            title = (val) ->
                if val is undefined then _title else _title = val
            
            reset = ->
                _panel_index = 1 ; _proportion = 'none' ; _orientation = 'none'
            
            _content = ''
            content = (val) ->
                if val is undefined then _content else (reset() ; _content = val ? '')
            
            _body = ''
            body = (val) ->
                if val is undefined then _body else (reset() ; _body = val ? '')
            
            _head = ''
            head = (val) ->
                if val is undefined then _head else (reset() ; _head = val ? '')
            
            {panel_index, proportion, main_body_done, orientation, title, reset, content, body, head}
            
        
        helpers = new Chocokup.helpers
        for helper_ext in ['helpers', 'kups', 'code']
            if @params?[helper_ext]?
                helpers[k] = v for k,v of @params[helper_ext] 
                delete @params[helper_ext]

        helpers[k] = v for k,v of Chocokup.registered_kups
        
        if @params?['interface']?
            _interface = @params.interface
            delete @params.interface

        if @params?.document?
            document = @params.document
            delete @params.document

        all_tags = options?.all_tags ? true
        format = options?.format ? false
        data = { params:@params, format, all_tags, hardcode:helpers, document, 'interface':_interface, actor:_interface?.actor, locals, bin, __ }
        __.title @title
        __.content Coffeekup.render @content, data
        __.body Coffeekup.render @body_template, data
        __.head Coffeekup.render @head_template, data

class Chocokup.Document extends Chocokup
    constructor: (@title, @params, @content) -> super @params, @content
    head_template: ->
        doctype 5
        html manifest:"#{@params?.manifest or ''}", -> 
            head -> 
                title "#{@__.title() or 'Untitled'}"
                meta 
                    name:"viewport" 
                    content:"user-scalable=no, width=device-width, initial-scale=1.0, maximum-scale=1.0"
                meta
                    name:"viewport" 
                    content:"initial-scale=1.0,user-scalable=no,maximum-scale=1" 
                    media:"(device-height: 568px)"
                meta 
                    name:"apple-mobile-web-app-capable" 
                    content:"yes"
                style """
                    #{Chocokup.Css[@params?.theme ? "reset"]}
                    #{Chocokup.Css.core}
                    """
                ie 'lt IE 9', ->
                    script src:"/static/lib/html5shiv.js", type:"text/javascript", charset:"utf-8"

            text "#{@__.body()}"
                
    body_template: ->
            text "#{@__.content()}"

class Chocokup.Html extends Chocokup
    constructor: (@params, @content) ->
        super @params, @content
        @params = {} unless @params?

Chocokup.Panel = Chocokup.Html

class Chocokup.App extends Chocokup.Document
    
    @manifest = 
        cache : """
        /static/lib/coffee-script.js
        /static/lib/chocodash.js
        /static/lib/litejq.js
        /static/lib/locco.js
        """
        
    body_template: ->
        script src:"/static/lib/coffee-script.js", type:"text/javascript", charset:"utf-8" if @params?.with_coffee
        script src:"/static/lib/chocodash.js", type:"text/javascript", charset:"utf-8"
        script src:"/static/lib/litejq.js", type:"text/javascript", charset:"utf-8"
        script src:"/static/lib/locco.js", type:"text/javascript", charset:"utf-8"
       
        text "#{@__.content()}"
        
Chocokup.Kups =
    Tablet: ->
        style """
        .chocoblack {background-color: #241A15;border: 1px solid #080401;-webkit-box-shadow: inset 0 0 15px #080401;-moz-box-shadow: inset 0 0 15px #080401;-o-box-shadow: inset 0 0 15px #080401;box-shadow: inset 0 0 15px #080401;}
        .chocomilk {background-color:rgb(245, 242, 232);border: 2px solid rgba(255, 204, 0, 0.3);color: rgb(92, 75, 66);}
        .frame.chocomilk.round {-webkit-box-shadow: inset 0 0 20px #080401;-moz-box-shadow: inset 0 0 20px #080401;-o-box-shadow: inset 0 0 20px #080401;box-shadow: inset 0 0 20px #080401;} 
        """
        
        panel "#.chocoblack", proportion:'third', ->
            panel ->
                panel proportion:'third', orientation: 'vertical', ->
                    panel -> box "#.chocoblack", ""
                    panel -> box "#.chocoblack", ""
                    panel -> box "#.chocoblack", ""
            panel ->
                panel proportion:'third', orientation: 'vertical', ->
                    panel -> box "#.chocoblack", ""
                    panel ->
                        box "#.chocomilk.round", ->
                            table '#.fullscreen.expand', -> 
                                td style:'text-align:center;vertical-align:middle;', -> key()
                    panel -> box "#.chocoblack", ""
            panel ->
                panel proportion:'third', orientation: 'vertical', ->
                    panel -> box "#.chocoblack", ""
                    panel -> box "#.chocoblack", ""
                    panel -> box "#.chocoblack", ""

class Chocokup.Css
    @prefix = (css) -> (css.replace(/-\?-/g, p) for p in ['-webkit-', '-moz-', '-o-', '-ms-', '']).join '\n'

    @reset: """
    /* Eric Meyer's Reset CSS v2.0 - http://cssreset.com */
    html,body,div,span,applet,object,iframe,h1,h2,h3,h4,h5,h6,p,blockquote,pre,a,abbr,acronym,address,big,cite,code,del,dfn,em,img,ins,kbd,q,s,samp,small,strike,strong,sub,sup,tt,var,b,u,i,center,dl,dt,dd,ol,ul,li,fieldset,form,label,legend,table,caption,tbody,tfoot,thead,tr,th,td,article,aside,canvas,details,embed,figure,figcaption,footer,header,hgroup,menu,nav,output,ruby,section,summary,time,mark,audio,video{border:0;font-size:100%;font:inherit;vertical-align:baseline;margin:0;padding:0}article,aside,details,figcaption,figure,footer,header,hgroup,menu,nav,section{display:block}body{line-height:1}ol,ul{list-style:none}blockquote,q{quotes:none}blockquote:before,blockquote:after,q:before,q:after{content:none}table{border-collapse:collapse;border-spacing:0}
    """

    @basic: @reset + """
    /* Paper - chocolatejs.org */
    body{line-height:1.3;margin:8px;}
    h1,h2,h3,h4,h5,h6{font-weight: bold;}h1{font-size: 2em;}h2{font-size: 1.5em;}h3{font-size: 1.17em;}h5{font-size: 0.83em;}h6{font-size: 0.67em;}
    pre{margin:0.25em 0px;padding:0.8em 1.2em;}
    abbr,acronym{border-bottom:.1em dotted;cursor: help;}
    strong, b{font-weight: bold;}
    code,kbd,samp{font-size:smaller;padding:0.2em 0.45em 0.4em;background-color:lightgray;white-space:nowrap;border-radius:0.3em;}
    pre code{white-space:pre;background-color: inherit;padding:0;}
    kbd{display: inline-block;margin:0.25em 0;padding:0.4em 0.3em;}
    em,i{font-style: italic;}
    q {font-style:italic;padding:0 0.25em;}q:before{position:relative;top:0.25em;left:-0.25em;content:"\\201C";font-size:1.25em;}q:after{position:relative;top:0.6em;content:"\\201D";font-size:1.25em;}
    small{font-size:smaller;}
    sub{vertical-align:sub;font-size:smaller;}
    sup{vertical-align:super;font-size:smaller;}
    dt{font-style:normal;font-weight:bold;}
    dd{padding-left:1em;}
    ol{list-style:decimal;padding:0 2.25em;}
    ul{list-style:disc;padding:0 2.25em;}
    """

    @paper: @basic + """
    ul,ol,pre{margin: 12px 0;}
    h1,h2,h3,h4,h5,h6,p{margin: 16px 0;}
    """

    @writer: @paper + """
    /* Writer - chocolatejs.org */
    body{font-family:Georgia, serif;}
    blockquote{font-style:italic;margin:0.25em 0 0.45em;padding:0 1em;}blockquote:before{content:"\\201C";font-size:1.5em;top:-0.2em;}blockquote cite{display:block;font-size:0.85em;}blockquote cite:before{content:"\\2014 \\2009";}blockquote p{display:inline;}
    pre{font-family: inherit;font-size:inherit;}
    ins{border-bottom:solid 2px gray;border-radius:0.5em;padding:0 0.25em;text-decoration:none;}
    """

    @coder: @paper + """
    /* Coder - chocolatejs.org */
    body{font-family: Tahoma;font-size:small;}
    pre{background-color:#F7F7F7;margin:0.25em 0px;padding:0.8em 1.2em;}
    blockquote {border-left:0.4em solid lightgray;font-style:italic;margin:0.25em 0;padding:0.5em 1em;}blockquote cite{display:block;font-size:0.85em;}blockquote cite:before{content:"\\2014 \\2009";}blockquote p{display:inline;}
    """
    
    @core: """
    .panel{bottom:0;height:auto;left:0;overflow:hidden;position:absolute;right:0;top:0;width:auto;}
    .hidden{display:none;}
    .screen-95{height:96%;left:5%;top:2%;width:90%;}
    .screen-90{height:92%;left:10%;top:4%;width:80%;}
    .screen-85{height:88%;left:15%;top:6%;width:70%;}
    .screen-80{height:84%;left:20%;top:8%;width:60%;}
    .row-1 {height:10;}
    .row-2 {height:20%;}
    .row-3 {height:30%;}
    .row-4 {height:40%;}
    .row-5 {height:50%;}
    .row-6 {height:60%;}
    .row-7 {height:70%;}
    .row-8 {height:80%;}
    .row-9 {height:90%;}
    .row-10 {height:100%;}    
    .row.offset-1 {top:10%;margin-left:auto;}
    .row.offset-2 {top:20%;margin-left:auto;}
    .row.offset-3 {top:30%;margin-left:auto;}
    .row.offset-4 {top:40%;margin-left:auto;}
    .row.offset-5 {top:50%;margin-left:auto;}
    .row.offset-6 {top:60%;margin-left:auto;}
    .row.offset-7 {top:70%;margin-left:auto;}
    .row.offset-8 {top:80%;margin-left:auto;}
    .row.offset-9 {top:90%;margin-left:auto;}
    .row.offset-10 {top:100%;left:auto;}    
    .top{bottom:auto;top:0;}
    .third.vertical.middle{top:33.33%;}
    .bottom{bottom:0;top:auto;}
    .left{left:0;right:auto;}
    .third.horizontal.center{left:33.33%;}
    .right{left:auto;right:0;}
    .half.horizontal{width:50%;}
    .half.vertical{height:50%;}
    .half-served.horizontal.left{width:80%;}
    .half-served.vertical.top{height:80%;}
    .half-served.horizontal.right{width:20%;}
    .half-served.vertical.bottom{height:20%;}
    .third.horizontal{width:33.33%;}
    .third.vertical{height:33.33%;}
    .service.horizontal{width:20%;}
    .fullscreen > .service.horizontal{width:0%;}
    .service.vertical{height:20%;}
    .fullscreen > .service.vertical{height:0%;}
    .served.horizontal{left:20%;right:20%;width:60%;}
    .fullscreen > .served.horizontal{left:0%;right:0%;width:100%;}
    .served.vertical{bottom:20%;height:60%;top:20%;}
    .fullscreen > .served.vertical{bottom:0%;height:100%;top:0%;}
    .fullscreen.shrink{height:0%;width:0%;}
    .shrink.horizontal{width:0%;}
    .shrink.vertical{height:0%;}
    .fullscreen.expand{height:100%;width:100%;}
    .expand.horizontal{width:100%;}
    .expand.vertical{height:100%;}
    .source-code{white-space:pre;}
    .float-left{float:left;}
    .float-margin-left{float:left;margin-left:1em;}
    .float-right{float:right;}
    .float-margin-right{float:right;margin-right:1em;}
    .margin-none{margin:0;}
    .margin{margin:1em;}
    .margin-left{margin-left:1em;}
    .margin-right{margin-right:1em;}
    .margin-top{margin-top:1em;}
    .margin-bottom{margin-bottom:1em;}
    .padding-none{padding:0;}
    .padding{padding:1em;}
    .padding-left{padding-left:1em;}
    .padding-right{padding-right:1em;}
    .padding-top{padding-top:1em;}
    .padding-bottom{padding-bottom:1em;}
    .header{bottom:auto;height:2.4em;line-height:2.4em;overflow:hidden;position:absolute;text-align:center;top:0px;width:100%;}
    .body{bottom:2.4em;overflow:auto;position:absolute;top:2.4em;-webkit-overflow-scrolling:touch;}
    .footer{bottom:0px;height:2.4em;line-height:2.4em;overflow:hidden;position:absolute;text-align:center;top:auto;width:100%;}
    .no-header{top:0px;}
    .no-footer{bottom:0px;}
    .header.by-bootstrap, .footer.by-bootstrap{height:40px;line-height:inherit;margin:0;padding:0;}
    .header.by-2, .footer.by-2{height:4.8em;}
    .header.by-3, .footer.by-3{height:7.2em;}
    .header.by-4, .footer.by-4{height:9.6em;}
    .header.by-5, .footer.by-5{height:12em;}
    .header.by-10, .footer.by-10{height:24em;}
    .with-bootstrap-headers{top:40px;}
    .with-2-headers{top:4.8em;}
    .with-3-headers{top:7.2em;}
    .with-4-headers{top:9.6em;}
    .with-5-headers{top:12em;}
    .with-10-headers{top:24em;}
    .with-bootstrap-footers{bottom:40px;}
    .with-2-footers{bottom:4.8em;}
    .with-3-footers{bottom:7.2em;}
    .with-4-footers{bottom:9.6emx;}
    .with-5-footers{bottom:12em;}
    .with-10-footers{bottom:24em;}
    .inline{position:relative;}
    .scroll *{overflow:auto;webkit-overflow-scrolling:touch;}
    .no-scroll *{overflow:hidden;}
    .no-crop {overflow: visible;}

    .row{margin:0 auto;width:960px;overflow:hidden;display:block;}
    .row .row{margin:0 -16px 0 -16px;width:auto;display:inline-block}
    [class^="col-"],[class*=" col-"]{margin:0 16px 0 16px;float:left;display:inline}
    .col-1{width:48px}
    .col-2{width:128px}
    .col-3{width:208px}
    .col-4{width:288px}
    .col-5{width:368px}
    .col-6{width:448px}
    .col-7{width:528px}
    .col-8{width:608px}
    .col-9{width:688px}
    .col-10{width:768px}
    .col-11{width:848px}
    .col-12{width:928px}
    .offset-1{margin-left:96px}
    .offset-2{margin-left:176px}
    .offset-3{margin-left:256px}
    .offset-4{margin-left:336px}
    .offset-5{margin-left:416px}
    .offset-6{margin-left:496px}
    .offset-7{margin-left:576px}
    .offset-8{margin-left:656px}
    .offset-9{margin-left:736px}
    .offset-10{margin-left:816px}
    .offset-11{margin-left:896px}
    .show-phone{display:none !important}
    .show-tablet{display:none !important}
    .show-screen{display:inherit !important}
    .hide-phone{display:inherit !important}
    .hide-tablet{display:inherit !important}
    .hide-screen{display:none !important}

    .row.fluid {width:100%}
    .row.fluid .row{margin:0}
    .row.fluid [class^="col-"],.row.fluid [class*=" col-"]{margin:0}
    .row.fluid .col-1{width:8.333333333333332%}
    .row.fluid .col-2{width:16.666666666666664%}
    .row.fluid .col-3{width:25%}
    .row.fluid .col-4{width:33.33333333333333%}
    .row.fluid .col-5{width:41.66666666666667%}
    .row.fluid .col-6{width:50%}
    .row.fluid .col-7{width:58.333333333333336%}
    .row.fluid .col-8{width:66.66666666666666%}
    .row.fluid .col-9{width:75%}
    .row.fluid .col-10{width:83.33333333333334%}
    .row.fluid .col-11{width:91.66666666666666%}
    .row.fluid .col-12{width:100%}
    .row.fluid .offset-1{margin-left:8.333333333333332%}
    .row.fluid .offset-2{margin-left:16.666666666666664%}
    .row.fluid .offset-3{margin-left:25%}
    .row.fluid .offset-4{margin-left:33.33333333333333%}
    .row.fluid .offset-5{margin-left:41.66666666666667%}
    .row.fluid .offset-6{margin-left:50%}
    .row.fluid .offset-7{margin-left:58.333333333333336%}
    .row.fluid .offset-8{margin-left:66.66666666666666%}
    .row.fluid .offset-9{margin-left:75%}
    .row.fluid .offset-10{margin-left:83.33333333333334%}
    .row.fluid .offset-11{margin-left:91.66666666666666%}
    
    @media only screen and (min-width:1200px){
    .row{width:1200px;}
    .row .row{margin:0 -20px 0 -20px}
    [class^="col-"],[class*=" col-"]{margin:0 20px 0 20px}
    .col-1{width:60px}
    .col-2{width:160px}
    .col-3{width:260px}
    .col-4{width:360px}
    .col-5{width:460px}
    .col-6{width:560px}
    .col-7{width:660px}
    .col-8{width:760px}
    .col-9{width:860px}
    .col-10{width:960px}
    .col-11{width:1060px}
    .col-12{width:1160px}
    .offset-1{margin-left:120px}
    .offset-2{margin-left:220px}
    .offset-3{margin-left:320px}
    .offset-4{margin-left:420px}
    .offset-5{margin-left:520px}
    .offset-6{margin-left:620px}
    .offset-7{margin-left:720px}
    .offset-8{margin-left:820px}
    .offset-9{margin-left:920px}
    .offset-10{margin-left:1020px}
    .offset-11{margin-left:1120px}
    .show-phone{display:none !important}
    .show-tablet{display:none !important}
    .show-screen{display:inherit}
    .hide-phone{display:inherit !important}
    .hide-tablet{display:inherit !important}
    .hide-screen{display:none !important}
    }
    
    @media only screen and (min-width: 768px) and (max-width: 959px){
    .row{width:768px;}
    .row .row{margin:0 -14px 0 -14px}
    [class^="col-"],[class*=" col-"]{margin:0 14px 0 14px}
    .col-1{width:36px}
    .col-2{width:100px}
    .col-3{width:164px}
    .col-4{width:228px}
    .col-5{width:292px}
    .col-6{width:356px}
    .col-7{width:420px}
    .col-8{width:484px}
    .col-9{width:548px}
    .col-10{width:612px}
    .col-11{width:676px}
    .col-12{width:740px}
    .offset-1{margin-left:78px}
    .offset-2{margin-left:142px}
    .offset-3{margin-left:206px}
    .offset-4{margin-left:270px}
    .offset-5{margin-left:334px}
    .offset-6{margin-left:398px}
    .offset-7{margin-left:462px}
    .offset-8{margin-left:526px}
    .offset-9{margin-left:590px}
    .offset-10{margin-left:654px}
    .offset-11{margin-left:718px}
    .show-phone{display:none !important}
    .show-tablet{display:inherit !important}
    .show-screen{display:none !important}
    .hide-phone{display:inherit !important}
    .hide-tablet{display:none !important}
    .hide-screen{display:inherit !important}
    }
    
    @media only screen and (max-width: 767px){
    .row{width:300px;}
    .row .row{margin:0}
    [class^="col-"],[class*=" col-"]{width:300px;margin:10px 0 0 0}
    .offset-1,.offset-2,.offset-3,.offset-4,.offset-5,.offset-6,.offset-7,.offset-8,.offset-9,.offset-10,.offset-11{margin-left:0}
    .show-phone{display:inherit !important}
    .show-tablet{display:none !important}
    .show-screen{display:none !important}
    .hide-phone{display:none !important}
    .hide-tablet{display:inherit !important}
    .hide-screen{display:inherit !important}
    }
    
    @media only screen and (min-width: 480px) and (max-width: 767px){
    .row{margin:0 auto;width:456px}
    .row .row{margin:0;width:auto;display:inline-block}
    [class^="col-"],[class*=" col-"]{margin:10px 0 0 0;width:456px}
    .show-phone,.hide-tablet,.hide-screen{display:inherit !important}
    .show-tablet,.show-screen,.hide-phone{display:none !important}
    }
    """

class Chocokup.Css.Animation

    #
    # Create Animation sample
    #
    # anims = [
    #    {type:'typing', what:'You type http://www.apple.com.', css: 'text-to-appear'}
    #    {type:'typing', what:'and then wait.....', css: 'text-to-appear'}
    #    {type:'fly', what:['message', 'wifi'], css:'on-screen'}
    #    {type:'typing', what:'an Html document should come back.......', css: 'text-to-appear'}
    #    {type:'fly', what:['message-filled', 'back-wifi'], css:'on-screen'}
    #    {type:'typing', what:'after Html parsing...', css: 'text-to-appear'}
    #    {type:'typing', what:'the document is displayed on screen.', css: 'text-to-appear'}
    #    {type:'appear', what:['document'], css: 'on-screen'}
    # ]
    #
    # Chocokup.Css.Animation.create anims, css_class: select:'to_anim', trigger:'animate'
    #
    #   will builds CSS3 defs for simple animations for elements with 'animate' css class
    #
    @create = (anims, css_class) ->
        result = ''
        css_class ?= {}
        css_class.select ?= 'to-anim'
        css_class.trigger ?= 'animate'
        css = []
        delay = 0
        prefix = Chocokup.Css.prefix
        for anim, i in anims
            switch anim.type
                when 'typing'
                    time = 0.15
                    css.push ".#{anim.css ? 'typing'}.text-#{i}.#{css_class.trigger} span {"
                    css.push prefix("    -?-animation: typing #{time * anim.what.length}s steps(#{anim.what.length}, end), blink-caret 0.5s step-end;")
                    css.push prefix("    -?-animation-iteration-count: 1, #{2 * time * anim.what.length};")
                    css.push prefix("    -?-animation-delay: #{delay}s;")
                    css.push prefix("    -?-animation-fill-mode: forwards, none;")
                    css.push '}\n'
                    delay += time * anim.what.length
                when 'fly'
                    time = 4
                    for what in anim.what
                        css.push ".#{anim.type}-" + what + ".#{css_class.trigger} {"
                        css.push prefix("    -?-animation: #{anim.type}-#{what} #{time}s;")
                        css.push prefix("    -?-animation-delay: #{delay}s;")
                        css.push prefix("    -?-animation-fill-mode: forwards;")
                        css.push "    position:relative;"
                        css.push '}\n'
                    delay += time
                when 'open'
                    time = 3
                    for what in anim.what
                        css.push ".#{anim.type}-" + what + ".#{css_class.trigger} {"
                        css.push prefix("    -?-animation: #{anim.type}-#{what} #{time}s;")
                        css.push prefix("    -?-animation-delay: #{delay}s;")
                        css.push prefix("    -?-animation-fill-mode: forwards;")
                        css.push "    position:relative;"
                        css.push '}\n'
                    delay += time
                when 'appear'
                    time = 2.5
                    for what in anim.what
                        css.push ".#{anim.type}-#{what}.#{css_class.trigger} {"
                        css.push prefix("    -?-animation: #{anim.type} #{time}s;")
                        css.push prefix("    -?-animation-delay: #{delay}s;")
                        css.push prefix("    -?-animation-fill-mode: forwards;")
                        css.push '}\n'
                    delay += time
        result += '\n<style>\n' + css.join('\n') + '\n</style>\n'
        
        for anim, i in anims
            if anim.type is 'typing'
                result += "\n<div class='#{css_class.select} text-#{i} #{anim.css}'>" 
                result += "\n    " + anim.what
                result += "\n    <span>&nbsp</span>"
                result += "\n</div>"
        
        result
        
_module = window ? module
_module[if _module.exports? then "exports" else "Chocokup"] = Chocokup
