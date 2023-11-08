## Unifetch
when not defined js:
  import std/asyncdispatch
else:
  import std/asyncjs

when not defined js:
  import unifetch/backends/desktop
  export desktop
elif defined nodejs:
  import unifetch/backends/nodejs
  export nodejs
elif defined userscript:
  import unifetch/backends/userscript
  export userscript
else:
  import unifetch/backends/web
  export web

from std/uri import Uri

using
  uni: UniClient
  url: Uri or string
  body: string
  multipart: MultipartData

proc get*(uni; url): Future[UniResponse] {.async.} =
  ## Unifetch GET
  result = await uni.request(url, HttpMethod.HttpGet, multipart = nil)

proc post*(uni; url; body; multipart): Future[UniResponse] {.async.} =
  ## Unifetch GET
  result = await uni.request(url, HttpMethod.HttpPost, body, multipart)

proc fetch*(
  url: string;
  httpMethod = HttpGet;
  headers = newHttpHeaders();
  body = "";
  multipart: MultipartData = nil;
  proxy: Proxy = nil;
  insecure = false
): Future[string] {.async.} =
  ## Single proc request, returns the body and raises an exception if http code
  ## wasn't 200
  ##
  ## Compile with `-d:unifetchCache=/tmp/unifetchCache`
  let client = newUniClient(headers = headers, proxy = proxy, insecure = insecure)
  defer: close client
  let resp = await client.request(url, httpMethod, body, multipart)
  if resp.code.is4xx or resp.code.is5xx:
    raise newException(UnifetchError, $resp.code)
  else:
    result = resp.body

when isMainModule:
  # let uni = newUniClient(headers = newHttpHeaders({
  #   "tst": "asd"
  # }))
  # uni.headers = newHttpHeaders({
  #   "tst": "asd",
  #   "tstadas": "sdasd"
  # })
  # let req = waitFor uni.get("https://httpbin.org/get")
  # echo req.body
  # echo req.code
  # echo req.headers[]
  # close uni
  import times
  echo now()
  echo waitFor fetch("https://localhost", insecure = true)
  echo now()
  echo waitFor fetch "https://localhost"
  echo now()
