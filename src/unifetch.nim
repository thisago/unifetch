## Unifetch

when not defined js:
  import unifetch/backends/desktop
  export desktop
elif defined nodejs:
  import unifetch/backends/nodejs
  export nodejs
else:
  import unifetch/backends/web
  export web

when isMainModule:
  import asyncdispatch
  let uni = newUniClient(headers = newHttpHeaders({
    "tst": "asd"
  }))
  uni.headers = newHttpHeaders({
    "tst": "asd",
    "tstadas": "sdasd"
  })
  let req = waitFor uni.get("https://httpbin.org/get")
  echo req.body
  echo req.code
  echo req.headers[]
  close uni
