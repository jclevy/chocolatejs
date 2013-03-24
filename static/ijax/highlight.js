/*
Syntax highlighting with language autodetection.
http://softwaremaniacs.org/soft/highlight/
*/

var Highlight = new function() {

  /* Utility functions */

  function escape(value) {
    return value.replace(/&/gm, '&amp;').replace(/</gm, '&lt;');
  }

  function langRe(language, value, global) {
    return RegExp(
      value,
      'm' + (language.case_insensitive ? 'i' : '') + (global ? 'g' : '')
    );
  }

  function findCode(pre) {
    for (var i = 0; i < pre.childNodes.length; i++) {
      var node = pre.childNodes[i];
      if (node.nodeName == 'CODE')
        return node;
      if (!(node.nodeType == 3 && node.nodeValue.match(/\s+/)))
        break;
    }
  }

  function blockText(block, ignoreNewLines) {
    var result = '';
    for (var i = 0; i < block.childNodes.length; i++)
      if (block.childNodes[i].nodeType == 3) {
        var chunk = block.childNodes[i].nodeValue;
        if (ignoreNewLines)
          chunk = chunk.replace(/\n/g, '');
        result += chunk;
      } else if (block.childNodes[i].nodeName == 'BR')
        result += '\n';
      else
        result += blockText(block.childNodes[i]);
    // Thank you, MSIE...
    if (/MSIE [678]/.test(navigator.userAgent))
      result = result.replace(/\r/g, '\n');
    return result;
  }

  function blockLanguage(block) {
    var classes = block.className.split(/\s+/);
    classes = classes.concat(block.parentNode.className.split(/\s+/));
    for (var i = 0; i < classes.length; i++) {
      var class_ = classes[i].replace(/^language-/, '');
      if (languages[class_] || class_ == 'no-highlight') {
        return class_;
      }
    }
  }

  /* Stream merging */

  function nodeStream(node) {
    var result = [];
    (function (node, offset) {
      for (var i = 0; i < node.childNodes.length; i++) {
        if (node.childNodes[i].nodeType == 3)
          offset += node.childNodes[i].nodeValue.length;
        else if (node.childNodes[i].nodeName == 'BR')
          offset += 1;
        else if (node.childNodes[i].nodeType == 1) {
          result.push({
            event: 'start',
            offset: offset,
            node: node.childNodes[i]
          });
          offset = arguments.callee(node.childNodes[i], offset);
          result.push({
            event: 'stop',
            offset: offset,
            node: node.childNodes[i]
          });
        }
      }
      return offset;
    })(node, 0);
    return result;
  }

  function mergeStreams(stream1, stream2, value) {
    var processed = 0;
    var result = '';
    var nodeStack = [];

    function selectStream() {
      if (stream1.length && stream2.length) {
        if (stream1[0].offset != stream2[0].offset)
          return (stream1[0].offset < stream2[0].offset) ? stream1 : stream2;
        else {
          /*
          To avoid starting the stream just before it should stop the order is
          ensured that stream1 always starts first and closes last:

          if (event1 == 'start' && event2 == 'start')
            return stream1;
          if (event1 == 'start' && event2 == 'stop')
            return stream2;
          if (event1 == 'stop' && event2 == 'start')
            return stream1;
          if (event1 == 'stop' && event2 == 'stop')
            return stream2;

          ... which is collapsed to:
          */
          return stream2[0].event == 'start' ? stream1 : stream2;
        }
      } else {
        return stream1.length ? stream1 : stream2;
      }
    }

    function open(node) {
      var result = '<' + node.nodeName.toLowerCase();
      for (var i = 0; i < node.attributes.length; i++) {
        var attribute = node.attributes[i];
        result += ' ' + attribute.nodeName.toLowerCase();
        if (attribute.value !== undefined && attribute.value !== false && attribute.value !== null) {
          result += '="' + escape(attribute.value) + '"';
        }
      }
      return result + '>';
    }

    while (stream1.length || stream2.length) {
      var current = selectStream().splice(0, 1)[0];
      result += escape(value.substr(processed, current.offset - processed));
      processed = current.offset;
      if ( current.event == 'start') {
        result += open(current.node);
        nodeStack.push(current.node);
      } else if (current.event == 'stop') {
        var node, i = nodeStack.length;
        do {
          i--;
          node = nodeStack[i];
          result += ('</' + node.nodeName.toLowerCase() + '>');
        } while (node != current.node);
        nodeStack.splice(i, 1);
        while (i < nodeStack.length) {
          result += open(nodeStack[i]);
          i++;
        }
      }
    }
    return result + escape(value.substr(processed));
  }

  /* Initialization */

  function compileModes() {

    function compileMode(mode, language, is_default) {
      if (mode.compiled)
        return;
      var group;

      if (!is_default) {
        mode.beginRe = langRe(language, mode.begin ? mode.begin : '\\B|\\b');
        if (!mode.end && !mode.endsWithParent)
          mode.end = '\\B|\\b';
        if (mode.end)
          mode.endRe = langRe(language, mode.end);
      }
      if (mode.illegal)
        mode.illegalRe = langRe(language, mode.illegal);
      if (mode.relevance === undefined)
        mode.relevance = 1;
      if (mode.keywords) {
        mode.lexemsRe = langRe(language, mode.lexems || Highlight.IDENT_RE, true);
        for (var className in mode.keywords) {
          if (!mode.keywords.hasOwnProperty(className))
            continue;
          if (mode.keywords[className] instanceof Object) {
            group = mode.keywords[className];
          } else {
            group = mode.keywords;
            className = 'keyword';
          }
          for (var keyword in group) {
            if (!group.hasOwnProperty(keyword))
              continue;
            mode.keywords[keyword] = [className, group[keyword]];
          }
        }
      }
      if (!mode.contains) {
        mode.contains = [];
      }
      // compiled flag is set before compiling submodes to avoid self-recursion
      // (see lisp where quoted_list contains quoted_list)
      mode.compiled = true;
      for (var i = 0; i < mode.contains.length; i++) {
        if (mode.contains[i] == 'self') {
          mode.contains[i] = mode;
        }
        compileMode(mode.contains[i], language, false);
      }
      if (mode.starts) {
        compileMode(mode.starts, language, false);
      }
    }

    for (var i in languages) {
      if (!languages.hasOwnProperty(i))
        continue;
      compileMode(languages[i].defaultMode, languages[i], true);
    }
  }

  /*
  Core highlighting function. Accepts a language name and a string with the
  code to highlight. Returns an object with the following properties:

  - relevance (int)
  - keyword_count (int)
  - value (an HTML string with highlighting markup)

  */
  function highlight(language_name, value) {
    if (!compileModes.called) {
      compileModes();
      compileModes.called = true;
    }

    function subMode(lexem, mode) {
      for (var i = 0; i < mode.contains.length; i++) {
        if (mode.contains[i].beginRe.test(lexem)) {
          return mode.contains[i];
        }
      }
    }

    function endOfMode(mode_index, lexem) {
      if (modes[mode_index].end && modes[mode_index].endRe.test(lexem))
        return 1;
      if (modes[mode_index].endsWithParent) {
        var level = endOfMode(mode_index - 1, lexem);
        return level ? level + 1 : 0;
      }
      return 0;
    }

    function isIllegal(lexem, mode) {
      return mode.illegal && mode.illegalRe.test(lexem);
    }

    function compileTerminators(mode, language) {
      var terminators = [];

      for (var i = 0; i < mode.contains.length; i++) {
        terminators.push(mode.contains[i].begin);
      }

      var index = modes.length - 1;
      do {
        if (modes[index].end) {
          terminators.push(modes[index].end);
        }
        index--;
      } while (modes[index + 1].endsWithParent);

      if (mode.illegal) {
        terminators.push(mode.illegal);
      }

      return langRe(language, '(' + terminators.join('|') + ')', true);
    }

    function eatModeChunk(value, index) {
      var mode = modes[modes.length - 1];
      if (!mode.terminators) {
        mode.terminators = compileTerminators(mode, language);
      }
      mode.terminators.lastIndex = index;
      var match = mode.terminators.exec(value);
      if (match)
        return [value.substr(index, match.index - index), match[0], false];
      else
        return [value.substr(index), '', true];
    }

    function keywordMatch(mode, match) {
      var match_str = language.case_insensitive ? match[0].toLowerCase() : match[0];
      var value = mode.keywords[match_str];
      if (value && value instanceof Array)
          return value;
      return false;
    }

    function processKeywords(buffer, mode) {
      buffer = escape(buffer);
      if (!mode.keywords)
        return buffer;
      var result = '';
      var last_index = 0;
      mode.lexemsRe.lastIndex = 0;
      var match = mode.lexemsRe.exec(buffer);
      while (match) {
        result += buffer.substr(last_index, match.index - last_index);
        var keyword_match = keywordMatch(mode, match);
        if (keyword_match) {
          keyword_count += keyword_match[1];
          result += '<span class="'+ keyword_match[0] +'">' + match[0] + '</span>';
        } else {
          result += match[0];
        }
        last_index = mode.lexemsRe.lastIndex;
        match = mode.lexemsRe.exec(buffer);
      }
      return result + buffer.substr(last_index, buffer.length - last_index);
    }

    function processBuffer(buffer, mode) {
      if (mode.subLanguage && languages[mode.subLanguage]) {
        var result = highlight(mode.subLanguage, buffer);
        keyword_count += result.keyword_count;
        return result.value;
      } else {
        return processKeywords(buffer, mode);
      }
    }

    function startNewMode(mode, lexem) {
      var markup = mode.className?'<span class="' + mode.className + '">':'';
      if (mode.returnBegin) {
        result += markup;
        mode.buffer = '';
      } else if (mode.excludeBegin) {
        result += escape(lexem) + markup;
        mode.buffer = '';
      } else {
        result += markup;
        mode.buffer = lexem;
      }
      modes.push(mode);
      relevance += mode.relevance;
    }

    function processModeInfo(buffer, lexem, end) {
      var current_mode = modes[modes.length - 1];
      if (end) {
        result += processBuffer(current_mode.buffer + buffer, current_mode);
        return false;
      }

      var new_mode = subMode(lexem, current_mode);
      if (new_mode) {
        result += processBuffer(current_mode.buffer + buffer, current_mode);
        startNewMode(new_mode, lexem);
        return new_mode.returnBegin;
      }

      var end_level = endOfMode(modes.length - 1, lexem);
      if (end_level) {
        var markup = current_mode.className?'</span>':'';
        if (current_mode.returnEnd) {
          result += processBuffer(current_mode.buffer + buffer, current_mode) + markup;
        } else if (current_mode.excludeEnd) {
          result += processBuffer(current_mode.buffer + buffer, current_mode) + markup + escape(lexem);
        } else {
          result += processBuffer(current_mode.buffer + buffer + lexem, current_mode) + markup;
        }
        while (end_level > 1) {
          markup = modes[modes.length - 2].className?'</span>':'';
          result += markup;
          end_level--;
          modes.length--;
        }
        var last_ended_mode = modes[modes.length - 1];
        modes.length--;
        modes[modes.length - 1].buffer = '';
        if (last_ended_mode.starts) {
          startNewMode(last_ended_mode.starts, '');
        }
        return current_mode.returnEnd;
      }

      if (isIllegal(lexem, current_mode))
        throw 'Illegal';
    }

    var language = languages[language_name];
    var modes = [language.defaultMode];
    var relevance = 0;
    var keyword_count = 0;
    var result = '';
    try {
      var mode_info, index = 0;
      language.defaultMode.buffer = '';
      do {
        mode_info = eatModeChunk(value, index);
        var return_lexem = processModeInfo(mode_info[0], mode_info[1], mode_info[2]);
        index += mode_info[0].length;
        if (!return_lexem) {
          index += mode_info[1].length;
        }
      } while (!mode_info[2]);
      if(modes.length > 1)
        throw 'Illegal';
      return {
        relevance: relevance,
        keyword_count: keyword_count,
        value: result
      };
    } catch (e) {
      if (e == 'Illegal') {
        return {
          relevance: relevance,
          keyword_count: keyword_count,
          value: result + '&nbsp;<span class="error">ERROR</span>',
          error: {
              type: e,
              value: escape(value)
          }
        };
      } else {
        throw e;
      }
    }
  }

  /*
  Highlighting with language detection. Accepts a string with the code to
  highlight. Returns an object with the following properties:

  - language (detected language)
  - relevance (int)
  - keyword_count (int)
  - value (an HTML string with highlighting markup)
  - second_best (object with the same structure for second-best heuristically
    detected language, may be absent)

  */
  function highlightAuto(text) {
    var result = {
      keyword_count: 0,
      relevance: 0,
      value: escape(text)
    };
    var second_best = result;
    for (var key in languages) {
      if (!languages.hasOwnProperty(key))
        continue;
      var current = highlight(key, text);
      current.language = key;
      if (current.keyword_count + current.relevance > second_best.keyword_count + second_best.relevance) {
        second_best = current;
      }
      if (current.keyword_count + current.relevance > result.keyword_count + result.relevance) {
        second_best = result;
        result = current;
      }
    }
    if (second_best.language) {
      result.second_best = second_best;
    }
    return result;
  }

  /*
  Post-processing of the highlighted markup:

  - replace TABs with something more useful
  - replace real line-breaks with '<br>' for non-pre containers

  */
  function fixMarkup(value, tabReplace, useBR) {
    if (tabReplace) {
      value = value.replace(/^((<[^>]+>|\t)+)/gm, function(match, p1, offset, s) {
        return p1.replace(/\t/g, tabReplace);
      });
    }
    if (useBR) {
      value = value.replace(/\n/g, '<br>');
    }
    return value;
  }

  /*
  Applies highlighting to a DOM node containing code. Accepts a DOM node and
  two optional parameters for fixMarkup.
  */
  function highlightBlock(block, tabReplace, useBR) {
    var text = blockText(block, useBR);
    var language = blockLanguage(block);
    var result, pre;
    if (language == 'no-highlight')
        return;
    if (language) {
      result = highlight(language, text);
    } else {
      result = highlightAuto(text);
      language = result.language;
    }
    var original = nodeStream(block);
    if (original.length) {
      pre = document.createElement('pre');
      pre.innerHTML = result.value;
      result.value = mergeStreams(original, nodeStream(pre), text);
    }
    result.value = fixMarkup(result.value, tabReplace, useBR);

    var class_name = block.className;
    if (!class_name.match('(\\s|^)(language-)?' + language + '(\\s|$)')) {
      class_name = class_name ? (class_name + ' ' + language) : language;
    }
    if (/MSIE [678]/.test(navigator.userAgent) && block.tagName == 'CODE' && block.parentNode.tagName == 'PRE') {
      // This is for backwards compatibility only. IE needs this strange
      // hack becasue it cannot just cleanly replace <code> block contents.
      pre = block.parentNode;
      var container = document.createElement('div');
      container.innerHTML = '<pre><code>' + result.value + '</code></pre>';
      block = container.firstChild.firstChild;
      container.firstChild.className = pre.className;
      pre.parentNode.replaceChild(container.firstChild, pre);
    } else {
      block.innerHTML = result.value;
    }
    block.className = class_name;
    block.result = {
      language: language,
      kw: result.keyword_count,
      re: result.relevance
    };
    if (result.second_best) {
      block.second_best = {
        language: result.second_best.language,
        kw: result.second_best.keyword_count,
        re: result.second_best.relevance
      };
    }
  }

  /*
  Applies highlighting to all <pre><code>..</code></pre> blocks on a page.
  */
  function initHighlighting() {
    if (initHighlighting.called)
      return;
    initHighlighting.called = true;
    var pres = document.getElementsByTagName('pre');
    for (var i = 0; i < pres.length; i++) {
      var code = findCode(pres[i]);
      if (code)
        highlightBlock(code, Highlight.tabReplace);
    }
  }

  /*
  Attaches highlighting to the page load event.
  */
  function initHighlightingOnLoad() {
    if (window.addEventListener) {
      window.addEventListener('DOMContentLoaded', initHighlighting, false);
      window.addEventListener('load', initHighlighting, false);
    } else if (window.attachEvent)
      window.attachEvent('onload', initHighlighting);
    else
      window.onload = initHighlighting;
  }

  var languages = {}; // a shortcut to avoid writing "this." everywhere

  /* Interface definition */

  this.LANGUAGES = languages;
  this.highlight = highlight;
  this.highlightAuto = highlightAuto;
  this.fixMarkup = fixMarkup;
  this.highlightBlock = highlightBlock;
  this.initHighlighting = initHighlighting;
  this.initHighlightingOnLoad = initHighlightingOnLoad;

  // Common regexps
  this.IDENT_RE = '[a-zA-Z][a-zA-Z0-9_]*';
  this.UNDERSCORE_IDENT_RE = '[a-zA-Z_][a-zA-Z0-9_]*';
  this.NUMBER_RE = '\\b\\d+(\\.\\d+)?';
  this.C_NUMBER_RE = '\\b(0[xX][a-fA-F0-9]+|(\\d+(\\.\\d*)?|\\.\\d+)([eE][-+]?\\d+)?)'; // 0x..., 0..., decimal, float
  this.BINARY_NUMBER_RE = '\\b(0b[01]+)'; // 0b...
  this.RE_STARTERS_RE = '!|!=|!==|%|%=|&|&&|&=|\\*|\\*=|\\+|\\+=|,|\\.|-|-=|/|/=|:|;|<|<<|<<=|<=|=|==|===|>|>=|>>|>>=|>>>|>>>=|\\?|\\[|\\{|\\(|\\^|\\^=|\\||\\|=|\\|\\||~';

  // Common modes
  this.BACKSLASH_ESCAPE = {
    begin: '\\\\.', relevance: 0
  };
  this.APOS_STRING_MODE = {
    className: 'string',
    begin: '\'', end: '\'',
    illegal: '\\n',
    contains: [this.BACKSLASH_ESCAPE],
    relevance: 0
  };
  this.QUOTE_STRING_MODE = {
    className: 'string',
    begin: '"', end: '"',
    illegal: '\\n',
    contains: [this.BACKSLASH_ESCAPE],
    relevance: 0
  };
  this.C_LINE_COMMENT_MODE = {
    className: 'comment',
    begin: '//', end: '$'
  };
  this.C_BLOCK_COMMENT_MODE = {
    className: 'comment',
    begin: '/\\*', end: '\\*/'
  };
  this.HASH_COMMENT_MODE = {
    className: 'comment',
    begin: '#', end: '$'
  };
  this.NUMBER_MODE = {
    className: 'number',
    begin: this.NUMBER_RE,
    relevance: 0
  };
  this.C_NUMBER_MODE = {
    className: 'number',
    begin: this.C_NUMBER_RE,
    relevance: 0
  };
  this.BINARY_NUMBER_MODE = {
    className: 'number',
    begin: this.BINARY_NUMBER_RE,
    relevance: 0
  };

  // Utility functions
  this.inherit = function(parent, obj) {
    var result = {}, key;
    for (key in parent)
      result[key] = parent[key];
    if (obj)
      for (key in obj)
        result[key] = obj[key];
    return result;
  };
}();

