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
  from std/jsonutils import toJson, jsonTo

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
      {.fatal: "Caching not implemented for NodeJS".}
    else:
      const localStorageConfKey = "unifetchCache"
      type
        CacheConfig = object
          cachedIds: seq[string]
          cacheDir: string

      when defined userscript:
        {.fatal: "Caching not implemented for userscript".}
      else:
        from std/dom import window, getItem, setItem, Storage
        from std/jsffi import hasOwnProperty

        proc getCacheConf: CacheConfig =
          try:
            result = window.localStorage.getItem(localStorageConfKey).`$`.parseJson.jsonTo CacheConfig
          except:
            result = CacheConfig(
              cacheDir: cacheDir
            )

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
        # Caching not implemented for NodeJS
        discard
      elif defined userscript:
        # Caching not implemented for userscript
        discard
      else:
        var conf = getCacheConf()
        let id = $toMd5 toCurl(httpHeaders, url, httpMethod, body)
        if id in conf.cachedIds:
          let cacheData = window.localStorage.getItem(id).`$`.split "\l"
          promiseResolve cacheData[1].parseJson.jsonTo UniResponse
        else:
          proc resolve(resp: UniResponse) {.inject.} =
            window.localStorage.setItem(id, $url & "\l" & $resp.toJson)
            conf.cachedIds.add id
            window.localStorage.setItem(localStorageConfKey, $conf.toJson)
            promiseResolve resp
          bodyCode
    else:
      proc resolve(resp: UniResponse) {.inject.} =
        promiseResolve resp
      bodyCode
