# Pandoc Configuration Files #
This is a fork of iandol's Pandoc data directory [`contents`](https://github.com/iandol/dotpandoc) (default location: `$HOME/.local/share/pandoc/` on macOS and Linux). 

Iandol uses [`pandocomatic`](https://github.com/htdebeer/pandocomatic) to manage Pandoc via the [`pandocomatic.yaml`](https://github.com/iandol/dotpandoc/blob/master/pandocomatic.yaml) configuration file. Pandocomatic automates all Pandoc settings, so simply assign one or more "recipes" in the document metadata (docx-refs, latex-letter etc.) and the correct Pandoc settings are used for you. Pandocomatic can also run pre– and post–processing scripts to help with tweaks Pandoc may not be able to implement directly. Some of Iandol's pandocomatic recipes are also available as [defaults files](https://pandoc.org/MANUAL.html#defaults-files) callable directly using `pandoc -d`.

Iandol generally uses pandocomatic recipes triggered automagically via Scrivener's post-processing compile feature; see [Scrivomatic](https://github.com/iandol/scrivomatic) for more details of the workflow. These templates and filters are customised: several [Pandoc templates](https://github.com/iandol/dotpandoc/tree/master/templates) have been collected and modified, and use a [set of filters to transform Academic metadata](https://github.com/iandol/dotpandoc/tree/master/filters) to multiple outputs; the filters are written in Ruby using [https://github.com/htdebeer/paru](Paru). 

Don't forget to change the font metadata to those you have on your computer.
