// Allen Institute preprint template for Typst.
//
// A port of preprint.cls (v2.0): the same page, fonts, title block, abstract box,
// line numbers, captions, tables, author-date citations, two-column references,
// S-numbered supplementary items and author contribution matrix. Usage:
//
//   #import "typst/preprint.typ": *
//   #show: preprint.with(title: [...], authors: (...), affiliations: (...), ...)
//
// The fonts are in typst/fonts: `typst compile --font-path typst/fonts main.typ`.

#let colors = (
  gray1: rgb("#aaa39f"),
  gray2: rgb("#737373"),
  blue: rgb("#6464ff"),
  maroon: rgb("#cd0f55"),
  teal: rgb("#00a59b"),
  green: rgb("#cdeb05"),
  orange: rgb("#ff6e00"),
  rose: rgb("#ff00ff"),
  ochre: rgb("#dc9600"),
  yellow: rgb("#ffeb23"),
  orcid: rgb("#a6ce39"),
  abstract: rgb("#f3f0e8"),
  table-head: luma(179), // black!30
  table-row: luma(230), // black!10
)

#let font = ("Source Sans 3", "Source Sans Pro")
#let mono = ("DejaVu Sans Mono",) // Bera Mono's successor
#let math-font = ("Noto Sans Math",)

// The class is set at 10 pt with Source Sans scaled by 1.1, so every LaTeX size is
// 1.1 times its nominal size while the baselines stay those of the 10-pt class.
#let sizes = (
  tiny: 5.5pt,
  script: 7.7pt,
  footnote: 8.8pt,
  small: 9.9pt,
  normal: 11pt,
  abstract: 10.45pt,
  title: 19pt,
)
// Typst's leading is the gap from one baseline to the next line's cap height.
#let _leading(size, baseline) = baseline - 0.66 * size // Source Sans cap height
#let _topskip = 10pt - 0.66 * sizes.normal
#let leading = (
  script: _leading(sizes.script, 8pt),
  footnote: _leading(sizes.footnote, 9.5pt),
  small: _leading(sizes.small, 11pt),
  normal: _leading(sizes.normal, 12pt),
  abstract: _leading(sizes.abstract, 12pt),
  title: _leading(sizes.title, 22pt),
)

// booktabs rules, placed in the table as in LaTeX: `table(toprule, table.header(..),
// midrule, .., bottomrule)`.
#let toprule = table.hline(stroke: 0.08em + black)
#let midrule = table.hline(stroke: 0.05em + black)
#let bottomrule = table.hline(stroke: 0.08em + black)

#let _icon(name, height, baseline: 0.1em) = box(
  baseline: baseline,
  image("icons/" + name + ".svg", height: height),
)

/// A GitHub repository as a link with the GitHub icon: `#github("org/repo")`.
#let github(repo) = link("https://github.com/" + repo)[#_icon("github-icon", 0.82em, baseline: 0.06em)#h(0.17em)#repo]

/// A table with notes under it, as threeparttable: the notes are aligned with the
/// table's left edge. `#table-notes(table(..), ([], [Table note]), ([a], [First note]))`.
#let table-notes(table, ..notes) = box(stack(
  spacing: 4pt,
  table,
  {
    set text(size: sizes.footnote)
    set par(leading: leading.footnote, first-line-indent: 0pt, justify: false)
    set align(left)
    grid(columns: (13pt, auto), row-gutter: 3.9pt, ..notes.pos().flatten())
  },
))

/// Everything after it is supplementary: figures and tables are numbered S1, S2, ...
#let supplement(body) = {
  counter(figure.where(kind: image)).update(0)
  counter(figure.where(kind: table)).update(0)
  set figure(numbering: n => "S" + str(n))
  body
}

