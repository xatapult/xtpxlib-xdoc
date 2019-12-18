# `xtpxlib-xdoc`: Xatapult XML Library - DocBook publication toolchain

**Xatapult Content Engineering - [`http://www.xatapult.com`](http://www.xatapult.com)**

---------- 

The `xtpxlib-xdoc` component contains an XProc (1.0) based DocBook publication toolchain. 
* Starting point is some narrative written in DocBook, with the following extensions:
  * Parameter references that are expanded (for dates, times, phrases, names, etc.)
  * Special elements that trigger conversions. These conversions can insert generated DocBook into the source. For instance complex tables, documentation, etc.
* The resulting "pure" DocBook can be used for further processing. 
* The component contains specific pipelines for converting the DocBook to PDF and XHTML  

## Technical information

Component version: V0.9 - 2019-12-18

Documentation: [`https://xdoc.xtpxlib.org`](https://xdoc.xtpxlib.org)

Git URI: `git@github.com:xatapult/xtpxlib-xdoc.git`

Git site: [`https://github.com/xatapult/xtpxlib-xdoc`](https://github.com/xatapult/xtpxlib-xdoc)
      
This component depends on:
* [`xtpxlib-container`](https://container.xtpxlib.org) (Support for XML containers (multiple files wrapped into one))
* [`xtpxlib-common`](https://common.xtpxlib.org) (Common component: Shared libraries and IDE support)

## Version history

**V0.9 - 2019-12-18 (current)**

Pre-release to test GitHub pages functionality.


