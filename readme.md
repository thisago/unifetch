<div align=center>

# Unifetch

#### Multi backend HTTP fetching

**[About](#about) - [Features](#features) - [Why?](#why) - [Usage](#usage)** - [License](#license)

> **Warning**
> Not all backends are implemented.

</div>

## About

Unified fetching

## Features

- Supported backends
  - [x] C-like
  - [x] Javascript
    - [x] Web (async XMLHttpRequest)
    - [x] NodeJS (std http/https)
    - [ ] Userscript (GM API)
- [x] Sharable request caching over backends and others binaries
- [x] Request Curl representation

## Why?

Compile the same code to any backend with extra features!

### Development features

Also, Unifetch provides you helpful features for development purposes

#### Curl representation

If some request isn't worked as expected for some reason, you can enable this
feature with `-d:unifetchShowCurlRepr` and analyze the curl request externally!

#### Persistent caching

You can enable a persistent request caching with `-d:unifetchCache=/tmp/unifetchCache`.
All requests would be saved into specified directory and skip when the parameters
is exactly the same and cache exists.

In JS-web backend the cache is stored in LocalStorage, every request saves a new
entry

## Usage

```nim
import pkg/unifetch

echo fetch "https://example.com"
```

or

```nim
import pkg/unifetch

let
  uni = newUniClient()
  resp = await uni.get("https://example.com")

echo resp.body
```

## TODO

- [ ] Javascript Backend
  <!-- - [ ] Use fetch for web -->
  - [ ] Userscript (GM API)
  - [ ] Implement proxy at NodeJS backend
- [ ] Add tests
- [ ] Production ready caching (without response parameters or encrypting it) with optional expiration
  - [ ] Optional runtime only cache

## License

This library is licensed over MIT license!