// export
_module = typeof window !== "undefined" && window !== null ? window : module;
_module.exports = Highlight;

/*
Language: CoffeeScript
Author: Dmytrii Nagirniak <dnagir@gmail.com>
Contributors: Oleg Efimov <efimovov@gmail.com>
Description: CoffeeScript is a programming language that transcompiles to JavaScript. For info about language see http://coffeescript.org/
*/

Highlight.LANGUAGES.coffeescript = function() {
  var keywords = {
    'keyword': {
      // JS keywords
      'in': 1, 'if': 1, 'for': 1, 'while': 1, 'finally': 1,
      'new': 1, 'do': 1, 'return': 1, 'else': 1,
      'break': 1, 'catch': 1, 'instanceof': 1, 'throw': 1,
      'try': 1, 'this': 1, 'switch': 1, 'continue': 1, 'typeof': 1,
      'delete': 1, 'debugger': 1,
      'class': 1, 'extends': 1, 'super': 1,
      // Coffee keywords
      'then': 1, 'unless': 1, 'until': 1, 'loop': 2, 'of': 2, 'by': 1, 'when': 2,
      'and': 1, 'or': 1, 'is': 1, 'isnt': 2, 'not': 1
    },
    'literal': {
      // JS literals
      'true': 1, 'false': 1, 'null': 1, 'undefined': 1,
      // Coffee literals
      'yes': 1, 'no': 1, 'on': 1, 'off': 1
    },
    'reserved': {
      'case': 1, 'default': 1, 'function': 1, 'var': 1, 'void': 1, 'with': 1,
      'const': 1, 'let': 1, 'enum': 1, 'export': 1, 'import': 1, 'native': 1,
      '__hasProp': 1 , '__extends': 1 , '__slice': 1 , '__bind': 1 , '__indexOf': 1
    }
  };

  var JS_IDENT_RE = '[A-Za-z$_][0-9A-Za-z$_]*';

  var COFFEE_QUOTE_STRING_SUBST_MODE = {
    className: 'subst',
    begin: '#\\{', end: '}',
    keywords: keywords,
    contains: [Highlight.C_NUMBER_MODE, Highlight.BINARY_NUMBER_MODE]
  };

  var COFFEE_QUOTE_STRING_MODE = {
    className: 'string',
    begin: '"', end: '"',
    relevance: 0,
    contains: [Highlight.BACKSLASH_ESCAPE, COFFEE_QUOTE_STRING_SUBST_MODE]
  };

  var COFFEE_HEREDOC_MODE = {
    className: 'string',
    begin: '"""', end: '"""',
    contains: [Highlight.BACKSLASH_ESCAPE, COFFEE_QUOTE_STRING_SUBST_MODE]
  };

  var COFFEE_APOS_HEREDOC_MODE = {
    className: 'string',
    begin: "'''", end: "'''",
    contains: [Highlight.BACKSLASH_ESCAPE, COFFEE_QUOTE_STRING_SUBST_MODE]
  };

  var COFFEE_HERECOMMENT_MODE = {
    className: 'comment',
    begin: '###', end: '###'
  };

  var COFFEE_HEREGEX_MODE = {
    className: 'regexp',
    begin: '///', end: '///',
    contains: [Highlight.HASH_COMMENT_MODE]
  };

  var COFFEE_FUNCTION_DECLARATION_MODE = {
    className: 'function',
    begin:'[-=]>'
  };
  
  var COFFEE_VARIABLE_ASSIGNMENT_MODE = {
      className: 'variable',
      begin: JS_IDENT_RE + "\\s*\\="
  };
  
  var COFFEE_PROPERTY_ASSIGNMENT_MODE = {
      className: 'property',
      begin: JS_IDENT_RE + "\\s*\\:"
  };
  
  var COFFEE_EMBEDDED_JAVASCRIPT = {
    className: 'javascript',
    begin: '`', end: '`',
    excludeBegin: true, excludeEnd: true,
    subLanguage: 'javascript'
  };

  return {
    defaultMode: {
      keywords: keywords,
      contains: [
        // Numbers 
        Highlight.C_NUMBER_MODE,
        Highlight.BINARY_NUMBER_MODE,
        // Strings
        COFFEE_APOS_HEREDOC_MODE, // Should be before Highlight.APOS_STRING_MODE for greater priority
        Highlight.APOS_STRING_MODE,
        COFFEE_HEREDOC_MODE, // Should be before COFFEE_QUOTE_STRING_MODE for greater priority
        COFFEE_QUOTE_STRING_MODE,
        // Comments
        COFFEE_HERECOMMENT_MODE, // Should be before Highlight.HASH_COMMENT_MODE for greater priority
        Highlight.HASH_COMMENT_MODE,
        // CoffeeScript specific modes
        COFFEE_HEREGEX_MODE,
        COFFEE_EMBEDDED_JAVASCRIPT,
        COFFEE_FUNCTION_DECLARATION_MODE,
        COFFEE_VARIABLE_ASSIGNMENT_MODE,
        COFFEE_PROPERTY_ASSIGNMENT_MODE
      ]
    }
  };
}();

