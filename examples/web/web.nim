import std/asyncjs
from std/dom import document, getElementById

import pkg/unifetch

proc main {.async.} =
  document.getElementById("response").innerHTML = await fetch(
    url = "https://corsproxy.io/?https://httpbin.org/get",
    headers = newHttpHeaders({
      "Test": "hello",
      "bye": "test2"
    })
  )

discard main()
