Coffeekup = require './coffeekup'

class Chocokup
    constructor: (@params, @content) ->
        if @content is undefined
            @content = @params
            @params = undefined
    head_template: ->
        text "#{@body}"
    body_template: ->
        text "#{@content}"
    @helpers:
        verify : (args...) ->
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
            id_class:id_class, attributes:attributes, content:content

        panel : ->
            { id_class, attributes, content } = verify arguments...
                
            switch @proportion
                when 'half', 'third', 'half-served'
                    if @orientation is 'vertical'
                        new_id_class = """space.#{@proportion}.vertical"""
                        switch @panel_index
                            when 1
                                new_id_class += '.top'
                            when 2
                                new_id_class += if @proportion in ['half', 'half-served'] then '.bottom' else '.middle'
                            when 3
                                new_id_class += '.bottom'
                    else
                        new_id_class = """space.#{@proportion}.horizontal"""
                        switch @panel_index
                            when 1
                                new_id_class += '.left'
                            when 2
                                new_id_class += if @proportion in ['half', 'half-served'] then '.right' else '.center'
                            when 3
                                new_id_class += '.right'
                            
                when 'served'
                    if @orientation is 'vertical'
                        new_id_class = 'space.service.vertical'
                        switch @panel_index 
                            when 1
                                new_id_class += '.top'
                            when 2
                                new_id_class += '.served.center'
                            when 3
                                new_id_class += '.bottom'
                    else
                        new_id_class = 'space.service.horizontal'
                        switch @panel_index 
                            when 1
                                new_id_class += '.left'
                            when 2
                                new_id_class += '.served.center'
                            when 3
                                new_id_class += '.right'
                else new_id_class = 'space'
                
            panel_index_keep = @panel_index
            proportion_keep = @proportion
            orientation_keep = @orientation
            
            @panel_index = 1
            @panel_infos ?= []
            @panel_infos.push {} 
            
            @proportion = 'none'
            @orientation = 'none'
            
            if attributes?
                if attributes.coverage then new_id_class += (if new_id_class isnt '' then '.' else '') + 'screen-' + attributes.coverage 
                @proportion = attributes.proportion if attributes.proportion?
                @orientation = attributes.orientation if attributes.orientation?
                delete attributes.proportion
                delete attributes.orientation
                delete attributes.coverage
                
            id_class = new_id_class + (if id_class isnt '' then '.' else '') + id_class

            flush = -> 
                if (panel_info = @panel_infos[@panel_infos.length - 1]).footer_kept?
                    {id_class, attributes, content} = panel_info.footer_kept ; panel id_class, attributes, content ; panel_info.footer_kept = undefined

            content_ = if typeof content is "function" then => content.apply @ ; flush.apply @ else content
            
            if proportion_keep isnt 'none' and @proportion is 'none'
                div id_class, -> div 'space', attributes, content_
            else
                div id_class, attributes, content_
            
            @panel_index = panel_index_keep + 1
            @proportion = proportion_keep
            @orientation = orientation_keep

            @panel_infos.pop()
        box : ->
            { id_class, attributes, content } = verify arguments...
            
            id_class = 'frame' + (if id_class isnt '' then '.' else '') + id_class
            panel id_class, attributes, -> panel 'sizer', content

        header : ->
            { id_class, attributes, content } = verify arguments...
            
            if attributes?.html5? then tag 'header', arguments...
            else
                panel_info = @panel_infos[@panel_infos.length - 1]
                panel_info.hasHeader = true
                id_class = 'header' + (if id_class isnt '' then '.' else '') + id_class
                if attributes?.by?
                    id_class += '.by-' + attributes.by
                    panel_info.header_by = attributes.by
                panel id_class, attributes, content

        footer : ->
            { id_class, attributes, content } = verify arguments...
            
            if attributes?.html5? then tag 'footer', arguments...
            else
                panel_info = @panel_infos[@panel_infos.length - 1]
                panel_info.hasFooter = true
                id_class = 'footer' + (if id_class isnt '' then '.' else '') + id_class
                if attributes?.by?
                    id_class += '.by-' + attributes.by
                    panel_info.footer_by = attributes.by
                panel_info.footer_kept = {id_class, attributes, content}

        body : ->
            { id_class, attributes, content } = verify arguments...
            
            if @panel_infos?.length > 0
                new_id_class = 'body'
                panel_info = @panel_infos[@panel_infos.length - 1]
                if panel_info.hasHeader isnt true then new_id_class += '.no-header'
                if panel_info.hasFooter isnt true then new_id_class += '.no-footer'
                if count = panel_info.header_by then new_id_class += ".with-#{count}-headers"
                if count = panel_info.footer_by then new_id_class += ".with-#{count}-footers"
                id_class = new_id_class + (if id_class isnt '' then '.' else '') + id_class
                                
                panel id_class, attributes, content
            else
                @main_body_done = true
                tag 'body', arguments...

        title : ->
            { id_class, attributes, content } = verify arguments...

            if @main_body_done?
                attributes ?= {}
                attributes.style = (attributes.style ? '') + 'text-align:center;'
                h3 id_class, attributes, content
            else
                tag 'title', arguments...

    render: (options) ->
        locals = options?.locals ? {}
        locals = { locals } if Object.prototype.toString.apply(locals) isnt '[object Object]'
        locals.backdoor_key = options?.backdoor_key
        format = options?.format ? true
        content_html = Coffeekup.render @content, panel_index : 1, webcontrol_index : 0, proportion : 'none', orientation : 'none', hardcode : Chocokup.helpers, params : @params, format : format, locals : locals
        body_html = Coffeekup.render @body_template, content : content_html, title : @title, panel_index : 1, proportion : 'none', orientation : 'none', hardcode : Chocokup.helpers, params : @params, format : format, locals : locals
        head_html = Coffeekup.render @head_template,  body :  body_html, title : @title, panel_index : 1, proportion : 'none', orientation : 'none', hardcode : Chocokup.helpers, params : @params, format : format, locals : locals
        if head_html is undefined then 'None' else '' + head_html

