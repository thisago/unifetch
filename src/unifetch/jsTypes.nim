when not defined js:
  {.fatal: "Submodule designed for JS backend".}

from std/uri import Uri, parseUri

## std/httpclient compatibility
type
  Proxy* = ref object
    url*: Uri
    auth*: string

  MultipartEntry = object
    name, content: string
    case isFile: bool
    of true:
      filename, contentType: string
      fileSize: int64
      isStream: bool
    else: discard

  MultipartEntries* = openArray[tuple[name, content: string]]
  MultipartData* = ref object
    content: seq[MultipartEntry]

proc newProxy*(url: string; auth = ""): Proxy =
  ## Constructs a new `TProxy` object.
  result = Proxy(url: parseUri url, auth: auth)

proc newProxy*(url: Uri; auth = ""): Proxy =
  ## Constructs a new `TProxy` object.
  result = Proxy(url: url, auth: auth)
  