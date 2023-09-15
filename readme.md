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

Compile the same code to any backend

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
