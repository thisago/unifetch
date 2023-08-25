from std/httpcore import HttpHeaders, newHttpHeaders, HttpCode, `$`
export httpcore

from std/uri import Uri, parseUri
export uri

type
  UniClientBase* = ref object of RootObj
  UniResponse* = ref object
    headers*: HttpHeaders
    code*: HttpCode
    body*: string
