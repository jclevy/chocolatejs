# **Docco** is a quick-and-dirty, hundred-line-long, literate-programming-style
# documentation generator. It produces HTML that displays your comments
# alongside your code. Comments are passed through
# [Markdown](http://daringfireball.net/projects/markdown/syntax), and code is
# passed through [Highlight](https://github.com/isagalaev/highlight.js) syntax highlighting.
# This page is the result of running Docco against its own source file.
# This version was modified to be used on demand. It will not produce any file.
#
# The [source for Docco](http://github.com/jashkenas/docco) is available on GitHub,
# and released under the MIT license.
#
# The [source for Doccolate](http://github.com/jclevy/doccolate) is available on GitHub,
# and released under the MIT license.
#

#### Main Documentation Generation Functions
Highlight = require './highlight'
Chocodown = require './chocodown'

# **Path** utility function to extract file extention via `extname` and file name via `basename` 
path =
    extname: (path) ->
        items = path.split('.')
        result = items[-1..][0]
        return if items.length > 1 then '.' + result else result
    basename: (path) ->
        items = path.split('/')
        return items[-1..][0]

# Suported languages
languages =
  '.coffee':
    name: 'coffeescript', symbol: '#', symbol_close: ''
  '.js':
    name: 'javascript', symbol: '//', symbol_close: ''
  '.css':
    name: 'css', symbol: '/* ', symbol_close: ' */'
  '.rb':
    name: 'ruby', symbol: '#', symbol_close: ''
  '.py':
    name: 'python', symbol: '#', symbol_close: ''
  '.markdown':
    name: 'markdown', symbol: '', symbol_close: ''
  '.md':
    name: 'markdown', symbol: '', symbol_close: ''

for ext, l of languages

  # Does the line begin with a comment?
  l.comment_matcher = new RegExp('^\\s*' + l.symbol.replace('*', '\\*') + '\\s?')

  # Ignore [hashbangs](http://en.wikipedia.org/wiki/Shebang_(Unix))
  # and interpolations... and # immediately followed by a letter or a digit
  l.comment_filter = new RegExp('(^#![/]|^\\s*#[\\{|\\w])')

  # The dividing token we feed into Highlight, to delimit the boundaries between
  # sections.
  l.divider_text = '\n' + l.symbol + 'DIVIDER' + l.symbol_close + '\n'

  # The mirror of `divider_text` that we expect Highlight to return. We can split
  # on this to recover the original sections.
  # Note: the class is "c" for Python and "c1" for the other languages
  l.divider_html = new RegExp('\\n*<span class="comment">' + l.symbol.replace('*', '\\*') + 'DIVIDER' + l.symbol_close.replace('*', '\\*') + '<\\/span>\\n*')
  
get_language = (source) -> languages[path.extname(source)]

# Given a string of source code, parse out each comment and the code that
# follows it, and create an individual **section** for it.
# Sections take the form:
#
#     {
#       docs_text: ...
#       docs_html: ...
#       code_text: ...
#       code_html: ...
#     }
#
parse = (source, code) ->
  language = get_language source
  
  lines    = code.split '\n'
  sections = []
  has_code = docs_text = code_text = ''

  save = (docs, code) ->
    sections.push docs_text: docs, code_text: code

  for line in lines
    if line.match(language.comment_matcher) and not line.match(language.comment_filter)
      if has_code
        save docs_text, code_text
        has_code = docs_text = code_text = ''
      docs_text += line.replace(language.comment_matcher, '') + '\n'
    else
      has_code = yes
      code_text += line + '\n'
  save docs_text, code_text
  sections

# The start of each Highlight highlighted block.
highlight_start = '<div class="highlight"><pre>'

# The end of each Highlight highlighted block.
highlight_end   = '</pre></div>'

# Once all of the code is finished highlighting, we can generate the HTML file
# and write out the documentation. Pass the completed sections into the template
generate_html = (source, sections) ->
    title = path.basename source
    doc_min_width = '450px'
    doc_max_width = '450px'
    code_width = '100%'
            
    html  = docco_template { title, sections, css_class:options.css_class, style:options.default_style, doc_min_width, doc_max_width, code_width }
  
# Highlights a single chunk of language code, using **Highlight**,
# and runs the text of its corresponding comment through **Markdown**, using the
# **Github-flavored-Markdown** modification of [Showdown.js](http://attacklab.net/showdown/).
#
# We process the entire file in a single call to Highlight by inserting little
# marker comments between each section and then splitting the result string
# wherever our markers occur.
highlight = (source, sections) ->
    language = get_language source
    
    code = (section.code_text for section in sections).join(language.divider_text)
    result = Highlight.highlight(language.name, code).value
    fragments = result.split language.divider_html
    for section, i in sections
        section.code_html = highlight_start + fragments[i] + highlight_end
        section.docs_html = new Chocodown.converter().makeHtml section.docs_text    

# Generate the documentation for a source file by reading it in, splitting it
# up into comment/code sections, highlighting them for the appropriate language,
# and merging them into an HTML template.
generate = (source, code) ->
    switch path.extname(source)
        when '.txt'
            html = '<pre>' + code + '</pre>'
        when '.markdown', '.md'
            html = new Chocodown.converter().makeHtml code
        else
            sections = parse source, code
            hihilighted = highlight source, sections
            html = generate_html source, sections
    
