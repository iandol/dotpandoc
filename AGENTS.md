# AGENTS.md — Pandoc Data Directory

This is a Pandoc data directory (installed at `~/.local/share/pandoc/`) containing
defaults files, filters, templates, CSL styles, and pipeline scripts for producing
academic documents across LaTeX/PDF, Typst, DOCX, ODT, HTML, and EPUB.

## Key Resources

- **Pandoc template syntax**: https://pandoc.org/MANUAL.html#template-syntax
- **Lua filters API** (preferred): https://pandoc.org/lua-filters.html
- Lua filters use the `pandoc` module. The `.luacheckrc` registers pandoc globals
  (`FORMAT`, `PANDOC_VERSION`, `pandoc`, `PANDOC_WRITER_OPTIONS`, etc.).

## Architecture

```
dotpandoc/
├── pandocomatic.yaml    # Central pipeline config (~85 recipes)
├── defaults/            # Pandoc defaults YAML files (`pandoc -d <name>`)
├── filters/             # Lua (.lua) and Ruby (.rb) filters
├── templates/           # Pandoc templates for all output formats
├── csl/                 # Citation Style Language files (~37 styles)
├── preprocessors/       # Scripts run BEFORE Pandoc (Ruby/Python/Shell)
├── postprocessors/      # Scripts run AFTER Pandoc (Ruby/Elvish)
├── metadata/            # Default metadata YAML for Typst
├── custom/              # Custom LaTeX/Typst document classes
├── writers/             # Custom Pandoc writers (e.g. bbcode.lua)
└── scripts/             # Utility scripts (Elvish)
```

## Dual Workflow

This repo supports two modes of running Pandoc:

### 1. pandocomatic (via `pandocomatic.yaml`)
The central pipeline config. Recipes use `extends:` for modular composition.
Each recipe has three stages:
- **preprocessors/** — modify source Markdown before Pandoc
- **filters/** — inline Pandoc AST transforms
- **postprocessors/** — fix output after Pandoc

### 2. Pandoc defaults files (`defaults/`)
Standalone YAML files invoked with `pandoc -d <name>`. Modular:
- Base format files: `latex.yaml`, `html.yaml`, `typst.yaml`, `docx.yaml`, `odt.yaml`
- Feature layers: `refs.yaml` (citeproc), `crossref.yaml` (pandoc-crossref), `index.yaml`
- Combined: `latex-crossref.yaml` extends `[latex, refs, crossref]`

## Filters

### Lua filters (preferred, ~35 files)
Use the Pandoc Lua API. Utility functions are in `filters/shared.lua` and
`filters/logging.lua`. Key conventions:
- Inline filters return a table of 0 results (an empty list) to remove elements
- Filter functions receive the element and return it (modified), `nil` (remove),
  or a new element
- The `FORMAT` global tells you the output format; guard transforms per-format
- Use `pandoc.utils.stringify()` to get plain text from AST inlines

### Ruby filters (~18 files)
Use the Paru gem. Ruby filters are secondary; prefer Lua.

## Templates

Templates use Pandoc's template language (see link above). Key patterns:
- Conditionals: `$if(variable)$...$endif$`
- Loops: `$for(author)$...$endfor$`
- Variables: `$variable$` (escaped), `$variable.html$` (raw)
- Partials: `$partial$` (inject template partials)
- Template naming by format suffix: `.latex`, `.typst`, `.html5`, `.docx`,
  `.odt`, `.plain`

## CSL Styles

Located in `csl/`. Format-specific styles (e.g. `cell2024-ian.csl` is a custom
Cell Press variant). Use with `--csl csl/journal.csl` or via defaults files.

## Output Formats & Pipelines

Primary output targets and their typical pipeline:

| Format | Template | Defaults | Notes |
|--------|----------|----------|-------|
| ODT | `custom.odt` | `odt*.yaml` | Reference ODT for styling; `--reference-doc` |
| DOCX | `custom.docx` | `docx*.yaml` | Multiple reference-docx variants (fonts, colors) |
| Typst | `custom.typst` | `typst*.yaml` | Use `typstFix.lua` filter for compat |
| LaTeX | `custom.latex` | `latex*.yaml` | Multiple doc classes (memoir, tufte, elsarticle, eisvogel) |

Reference documents (`.docx`, `.odt`) define styles, not content — Pandoc
maps its internal style names to the styles defined in the reference file.

## Preprocessors & Postprocessors

Preprocessors modify the **Markdown source** before Pandoc sees it:
- `fixCrossref.rb` — ensures crossref labels survive styled captions
- `convertEndnoteRefs.rb` — EndNote → Pandoc citation syntax
- `criticmarkup*` — CriticMarkup change tracking

Postprocessors fix Pandoc's **output**:
- `fixLaTeX.rb` — LaTeX output cleanups
- `fixHTML.rb` — HTML output cleanups
- `typst2pdf` — watches Typst files and auto-compiles to PDF

## Testing

- `test.md` — general test document
- `test-tufte.md` — Tufte output test
- `test_elsarticle.md` — Elsevier article test
- Lua linting: `luacheck` with `.luacheckrc` (pandoc globals registered)
- VS Code launch configs support pipe-based debugging of Lua and Ruby filters

## Bibliography

- `Core.bib` / `Core.json` — main bibliography (gitignored)
- `citeproc` is used for citation rendering; `--citeproc` or `citeproc: true`
- `cite-abbr.json` — journal name abbreviation mapping for citations

## Notable Conventions

- Lua filters are the preferred filter language
- Use `shared.lua` for common utility functions
- Fonts are configured for specific commercial faces (Greta Text Pro, Greta Sans
  Pro, Alegreya, Rec Mono Duotone) — these would need changes for other users
- The project is heavily oriented toward neuroscience/psychology publishing
- File paths in pandocomatic.yaml reference this directory as the data dir