/// The author contribution matrix, as the tikz heatmap of main.tex: *authors* label
/// the columns, *roles* the rows and *levels* holds one row per role with each
/// author's share in percent (100 lead, 50 equal, 20 supporting).
#let contribution-matrix(authors, roles, levels, note: none) = context {
  let tile = 6mm
  let gap = 3mm // between the row labels and the tiles
  let label-w = calc.max(..roles.map(r => measure(r).width))
  let head-w = calc.max(..authors.map(a => measure(a).width))
  let head-h = head-w * calc.sin(45deg) + 2.2mm
  let x0 = label-w + gap
  let body-h = roles.len() * tile
  let note-h = if note == none { 0pt } else { 2.6mm + measure(note).height + 2mm }
  let width = x0 + authors.len() * tile + head-w * calc.cos(45deg)
  block(breakable: false, box(width: width, height: head-h + body-h + note-h, {
    for (j, a) in authors.enumerate() {
      // Each label starts above its column and rises at 45 degrees.
      place(top + left, dx: x0 + j * tile + 2.5mm, dy: head-h - 2.6mm, rotate(
        -45deg,
        origin: bottom + left,
        reflow: false,
        place(bottom + left, a),
      ))
    }
    for (i, role) in roles.enumerate() {
      let y = head-h + i * tile
      place(top + left, dy: y - 1pt, box(width: label-w, height: tile, align(right + horizon, role)))
      for (j, x) in levels.at(i).enumerate() {
        if x > 0 {
          let fill = colors.blue.lighten(100% - x * 1%)
          place(top + left, dx: x0 + j * tile, dy: y, rect(width: tile, height: tile, stroke: none, fill: fill))
        }
      }
    }
    if note != none { place(top + left, dx: x0, dy: head-h + body-h + 2.6mm, note) }
  }))
}

// What sits between two headings unless they are consecutive.
#let _blocks = selector(par).or(list).or(enum).or(terms).or(figure).or(table).or(
  math.equation.where(block: true),
).or(raw.where(block: true))

// A caption on one line is centred, a longer one justified (caption's singlelinecheck).
#let _caption(it) = layout(size => {
  let body = [*#it.supplement #context it.counter.display(it.numbering)#it.separator*#it.body]
  let one-line = measure(body, width: size.width).height <= measure([X], width: size.width).height * 1.5
  align(if one-line { center } else { left }, body)
})