class Chocokup.Document extends Chocokup
    constructor: (@title, @params, @content) -> super @params, @content
    head_template: ->
        doctype 5
        html manifest:"#{@params?.manifest or ''}", -> 
            head -> 
                title "#{@title or 'Untitled'}"
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
                style '''
                      html, body {
                        margin:0;
                        padding:0;
                        overflow: hidden;
                        height: 100%;
                      }
                                    
                      .space {
                        position: absolute;
                        left: 0;
                        top: 0;
                        right: 0;
                        bottom: 0;
                        width: auto;
                        height: auto;
                        overflow: hidden;
                      }
                      .hidden {
                        display:none;
                      }
                      .screen-95 {
                        left: 5%;
                        top: 2%;
                        width: 90%;
                        height: 96%;
                      }
                      .screen-90 {
                        left: 10%;
                        top: 4%;
                        width: 80%;
                        height: 92%;
                      }
                      .screen-85 {
                        left: 15%;
                        top: 6%;
                        width: 70%;
                        height: 88%;
                      }
                      .screen-80 {
                        left: 20%;
                        top: 8%;
                        width: 60%;
                        height: 84%;
                      }
                      .top {
                        top: 0;
                        bottom: auto;
                      }
                      .third.vertical.middle {
                        top: 33.33%;
                      }
                      .bottom {
                        top: auto;
                        bottom: 0;
                      }
                      .left {
                        left: 0;
                        right: auto;
                      }
                      .third.horizontal.center {
                        left: 33.33%;
                      }
                      .right {
                        left: auto;
                        right: 0;
                      }
                      .half.horizontal {
                        width: 50%;
                      }
                      .half.vertical {
                        height: 50%;
                      }
                      .half-served.horizontal.left {
                        width: 80%;
                      }
                      .half-served.vertical.top {
                        height: 80%;
                      }
                      .half-served.horizontal.right {
                        width: 20%;
                      }
                      .half-served.vertical.bottom {
                        height: 20%;
                      }
                      .third.horizontal {
                        width: 33.33%;
                      }
                      .third.vertical {
                        height: 33.33%;
                      }
                      .service.horizontal {
                        width: 20%;
                      }
                      .fullscreen > .service.horizontal {
                        width: 0%;
                      }
                      .service.vertical {
                        height: 20%;
                      }
                      .fullscreen > .service.vertical {
                        height: 0%;
                      }
                      .served.horizontal {
                        left: 20%;
                        width: 60%;
                        right: 20%;
                      }
                      .fullscreen > .served.horizontal {
                        left: 0%;
                        width: 100%;
                        right: 0%;
                      }
                      .served.vertical {
                        top: 20%;
                        height: 60%;
                        bottom: 20%;
                      }
                      .fullscreen > .served.vertical {
                        top: 0%;
                        height: 100%;
                        bottom: 0%;
                      }
                      .fullscreen.shrink {
                        width: 0%;
                        height: 0%;
                      }
                      .shrink.horizontal {
                        width: 0%;
                      }
                      .shrink.vertical {
                        height: 0%;
                      }
                      .fullscreen.expand {
                        width: 100%;
                        height: 100%;
                      }
                      .expand.horizontal {
                        width: 100%;
                      }
                      .expand.vertical {
                        height: 100%;
                      }
                      .source-code {
                        white-space: pre;
                      }
                      .float-left {
                        float: left;
                        margin-left: 10px;
                      }
                      .float-right {
                        float: right;
                        margin-right: 10px;
                      }
                      .header {
                        position: absolute;
                        height:32px;
                        width:100%;
                        overflow:hidden;
                        top: 0px;
                        bottom: auto;
                        text-align:center;
                        line-height: 32px;
                        /*
                        background:#ddd;
                        border-bottom:solid 1px #666;
                        */
                      }
                      .body {
                        overflow:auto;
                        -webkit-overflow-scrolling:touch;
                        top:32px;
                        bottom:32px;
                        position:absolute;
                      }
                      .footer {
                        position: absolute;
                        height:32px;
                        width:100%;
                        overflow:hidden;
                        top: auto;
                        bottom: 0px;
                        text-align:center;
                        line-height: 32px;
                        /*
                        background:#ddd;
                        border-top:solid 1px #666;
                        */
                      }
                      .no-header {
                        top:0px;
                      }
                      .no-footer {
                        bottom:0px;
                      }
                      .header.by-bootstrap, .footer.by-bootstrap {
                        height:40px;
                        line-height: inherit;
                        margin: 0;
                        padding: 0;
                      }
                      .header.by-2, .footer.by-2 {
                        height:64px;
                      }
                      .header.by-3, .footer.by-3 {
                        height:96px;
                      }
                      .header.by-4, .footer.by-4 {
                        height:128px;
                      }
                      .header.by-5, .footer.by-5 {
                        height:160px;
                      }
                      .header.by-10, .footer.by-10 {
                        height:320px;
                      }
                      .with-bootstrap-headers {
                        top:40px;
                      }
                      .with-2-headers {
                        top:64px;
                      }
                      .with-3-headers {
                        top:96px;
                      }
                      .with-4-headers {
                        top:128px;
                      }
                      .with-5-headers {
                        top:160px;
                      }
                      .with-10-headers {
                        top:320px;
                      }
                      .with-bootstrap-footers {
                        bottom:40px;
                      }
                      .with-2-footers {
                        bottom:64px;
                      }
                      .with-3-footers {
                        bottom:96px;
                      }
                      .with-4-footers {
                        bottom:128px;
                      }
                      .with-5-footers {
                        bottom:160px;
                      }
                      .with-10-footers {
                        bottom:320px;
                      }
                      .inline {
                        position:relative;
                      }
                      .scroll * {
                        overflow: auto;
                        -webkit-overflow-scrolling:touch;
                      }
                      .no-scroll * {
                        overflow: hidden;
                      }
                      * html .body {
                        position: fixed;
                        height: 100%;
                        width: 100%;
                      }
                '''
                
            text "#{@body}"
                
    body_template: ->
            text "#{@content}"

class Chocokup.Panel extends Chocokup
    constructor: (@params, @content) ->
        super @params, @content
        @params = {} unless @params?

class Chocokup.Css
    @prefix = (css) -> (css.replace(/-\?-/g, p) for p in ['-webkit-', '-moz-', '-o-', '-ms-', '']).join '\n'

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
_module.exports = Chocokup
_module.Chocokup = Chocokup if window?
