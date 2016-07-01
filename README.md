# ajax-action

 [Action](https://github.com/winterland1989/Action.js) wrapper for ajax library.

+ Usage: `npm install ajax-action`

+ What is [Action](https://github.com/winterland1989/Action.js)?

# API document

buildParam(paramObj)
--------------------

Convert an object to a query string, for adding param to url.

```js
AA = require('ajax-action');

var param = AA.buildParam({
    uid: 1
,   posts:[
        'foo'
    ,   'bar'
    ]
,   test:{
        foo: 'bar'    
    }
})
//param == "uid=1&posts=foo&posts=bar&test%5Bfoo%5D=bar"
//decodeURIComponent(param) == "uid=1&posts=foo&posts=bar&test[foo]=bar"
```

Please note following convertions:

```js
AA.buildParam({a:'', b: null, c: undefined}) // a=&b
```

parseParam(paramString)
----------------------

Parse a parameter string into a object.

```js
AA.parseParam('a=2&b=3&a=4')
// { a: [ '2', '4' ], b: '3' }
AA.parseParam('a=3&b=&c=5')
// { a: '3', b: '', c: '5' }
```

Note this function can only parse simple key-value pair(not nested), for example:

```js
AA.parseParam('a[b]=2&c=4')
// {'a[b]':2, c: 4}
```


jsonp(opts)
-----------
Make a JSON with Padding request, if failed, error 'REQUEST_ERROR: error when making jsonp request' will be passed on, opts format:

```js
{
    url :: String
    // target url, add params if you wish to send data

,   callback :: String
    // this is the callback key in the param
    // omit it with default 'callback' 
}
```

When a `jsonp` `Action` fired with `go`, the script tag are returned(will be removed from DOM after request finish).

```js
var script = AA.jsonp({
  url: 'http://jsonplaceholder.typicode.com/posts?' + Action.param({
    userId: 2
  })
}).go(function(data) {
  console.log(script);
  return console.log(data);
});

```

Since the data are already deserialized via the Padding part of JSON with Padding, the data should be a javascript value.

Note that, because HTTP method `GET` doesn't support request body, send parameter to server using `buildParam` like this:

```haskell
AA.jsonp({
    url: 'http://jsonplaceholder.typicode.com/posts' + buildParam({id:1})
}).go(...)
```

ajax(opts)
-----------------
Make an AJAX request, opts format:

```js
{
    url :: String
    // target url, when using method without request body
    // eg. 'GET', 'DELETE'
    // add params if you wish to send data

,   method :: String
    // 'GET' | 'POST' | 'DELETE' | 'PUT' ...

,   data :: String | Object | FormData
    // request payload, only use this when request method support body
    // String will add header: 'Content-Type', 'application/x-www-form-urlencoded'
    // FormData will add header: 'Content-Type', 'multipart/form-data; boundary=...'
    // Other Object will add header: 'Content-Type', 'application/json; charset=UTF-8'

,   headers :: Object
    // custom headers key-value pairs

,   timeout :: Int
    // max request time in milliseconds

,   responseType :: String
    // Enumerated value that defines the response type
    // only works with some broswers
    // check https://developer.mozilla.org/en-US/docs/Web/API/XMLHttpRequest
}
```

Without setting `responseType`, response are passed as string as it is, so deserialize it if you must, If request failed, error 'REQUEST_ERROR: statusx' will be passed on, `x` is the xhr status, if request didn't finish within given timeout, error 'REQUEST_ERROR: timeout' will be passed on. When `ajax` `Action` are fired, the `xhr` object will be returned without block.

```js
// send data with urlencoded string
var xhr = AA.ajax({
    method: 'POST',
    url: 'http://jsonplaceholder.typicode.com/posts',
    data: AA.buildParam({
      what: 3
    })
})
.next(JSON.parse) // all responses are string if no responseType provided
.go(function(data) {
    // use xhr object to obtain response headers
    console.log(xhr.getAllResponseHeaders());
    console.log(data);
});

// send object with json
var xhr = AA.ajax({
    method: 'POST',
    url: 'http://jsonplaceholder.typicode.com/posts',
    data: {
        foo: 'bar'
    },
    timeout: 100
}).guard(function(e) {
    console.log(e);
    return 'error handled';
}).go(function(data) {
    console.log(data);
});

// send FormData

var f = new FormData();
var f.append('username', 'Chris');

var xhr = AA.ajax({
    method: 'POST',
    url: 'http://jsonplaceholder.typicode.com/posts',
    data: f,
    // use responseType to auto deserialize data
    responseType: 'json'
}).go(function(data) {
    console.log(data);
});
```

Note that, for HTTP method which doesn't support request body, send parameter to server using `buildParam` like this:

```haskell
AA.ajax({
    method: 'GET',
    url: 'http://jsonplaceholder.typicode.com/posts' + buildParam({id:1})
}).go(...)
```

parseSearch()
-------------

Parse current browser's `window.location.search`.

parseHash()
-----------

Parse current browser's `window.location.hash`.

setHash(parameterObj)
--------------------

Set a parameter object into `window.location.hash`, this function is added because i always need a minimal router utitly, and my solution is:

+ Initialize application with a hash state using `parseHash`, then route application to certain state.

+ Everytime application state change, change hash string using `setHash` so users can use the link to re-enter this state.

divideArray([a], Int)
------------

A helper for dividing workload in to group of workload，eg:

`divideArray [1..10], 3 ==  [ [1, 2, 3], [4, 5, 6], [7, 8, 9], [10] ]`

That'all, happy hacking!
