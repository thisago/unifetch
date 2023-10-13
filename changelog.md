# Changelog

## Version 0.8.0 (2023/10/13)

- Implemented NodeJS backend
- Added NodeJS cache

## Version 0.7.1 (2023/09/28)

- Removed cache list from LocalStorage for web caching

## Version 0.7.0 (2023/09/28)

- Added caching for web backend with localStorage!

## Version 0.6.0 (2023/09/28)

- Moved `get` and `post` procs to main file to prevent duplication
- Added JS backend!
- Added examples for backends:
  - Desktop
  - JS

## Version 0.5.0 (2023/09/28)

- Added requested url to cache file

## Version 0.4.1 (2023/09/26)

- Fixed missing import when cache is disabled

## Version 0.4.0 (2023/09/26)

- Added fetch cache in any request proc

## Version 0.3.0 (2023/09/26)

- Added `unifetch.fetch` persistent caching (for development purposes)
- Added useragent to directly to client headers to show in curl representation
- Renamed debug curl representation option to `-d:unifetchShowCurlRepr`

## Version 0.2.0 (2023/09/14)

- Added `fetch` proc, single call request

## Version 0.1.3 (2023/09/05)

- Fixed 1.6.4 issue

## Version 0.1.2 (2023/09/05)

- Added debug option `-d:unifetchDebugCurl` to show curl representation of the request

## Version 0.1.1 (2023/09/03)

- Exported `unifetch.backends.desktop.request`

## Version 0.1.0 (2023/08/25)

- Init
