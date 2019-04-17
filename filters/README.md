# My Filters #
Most of the filters here are really aimed to handle academic paper workflows. For scientific papers we normally have multiple authors, each with an affiliation to an Istitution and optionally an address for correspondence. Pandoc offers templates that allow us to convert metadata into this structured content, and for HTML and LaTeX I use this mechanism. Word and LibreOffice do not allow such flexibility, and so we must use filters to transform the metadata to add the correct information to the document body itself.

My YAML metadata normally looks something like this (<$…> are Scrivener placeholders):

```yaml
title: "<$projecttitle>"
author:
  - name: Joanna Doe
    affiliation: 1
    equal_contributor: true
    correspondence: joanna@doe.org
  - name: John Doe
    affiliation: 1,2
    equal_contributor: true
institute:
  - 1: University of X
  - 2: Institute of Y
keywords:
  - example
  - metadata
created: "<$createdDate>"
compiled: "<$fulldate> @ <$fulltime>"
wordcount: <$wc>
pandocomatic_:
  use-template: [docx-refs, html-refs-pdf]
  pandoc:
    bibliography: Core.json 
    csl: csl/cell.csl
```

The [assimilateMetadata](https://github.com/iandol/dotpandoc/blob/master/filters/assimilateMetadata) filter is the main filter that makes sure the author and institute fields are converted into the correct formats, adding a new field `correspondence_list` and `equal_contributions` for Pandoc templates to use.

The [simplifyMetadata](https://github.com/iandol/dotpandoc/blob/master/filters/authorSimplifyMetadata) filter takes the author fields and modifies them to work with Word/LibreOffice, collapsing `affiliation`, `correspondence` and `equal_contributor` to superscripts after the name, and adding the `correspondence` information as a paragraph directly into the document body:

```
---
author:
  - Joanna Doe ^1*†^
  - John Doe ^2†^
---
† equal contribution
* Correspondence: joanna@doe.org
```


Likewise, my [prependInstitute](https://github.com/iandol/dotpandoc/blob/master/filters/prependInstitute) filter takes the `institute` metadata and prepends a paragraph into the document body:

```
Affiliations: ^1^ — University of X & ^2^ — Institute of Y
```

As I also prepend comments and keywords, I've created a filter that prepends a "list of metadata entries", which is a bit faster than running sperate prependXXX filters for each item to prepend: [prependAll](https://github.com/iandol/dotpandoc/blob/master/filters/prependAll). [prependAuthor](https://github.com/iandol/dotpandoc/blob/master/filters/prependAuthor) is used to get author information into plain-text outputs.

Other filters here are from other sources or for testing purposes. I do use addToday and removeHR regularly.

As an alternative to my metadata filter, you could also use Pandoc-Scholar's Lua filter: https://github.com/pandoc-scholar/pandoc-scholar/tree/master/lua-filters/scholarly-metadata  


