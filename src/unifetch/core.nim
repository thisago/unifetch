from std/httpcore import HttpHeaders, newHttpHeaders, HttpCode, `$`, is4xx, is5xx,
                          HttpMethod
export httpcore

from std/uri import Uri, parseUri
export uri

when defined js:
  import jsTypes
  export jsTypes

const uaMozilla* = "Mozilla/5.0 (Windows NT 10.0; rv:109.0) Gecko/20100101 Firefox/115.0"

const showCurlRepr* {.booldefine: "unifetchShowCurlRepr".} = false
const
  unifetchNodejsUsesNodefetch* = true

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
  # imports for all backends
  from std/md5 import toMd5, `$`
  from std/strutils import split
  from std/json import parseJson, `$`
  # from std/jsonutils import toJson, jsonTo
  import std/jsonutils

  import unifetch/toCurl

when not defined js:
  when cacheDir.len > 0:
    import std/asyncdispatch
    from std/os import `/`, existsOrCreateDir, fileExists
    from std/httpcore import HttpHeaders, `$`

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
        let cacheData = path.readFile.split "\l"
        res = cacheData[1].parseJson.jsonTo UniResponse
      else:
        bodyCode
        path.writeFile($url & "\l" & $res.toJson)
    else:
      bodyCode
else:
  import std/asyncjs
  when cacheDir.len > 0:
    when defined nodejs:
      import pkg/nodejs/jsfs
      from std/os import `/`
      requireFs()

      try:
        if not cacheDir.existsSync:
          mkdirSync cstring cacheDir
      except OsError:
        quit "Cannot create Unifetch cache dir: " & cacheDir
    else:
      when defined userscript:
        {.fatal: "Caching not implemented for userscript".}
      else:
        from std/dom import window, getItem, setItem, Storage

        proc setItem(key, value: cstring) =
          window.localStorage.setItem(key, value)
        proc hasItem(key: cstring): bool =
          not window.localStorage.getItem(key).isNil
        proc getItem(key: cstring): string =
          $window.localStorage.getItem key

  template requestIfNoCache*(
    promiseResolve: proc(resp: UniResponse);
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
      when defined nodejs:
        let
          id = $toMd5 toCurl(httpHeaders, url, httpMethod, body)
          path = cacheDir / id
        if path.existsSync:
          let cacheData = path.readFileSync.`$`.split "\l"
          promiseResolve cacheData[1].parseJson.jsonTo UniResponse
        else:
          proc resolve(resp: UniResponse) {.inject.} =
            echo resp[]
            path.writeFileSync($url & "\l" & $resp.toJson)
            promiseResolve resp
          bodyCode
      else:
        let id = $toMd5 toCurl(httpHeaders, url, httpMethod, body)
        if hasItem id:
          let cacheData = getItem(id).split "\l"
          promiseResolve cacheData[1].parseJson.jsonTo UniResponse
        else:
          proc resolve(resp: UniResponse) {.inject.} =
            setItem(id, $url & "\l" & $resp.toJson)
            promiseResolve resp
          bodyCode
    else:
      proc resolve(resp: UniResponse) {.inject.} =
        promiseResolve resp
      bodyCode