/*
Language: CSS
*/

Highlight.LANGUAGES.css = function() {
  var FUNCTION = {
    className: 'function',
    begin: Highlight.IDENT_RE + '\\(', end: '\\)',
    contains: [{
        endsWithParent: true, excludeEnd: true,
        contains: [Highlight.NUMBER_MODE, Highlight.APOS_STRING_MODE, Highlight.QUOTE_STRING_MODE]
    }]
  };
  return {
    case_insensitive: true,
    defaultMode: {
      illegal: '[=/|\']',
      contains: [
        Highlight.C_BLOCK_COMMENT_MODE,
        {
          className: 'id', begin: '\\#[A-Za-z0-9_-]+'
        },
        {
          className: 'class', begin: '\\.[A-Za-z0-9_-]+',
          relevance: 0
        },
        {
          className: 'attr_selector',
          begin: '\\[', end: '\\]',
          illegal: '$'
        },
        {
          className: 'pseudo',
          begin: ':(:)?[a-zA-Z0-9\\_\\-\\+\\(\\)\\"\\\']+'
        },
        {
          className: 'at_rule',
          begin: '@(font-face|page)',
          lexems: '[a-z-]+',
          keywords: {'font-face': 1, 'page': 1}
        },
        {
          className: 'at_rule',
          begin: '@', end: '[{;]', // at_rule eating first "{" is a good thing
                                   // because it doesn't let it to be parsed as
                                   // a rule set but instead drops parser into
                                   // the defaultMode which is how it should be.
          excludeEnd: true,
          keywords: {'import': 1, 'page': 1, 'media': 1, 'charset': 1},
          contains: [
            FUNCTION,
            Highlight.APOS_STRING_MODE, Highlight.QUOTE_STRING_MODE,
            Highlight.NUMBER_MODE
          ]
        },
        {
          className: 'tag', begin: Highlight.IDENT_RE,
          relevance: 0
        },
        {
          className: 'rules',
          begin: '{', end: '}',
          illegal: '[^\\s]',
          relevance: 0,
          contains: [
            Highlight.C_BLOCK_COMMENT_MODE,
            {
              className: 'rule',
              begin: '[^\\s]', returnBegin: true, end: ';', endsWithParent: true,
              contains: [
                {
                  className: 'attribute',
                  begin: '[A-Z\\_\\.\\-]+', end: ':',
                  excludeEnd: true,
                  illegal: '[^\\s]',
                  starts: {
                    className: 'value',
                    endsWithParent: true, excludeEnd: true,
                    contains: [
                      FUNCTION,
                      Highlight.NUMBER_MODE,
                      Highlight.QUOTE_STRING_MODE,
                      Highlight.APOS_STRING_MODE,
                      Highlight.C_BLOCK_COMMENT_MODE,
                      {
                        className: 'hexcolor', begin: '\\#[0-9A-F]+'
                      },
                      {
                        className: 'important', begin: '!important'
                      }
                    ]
                  }
                }
              ]
            }
          ]
        }
      ]
    }
  };
}();

