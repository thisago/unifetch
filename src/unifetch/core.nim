from std/httpcore import HttpHeaders, newHttpHeaders, HttpCode, `$`
export httpcore

from std/uri import Uri, parseUri
export uri

const uaMozilla* = "Mozilla/5.0 (Windows NT 10.0; rv:109.0) Gecko/20100101 Firefox/115.0"

const unifetchDebugCurl* {.booldefine.} = false

type
  UniClientBase* = ref object of RootObj
  UniResponse* = ref object
    headers*: HttpHeaders
    code*: HttpCode
    body*: string