/// The preprint: front matter, page style and every set rule.
#let preprint(
  title: none,
  short-title: none,
  manuscript: "Preprint",
  authors: (),
  affiliations: (:),
  abstract: none,
  keywords: (),
  logo: true,
  body,
) = {
  let short-title = if short-title == none { title } else { short-title }
  let first-author = if authors.len() > 0 { authors.at(0).name } else { "" }

  set document(title: title, author: authors.map(a => a.name))
  set page(
    width: 210mm,
    height: 276mm,
    // The first baseline sits 	opskip (10 pt) below the top of the text area.
    margin: (top: 2.8cm + _topskip, bottom: 2.5cm, x: 2.5cm),
    header-ascent: 0.8cm + _topskip,
    header: context {
      let p = counter(page).get().first()
      if p == 1 { return }
      set text(size: sizes.normal)
      set par.line(numbering: none)
      if calc.even(p) [#p#h(2em)#first-author _et al._#h(1fr)] else [#h(1fr)_#short-title _#h(2em - 2.9pt)#p]
    },
  )
  set text(font: font, size: sizes.normal, lang: "en", hyphenate: true)
  // Justified with a little give in letter spacing, as microtype's font expansion.
  set par(
    justify: true,
    leading: leading.normal,
    spacing: leading.normal,
    first-line-indent: 15pt,
    justification-limits: (tracking: (min: -0.012em, max: 0.012em)),
  )
  show strong: set text(weight: "semibold")

  // Inline code and listings in Bera Mono at 0.9 (beramono [scaled]); listings are
  // \small in minted's manni style.
  show raw: set text(font: mono)
  show raw.where(block: false): set text(size: 0.9em)
  show raw.where(block: true): set text(size: sizes.small * 0.9)
  show raw.where(block: true): set par(leading: _leading(sizes.small * 0.9, 11pt), justify: false)
  set raw(theme: "manni.tmTheme")
  show raw.where(block: true): set block(above: 1.2em, below: 1.2em)

  // Sans-serif math, as the class's sansmath and mathastext: Noto Sans Math, the
  // closest OpenType math font to Source Sans.
  show math.equation: set text(font: math-font)
  set math.equation(numbering: "(1)")
  // LaTeX's display skips above and below; rows \jot apart.
  show math.equation.where(block: true): set block(above: 15pt, below: 12pt)
  show math.equation.where(block: true): set par(leading: 3pt)

  // Line numbers every five lines (lineno's [modulo]) beside the running text only.
  set par.line(
    numbering: n => if calc.rem(n, 5) == 0 { text(size: sizes.tiny, str(n)) },
    number-clearance: 14pt,
    numbering-scope: "document",
  )
  show figure: set par.line(numbering: none)
  show raw.where(block: true): set par.line(numbering: none)
  show math.equation.where(block: true): set par.line(numbering: none)

  // Unnumbered sections: semibold; subsections semibold italic; then italic. A
  // heading right after another follows at the normal line distance (\@nobreak).
  set heading(numbering: none)
  show heading: it => {
    let style = (
      (weight: "semibold", style: "normal"),
      (weight: "semibold", style: "italic"),
      (weight: "regular", style: "italic"),
    ).at(calc.min(it.level, 3) - 1)
    // 3.5ex (3.25ex below sections) above and 0.2ex below, plus \baselineskip.
    let ex = 5.6pt
    let above = (if it.level == 1 { 3.5 } else { 3.25 }) * ex + 12pt - 0.66 * sizes.normal
    let below = 0.2 * ex + 12pt - 0.66 * sizes.normal
    block(above: above, below: below, sticky: true, context {
      let before = query(selector(heading).before(it.location(), inclusive: false))
      let follows = before.len() > 0 and {
        let prev = before.last().location()
        prev.page() == here().page() and query(_blocks.after(prev).before(it.location())).len() == 0
      }
      if follows { v(below - above) }
      block(text(size: sizes.normal, ..style, it.body))
    })
  }

  // hyperref colours: cross-references blue, citations gray, URLs teal. A reference
  // to an unnumbered section prints its name in bold, as \nameref does here.
  show link: set text(fill: colors.teal)
  show ref: it => {
    let el = it.element
    if el == none { it } else if el.func() == heading {
      link(el.location(), text(fill: colors.blue, weight: "semibold", el.body))
    } else { text(fill: colors.blue, it) }
  }
  show cite: set text(fill: colors.gray2)
  set cite(style: "aind-preprint.csl")
  set bibliography(style: "aind-preprint.csl", title: none)

  // Footnotes: blue marks, entries numbered "1." at footnote size.
  show footnote: set text(fill: colors.blue)
  set footnote.entry(separator: line(length: 40%, stroke: 0.4pt), gap: 0.4em, clearance: 1em)
  show footnote.entry: it => {
    set text(size: sizes.footnote, fill: black)
    set par(leading: leading.footnote, first-line-indent: 0pt)
    let n = counter(footnote).at(it.note.location())
    [#h(0.6em)#numbering(it.note.numbering, ..n). #it.note.body]
  }

  // Floats: captions \small with a bold label and a colon, below figures and above
  // tables; tables \footnotesize with booktabs rules and the class's fills.
  set place(clearance: 20pt)
  set figure(gap: 10pt)
  set figure.caption(separator: [: ])
  show figure.caption: it => {
    set text(size: sizes.small)
    set par(leading: leading.small, justify: true, first-line-indent: 0pt)
    _caption(it)
  }
  show figure.where(kind: table): set figure.caption(position: top)
  show figure.where(kind: table): set figure(gap: 15pt)
  show figure.where(kind: table): set text(size: sizes.footnote)
  show figure.where(kind: table): set par(leading: leading.footnote)
  set table(
    align: left,
    stroke: none,
    inset: (x: 6pt, top: 4.6pt, bottom: 3.6pt),
    fill: (_, y) => if y == 0 { colors.table-head } else { colors.table-row },
  )
  show table: set par(justify: false)
  set list(indent: 0pt, body-indent: 0.6em, spacing: leading.normal)
  set enum(indent: 0pt, body-indent: 0.75em, spacing: leading.normal)
  // 	opsep (8 pt plus 2 pt) above and below a list.
  show list: it => block(above: leading.normal + 10pt, below: leading.normal + 10pt, it)
  show enum: it => block(above: leading.normal + 10pt, below: leading.normal + 10pt, it)

  // Front matter.
  {
    set par.line(numbering: none)
    set par(first-line-indent: 0pt, justify: false)
    if logo {
      place(top + right, dy: -23pt - _topskip, image("icons/lens-icon.svg", width: 12mm))
      v(28pt - _topskip)
    }
    text(weight: "semibold", upper(manuscript))
    v(1em + 4.3pt)
    block(text(size: sizes.title, weight: "semibold", par(leading: leading.title, title)))
    v(1em)

    // Affiliations in order of first use, each numbered once.
    let order = ()
    for a in authors {
      for key in a.at("affiliations", default: ()) {
        if key not in order { order.push(key) }
      }
    }
    let numbered = order.len() > 1
    let marks(a) = {
      let m = a.at("affiliations", default: ()).map(k => str(order.position(x => x == k) + 1))
      let out = if numbered { m.join(",") } else { "" }
      if a.at("equal", default: false) { out += "†" }
      if a.at("email", default: none) != none { out += "*" }
      if out != "" { super(out) }
    }
    let names = authors.map(a => {
      let orcid = a.at("orcid", default: none)
      if orcid != none {
        link("https://orcid.org/" + orcid, _icon("orcid-icon", 0.9em))
        h(0.17em)
      }
      a.name
      marks(a)
    })
    if names.len() <= 2 { names.join[ and ] } else { names.slice(0, -1).join[, ] + [, and ] + names.last() }
    v(0.5em - 1.4pt)
    {
      set text(size: sizes.footnote)
      set par(leading: leading.footnote, spacing: leading.footnote)
      for (i, key) in order.enumerate() {
        [#if numbered { super(str(i + 1)) }#affiliations.at(key)]
        parbreak()
      }
      v(0.5em + 1.4pt)
      if authors.any(a => a.at("equal", default: false)) [†Equal contributors.\ ]
      let emails = authors.filter(a => a.at("email", default: none) != none).map(a => a.email)
      if emails.len() > 0 [\*Correspondence: #emails.map(e => link("mailto:" + e, e)).join[; ]]
    }
    v(2.25em + 1.4pt)

    if abstract != none {
      block(width: 100%, inset: (x: 10pt, y: 3mm), fill: colors.abstract, breakable: true, {
        set text(size: sizes.abstract)
        set par(leading: leading.abstract, justify: true)
        abstract
      })
    }
    {
      set text(size: sizes.footnote)
      v(0.9em + 8pt)
      if keywords.len() > 0 [*Keywords:* #keywords.join(" / ")]
      v(0.5em)
    }
  }
  body
}

/// The bibliography in two balanced columns (multicols), headed "References" in the
/// first: `#references(bibliography("references.bib"))`.
#let references(bib) = {
  set par.line(numbering: none)
  let gutter = 10pt
  let body = {
    heading(level: 1)[References]
    set text(size: sizes.footnote)
    set par(first-line-indent: 0pt, hanging-indent: 1em, justify: true, leading: leading.footnote, spacing: leading.footnote + 6pt)
    bib
  }
  layout(size => {
    let width = (size.width - gutter) / 2
    let height = measure(block(width: width, body)).height
    block(height: height / 2 + 9.5pt, columns(2, gutter: gutter, body))
  })
}