/*
Language: JavaScript
*/

Highlight.LANGUAGES.javascript = {
  defaultMode: {
    keywords: {
      'keyword': {
        'in': 1, 'if': 1, 'for': 1, 'while': 1, 'finally': 1, 'var': 1, 'new': 1, 'function': 1, 'do': 1,
        'return': 1, 'void': 1, 'else': 1, 'break': 1, 'catch': 1, 'instanceof': 1, 'with': 1, 'throw': 1,
        'case': 1, 'default': 1, 'try': 1, 'this': 1, 'switch': 1, 'continue': 1, 'typeof': 1, 'delete': 1
      },
      'literal': {'true': 1, 'false': 1, 'null': 1}
    },
    contains: [
      Highlight.APOS_STRING_MODE,
      Highlight.QUOTE_STRING_MODE,
      Highlight.C_LINE_COMMENT_MODE,
      Highlight.C_BLOCK_COMMENT_MODE,
      Highlight.C_NUMBER_MODE,
      {
        className: 'variable',
        begin: Highlight.UNDERSCORE_IDENT_RE + '\\s*\\='
      },
      {
        className: 'property',
        begin: Highlight.UNDERSCORE_IDENT_RE + '\\s*\\:'
      },
      { // regexp container
        begin: '(' + Highlight.RE_STARTERS_RE + '|case|return|throw)\\s*',
        keywords: {'return': 1, 'throw': 1, 'case': 1},
        contains: [
          Highlight.C_LINE_COMMENT_MODE,
          Highlight.C_BLOCK_COMMENT_MODE,
          {
            className: 'regexp',
            begin: '/', end: '/[gim]*',
            contains: [{begin: '\\\\/'}]
          }
        ],
        relevance: 0
      },
      {
        className: 'function',
        begin: '\\bfunction\\b', end: '{',
        keywords: {'function': 1},
        contains: [
          {
            className: 'title', begin: '[A-Za-z$_][0-9A-Za-z$_]*'
          },
          {
            className: 'params',
            begin: '\\(', end: '\\)',
            contains: [
              Highlight.APOS_STRING_MODE,
              Highlight.QUOTE_STRING_MODE,
              Highlight.C_LINE_COMMENT_MODE,
              Highlight.C_BLOCK_COMMENT_MODE
            ]
          }
        ]
      }
    ]
  }
};

