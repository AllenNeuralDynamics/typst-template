# typst-template

The [Typst](https://typst.app) template for preprints posted by the Allen Institute: the
page, fonts, title block, abstract box, line numbers, captions, tables, author-date
citations, two-column references, S-numbered supplementary items and author
contribution matrix of the Allen Institute preprint style. `main.typ` is an example
paper that shows every feature; start from it. It needs Typst 0.15 or later.

If you have questions, please post an issue in this repository.

## Starting a paper

There are three ways to start a paper:

- **Copy it.** Download `aind-preprint-typst.zip` from the
  [latest release](https://github.com/AllenNeuralDynamics/typst-template/releases/latest)
  and unzip it, or upload it to [typst.app](https://typst.app) as a project.
- **Keep it in your paper's repository as a git submodule**, so the template is not
  copied and can be updated: see [docs/submodule.md](docs/submodule.md).
- **Create a project with `typst init`.** This repository is a Typst package
  (`typst.toml`); with it installed as a local package (copy it to
  `{data-dir}/typst/packages/local/aind-preprint/<version>/`), run
  `typst init @local/aind-preprint:<version> my-paper`.

Compile in the folder of `main.typ`, pointing Typst at the bundled fonts:

```bash
typst compile --font-path fonts main.typ
```

To preview in VS Code, use the
[Tinymist](https://marketplace.visualstudio.com/items?itemName=myriad-dreamin.tinymist)
extension and add the template's `fonts` folder to its font paths.

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

Figures can be PDF, SVG or PNG. Use SVG or PNG if you preview in an editor: Typst
compiles PDF figures, but Tinymist's live preview does not show them.

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
