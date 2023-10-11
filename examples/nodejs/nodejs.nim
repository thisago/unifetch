import std/asyncjs
import pkg/unifetch

proc main {.async.} =
  echo await fetch(
    url = "https://httpbin.org/get",
    headers = newHttpHeaders({
      "Test": "hello",
      "bye": "test2"
    })
  )

discard main()
