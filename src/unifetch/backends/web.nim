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

proc request*(uni; url; httpMethod; body = ""; multipart): Future[UniResponse] =
  ## Do the request
  when showCurlRepr:
    echo toCurl(uni.headers, url, httpMethod, body)
  let promise = newPromise() do (resolve: proc(resp: UniResponse)):
    resolve.requestIfNoCache(uni.headers, url, httpMethod, body):
      var xml = newXMLHttpRequest()
      if xml.isNil:
        raise newException(UnifetchError, "Cannot create an XML HTTP instance.")
        return
      xml.onreadystatechange = proc (e: Event) =
        if xml.readyState == rsDone:
          var res = new UniResponse
          res.code = HttpCode xml.status
          res.body = $xml.responseText
          resolve res

      xml.open($httpMethod, $url)
      for (key, value) in uni.headers.pairs:
        xml.setRequestHeader(key.cstring, value.cstring)
      send xml
  return promise
