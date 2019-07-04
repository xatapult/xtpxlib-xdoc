# `xtpxlib-xdoc`: Xatapult XML Library - DocBook based documentation generation support

Version, release and dependency information: See `/version.xml` 

Xatapult Content Engineering - http://www.xatapult.nl

Erik Siegel - erik@xatapult.nl - +31 6 53260792

----

**`xtpxlib`** is a library containing software for processing XML, using languages like 
XSLT, XProc etc. It consists of several separate components, named `xtpxlib-*`. Everything can be found on GitHub ([https://github.com/eriksiegel](https://github.com/eriksiegel)).

**`xtpxlib-xdoc`** ([https://github.com/eriksiegel/xtpxlib-TBD](https://github.com/eriksiegel/xtpxlib-TBD)) is TBD.

----

## TODOs

* Change namespace into xtpxdoc
* Schema adapt so constructs in this namespace validate (against own schema, that would be nice!)
* Revisit the XML structure stuff. Too complex (refers to global stuff nobody uses), different format?
  * Generate from schemas/check against schemas? 
* Rewrite documentation and eat own dogshit: Add constructs for XML structures, pipeline calls, schema calls, etc.
* Add something standard for parameters
* Contents based on parameters? if/choose constructs?
* Consolidate all convert stuff into a single pipeline (and rename docbook-db5, name is not intuitive)
* For FOP: Table column width when column is fixed width based on code entries. @role based?
* Output to others: HTML, Markdown 

**Requirements**

* Multilingual?
* Parameter drive



**PROCESS**

* Must be able to pass filters for the parameter expansion
  * And must be able to set defaults for the filters!
* Include all files 
* Validate
* Process and expand parameters
    * Must be able to escape these
* Process the various stuff:
  * XML descriptions ==> is a general XProc pipeline
  * So... distinguish between core stuff (do XProc/XSLT)  and built-in expansions (XProc for XML descriptions)? 
  * XProcs
  * XSLTs     
* What do we do with refs to chaqpters etc. Text must be multilingual!

----

## Using `xtpxlib`

* Clone the GitHub repository to some appropriate location on disk. That's basicly it for installation.
* If you use more than one `xtpxlib` component, all repositories must be cloned in the same base directory.

----

## Notes on installing the DocBook schemas

TBD: in docbook folder, remove tools and documentation. From downloaded zip in [https://docbook.org/xml/5.1/](https://docbook.org/xml/5.1/)

Use currently V5.1

----

## FROM OLD TBD

## XProc libraries

Subdirectory: `xplmod`

| Library | Description |
|----|----|
| `db5-pdf.mod/db5-pdf.mod.xpl` | Turns a limited subset of Docbook 5 into PDF using XSL-FO/FOP. The Docbook 5 dialect used van be found in `test/db5-dialect-description/db5-dialect-description.xml`. If you want to turn this into a PDF, use the module test script `xplmod/db5-pdf.mod/test/test-db5-pdf.xpl`. |
| `descriptions-db5.mod/descriptions-db5.mod.xpl` | Turns descriptions of XML constructs, that you can mingle with your Docbook 5 contents, into full descriptions. Examples in `test/element-description/` | 
| `convert-db5.mod/convert-db5.mod.xpl` | Checks for several conversion elements in the source to apply an XSL or XProc directly. See also the documentation of the module.| 

----

## Library contents

### Directories at root level

| Directory | Description | Remarks |
| --------- | ----------- | --------|
| `data` | Static data files. |  |
| `etc` | Other files, mostly for use inside oXygen. |  |
| `xplmod` | XProc 1.0 libraries. |  |
| `xsd` | XML Schemas. |  |
| `xsl` | XSLT scripts. |  |
| `xslmod` | XSLT libraries. |  |

The subdirectories named `tmp` and  `build` may appear while running parts of the library. These directories are for temporary and build results. Git will ignore them because of the `.gitignore` settings.

Most files contain a header comment about what they're for.
