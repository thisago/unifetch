<div align=center>

# Unifetch

#### Multi backend HTTP fetching

**[About](#about) - [Usage](#usage)** - [License](#license)

</div>

## About

The [@myblebot](https://myblebot.t.me) is a inline Telegram bot that provides a MyBible module texts in your chat!

## Usage

```nim
from pkg/unifetch

let
  uni = newUniClient()
  resp = await uni.get("https://google.com")

echo resp.body
```


## License

This library is licensed over MIT license!
