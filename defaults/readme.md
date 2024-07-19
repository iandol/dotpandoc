# Pandoc Defaults

Since V2.8, Pandoc allows one to pass in sets of default.yaml settings, using the `--defaults | -d` option. This option uses a folder (this one) containing yaml files. You can call them directly from pandoc (no need for pandocomatic and ruby at all) like so:

```shell
pandoc -d refs -d latex test.md -o test.tex
```

Notice how you can combine sets together, so for example `-d refs -d html -d pdf-prince` will make a PDF using [princeXML](https://www.princexml.com) from HTML outputs with full CSL academic references. Since Pandoc V2.11 default files can even call other default files, for example see [latex-refs.yaml](https://github.com/iandol/dotpandoc/blob/master/defaults/latex-refs.yaml), so now the combination is specified by the defaults file and you only need to call `-d latex-refs`.

Since Pandoc V2.12 we can now use relative or other paths, using `${VARIABLE}`; for example to refer to the home directory use `${HOME}`. There are two magic env variables:

* `${USERDATA}` — points to the Pandoc data directory (default is `~/.local/share/pandoc/`).
* `${.}` — points to the same folder the defaults file is found, allowing to package up resources in a portable folder.

Documentation is here: https://pandoc.org/MANUAL.html#default-files 

## Defaults and Scrivener

While I still prefer to use pandocomatic, the defaults files do simplify the setup for people who may prefer a single install requirement (only Pandoc is needed, not Ruby). Currently you cannot call pandoc defaults from Scrivener's project metadata file (though see [issue #5870](https://github.com/jgm/pandoc/issues/5870)), what this means is that you can't use the metadata edited *in* Scrivener to customise your compile. **BUT** you can create *different Compile formats* in Scriveners Compile manager, each with a different set of pandoc defaults options, i.e. to output citeproc references to docx:

![](https://raw.githubusercontent.com/iandol/scrivomatic/master/images/defaults.png)
_ _ _ _ _ _
_Figure 1 — Compile post-processing pane in Scrivener to call the default files to generate a docx with references processed with citeproc…_
_ _ _ _ _ _

You make different Compile formats for different combinations of `defaults` options. 

## Why I still prefer pandocomatic?

This is because of pandocomatic's ability to call pre/post processing scripts in a single recipe. For example, by default pandoc-crossref cannot recognise crossrefs in styled caption, so I made a [small script to fix this in the source markdown file](https://github.com/iandol/dotpandoc/blob/master/pandocomatic.yaml#L18). Pandocomatic enables me to easily call this before pandoc is run, without any other fiddling or manual intervention. This is not possible with pandoc directly, you would need to write a wrapper script to call your modifier processors first then run pandoc, and, well, I already have pandocomatic to do that elegantly for me!

As I mentioned above, I also prefer to edit frontmatter metadata in Scrivener's editor (https://github.com/iandol/scrivomatic#compiling-your-project see Fig. 3) -- it means I can quickly change outputs with edits to a text file I manage **directly** in Scrivener's binder, no need to go to the command line, or fiddle with compile formats etc.

