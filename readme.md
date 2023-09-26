<div align=center>

# Unifetch

#### Multi backend HTTP fetching

**[About](#about) - [Why?](#why) - [Usage](#usage)** - [License](#license)

> **Warning**
> Not all backends are implemented.

</div>

## About

Unified fetching

## Why?

Compile the same code to any backend with extra features!

### Development features

Also, Unifetch provides you helpful features for development purposes

#### Curl representation

If some request isn't worked as expected for some reason, you can enable this
feature with `-d:unifetchShowCurlRepr`

#### Persistent caching

You can enable a persistent request caching with `-d:unifetchCache=/tmp/unifetchCache`.
All requests would be saved into specified directory and skip when the parameters
is exactly the same and cache exists.

## Usage

```nim
from pkg/unifetch

echo fetch "https://example.com"
```

or

```nim
from pkg/unifetch

let
  uni = newUniClient()
  resp = await uni.get("https://example.com")

echo resp.body
```

## TODO

- [ ] Backends
  - [-] Desktop
  - [ ] Javascript
    - [ ] NodeJS
    - [ ] Web
    - [ ] Userscript
- [ ] Add tests

## License

This library is licensed over MIT license!
