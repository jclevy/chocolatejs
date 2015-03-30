# litejQ

---

**litejQ** is an API-compatible subset of jQuery intended to be Chocolate.js client-side scripts foundation. 

It helps to manipulate the DOM in a cross-browser compatible way and implements only the most commonly needed functionality with the goal of having a small footprint.

## <a name="litejQ-Summary"></a> Summary

 - [$.ready](#litejQ-ready)
 - [$.noConflict](#litejQ-noConflict)
 - [$.type](#litejQ-type)
 - [$.isArray](#litejQ-isArray)
 - [$.isWindow](#litejQ-isArray)
 - [$.isPlainObject](#litejQ-isArray)
 - [$.each](#litejQ-each)
 - [$.map](#litejQ-map)
 - [$.extend](#litejQ-extend)
 - [$.globalEval](#litejQ-globalEval)
 - [.get](#litejQ-fn-get)
 - [.each](#litejQ-fn-each)
 - [.splice](#litejQ-fn-splice)
 - [.map](#litejQ-fn-map)
 - Ajax
  - [$.ajax](#litejQ-ajax)
  - [$.get](#litejQ-get)
  - [$.post](#litejQ-post)
  - [$.getJson](#litejQ-getJson)
  - [$.param](#litejQ-param)
 - Query
  - [.filter](#litejQ-fn-filter)
  - [.find](#litejQ-fn-find)
  - [.parent](#litejQ-fn-parent)
  - [.parents](#litejQ-fn-parents)
  - [.siblings](#litejQ-fn-siblings)
  - [.children](#litejQ-fn-children)
  - [.first](#litejQ-fn-first)
  - [.last](#litejQ-fn-last)
  - [.closest](#litejQ-fn-closest)
 - Event
  - [$.Event](#litejQ-Event)
  - [$.now](#litejQ-now)
  - [.on](#litejQ-fn-on)
  - [.off](#litejQ-fn-off)
  - [.bind](#litejQ-fn-bind)
  - [.unbind](#litejQ-fn-unbind)
  - [.delegate](#litejQ-fn-delegate)
  - [.undelegate](#litejQ-fn-undelegate)
 - Style
  - [.addClass](#litejQ-fn-addClass)
  - [.removeClass](#litejQ-fn-removeClass)
  - [.toggleClass](#litejQ-fn-toggleClass)
  - [.hasClass](#litejQ-fn-hasClass)
  - [.css](#litejQ-fn-css)
 - Dom
  - [.text](#litejQ-fn-text)
  - [.html](#litejQ-fn-html)
  - [.append](#litejQ-fn-append)
  - [.prepend](#litejQ-fn-prepend)
  - [.replaceWith](#litejQ-fn-replaceWith)
  - [.after](#litejQ-fn-after)
  - [.empty](#litejQ-fn-empty)
  - [.attr](#litejQ-fn-attr)
  - [.removeAttr](#litejQ-fn-removeAttr)
  - [.data](#litejQ-fn-data)
  - [.removeData](#litejQ-fn-removeData)
  - [.val](#litejQ-fn-.val)
  - [.show](#litejQ-fn-show)
  - [.hide](#litejQ-fn-hide)
  - [.height](#litejQ-fn-height)
  - [.width](#litejQ-fn-width)
  - [.offset](#litejQ-fn-offset)
  - [.remove](#litejQ-fn-remove)

---    

    ! html
    <script src='/static/lib/litejq.js'></script>
    
    <style>
        pre {
            border: 1px solid grey;
            padding: 10px;
            font-size:11px;
            white-space:pre-wrap;
        }
    </style>

## <a name="litejQ-dollar"></a> $ [⌂](#litejQ-Summary)

$ is the shortcut for litejQ. If $ is already defined, it is not overloaded.  
If jQuery is already loaded, then litejQ is not loaded.

---

## <a name="litejQ-ready"></a> .ready(func) [⌂](#litejQ-Summary)

*Specify a function to execute when the DOM is fully loaded*
    

`$().ready(), $(document).ready(), $(function(){...})`


    #! html
    Page is <span id='onready'>not loaded</span>!

    <script>
        $(function(){
           $('#onready').text('loaded');     
        });
    </script>
    
---

## <a name="litejQ-noConflict"></a> $.noConflict() [⌂](#litejQ-Summary)

*Relinquish litejQ's control of the $ variable.*

`$.noConflict(), litejQ.noConflict()`
 
Many JavaScript libraries use `$` as a function or variable name, just as litejQ does. 
If you need to use another JavaScript library alongside litejQ, 
return control of `$` back to the other library with a call to `$.noConflict()`.

---

    ! chocokup
    
    Chocokup.helpers::check = (base, set) ->
            
        for spec in set
            id = Chocokup.helpers::check.id++
            test = { text: spec[0], expr: ""}
            expect = spec[1]
            callback = spec[2]
            
            cb_declare = if callback? then "var cb = {values: [], getValues: function(){return cb.values.join(',')} }; " else null
            test.expr = if callback isnt 'cb_sync' then "#{base}.#{test.text}" else "(function(){#{base}.#{test.text}; return cb.getValues(); })()"
            test.expr = if callback isnt 'cb_async' then "#{test.expr}" else "null, (#{test.expr})"
            
            div -> 
                text "#{base}.#{test.text} → #{expect}"
                if Chocokup.helpers::check.doCheck 
                    text ' :' ; span "#test-#{id}", ''
                    script "$(function(){ var result, tries = 0, show = function() {if (result == null && tries++ < 30) setTimeout(show, 100); else result = JSON.stringify(result), $('#test-#{id}').text(result === '#{expect}' ? '✔' : '✖ (' + result + ')')}; try { #{cb_declare ? ''} result = #{test.expr};} catch (e) {result = e}; show(); })"
                    
    Chocokup.helpers::check.id = 0
    
    Chocokup.helpers::check.doCheck = on
    

## <a name="litejQ-type"></a> $.type(value) [⌂](#litejQ-Summary)

*Determine the internal JavaScript [[Class]] of an object.*

    ! chocokup
    
    check '$', [
            ['type(undefined)', '"undefined"']
            ['type(null)', '"null"']
            ['type(true)', '"boolean"']
            ['type(1)', '"number"']
        ]
        
---

## <a name="litejQ-isArray"></a> $.isArray(value), $.isWindow(value), $.isPlainObject(value) [⌂](#litejQ-Summary)

*Determine whether the argument is an array, window or a a plain object (created using “{}” or “new Object”).*

    ! chocokup
    
    check '$', [
            ['isArray([])', 'true']
            ['isWindow(window)', 'true']
            ['isPlainObject(new Object)', 'true']
        ]

---

## <a name="litejQ-each"></a> $.each(elements, callback) [⌂](#litejQ-Summary)

*A generic iterator function, which can be used to seamlessly iterate over both objects and arrays.*

    ! chocokup
    
    check '$', [
            ['each(["a","b"], function (i,v) { cb.values.push(v); })', '"a,b"', 'cb_sync']
            ['each({a:1, b:2}, function (k,v) { cb.values.push(k + ":" + v) })', '"a:1,b:2"', 'cb_sync']
        ]
    
---

## <a name="litejQ-map"></a> $.map(elements, callback, arg) [⌂](#litejQ-Summary)

*Translate all items in an array or object to new array of items.*

    ! chocokup

    check '$', [
            ['map(["a","b",["c", "d"]], function(val){return val})', '["a","b","c","d"]' ]
            ['map({a:1,b:2}, function(v, k){return k})', '["a","b"]' ]
            ['map({a:1,b:[2,3]}, function(v, k){return v})', '[1,2,3]' ]
            ['map({a:1,b:2,c:3}, function(v, k, a){return a + v}, ["z"])', '["z1","z2","z3"]' ]
        ]
   
---

## <a name="litejQ-extend"></a> $.extend( target [, object1 ] [, objectN ] ) [⌂](#litejQ-Summary)

*Merge the contents of two or more objects together into the first object.*

    ! chocokup
    
    check '$', [
        ['extend({a:1}, {b:2})', '{"a":1,"b":2}']
        ['extend({a:1}, {b:2}, {c:3})', '{"a":1,"b":2,"c":3}']
        ['extend({a:1,b:{c:2, d:3}}, {b:{c:4}, e:5})', '{"a":1,"b":{"c":4},"e":5}']
    ]
   
---

## <a name="litejQ-globalEval"></a> $.globalEval(text) [⌂](#litejQ-Summary)

*Execute some JavaScript code globally*

---


## <a name="litejQ-fn-get"></a> .get(num) [⌂](#litejQ-Summary)

---

## <a name="litejQ-fn-each"></a> .each(callback, args) [⌂](#litejQ-Summary)

---

## <a name="litejQ-fn-splice"></a> .splice(index , howMany[, element1[, ...[, elementN]]]) [⌂](#litejQ-Summary)

---

## <a name="litejQ-fn-map"></a> .map(func) [⌂](#litejQ-Summary)

---

---

## Ajax functions

---

## <a name="litejQ-ajax"></a> $.ajax(url, options) [⌂](#litejQ-Summary)

*Perform an asynchronous HTTP (Ajax) request.*

    ! chocokup

    check '$', [
        ['ajax("/-/ping?how=raw", {success: function(e){result = e.status}})', '"Ok"', "cb_async"]
    ]
    
---

## <a name="litejQ-get"></a> $.get(url, data, success, dataType) [⌂](#litejQ-Summary)

*Load data from the server using a HTTP GET request.*

    ! chocokup

    check '$', [
        ['get("/-/ping?how=raw", null, function(e){result = e.status}, "json")', '"Ok"', "cb_async"]
    ]
    
---

## <a name="litejQ-post"></a> $.post(url, data, success, dataType) [⌂](#litejQ-Summary)

*Load data from the server using a HTTP POST request.*

    ! chocokup

    check '$', [
    ]
    
---

## <a name="litejQ-getJson", ["></a> $.getJson(url, data, success) [⌂](#litejQ-Summary)

*Load JSON-encoded data from the server using a GET HTTP request.*

    ! chocokup

    check '$', [
        ['getJson("/-/ping?how=raw", null, function(e){result = e.status})', '"Ok"', "cb_async"]
    ]
    
---

## <a name="litejQ-param"></a> $.param(parameters) [⌂](#litejQ-Summary)

*Create a serialized representation of an array or object, suitable for use in a URL query string or Ajax request.*

    ! chocokup

    check '$', [
        ['param([1,2,"a"])', '"0=1&1=2&2=a"']
        ['param({a:1,b:2,c:"a"})', '"a=1&b=2&c=a"']
    ]
    
---

---

## Query functions

    #! html
    <div class="small">
        <div id="litejQ-fn-sample">
            <span class="odd">span1</span>
            <strong>strong1</strong>
            <span class="even">span2</span>
            <strong>strong2</strong>
        </div>
    </div>

---

## <a name="litejQ-fn-filter"></a> .filter(selector) [⌂](#litejQ-Summary)

*Reduce the set of matched elements to those that match the selector.*

    ! chocokup
    
    check '$("span")', [
        ['filter(".even").text()', '"span2"']
    ]
    
---

## <a name="litejQ-fn-find"></a> .find(selector) [⌂](#litejQ-Summary)

*Get the descendants of each element in the current set of matched elements, filtered by a selector.*

    ! chocokup

    check '$("#litejQ-fn-sample")', [
        ['find("span").text()', '"span1span2"']
    ]
    
---

## <a name="litejQ-fn-parent"></a> .parent(selector)  [⌂](#litejQ-Summary)

*Get the parent of each element in the current set of matched elements, optionally filtered by a selector.*

    ! chocokup

    check '$("span.even")', [
        ['parent().attr("id")', '"litejQ-fn-sample"']
        ['parent("div").length', '1']
        ['parent("div.small").length', '0']
    ]
    
---

## <a name="litejQ-fn-parents"></a> .parents(selector) [⌂](#litejQ-Summary)

*Get the ancestors of each element in the current set of matched elements, optionally filtered by a selector.*

    ! chocokup

    check '$("span.even")', [
        ['parents().attr("id")', '"litejQ-fn-sample"']
        ['parents("div").length', '2']
        ['parents("div.small").length', '1']
    ]
    
---

## <a name="litejQ-fn-siblings"></a> .siblings(selector) [⌂](#litejQ-Summary)

*Get the siblings of each element in the set of matched elements, optionally filtered by a selector.*

    ! chocokup
    
    check '$("span.even")', [
        ['siblings().text()', '"span1strong1strong2"']
    ]
    
---

## <a name="litejQ-fn-children"></a> .children(selector) [⌂](#litejQ-Summary)

*Get the children of each element in the set of matched elements, optionally filtered by a selector.*

    ! chocokup

    check '$', [
    ]
    
---

## <a name="litejQ-fn-first"></a> .first() [⌂](#litejQ-Summary)

*Reduce the set of matched elements to the first in the set.*

    ! chocokup

    check '$', [
    ]
    
---

## <a name="litejQ-fn-last"></a> .last() [⌂](#litejQ-Summary)

*Reduce the set of matched elements to the final one in the set.*

    ! chocokup

    check '$', [
    ]
    
---

## <a name="litejQ-fn-next"></a> .next() [⌂](#litejQ-Summary)

*Get the immediately following sibling of each element in the set of matched elements.*

    ! chocokup

    check '$("#litejQ-fn-sample span")', [
        ['next().text()', '"strong1strong2"']
    ]
    
---

## <a name="litejQ-fn-prev"></a> .prev() [⌂](#litejQ-Summary)

*Get the immediately preceding sibling of each element in the set of matched elements*

    ! chocokup

    check '$("#litejQ-fn-sample strong")', [
        ['prev().text()', '"span1span2"']
    ]
    
---

## <a name="litejQ-fn-closest"></a> .closest(selector, context) [⌂](#litejQ-Summary)

*For each element in the set, get the first element that matches the selector by testing the element itself and traversing up through its ancestors in the DOM tree.*

    ! chocokup

    check '$("span.even")', [
        ['closest("div").attr("id")', '"litejQ-fn-sample"']
        ['closest("div.small").length', '1']
    ]

---

---

## Event functions

---

## <a name="litejQ-Event"></a> $.Event(src, props) [⌂](#litejQ-Summary)

---

## <a name="litejQ-now"></a> $.now() [⌂](#litejQ-Summary)

---

## <a name="litejQ-fn-on"></a> .on(event, selector, callback) [⌂](#litejQ-Summary)

---

## <a name="litejQ-fn-off"></a> .off(event, selector, callback) [⌂](#litejQ-Summary)

---

## <a name="litejQ-fn-bind"></a> .bind(event, callback) [⌂](#litejQ-Summary)

---

## <a name="litejQ-fn-unbind"></a> .unbind(event, callback) [⌂](#litejQ-Summary)

---

## <a name="litejQ-fn-delegate"></a> .delegate(selector, event, callback) [⌂](#litejQ-Summary)

---

## <a name="litejQ-fn-undelegate"></a> .undelegate(selector, event, callback) [⌂](#litejQ-Summary)

---

---

## Style functions

---

## <a name="litejQ-fn-addClass"></a> addClass(name) [⌂](#litejQ-Summary)

---

## <a name="litejQ-fn-removeClass"></a> removeClass(name) [⌂](#litejQ-Summary)

---

## <a name="litejQ-fn-toggleClass"></a> toggleClass(name) [⌂](#litejQ-Summary)

---

## <a name="litejQ-fn-hasClass"></a> hasClass(name) [⌂](#litejQ-Summary)

---

## <a name="litejQ-fn-css"></a> css(property, value) [⌂](#litejQ-Summary)

---

---

## Dom functions

---

## <a name="litejQ-fn-text"></a> .text(value) [⌂](#litejQ-Summary)

---

## <a name="litejQ-fn-html"></a> .html(value) [⌂](#litejQ-Summary)

---

## <a name="litejQ-fn-append"></a> .append(value) [⌂](#litejQ-Summary)

---

## <a name="litejQ-fn-prepend"></a> .prepend(value) [⌂](#litejQ-Summary)

---

## <a name="litejQ-fn-replaceWith"></a> .replaceWith(value) [⌂](#litejQ-Summary)

---

## <a name="litejQ-fn-after"></a> .after(value) [⌂](#litejQ-Summary)

---

## <a name="litejQ-fn-empty"></a> .empty() [⌂](#litejQ-Summary)

---

## <a name="litejQ-fn-attr"></a> .attr(name, value) [⌂](#litejQ-Summary)

---

## <a name="litejQ-fn-removeAttr"></a> .removeAttr(name) [⌂](#litejQ-Summary)

---

## <a name="litejQ-fn-data"></a> .data(name, value) [⌂](#litejQ-Summary)

---

## <a name="litejQ-fn-removeData"></a> .removeData(name) [⌂](#litejQ-Summary)

---

## <a name="litejQ-fn-val"></a> .val(value) [⌂](#litejQ-Summary)

---

## <a name="litejQ-fn-show"></a> .show() [⌂](#litejQ-Summary)

---

## <a name="litejQ-fn-hide"></a> .hide() [⌂](#litejQ-Summary)

---

## <a name="litejQ-fn-height"></a> .height() [⌂](#litejQ-Summary)

---

## <a name="litejQ-fn-width"></a> .width() [⌂](#litejQ-Summary)

---

## <a name="litejQ-fn-offset"></a> .offset() [⌂](#litejQ-Summary)

---

## <a name="litejQ-fn-remove"></a> .remove() [⌂](#litejQ-Summary)

---

