htmlkup = (html, output_debug) ->
  preserve_ws = [
    'style'
    'script'
    ]

  SINGLETONS = [
    'area'
    'base'
    'br'
    'col'
    'command'
    'embed'
    'hr'
    'img'
    'input'
    'link'
    'meta'
    'param'
    'source'
    ]

  possibles =
    start: ['tag-open', 'doctype', 'predoctype-whitespace', 'predoctype-comment-open', 'text', 'end']
    doctype: ['reset']
    reset: ['tag-open', 'ie-open', 'ie-close', 'comment-open', 'tag-close', 'text', 'end']
    end: []

    'tag-open': ['attr-reset']
    'tag-close': ['reset']
    'tag-ws': ['attr', 'singleton', 'tag-gt']
    'tag-gt': ['cdata', 'reset']
    'singleton': ['reset']

    'attr-reset': ['tag-ws', 'singleton', 'tag-gt']
    'attr': ['tag-ws', 'attr-eq', 'tag-gt', 'singleton']
    'attr-eq': ['attr-value', 'attr-dqt', 'attr-sqt']
    'attr-dqt': ['attr-dvalue']
    'attr-sqt': ['attr-svalue']
    'attr-value': ['tag-ws', 'tag-gt', 'singleton']
    'attr-dvalue': ['attr-cdqt']
    'attr-svalue': ['attr-csqt']
    'attr-cdqt': ['tag-ws', 'tag-gt', 'singleton']
    'attr-csqt': ['tag-ws', 'tag-gt', 'singleton']

    text: ['reset']
    cdata: ['tag-close']

    'ie-open': ['reset']
    'ie-close': ['reset']

    'predoctype-whitespace': ['start']
    'predoctype-comment-open': ['predoctype-comment']
    'predoctype-comment': ['predoctype-comment-close']
    'predoctype-comment-close': ['start']

    'comment-open': ['comment']
    'comment': ['comment-close']
    'comment-close': ['reset']

  detect =
    'start'         : /^/
    'reset'         : /^/
    'doctype'       : /^<!doctype .*?>/i
    'end'           : /^$/

    'tag-open'      : /^<[a-zA-Z]([-_]?[a-zA-Z0-9])*/
    'tag-close'     : /^<\/[a-zA-Z]([-_]?[a-zA-Z0-9])*>/
    'tag-ws'        : /^[ \t\n]+/
    'tag-gt'        : /^>/
    'singleton'     : /^\/>/

    'attr-reset'    : /^/
    'attr'          : /^[a-zA-Z]([-_]?[a-zA-Z0-9])*/
    'attr-eq'       : /^=/
    'attr-dqt'      : /^"/
    'attr-sqt'      : /^'/
    'attr-value'    : /^[a-zA-Z0-9]([-_]?[a-zA-Z0-9])*/
    'attr-dvalue'   : /^[^"]*/
    'attr-svalue'   : /^[^']*/
    'attr-cdqt'     : /^"/
    'attr-csqt'     : /^'/

    'cdata'         : /^(\/\/)?<!\[CDATA\[([^>]|>)*?\/\/]]>/
    'text'          : /^(.|\n)+?($|(?=<[!/a-zA-Z]))/

    'ie-open'       : /^<!(?:--)?\[if.*?\]>/
    'ie-close'      : /^<!\[endif\](?:--)?>/

    'predoctype-whitespace'  : /^[ \t\n]+/
    'predoctype-comment-open'  : /^<!--/
    'predoctype-comment'       : /^(.|\n)*?(?=-->)/
    'predoctype-comment-close' : /^-->/

    'comment-open'  : /^<!--/
    'comment'       : /^(.|\n)*?(?=-->)/
    'comment-close' : /^-->/

  state = 'start'
  last_tag = {name: '', tags: []}
  last_attr = null
  parent_tags = []

  html = html.replace(/\t/g, '  ') # YEAH, GET OUTTA HERE, TABS!
  html = html.replace(/\r/g, "\n") # AND YOU, TOO, CARRIAGE RETURNS!

  initial_whitespace = (html.match /^[ \n]*/)[0]
  initial_indent = initial_whitespace.match(/[ ]*$/)[0]
  initial_whitespace = initial_whitespace.substring(0, initial_whitespace.length - initial_indent.length)
  final_whitespace = (html.match /[ \n]*$/)[0]
  html = html.trim()
  console.error {initial_whitespace, initial_indent, final_whitespace, html} if output_debug

  was_ws = if initial_whitespace.length then true else false
  c = 0
  while state != 'end'
    current = html.substring c

    if ! possibles[state]
      throw new Error "Missing possibles for #{state}"
    nexts = (next for next in possibles[state] when current.match detect[next])
    if ! nexts.length
      throw new Error "At: #{state} (#{JSON.stringify(if current.length > 10 then current.substring(0, 10) + '...' else current)} @#{c}), expected: #{(noun for noun in possibles[state]).join ' '}, found #{(noun for noun, regex of detect when current.match regex).join ' '}"

    next = nexts[0]
    value = (current.match detect[next])[0]
    c += value.length
    console.error {state, next, value} if output_debug

    switch next
      when 'doctype'
        last_tag.tags.push { doctype: value.match(/^<!doctype (.*?)>$/i)[1].toLowerCase() }
      when 'tag-open'
        new_tag = { name: value.substring(1), attrs: {}, tags: [] }
        new_tag.is_singleton = new_tag.name in SINGLETONS
        last_tag.tags.push new_tag
        parent_tags.push last_tag
        console.error 'push: ', parent_tags.length, last_tag if output_debug

        last_tag = new_tag
        last_attr = null
      when 'attr'
        if output_debug and last_attr then console.error {last_attr}
        last_attr = value
      when 'tag-ws'
        if last_attr then last_tag.attrs[last_attr] = true
        last_attr = null
      when 'attr-value', 'attr-dvalue', 'attr-svalue'
        last_tag.attrs[last_attr] = value
        last_attr = null
      when 'tag-gt'
        if last_attr then last_tag.attrs[last_attr] = true
        if last_tag.is_singleton and parent_tags.length
          last_tag = parent_tags.pop()
        console.error 'closing: ', last_tag if output_debug
      when 'singleton', 'tag-close', 'ie-close'
        if parent_tags.length
          last_tag = parent_tags.pop()
        console.error 'pop: ', parent_tags.length, last_tag if output_debug
      when 'text'
        if last_tag.name in preserve_ws
          last_tag.tags.push value
        else
          pre_whitespace = (value.match /^[ \n]*/)[0]
          post_whitespace = (value.match /[ \n]*$/)[0]
          last_tag.tags.push (if pre_whitespace then ' ' else '') + value.trim() + (if post_whitespace then ' ' else '')
      when 'cdata'
        last_tag.tags.push value
      when 'comment', 'predoctype-comment'
        last_tag.tags.push {comment: value}
      when 'ie-open'
        condition = value.match(/^<!(?:--)?\[if(.*?)\]>/)[1].trim()
        new_tag = { name: 'ie', attrs: {}, tags: [], is_singleton: false, ie_condition: condition }
        last_tag.tags.push new_tag
        parent_tags.push last_tag
        console.error 'push: ', parent_tags.length, last_tag if output_debug

        last_tag = new_tag
        last_attr = null

    state = next

  console.error parent_tags.length, last_tag if output_debug
  while parent_tags.length
    last_tag = parent_tags.pop()
  debug last_tag.tags if output_debug
  initial_whitespace + (render last_tag.tags, [initial_indent]).replace(/\n$/, '') + final_whitespace


doctypes =
  'html': 'default'
  'html': '5'
  '<?xml version="1.0" encoding="utf-8" ?>': 'xml'
  'html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"': 'transitional'
  'html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"': 'strict'
  'html PUBLIC "-//W3C//DTD XHTML 1.0 Frameset//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd"': 'frameset'
  '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd"': '1.1',
  'html PUBLIC "-//W3C//DTD XHTML Basic 1.1//EN" "http://www.w3.org/TR/xhtml-basic/xhtml-basic11.dtd"': 'basic'
  'html PUBLIC "-//WAPFORUM//DTD XHTML Mobile 1.2//EN" "http://www.openmobilealliance.org/tech/DTD/xhtml-mobile12.dtd"': 'mobile'
  'html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "ce-html-1.0-transitional.dtd"': 'ce'



render = (tags, indent = [])->
  ret = ''
  for tag in tags
    if typeof tag == 'string'
      str = tag
      if str.trim().length > 0
        if str.match(/[\n]/)
          str = str.replace(/"""/g, '"\\""').replace(/^\n|\n$/g, '')
          ret += "#{indent.join('')}text \"\"\"\n#{str}\n\"\"\""
        else
          ret += "#{indent.join('')}text #{JSON.stringify tag}"
        ret += "\n"
    else if tag.doctype?
      mapped = doctypes[tag.doctype.replace(/\s+/g, ' ')]
      if mapped == '5'
        ret += "doctype 5"
      else
        ret += "doctype #{JSON.stringify (if mapped? then mapped else tag.doctype)}"
      ret += "\n"
    else if tag.comment?
      ret += "#{indent.join('')}comment "
      str = tag.comment.trim()
      if str.match(/\n/)
        indent.push '  '
        str = str.replace(/"""/g, '"\\""').replace(/^\n|\n$/g, '').replace(/\n/g, "\n#{indent.join('')}")
        ret += "\"\"\"\n#{indent.join('')}#{str}\n#{indent.join('')}\"\"\""
        indent.pop()
      else
        ret += JSON.stringify str
      ret += "\n"
    else
      ret += "#{indent.join('')}#{tag.name}"
      extra = []

      if tag.attrs.class
        classes = (cls.trim() for cls in tag.attrs.class.split(" ") when cls.trim() != "")
        extra.push('.' + classes.join("."))

      if tag.attrs.id
        extra.unshift("\##{tag.attrs.id.replace(/^\s*(\S*)\s*$/, "$1")}")
      attrs = []
      if tag.attrs and Object.keys(tag.attrs).length
        for own ak, av of tag.attrs
          if ak in ['class', 'id'] then continue

          if av == true then av = ak
          else if av == false then continue

          if not ak.match /^[a-zA-Z0-9]+$/ then ak = JSON.stringify ak

          if not av.match /^[0-9]+$/ then av = JSON.stringify av
          attrs.push "#{ak}: #{av}"

      added_something = false
      if extra.length
        ret += ' ' + JSON.stringify extra.join("")
        added_something = true

      if tag.ie_condition
        ret += ' ' + JSON.stringify tag.ie_condition
        added_something = true

      if attrs.length
        if added_something then ret += ', '
        else ret += ' '
        ret += attrs.join(', ')
        added_something = true

      if not added_something and tag.tags.length == 0
        ret += "()\n"
      else if tag.tags.length == 0
        ret += "\n"
      else if tag.tags.length == 1 and typeof tag.tags[0] == 'string'
        str = tag.tags[0]
        if str.trim().length > 0
          if added_something then ret += ', '
          else ret += ' '
          if str.match(/\n/)
            indent.push '  '
            str = str.replace(/"""/g, '"\\""').replace(/^\n|\n$/g, '').replace(/\n/g, "\n#{indent.join('')}")
            ret += "\"\"\"\n#{indent.join('')}#{str}\n#{indent.join('')}\"\"\""
            indent.pop()
          else
            ret += JSON.stringify str
          ret += "\n"
      else
        if added_something then ret += ', '
        else ret += ' '
        ret += "->\n"
        indent.push '  '
        ret += render tag.tags, indent if tag.tags.length
        indent.pop()
  ret


debug = (tags, indent = [])->
  for tag in tags
    if typeof tag == 'string'
      console.error "#{indent.join('')}text: #{tag}"
    else if tag.doctype
      mapped = doctypes[tag.doctype.replace(/\s+/g, ' ')]
      console.error "#{indent.join('')}doctype: #{JSON.stringify tag.doctype} => #{JSON.stringify mapped}"
    else if tag.comment
      console.error "#{indent.join('')}comment: #{JSON.stringify tag.comment}"
    else
      console.error "#{indent.join('')}{ name: #{tag.name}"
      indent.push '  '
      if Object.keys(tag.attrs).length
        console.error "#{indent.join('')}attrs: {"
        indent.push '  '
        for own ak, av of tag.attrs
          console.error "#{indent.join('')}#{ak}: #{JSON.stringify av}"
        console.error "#{indent.join('')}}"
        indent.pop()
      if tag.ie_condition
        console.error "#{indent.join('')}ie_condition: #{JSON.stringify tag.ie_condition}"
      console.error "#{indent.join('')}tags:"
      indent.push '  '
      debug tag.tags, indent if tag.tags.length
      console.error "#{indent.join('')}}"
      indent.pop()
      console.error "#{indent.join('')}}"
      indent.pop()

_module = window ? module
_module[if _module.exports? then "exports" else "htmlkup"] = htmlkup
