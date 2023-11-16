# Package

version       = "0.10.0"
author        = "Thiago Navarro"
description   = "Multi backend HTTP fetching"
license       = "MIT"
srcDir        = "src"


# Dependencies

requires "nim >= 1.6.4"

when defined js:
  requires "ajax", "nodejs"
