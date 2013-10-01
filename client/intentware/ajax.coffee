#### Intentware.Ajax
# The Intentware service in the Browser
#

if window?
    window.modules['intentware/ajax'] = window.exports = window.Intentware.Ajax = {}
else return

# Ajax.Loader service
# Uses Mootools Request object
exports.Loader = Loader = class extends Request

    success: (text) ->
        @onSuccess @processScripts 'window.exports = {};\n' + text

# Ajax.Require service

use_cache = on

window.require = require = (modulename, filename, options) ->
    if arguments.length is 2 and Object.prototype.toString.apply filename isnt '[object String]'
        options = filename
        filename = null
        
    filename = modulename unless filename? 
    filename = resolve filename

    if options?.use_cache?
        cur_use_cache = use_cache
        use_cache = options.use_cache

    result = Intentware._require? filename
    return result if result?

    if use_cache
        cachedModule = window.modules[filename]
        return cachedModule if cachedModule?
    
    window.exports = {}

    request = new Loader
        url: '/static/ijax/' + filename + '.js'
        async: false
        onSuccess: null
        onFailure: (xhr) ->
            alert 'Error: ' + xhr.status
    .get()
    
    result = window.modules[filename] = window.exports
    window.exports = undefined

    if options?.use_cache?
        use_cache = cur_use_cache
    
    result

window.require.resolve = resolve = (filename) ->
    filename = filename.toLowerCase().replace(/^\.\//, '').replace(/\.\.\//g, '').replace(/^general\//, '').replace(/^client\//, '')
    filename = if (i=filename.lastIndexOf '.') >= 0 then filename[0...i] else filename

window.require.cache = (used) -> use_cache = used


# CSS Browser Selector
###
CSS Browser Selector v0.4.0 (Nov 02, 2010)
Rafael Lima (http://rafael.adm.br)
http://rafael.adm.br/css_browser_selector
License: http://creativecommons.org/licenses/by/2.5/
Contributors: http://rafael.adm.br/css_browser_selector#contributors
###
((u) ->
    ua = u.toLowerCase()
    is_ = (t) ->
        ua.indexOf(t) > -1
    
    g = "gecko"
    w = "webkit"
    s = "safari"
    o = "opera"
    m = "mobile"
    h = document.documentElement
    b = [ (if (not (/opera|webtv/i.test(ua)) and /msie\s(\d)/.test(ua)) then ("ie ie" + RegExp.$1) else (if is_("firefox/2") then g + " ff2" else (if is_("firefox/3.5") then g + " ff3 ff3_5" else (if is_("firefox/3.6") then g + " ff3 ff3_6" else (if is_("firefox/3") then g + " ff3" else (if is_("gecko/") then g else (if is_("opera") then o + (if /version\/(\d+)/.test(ua) then " " + o + RegExp.$1 else (if /opera(\s|\/)(\d+)/.test(ua) then " " + o + RegExp.$2 else "")) else (if is_("konqueror") then "konqueror" else (if is_("blackberry") then m + " blackberry" else (if is_("android") then m + " android" else (if is_("chrome") then w + " chrome" else (if is_("iron") then w + " iron" else (if is_("applewebkit/") then w + " " + s + (if /version\/(\d+)/.test(ua) then " " + s + RegExp.$1 else "") else (if is_("mozilla/") then g else "")))))))))))))), (if is_("j2me") then m + " j2me" else (if is_("iphone") then m + " iphone" else (if is_("ipod") then m + " ipod" else (if is_("ipad") then m + " ipad" else (if is_("mac") then "mac" else (if is_("darwin") then "mac" else (if is_("webtv") then "webtv" else (if is_("win") then "win" + (if is_("windows nt 6.0") then " vista" else "") else (if is_("freebsd") then "freebsd" else (if (is_("x11") or is_("linux")) then "linux" else "")))))))))), "js" ]
    c = b.join(" ")
    h.className += " " + c
    return c

)(navigator.userAgent)
