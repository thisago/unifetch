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


const cacheDir {.strdefine: "unifetchCache".} = ""
when cacheDir.len > 0:
  from std/os import `/`, existsOrCreateDir, fileExists
  from std/md5 import toMd5, `$`
  from std/httpcore import HttpHeaders

  import unifetch/toCurl

  try:
    discard existsOrCreateDir cacheDir
  except OsError:
    quit "Cannot create Unifetch cache dir: " & cacheDir

  proc reqCacheFile(
    httpHeaders: HttpHeaders;
    url: string or Uri;
    httpMethod: HttpMethod;
    body = ""
  ): string {.inline.} =
    ## Returns the request cache file, where request response is cached
    let id = $toMd5 toCurl(httpHeaders, url, httpMethod, body)
    result = cacheDir / id


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
  ##
  ## Compile with `-d:unifetchCache=/tmp/unifetchCache`
  when cacheDir.len > 0:
    let cache = reqCacheFile(headers, url, httpMethod, body)
    if cache.fileExists:
      return readFile cache

  let client = newUniClient(headers = headers, proxy = proxy)
  defer: close client
  let resp = await client.request(url, httpMethod, body, multipart)
  if resp.code.is4xx or resp.code.is5xx:
    raise newException(UnifetchError, $resp.code)
  else:
    result = resp.body

  when cacheDir.len > 0:
    cache.writeFile result


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
  echo waitFor fetch "https://httpbin.org/get"
  echo now()
  echo waitFor fetch "https://httpbin.org/get"
  echo now()
