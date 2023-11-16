when defined js:
  {.fatal: "This submodule doesn't works with JS backend".}

import std/asyncdispatch

from std/httpclient import newAsyncHttpClient, close, request, AsyncHttpClient,
                            HttpMethod, MultipartData, HttpMethod, Proxy,
                            newProxy, code, body
export httpclient
when defined ssl:
  from std/net import newContext, SslCVerifyMode


import unifetch/core
export core except UniClientBase

when showCurlRepr:
  import unifetch/toCurl

type UniClient* = ref object of UniClientBase
  ## Non JS Unifetch object
  client: AsyncHttpClient
  insecure: bool

using
  uni: UniClient
  url: Uri or string
  body: string
  multipart: MultipartData
  httpMethod: HttpMethod

func headers*(uni): HttpHeaders =
  uni.client.headers
func `headers=`*(uni; headers: HttpHeaders) =
  uni.client.headers = headers

proc newUniClient*(useragent = uaMozilla; headers = newHttpHeaders();
                   proxy: Proxy = nil; insecure = false): UniClient =
  ## Creates new UniClient object
  new result
  var newHeaders = headers
  if not newHeaders.hasKey("user-agent") and userAgent.len > 0:
    newHeaders["User-Agent"] = userAgent

  result.insecure = insecure

  when defined ssl:
    let sslContext = newContext(
      verifyMode = if insecure: CVerifyNone else: CVerifyPeer
    )
  elif not defined release:
    const sslContext = nil
    if insecure:
      stderr.writeLine "You aren't using SSL, there's no reason to disable verification."
  result.client = newAsyncHttpClient(
    proxy = proxy,
    headers = newHeaders,
    sslContext = sslContext
  )

proc close*(uni) =
  ## Closes client
  close uni.client

proc request*(uni; url; httpMethod; body = ""; multipart): Future[UniResponse] {.async.} =
  ## Do the request
  when showCurlRepr:
    echo toCurl(uni.headers, url, httpMethod, body, uni.insecure)

  result.requestIfNoCache(uni.headers, url, httpMethod, body):
    let resp = await uni.client.request(url, httpMethod, body,
                                        multipart = multipart)
    new result
    result.code = resp.code
    result.body = await resp.body
    result.headers = resp.headers
