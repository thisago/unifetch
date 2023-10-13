when not defined js:
  {.fatal: "This submodule doesn't works with non JS backends".}
when not defined nodejs:
  {.fatal: "This submodule works just at NodeJS".}

import std/asyncjs
from std/uri import `$`
import std/jsffi
import std/jsconsole

import pkg/nodejs/jshttp
requireHttp()
requireHttps()

import unifetch/core
export core except UniClientBase

when showCurlRepr:
  import unifetch/toCurl

type RequestCb = proc(resp: JsObject)
proc on(resp: JsObject; event: cstring; cb: proc(chunk: JsObject)) {.importcpp.}
proc `end`(resp: JsObject) {.importcpp.}
proc toString(stream: JsObject): cstring {.importcpp.}

func httpRequest(url: cstring; options: JsObject; cb: RequestCb): JsObject {.importjs: "http.request(@)".}
func httpsRequest(url: cstring; options: JsObject; cb: RequestCb): JsObject {.importjs: "https.request(@)".}

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
  result.proxy = proxy
  result.headers = newHeaders

  if not proxy.isNil:
    echo "Proxy is currently not implemented at NodeJS backend."

proc close*(uni) =
  ## Just to compatibilize with desktop backend

proc request*(uni; url; httpMethod; body = ""; multipart): Future[UniResponse] {.async.} =
  ## Do the request
  when showCurlRepr:
    echo toCurl(uni.headers, url, httpMethod, body)
  var res: UniResponse
  #result.requestIfNoCache(uni.headers, url, httpMethod, body):
  let promise = newPromise() do (promiseResolve: proc(resp: UniResponse)):
    var res: UniResponse
    promiseResolve.requestIfNoCache(res, uni.headers, url, httpMethod, body):
      var options = newJsObject()
      options["method"] = cstring $httpMethod
      if httpMethod notin {HttpGet, HttpHead}:
        options["body"] = cstring body
      options["headers"] = newJsObject()
      for (key, value) in uni.headers.pairs:
        options["headers"][key] = cstring value

      proc cb(r: JsObject) =
        new res
        res.code = HttpCode r["statusCode"].to int
        res.headers = newHttpHeaders()
        for key, val in r["headers"].pairs:
          res.headers[$key] = $val.to cstring
        r.on("data") do (chunk: auto):
          res.body &= $toString chunk
        r.on("end") do (_: auto):
          resolve res
      let req = if url[0..<5] == "https": httpsRequest(url, options, cb) else: httpRequest(url, options, cb)
      req.on("error") do (_: auto):
        promiseResolve res
      `end` req
  return promise
