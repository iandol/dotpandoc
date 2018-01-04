# My Filters #
Some of the filters here are really aimed to handle academic paper workflows. For scientific papers we normally have multiple authors, each with an affiliation to an Istitution and optionally an address for correspondence. Pandoc offers templates that allow us to convert metadata into this structured content, and for HTML and LaTeX I use this mechanism. Word and LibreOffice do not allow such flexibility, and so we must use filters to transform the metadata to add the correct information to the document body itself.

My YAML metadata normally looks like this (<$…> are Scrivener placeholders):

```yaml
title: "<$projecttitle>"
institute:
  - ^1^ University of X
  - ^2^ Institute of Y
author:
  - name: Joanna Doe
    affiliation: 1
    correspondence: joanna@doe.org
  - name: John Doe
    affiliation: 2
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

My [authorSimplifyMetadata](https://github.com/iandol/dotpandoc/blob/master/filters/authorSimplifyMetadata) filter takes the author fields and modifies them to work with Word/LibreOffice, collapsing `affiliation` and `correspondence` to superscripts after the name, and adding the `correspondence` information as a paragraph directly into the document body:

```
---
author:
  - Joanna Doe ^1*^
  - John Doe ^2^
---
* Correspondence: joanna@doe.org
```


Likewise, my [prependInstitute](https://github.com/iandol/dotpandoc/blob/master/filters/prependInstitute) filter takes the `institute` metadata and makes a paragraph in the document body:

```
Affiliations: ^1^ University of X & ^2^ Institute of Y
```

Other filters here are from other sources or for testing purposes. I do use addToday and removeHR regularly.

