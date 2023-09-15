import std/asyncdispatch

from std/httpclient import newAsyncHttpClient, close, request, AsyncHttpClient,
                            HttpMethod, MultipartData, HttpMethod, Proxy,
                            newProxy, code, body
export httpclient


import unifetch/core
export core except UniClientBase

when unifetchDebugCurl:
  import unifetch/toCurl

type UniClient* = ref object of UniClientBase
  ## Non JS Unifetch object
  client: AsyncHttpClient

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
                   proxy: Proxy = nil): UniClient =
  ## Creates new UniClient object
  new result
  result.client = newAsyncHttpClient(userAgent, proxy = proxy, headers = headers)

proc close*(uni) =
  ## Closes client
  close uni.client

proc request*(uni; url; httpMethod; body = ""; multipart): Future[UniResponse] {.async.} =
  ## Do the request
  when unifetchDebugCurl:
    echo toCurl(uni.headers, url, httpMethod, body)

  let resp = await uni.client.request(url, httpMethod, body,
                                      multipart = multipart)
  new result
  result.code = resp.code
  result.body = await resp.body
  result.headers = resp.headers

proc get*(uni; url): Future[UniResponse] {.async.} =
  ## Unifetch GET
  result = await uni.request(url, HttpMethod.HttpGet, multipart = nil)

proc post*(uni; url; body; multipart): Future[UniResponse] {.async.} =
  ## Unifetch GET
  result = await uni.request(url, HttpMethod.HttpPost, body, multipart)