/*
Language: Markdown
Requires: xml.js
Author: John Crepezzi <john.crepezzi@gmail.com>
Website: http://seejohncode.com/
*/

Highlight.LANGUAGES.markdown = {
  case_insensitive: true,
  defaultMode: {
    contains: [
      // highlight headers
      {
        className: 'header',
        begin: '^#{1,3}', end: '$'
      },
      {
        className: 'header',
        begin: '^.+?\\n[=-]{2,}$'
      },
      // inline html
      {
        begin: '<', end: '>',
        subLanguage: 'xml'
      },
      // lists (indicators only)
      {
        className: 'bullet',
        begin: '^([*+-]|(\\d+\\.))\\s+'
      },
      // strong segments
      {
        className: 'strong',
        begin: '[*_]{2}.+?[*_]{2}'
      },
      // emphasis segments
      {
        className: 'emphasis',
        begin: '[*_].+?[*_]'
      },
      // blockquotes
      {
        className: 'blockquote',
        begin: '^>\\s+', end: '$'
      },
      // code snippets
      {
        className: 'code',
        begin: '`.+?`'
      },
      {
        className: 'code',
        begin: '^    ', end: '$',
        relevance: 0
      },
      // horizontal rules
      {
        className: 'horizontal_rule',
        begin: '^-{3,}', end: '$'
      },
      // using links - title and link
      {
        begin: '\\[.+?\\]\\(.+?\\)',
        returnBegin: true,
        contains: [
          {
            className: 'link_label',
            begin: '\\[.+\\]'
          },
          {
            className: 'link_url',
            begin: '\\(', end: '\\)',
            excludeBegin: true, excludeEnd: true
          }
        ]
      }
    ]
  }
};

