# `xtpxlib-xdoc`: Xatapult XML Library - DocBook based documentation generation support

Version, release and dependency information: See `/version.xml` 

Xatapult Content Engineering - http://www.xatapult.nl

Erik Siegel - erik@xatapult.nl - +31 6 53260792

----

**`xtpxlib`** is a library containing software for processing XML, using languages like 
XSLT, XProc etc. It consists of several separate components, named `xtpxlib-*`. Everything can be found on GitHub ([https://github.com/eriksiegel](https://github.com/eriksiegel)).

**`xtpxlib-xdoc`** ([https://github.com/eriksiegel/xtpxlib-xdoc](https://github.com/eriksiegel/xtpxlib-xdoc)) is a library that supports conversions from DocBook&#160;5 with so-called xdoc extensions into "pure" DocBook&#160;5. From there you can convert it into some target format (currently only PDF through FOP is supported).

Xdoc extensions in the source DocBook can be standard ones, defined by this component (for instance formatting XML element descriptions). You can also easily add special conversions of your own, either in XProc or XSLT. There is documentation about all this in the component's `doc` folder.

----

## Using `xtpxlib`

* Clone the GitHub repository to some appropriate location on disk. That's basically it for installation.
* If you use more than one `xtpxlib` component, all repositories must be cloned in the same base directory.

----

## Library contents

### Directories at root level

| Directory | Description | Remarks |
| --------- | ----------- | --------|
| `doc` | Documentation. | See the documentation section below. This directory contains both the source and the PDF versions. So it can also serve as an example. |
| `etc` | Other files, mostly for use inside oXygen. |  |
| `test` | Test scripts and sources. |  |
| `transforms` | Special transformations. | See the documentation section below. |
| `xpl` | XProc pipelines for conversion of the DocBook. |  |
| `xsd` | Schemas for some of the formats used  by this component. |  |
| `xslmod` | XSLT libraries for internal component usage. |  |

The subdirectories named `tmp` and  `build` may appear while running parts of the library. These directories are for temporary and build results. Git will ignore them because of the `.gitignore` settings.

Most files contain a header comment about what they're for.

----

## Documentation

The `doc` folder contains several pieces of important documentation, all created for the conversion pipelines in this component. For each documentation part, as mentioned in the table below, there is both the XML xdoc source *and* the resulting PDF. The XML sources also serve as examples. The PDF's are created with the `xpl/xdoc-to-pdf` pipeline.


| Documentation | Description |
| ------------- | ----------- |
| `db5-dialect-description-article` | Describes which DocBook&#160;5 constructs are supported and which not. |
| `xdoc-extensions-description-article` | Describes the xdoc extension mechanism and the built-in xdoc conversions. |

----

## Notes on the DocBook schemas

The component contains an `xsd/docbook` folder that contains the docbook schemas with the adaptation that it now also accepts the xdoc extensions used by this library.

The original schemas were downloaded from [https://docbook.org/xml/5.1/](https://docbook.org/xml/5.1/) and stored in `xsd/docbook` The `docbook.nvdl` file was changed. The changes are marked with comments.

Use the `xsd/docbook/docbook.nvdl` file for validating your DocBook-with-xdoc contents.
