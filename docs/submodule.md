# Using the template from your own repository

This tutorial adds the template to a paper's repository as a git submodule. The paper
then uses the template's files directly, pinned to one commit of this repository, so
there is a single copy of the template to maintain: improve it here, then move each
paper to the new version when you choose.

It assumes a paper repository laid out like this, with the manuscript in its own folder:

```
my-paper/
├── manuscript/
│   ├── main.typ
│   ├── refs.bib
│   └── figures/
└── ...
```

## 1. Add the submodule

From the root of the paper repository:

```bash
git submodule add https://github.com/AllenNeuralDynamics/typst-template.git manuscript/template
git commit -m "Add the preprint template"
```

`manuscript/template/` is now a checkout of this repository, with the template's fonts,
icons, citation style and code theme.

Keep the submodule inside the folder that holds `main.typ`. Typst only reads files
under its project root, which by default is the folder of the file you compile; a
submodule elsewhere needs `--root` (see [Troubleshooting](#troubleshooting)).

## 2. Use the template in `main.typ`

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

The template's example (`manuscript/template/main.typ`) shows every feature.

## 3. Compile

Point Typst at the template's fonts:

```bash
typst compile --font-path manuscript/template/fonts manuscript/main.typ
```

## 4. Clone a paper that uses the template

A plain `git clone` leaves `manuscript/template/` empty. Clone with the submodule:

```bash
git clone --recurse-submodules https://github.com/<org>/my-paper.git
```

or, in an existing clone:

```bash
git submodule update --init
```

## 5. Move to a newer version of the template

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

## 6. Build the PDF in GitHub Actions

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

## Troubleshooting

- **`file not found` for `template/preprint.typ`**: the submodule is empty; run
  `git submodule update --init`.
- **`source file must be contained in project root`**: the submodule is outside the
  folder of `main.typ`. Move it in, or compile with `--root .` from a folder that holds
  both and import it by its path from there (e.g. `/template/preprint.typ`).
- **The text is in the wrong font**: Typst cannot find the template's fonts. Check
  `--font-path` points at `template/fonts`.
- **A figure is missing from the preview**: Tinymist's preview does not show PDF
  images; use SVG or PNG figures (the compiled PDF shows all three).
