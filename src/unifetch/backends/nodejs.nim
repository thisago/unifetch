when not defined js:
  {.fatal: "This submodule doesn't works with non JS backends".}
when not defined nodejs:
  {.fatal: "This submodule works just at NodeJS".}

import std/asyncjs
from std/uri import `$`
# from std/tables import keys
import std/jsffi
import std/jsconsole

import unifetch/core
export core except UniClientBase

when showCurlRepr:
  import unifetch/toCurl

when unifetchNodejsUsesNodefetch:
  #{.emit: "import fetch from 'node-fetch';".}
  {.emit: "const fetch = (...args) => import('node-fetch').then(({default: fetch}) => fetch(...args));".}
  proc fetch(url: cstring; options: JsObject): Future[JsObject] {.importc.}
  proc status(resp: JsObject): cstring {.importc.}
  proc body(resp: JsObject): cstring {.importc.}
  

type UniClient* = ref object of UniClientBase
  ## JS Unifetch object
  headers*: HttpHeaders
  proxy*: Proxy

using
  uni: UniClient
  url: Uri or string
  body: string
  multipart: MultipartData
  httpMethod: HttpMethod

proc newUniClient*(useragent = uaMozilla; headers = newHttpHeaders();
                   proxy: Proxy = nil): UniClient =
  ## Creates new UniClient object
  ##
  ## JS doesn't support proxy...
  new result
  var newHeaders = headers
  if not newHeaders.hasKey("user-agent") and userAgent.len > 0:
    newHeaders["User-Agent"] = userAgent
  newHeaders["Access-Control-Allow-Origin"] = "*"
  result.proxy = proxy
  result.headers = newHeaders

  if not proxy.isNil:
    echo "Proxy is ignored at JS backend."

proc close*(uni) =
  ## Just to compatibilize with desktop backend

proc request*(uni; url; httpMethod; body = ""; multipart): Future[UniResponse] {.async.} =
  ## Do the request
  when showCurlRepr:
    echo toCurl(uni.headers, url, httpMethod, body)
  var res: UniResponse
  #promiseResolve.requestIfNoCache(res, uni.headers, url, httpMethod, body):
  #result.requestIfNoCache(uni.headers, url, httpMethod, body):
  block tmp:
    var options = newJsObject()
    options["method"] = cstring $httpMethod
    if httpMethod notin {HttpGet, HttpHead}:
      options["body"] = cstring body
    options["headers"] = newJsObject()
    for (key, value) in uni.headers.pairs:
      options["headers"][key] = cstring value
    console.log options
    let resp = await fetch(url, options)
    let res = new UniResponse
    # res.status = HttpCode resp.status
    echo resp.status
    res.body = $resp.body
    return res
    # result.headers = resp.headers
