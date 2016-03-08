Action = require 'action-js'

parseParam = (str) ->
    if str?
        pairs = str.split("&")
        params = {}
        for pair in pairs
            pair = pair.split("=")
            key = decodeURIComponent(pair[0])
            value = if pair.length == 2 then decodeURIComponent pair[1] else null
            if params[key]?
                unless params[key] instanceof Array
                    params[key] = [params[key]]
                params[key].push(value)
            else
                params[key] = value
        params

    else {}

parseSearch = -> parseParam window.location.search[1..]
parseHash = -> parseParam window.location.hash[1..]
setHash = (hashObj) -> window.location.hash = '#' + (buildParam hashObj)

# recursively build param string
buildParamR = (prefix , data) ->
    result = []
    if data?
        if data instanceof Array
            for v in data
                if (typeof v) == 'object'
                    result.push buildParamR(prefix, v)
                else if v?
                    result.push encodeURIComponent(prefix) + "=" + encodeURIComponent(v)
        else
            for k, v of data
                key = if prefix then prefix + '[' + k + ']' else k
                if (typeof v) == 'object'
                    result.push buildParamR(key, v)
                else if v?
                    result.push encodeURIComponent(key) + "=" + encodeURIComponent(v)
    else if prefix?
        result.push encodeURIComponent(prefix)

    (kv for kv in result when kv != '').join '&'

# build query string
buildParam = (data) -> buildParamR('', data)

# make a jsonp request
jsonp = (opts) ->
    new Action (cb) ->
        callbackName = 'callback_' + (Math.round(Math.random() * 1e16)).toString(36)
        script = document.createElement 'script'

        window[callbackName] = (resp) ->
            script.parentNode.removeChild script
            cb resp
            window[callbackName] = undefined

        script.onerror = ->
            script.parentNode.removeChild script
            cb new Error 'REQUEST_ERROR: error when making jsonp request'
            window[callbackName] = undefined
            false

        script.onload = -> false

        script.src = opts.url + (if opts.url.indexOf('?') == -1 then '?' else '&') +
            (if opts.callback then opts.callback else 'callback') +
            '=' + callbackName

        script.callbackName = callbackName
        document.body.appendChild script
        script

# make a ajax request
ajax = (opts) ->
    new Action (cb) ->
        xhr = new (window.XMLHttpRequest)
        xhr.open opts.method, opts.url, true, opts.user, opts.password
        xhr.onload = ->
            if xhr.readyState == 4
                if xhr.status >= 200 and xhr.status < 300
                    if opts.responseType? then cb xhr.response
                    else cb xhr.responseText
                else
                    cb new Error 'REQUEST_ERROR: status' + xhr.status

        for k, v of opts.headers
            xhr.setRequestHeader k, v

        if opts.timeout
            xhr.timeout = opts.timeout
            xhr.ontimeout = ->
                cb new Error 'REQUEST_ERROR: timeout'

        if opts.responseType
            xhr.responseType = opts.responseType

        switch typeof opts.data
            when 'string'
                xhr.setRequestHeader 'Content-Type', 'application/x-www-form-urlencoded'
                xhr.send opts.data

            when 'object'
                if opts.data instanceof window.FormData
                    xhr.send opts.data
                else
                    xhr.setRequestHeader 'Content-Type', 'application/json; charset=UTF-8'
                    xhr.send JSON.stringify opts.data
            else xhr.send()
        xhr

module.exports = {
        parseParam
    ,   buildParam
    ,   jsonp
    ,   ajax
    ,   parseSearch
    ,   parseHash
    ,   setHash
    }