/*
Language: HTML, XML
*/

Highlight.LANGUAGES.xml = function(){
  var XML_IDENT_RE = '[A-Za-z0-9\\._:-]+';
  var TAG_INTERNALS = {
    endsWithParent: true,
    contains: [
      {
        className: 'attribute',
        begin: XML_IDENT_RE,
        relevance: 0
      },
      {
        begin: '="', returnBegin: true, end: '"',
        contains: [{
            className: 'value',
            begin: '"', endsWithParent: true
        }]
      },
      {
        begin: '=\'', returnBegin: true, end: '\'',
        contains: [{
          className: 'value',
          begin: '\'', endsWithParent: true
        }]
      },
      {
        begin: '=',
        contains: [{
          className: 'value',
          begin: '[^\\s/>]+'
        }]
      }
    ]
  };
  return {
    case_insensitive: true,
    defaultMode: {
      contains: [
        {
          className: 'pi',
          begin: '<\\?', end: '\\?>',
          relevance: 10
        },
        {
          className: 'doctype',
          begin: '<!DOCTYPE', end: '>',
          relevance: 10
        },
        {
          className: 'comment',
          begin: '<!--', end: '-->',
          relevance: 10
        },
        {
          className: 'cdata',
          begin: '<\\!\\[CDATA\\[', end: '\\]\\]>',
          relevance: 10
        },
        {
          className: 'tag',
          begin: '<style', end: '>',
          lexems: Highlight.IDENT_RE,  keywords: {'title': {'style': 1}},
          contains: [TAG_INTERNALS],
          starts: {
            className: 'css',
            end: '</style>', returnEnd: true,
            subLanguage: 'css'
          }
        },
        {
          className: 'tag',
          begin: '<script', end: '>',
          lexems: Highlight.IDENT_RE,  keywords: {'title': {'script': 1}},
          contains: [TAG_INTERNALS],
          starts: {
            className: 'javascript',
            end: '</script>', returnEnd: true,
            subLanguage: 'javascript'
          }
        },
        {
          className: 'vbscript',
          begin: '<%', end: '%>',
          subLanguage: 'vbscript'
        },
        {
          className: 'tag',
          begin: '</?', end: '/?>',
          contains: [
            {
              className: 'title', begin: XML_IDENT_RE
            },
            TAG_INTERNALS
          ]
        }
      ]
    }
  };
}();

// Default CSS for Code block
Highlight.defaultCodeCSS = "\
    .source_code .keyword {color: #954121;}\
    .source_code .comment {color: #a50;}\
    .source_code .number {color: #164;}\
    .source_code .literal {color: sienna;}\
    .source_code .string {color: #219161;}\
    .source_code .regexp {color: #f50;}\
    .source_code .function {color: #30a;}\
    .source_code .title {color: #00c;}\
    .source_code .params {color: #a0a;}\
    .source_code .variable {color: #19469D;}\
    .source_code .property {color: #19469D;}\
    .source_code .error {color: red;}\
    \
    .source_code .tag {color: blueviolet;}\
    .source_code .id {color: #085;}\
    .source_code .class {color: #05a;}\
    .source_code .attribute {color: sienna;}\
    .source_code .at_rule {color: #f50;}\
    .source_code .attr_selector {color: black;}\
    .source_code .pseudo {color: black;}\
    .source_code .rules {color: black;}\
    .source_code .value {color: #164;}\
    .source_code .hexcolor {color: black;}\
    .source_code .important {color: black;}\
    ";