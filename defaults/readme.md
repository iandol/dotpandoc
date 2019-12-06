# Pandoc Defaults

From V2.8, Pandoc allows us to pass in sets of default.yaml settings, using the `--defaults | -d` option. This folder contains several of such yaml files modified from my pandomcomatic templates. You can call them like so:

```shell
pandoc -d refs -d latex test.md -o test.tex
```

Notice you can combine sets together, so for example `-drefs -dhtml -dpdf-prince` will make a PDF using prince from HTML outputs with references.

Documentation is here: https://pandoc.org/MANUAL.html#default-files 