options =
    css_class: 'dl-s-default'
    default_style: """
        .dl-s-default {color: #252519;}
        .dl-s-default a {color: #444;}
        
        .dl-s-default .keyword {color: #954121;}
        .dl-s-default .comment {color: #a50;}
        .dl-s-default .number {color: #164;}
        .dl-s-default .literal {color: sienna;}
        .dl-s-default .string {color: #219161;}
        .dl-s-default .regexp {color: #f50;}
        .dl-s-default .function {color: #30a;}
        .dl-s-default .title {color: #00c;}
        .dl-s-default .params {color: #a0a;}
        .dl-s-default .variable {color: #19469D;}
        .dl-s-default .property {color: #19469D;}
        .dl-s-default .error {color: red;}
    
        .dl-s-default .tag {color: #170;}
        .dl-s-default .id {color: #085;}
        .dl-s-default .class {color: #05a;}
        .dl-s-default .at_rule {color: #f50;}
        .dl-s-default .attr_selector {color: black;}
        .dl-s-default .pseudo {color: black;}
        .dl-s-default .rules {color: black;}
        .dl-s-default .value {color: black;}
        .dl-s-default .hexcolor {color: black;}
        .dl-s-default .important {color: black;}
        """


Doccolate = { generate, options }
_module = window ? module
_module.exports = Doccolate
_module.Doccolate = Doccolate if window?

# Micro-templating, originally by John Resig, borrowed by way of
# [Underscore.js](http://documentcloud.github.com/underscore/).
template = (str) ->
  new Function 'obj',
    'var p=[],print=function(){p.push.apply(p,arguments);};' +
    'with(obj){p.push(\'' +
    str.replace(/[\r\t\n]/g, " ")
       .replace(/'(?=[^<]*%>)/g,"\t")
       .split("'").join("\\'")
       .split("\t").join("'")
       .replace(/<%=(.+?)%>/g, "',$1,'")
       .split('<%').join("');")
       .split('%>').join("p.push('") +
       "');}return p.join('');"
       
# Create the template that we will use to generate the Docco HTML page.
docco_template = template """
  <style>
    <%= style %>

    /*--------------------- Layout and Typography ----------------------------*/

    #docco_container {
      font-family: "Palatino Linotype", "Book Antiqua", Palatino, FreeSerif, serif;
      color: #252519;
    
      position: absolute;
      top: 0;
      left: 0;
    }
    
    #docco_container p {
      margin: 0 0 15px 0;
    }
    
    #docco_container h1, 
    #docco_container h2, 
    #docco_container h3, 
    #docco_container h4, 
    #docco_container h5, 
    #docco_container h6 {
      margin: 0px 0 15px 0;
    }

    
    #docco_container h1 {
      margin-top: 40px;
    }

    #docco_background {
      position: absolute;
      top: 0; left: 525px; right: 0; bottom: 0;
      background: #f5f5ff;
      border-left: 1px solid #e5e5ee;
      z-index: -1;
    }
    
      td.docco_docs, th.docco_docs {
        max-width: <%= doc_max_width %>;
        min-width: <%= doc_min_width %>;
        min-height: 5px;
        padding: 0px 25px 1px 50px;
        overflow-x: hidden;
        vertical-align: top;
        text-align: left;
        font-family: "Palatino Linotype", "Book Antiqua", Palatino, FreeSerif, serif;
        font-size: 15px;
        line-height: 20px;
      }
        .docco_docs pre {
          margin: 15px 0 15px;
          padding-left: 15px;
          color: darkSlateGray;
          font-size: 12px;
          line-height: 15px;
        }
        .docco_docs tt, .docco_docs code {
          background: #f8f8ff;
          border: 1px solid #dedede;
          padding: 0 0.2em;
          display: inline-block;
        }
        .docco_docs p tt, .docco_docs p code {
          font-size: 12px;
        }
        .docco_pilwrap {
          position: relative;
        }
          .docco_pilcrow {
            font: 12px Arial;
            text-decoration: none;
            color: #454545;
            position: absolute;
            top: 3px; left: -20px;
            padding: 1px 2px;
            opacity: 0;
            -webkit-transition: opacity 0.2s linear;
          }
            td.docco_docs:hover .docco_pilcrow {
              opacity: 1;
            }
      td.docco_code, th.docco_code {
        padding: 0px 15px 16px 25px;
        width: <%= code_width %>;
        vertical-align: top;
        background: #f5f5ff;
        border-left: 1px solid #e5e5ee;     
      }
        #.docco_container pre, #.docco_container tt, #.docco_container code {
          font-size: 12px; line-height: 18px;
          font-family: Menlo, Monaco, Consolas, "Lucida Console", monospace;
          margin: 0; padding: 0;
        }
  </style>
        
  <div id="docco_container" class="<%= css_class %>">
    <div id="docco_background"></div>
    <table cellpadding="0" cellspacing="0">
      <% if (title != '') { %>
        <thead>
          <tr>
            <th class="docco_docs">
              <h1>
                <%= title %>
              </h1>
            </th>
            <th class="docco_code">
            </th>
          </tr>
        </thead>
      <% } %>
      <tbody>
        <% for (var i=0, l=sections.length; i<l; i++) { %>
          <% var section = sections[i]; %>
          <tr id="docco_section-<%= i + 1 %>">
            <td class="docco_docs">
              <div class="docco_pilwrap">
                <a class="docco_pilcrow" href="#docco_section-<%= i + 1 %>">&#182;</a>
              </div>
              <%= section.docs_html %>
            </td>
            <td class="docco_code">
              <%= section.code_html %>
            </td>
          </tr>
        <% } %>
      </tbody>
    </table>
  </div>
"""