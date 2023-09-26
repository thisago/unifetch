from std/httpcore import HttpHeaders, newHttpHeaders, HttpCode, `$`, is4xx, is5xx,
                          HttpMethod
export httpcore

from std/uri import Uri, parseUri
export uri

const uaMozilla* = "Mozilla/5.0 (Windows NT 10.0; rv:109.0) Gecko/20100101 Firefox/115.0"

const showCurlRepr* {.booldefine: "unifetchShowCurlRepr".} = false

type
  UniClientBase* = ref object of RootObj
  UniResponse* = ref object
    headers*: HttpHeaders
    code*: HttpCode
    body*: string
  UnifetchError* = object of IOError
    ## Raised when `unifetch.fetch` request wasn't successful

const cacheDir {.strdefine: "unifetchCache".} = ""
when cacheDir.len > 0:
  when defined js:
    {.fatal: "JS cache is not implemented yet :(".}

  import std/asyncdispatch
  from std/os import `/`, existsOrCreateDir, fileExists
  from std/md5 import toMd5, `$`
  from std/httpcore import HttpHeaders, `$`
  from std/json import parseJson, `$`
  from std/jsonutils import toJson, jsonTo

  import unifetch/toCurl

  try:
    discard existsOrCreateDir cacheDir
  except OsError:
    quit "Cannot create Unifetch cache dir: " & cacheDir

template requestIfNoCache*(
  res: UniResponse;
  httpHeaders: HttpHeaders;
  url: string or Uri;
  httpMethod: HttpMethod;
  body = "";
  bodyCode: untyped
) =
  ## Runs `bodyCode` if no cache exists then save it or if cache is disabled
  ## just run
  when cacheDir.len > 0:
    let
      id = $toMd5 toCurl(httpHeaders, url, httpMethod, body)
      path = cacheDir / id
    if path.fileExists:
      res = path.readFile.parseJson.jsonTo UniResponse
    else:
      bodyCode
      path.writeFile($res.toJson)
  else:
    bodyCode
