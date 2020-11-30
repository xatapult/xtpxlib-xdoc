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

Component version: V1.1.2 - 2020-11-30

Documentation: [`https://xdoc.xtpxlib.org`](https://xdoc.xtpxlib.org)

Git URI: `git@github.com:xatapult/xtpxlib-xdoc.git`

Git site: [`https://github.com/xatapult/xtpxlib-xdoc`](https://github.com/xatapult/xtpxlib-xdoc)
      
This component depends on:
* [`xtpxlib-container`](https://container.xtpxlib.org) (Support for XML containers (multiple files wrapped into one))
* [`xtpxlib-common`](https://common.xtpxlib.org) (Common component: Shared libraries and IDE support)

## Version history

**V1.1.2 - 2020-11-30 (current)**

Various small changes and fixes

**V1.1.1 - 2020-10-15**

Added `id-suffix` option to generating code documentation.

When XProc options are declared twice (using `@use-when`), only the first is used.

**V1.1 - 2020-05-01**

Updated the DocBook to PDF conversion (added footnotes, callouts, nested tables, etc.).

**V1.0.A - 2020-02-16**

New logo and minor fixes.

**V1.0 - 2019-12-18**

Initial release

**V0.9 - 2019-12-18**

Pre-release to test GitHub pages functionality.


