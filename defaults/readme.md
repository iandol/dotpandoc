# Pandoc Defaults

From V2.8, Pandoc allows us to pass in sets of default.yaml settings, using the `--defaults | -d` option. This folder contains several of such yaml files modified from my pandomcomatic templates. You can call them like so:

```shell
pandoc -d refs -d latex test.md -o test.tex
```

Notice you can combine sets together, so for example `-drefs -dhtml -dpdf-prince` will make a PDF using prince from HTML outputs with CSL references.

Documentation is here: https://pandoc.org/MANUAL.html#default-files 

## Defaults and Scrivener

While I still prefer to use pandocomatic, these defaults files do simplify the setup for people who may prefer a single requirement (only Pandoc is needed). Currently you cannot call pandoc defaults from metadata (though see https://github.com/jgm/pandoc/issues/5870), what this means is that you can't use the metadata edited in Scrivener to customise your compile. BUT you can create different Compile formats in Scriveners Compile manager, each  with a different set of pandoc defaults options, i.e. output with citeproc references to docx:

![](https://raw.githubusercontent.com/iandol/scrivomatic/master/images/defaults.png)
_ _ _ _ _ _
_Figure 1 — Compile post-processing in Scrivener to call the default files to generate a docx with references processed with citeproc…_
_ _ _ _ _ _


