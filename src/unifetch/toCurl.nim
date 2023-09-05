from std/httpcore import HttpHeaders, HttpMethod, HttpPost, pairs
from std/strformat import fmt
from std/strutils import replace, join
from std/sugar import collect
from std/uri import Uri, `$`

proc toCurl*(
  httpHeaders: HttpHeaders;
  url: string or Uri;
  httpMethod: HttpMethod;
  body = ""
): string =
  ## Unifetch curl representation
  proc escape(s: string): auto =
    s.replace("'", "\\'")
  var headers = collect:
    for (hName, hVal) in httpHeaders.pairs:
      fmt"-H '{escape hName}: {escape hVal}'"
  result = fmt"curl '{escape $url}' " &
              (if httpMethod == HttpPost: "-X POST " else: "") &
              headers.join(" ") &
              (if body.len > 0: fmt" --data-raw '{body}'" else: "")

when isMainModule:
  from std/httpcore import newHttpHeaders, HttpGet
  echo toCurl(
    newHttpHeaders({
      "Header": "Val"
    }),
    "https://example.com",
    HttpGet
  )
  echo toCurl(
    newHttpHeaders({
      "Header": "Val"
    }),
    "https://example.com",
    HttpPost,
    "hello=world"
  )
