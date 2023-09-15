## Unifetch
import std/asyncdispatch
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

proc fetch*(
  url: string;
  httpMethod = HttpGet;
  headers = newHttpHeaders();
  body = "";
  multipart: MultipartData = nil;
  proxy: Proxy = nil
): Future[string] {.async.} =
  ## Single proc request, returns the body and raises an exception if http code
  ## wasn't 200
  let
    client = newUniClient(headers = headers, proxy = proxy)
    resp = await client.request(url, httpMethod, body, multipart)
  if resp.code.is4xx or resp.code.is5xx:
    result = resp.body
  else:
    raise newException(UnifetchError, $resp.code)

when isMainModule:
  let uni = newUniClient(headers = newHttpHeaders({
    "tst": "asd"
  }))
  uni.headers = newHttpHeaders({
    "tst": "asd",
    "tstadas": "sdasd"
  })
  let req = waitFor uni.get("https://httpbin.org/get")
  echo req.body
  echo req.code
  echo req.headers[]
  close uni
