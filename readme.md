<div align=center>

# Unifetch

#### Multi backend HTTP fetching

**[About](#about) - [Usage](#usage)** - [License](#license)

</div>

## About

Unified fetching

## Usage

```nim
from pkg/unifetch

let
  uni = newUniClient()
  resp = await uni.get("https://google.com")

echo resp.body
```

## TODO

- [ ] Unifetch proc
- [ ] Backends
  - [-] Desktop
  - [ ] Javascript
    - [ ] NodeJS
    - [ ] Web
    - [ ] Userscript

## License

This library is licensed over MIT license!
