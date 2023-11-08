when not defined js:
  {.fatal: "This submodule doesn't works with non JS backends".}

import std/asyncjs
from std/dom import Event
from std/uri import `$`
import jsconsole

import pkg/ajax

import unifetch/core
export core except UniClientBase

when showCurlRepr:
  import unifetch/toCurl

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
                   proxy: Proxy = nil; insecure = false): UniClient =
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

  when not defined release:
    if not proxy.isNil:
      echo "Proxy is ignored at JS backend."
    if insecure:
      echo "There's no way to disable SSL verification on browser."

proc close*(uni) =
  ## Just to compatibilize with desktop backend

proc request*(uni; url; httpMethod; body = ""; multipart): Future[UniResponse] =
  ## Do the request
  when showCurlRepr:
    echo toCurl(uni.headers, url, httpMethod, body)
  let promise = newPromise() do (promiseResolve: proc(resp: UniResponse)):
    var res: UniResponse
    promiseResolve.requestIfNoCache(res, uni.headers, url, httpMethod, body):
      var xml = newXMLHttpRequest()
      if xml.isNil:
        raise newException(UnifetchError, "Cannot create an XML HTTP instance.")
        return
      xml.onreadystatechange = proc (e: Event) =
        if xml.readyState == rsDone:
          new res
          res.code = HttpCode xml.status
          res.body = $xml.responseText
          resolve res

      xml.open($httpMethod, $url)
      for (key, value) in uni.headers.pairs:
        xml.setRequestHeader(key.cstring, value.cstring)
      send xml
  return promise
