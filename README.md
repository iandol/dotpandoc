# Pandoc Configuration Files

> Write once, display as desired

This is my "live" Pandoc data directory contents (default location: `$HOME/.local/share/pandoc/` on macOS and Linux). I usually use [`pandocomatic`](https://github.com/htdebeer/pandocomatic) to manage Pandoc via my [`pandocomatic.yaml`](https://github.com/iandol/dotpandoc/blob/master/pandocomatic.yaml) configuration file. Pandocomatic automates all Pandoc settings, so you simply assign one or more "recipes" in your document metadata (docx-refs, latex-letter etc.) and the correct Pandoc settings are used for you. Pandocomatic can also run pre– and post–processing scripts to help with tweaks Pandoc may not be able to implement directly. Many of my pandocomatic recipes are also available as [defaults files](https://pandoc.org/MANUAL.html#defaults-files) callable directly using `pandoc -d`.

Most of my writing is academic in nature. **I want to write once, and the compile process should convert text to multiple outputs (separation of concerns)**. I mostly use pandocomatic recipes triggered automagically via Scrivener's post-processing compile feature; see [Scrivomatic](https://github.com/iandol/scrivomatic) for more details of the workflow. My templates and filters are customised: I've collected and modified several [Pandoc templates](https://github.com/iandol/dotpandoc/tree/master/templates) and use a [set of filters to transform Academic metadata](https://github.com/iandol/dotpandoc/tree/master/filters) to multiple outputs; my older filters are written in Ruby using [https://github.com/htdebeer/paru](Paru) or more recently in Lua. 

I have my own personal choice of fonts, you should change the font metadata to those you have on your computer.

## Filters

I have a set of filters to convert academic metadata for multiple outputs. I also have some helpful general filters that tend to support multiple output formats:

* alerts.lua — admonitions / alerts using GFM or divs and outputs to ODT / DOCX / Typst / HTML / LaTeX
* convertIndex.lua — Use a generic \index{key} markup for ODT / DOCX / Typst / LaTeX general output.
* querverweis.lua — slightly modified from https://codeberg.org/tarleb/querverweis to add in-text labels (see Figure X)...
* typstFix.lua — convert `<label>` and cross-refs like `@fig-one` to raw typst so you do not have conflicts with citeproc that uses `@citekey` syntax.

Other filters I've added but may have forgotten...

## Templates

My Typst, ODT, DOCX and LaTeX defaults are modified from Pandoc, and I try to keep them up-to-date. On top of that I've collected or adapted several other template callable using defaults:

* letter.yaml — general letter writing using Typst.
* lapreprint.yaml — a brilliant typst template for bioRxiv preprints.
* eisvogel — a LaTeX report template modified to support my academic metadata
* tufte-book — modified for pandoc and several edge cases.
