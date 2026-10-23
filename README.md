# typst-template

The [Typst](https://typst.app) template for preprints posted by the Allen Institute: the
page, fonts, title block, abstract box, line numbers, captions, tables, author-date
citations, two-column references, S-numbered supplementary items and author
contribution matrix of the Allen Institute preprint style. `main.typ` is an example
paper that shows every feature; start from it. It needs Typst 0.15 or later.

If you have questions, please post an issue in this repository.

## Starting a paper

Pick the route that fits how you work:

- **On [typst.app](https://typst.app) (easiest).** Download `aind-preprint-typst.zip`
  from the [latest release](https://github.com/AllenNeuralDynamics/typst-template/releases/latest),
  unzip it and upload the files as a new project. The fonts are picked up
  automatically; nothing else to set up.
- **On your machine, as a copy.** Unzip the release, set up the fonts (below) and edit
  `main.typ`.
- **As a git submodule** of your paper's repository, so the template is not copied and
  can be updated: see [Using the template as a submodule](#using-the-template-as-a-submodule).

### Fonts

The template uses Source Sans 3 and Noto Sans Math, bundled in `fonts/`. Typst cannot
load fonts from an imported file, so when you compile locally, point it at that folder.
Without it the paper still compiles, but in fallback fonts and with a warning.

- **Command line.** Either pass the folder each time,

  ```bash
  typst compile --font-path fonts main.typ
  ```

  or set it once, after which `typst compile main.typ` is enough:

  ```bash
  export TYPST_FONT_PATHS=fonts          # PowerShell: $env:TYPST_FONT_PATHS = "fonts"
  ```

- **VS Code.** Install the
  [Tinymist](https://marketplace.visualstudio.com/items?itemName=myriad-dreamin.tinymist)
  extension and create `.vscode/settings.json` in the project folder:

  ```json
  {
    "tinymist.fontPaths": ["fonts"]
  }
  ```

## Using the template as a submodule

A submodule adds the template to a paper's repository pinned to one commit of this
repository, so there is a single copy to maintain: improve it here, then move each paper
to the new version when you choose. These steps assume a paper repository with the
manuscript in its own folder:

```
my-paper/
├── .vscode/settings.json
├── manuscript/
│   ├── main.typ
│   ├── refs.bib
│   └── figures/
└── ...
```

### 1. Add the submodule

From the root of the paper repository:

```bash
git submodule add https://github.com/AllenNeuralDynamics/typst-template.git manuscript/template
git commit -m "Add the preprint template"
```

Keep the submodule inside the folder that holds `main.typ`. Typst only reads files under
its project root, which by default is the folder of the file you compile.

### 2. Use the template in `main.typ`

```typst
#import "template/preprint.typ": *

#show: preprint.with(
  title: [The title of the paper],
  short-title: [A running title],
  authors: (
    (name: "First Author", affiliations: ("aind",), email: "first.author@alleninstitute.org",
      orcid: "0000-0000-0000-0000"),
    (name: "Second Author", affiliations: ("aind",)),
  ),
  affiliations: (aind: [Allen Institute, Neural Dynamics, Seattle, WA]),
  abstract: [The abstract.],
  keywords: ("keyword 1", "keyword 2"),
)

= Introduction

Text, citations @key and figures as usual.

#pagebreak()
#references(bibliography("refs.bib"))

#pagebreak()
#show: supplement
= Supplementary information
```

`manuscript/template/main.typ` shows every feature.

### 3. Set up the fonts

VS Code only reads settings from the root of the workspace, so the paper repository
carries the font path. Create `.vscode/settings.json` at its root:

```json
{
  "tinymist.fontPaths": ["manuscript/template/fonts"]
}
```

To compile from the command line:

```bash
typst compile --font-path manuscript/template/fonts manuscript/main.typ
```

### 4. Clone a paper that uses the template

A plain `git clone` leaves `manuscript/template/` empty. Clone with the submodule:

```bash
git clone --recurse-submodules https://github.com/<org>/my-paper.git
```

or, in an existing clone:

```bash
git submodule update --init
```

### 5. Move to a newer version of the template

The paper stays on the commit it pinned until you move it:

```bash
git submodule update --remote manuscript/template
git diff --submodule        # what changed in the template
git commit -am "Update the preprint template"
```

`--remote` follows the template's default branch. To pin a release instead (a new major
version may change the look of your paper):

```bash
git -C manuscript/template fetch --tags
git -C manuscript/template checkout v2.1.0
git commit -am "Pin the preprint template to v2.1.0"
```

To change the template itself, commit the change in this repository (not inside the
paper's submodule checkout), then update each paper as above.

### 6. Build the PDF in GitHub Actions

Check out the submodule along with the paper:

```yaml
name: Build the paper

on: [push, pull_request, workflow_dispatch]

jobs:
  pdf:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v7
        with:
          submodules: true
      - uses: typst-community/setup-typst@v5
        with:
          typst-version: 0.15.1
      - run: typst compile --font-path manuscript/template/fonts manuscript/main.typ paper.pdf
      - uses: actions/upload-artifact@v7
        with:
          name: paper
          path: paper.pdf
```

This template repository is internal, so the default token of a workflow in another
repository may not be able to check it out: give `actions/checkout` a token with read
access to it (`token: ${{ secrets.TEMPLATE_TOKEN }}`).

### Troubleshooting

- **`file not found` for `template/preprint.typ`**: the submodule is empty; run
  `git submodule update --init`.
- **`source file must be contained in project root`**: the submodule is outside the
  folder of `main.typ`. Move it in, or compile with `--root .` from a folder that holds
  both and import it by its path from there (e.g. `/template/preprint.typ`).
- **The text is in the wrong font**: Typst cannot find the template's fonts. Check the
  font path points at the template's `fonts` folder.
- **A figure is missing from the preview**: Tinymist's preview does not show PDF
  images; use SVG or PNG figures (the compiled PDF shows all three).

## Writing the paper

The front matter is set in one call at the top of `main.typ`:

```typst
#import "preprint.typ": *

#show: preprint.with(
  title: [Allen Institute preprint template],
  short-title: [Preprint template], // running title
  authors: (
    (name: "First Author", affiliations: ("aind", "other"), equal: true,
      email: "first.author@alleninstitute.org", orcid: "0000-0000-0000-0000"),
    (name: "Second Author", affiliations: ("aind",), orcid: "0000-0000-0000-0000"),
  ),
  affiliations: (
    aind: [Allen Institute, Neural Dynamics, Seattle, WA],
    other: [Present Address: A Different Organization, City, State],
  ),
  abstract: [...],
  keywords: ("keyword entry 1", "keyword entry 2"),
)
```

`equal: true` marks an equal contributor (†) and `email` a corresponding author (\*).
Affiliations are numbered in order of first use.

| To | Write |
| --- | --- |
| add sections | `= ...`, `== ...` |
| cite | `@key1 @key2` |
| refer to a figure or section | `@fig:x`, `@sec:x` (a section reference prints its name) |
| place a figure | `#figure(..., placement: bottom)`, `top` or `auto` |
| rule a table | `toprule`, `midrule`, `bottomrule` inside `table(...)` |
| add table notes | `#table-notes(table(...), ([a], [First note]), ...)` |
| start the supplement | `#show: supplement` |
| print the references | `#references(bibliography("references.bib"))` |
| stop the line numbers | `#set par.line(numbering: none)` |
| link a repository | `#github("org/repo")` |
| add the contribution matrix | `#contribution-matrix(authors, roles, levels, note: ...)` |
| show code | a fenced code block with a language (` ```python `) |

The example figures in `figures/` are placeholders; replace them with your own. Figures
can be PDF, SVG or PNG. Use SVG or PNG if you preview in an editor: Typst compiles PDF
figures, but Tinymist's live preview does not show them.

Citations use `aind-preprint.csl` (author-date, Chicago style). Replace
`references.bib` with your own BibTeX or BibLaTeX file.

## Releases

A release is made by pushing a version tag, which the CI turns into a GitHub release
with `aind-preprint-typst.zip` and the example PDF:

```bash
git tag v2.1.0
git push origin v2.1.0
```

Use [semantic versions](https://semver.org): a new major version when a change would
alter the look of existing papers or break their source, a minor one for additions. Keep
`version` in `typst.toml` equal to the tag.

## License

The template is licensed under the [MIT License](LICENSE). The bundled fonts in
`fonts/` remain under the SIL Open Font License 1.1, as stated in their license files.
