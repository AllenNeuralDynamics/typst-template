// The example preprint. Build from the repository root:
//   typst compile --font-path fonts main.typ
#import "preprint.typ": *

#let lorem-sentence = [Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.]

#show: preprint.with(
  title: [Allen Institute preprint template], // long title
  short-title: [Preprint template], // running title
  authors: (
    (
      name: "First Author",
      affiliations: ("aind", "other"),
      equal: true,
      email: "first.author@alleninstitute.org",
      orcid: "0000-0000-0000-0000",
    ),
    (name: "Second Author", affiliations: ("aind",), equal: true, orcid: "0000-0000-0000-0000"),
    (name: "Third Author", affiliations: ("aind",), orcid: "0000-0000-0000-0000"),
    (
      name: "Fourth Author",
      affiliations: ("aind",),
      email: "last.author@alleninstitute.org",
      orcid: "0000-0000-0000-0000",
    ),
  ),
  affiliations: (
    aind: [Allen Institute, Neural Dynamics, Seattle, WA],
    other: [Present Address: A Different Organization, City, State],
  ),
  abstract: [Insert abstract text here. #lorem-sentence],
  keywords: ("keyword entry 1", "keyword entry 2", "keyword entry 3"), // first letter not capped
)

= Introduction

This demo file is intended to serve as a "starter file." You can either use it to write
your manuscript from scratch, or copy and paste material from a Google or Word document.
See the `README.md` file for instructions.

= Adding references

Citations use `@key`. Here is an example of citing one article @mountcastle1997 or
multiple articles @hodgkin1952 @sherrington1907 @neher1976 @hubel1959.

By default, this template adopts the `author-date` referencing style, with the citation
style in `aind-preprint.csl`. To compile it on your own machine, with the fonts the
template ships, run this in the folder of `main.typ`:
+ `typst compile --font-path fonts main.typ`

= Using sub-sections

Example of how to link to a section: @sec:methods. #lorem-sentence #lorem-sentence
#lorem-sentence

== This is a sub-section

#lorem-sentence #lorem-sentence #lorem-sentence#footnote[This is an example of a footnote.]

=== This is a sub-subsection
#lorem-sentence
#lorem-sentence

= Figures & Tables

== Figures
@fig:half-page is an example of an embedded figure. Using `placement: bottom` will place
it at the bottom of the page; `placement: top` will place it at the top of the page. See
@fig:main-wide for a full-page figure (using `placement: auto`). You can also include
full-page supplemental figures such as @fig:supp-wide.

== Tables
See @tab:example.

#figure(
  image("figures/embedded-figure.svg", width: 100%),
  caption: [*This title should summarize the contents of the figure.* *a,* Description of first panel. *b,* Description of second panel. See the "Figure guidelines" section of `README.md` for formatting recommendations.],
  placement: bottom,
) <fig:half-page>

#figure(
  image("figures/full-page-figure.svg", width: 100%),
  caption: [*This title should summarize the contents of the figure.* *a,* Description of first panel. *b,* Description of second panel. *c,* Description of third panel. *d,* Description of fourth panel. *e-g*, Description of multiple panels. See the "Figure guidelines" section of `README.md` for formatting recommendations.],
  placement: auto,
) <fig:main-wide>

= Equations

Sample equations. #lorem-sentence #lorem-sentence #lorem-sentence

// Numbered equation
$
  (partial u(t,x)) / (partial t) &= A u(t,x) (1 - u(t,x) / K)
  - B (u(t - tau, x) w(t,x)) / (1 + E u(t - tau, x)), \
  (partial w(t,x)) / (partial t) &= delta (partial^2 w(t,x)) / (partial x^2) - C w(t,x)
  + D (u(t - tau, x) w(t,x)) / (1 + E u(t - tau, x)),
$ <eq:first>

#lorem-sentence #lorem-sentence #lorem-sentence

$
  (d U) / (d t) &= alpha U(t) (gamma - U(t)) - (U(t - tau) W(t)) / (1 + U(t - tau)), \
  (d W) / (d t) &= -W(t) + beta (U(t - tau) W(t)) / (1 + U(t - tau)).
$ <eq:another>

// Unnumbered equation
#math.equation(block: true, numbering: none, $
  & lr((partial (F_1, F_2)) / (partial (c, omega)))_((c_0, omega_0)) = lr(|
    mat(delim: #none, (partial F_1) / (partial c), (partial F_1) / (partial omega);
      (partial F_2) / (partial c), (partial F_2) / (partial omega))
  |)_((c_0, omega_0)) \
  & quad = -4 c_0 q omega_0 - 4 c_0 omega_0 p^2 = -4 c_0 omega_0 (q + p^2) > 0.
$)

= Source code

Here is an example of some nicely formatted Python source code:

```python
import numpy as np

def incmatrix(genl1,genl2):
    m = len(genl1)
    n = len(genl2)
    M = None #to become the incidence matrix
    VT = np.zeros((n*m,1), int)  #dummy variable

    #compute the bitwise xor matrix
    M1 = bitxormatrix(genl1)
    M2 = np.triu(bitxormatrix(genl2),1)

    for i in range(m-1):
        for j in range(i+1, m):
            [r,c] = np.where(M2 == M1[i,j])
            for k in range(len(r)):
                VT[(i)*n + r[k]] = 1;
                VT[(i)*n + c[k]] = 1;
                VT[(j)*n + r[k]] = 1;
                VT[(j)*n + c[k]] = 1;

                if M is None:
                    M = np.copy(VT)
                else:
                    M = np.concatenate((M, VT), 1)

                VT = np.zeros((n*m,1), int)

    return M
```

= Discussion
The discussion text goes here.

// The line numbers end here, as \end{linenumbers} in main.tex.
#set par.line(numbering: none)

= Data and code availability
Code for generating all figures is available from #github("AllenNeuralDynamics/aind-preprint-template"). Data is available on Code Ocean [insert link].

= Acknowledgments
This research was supported by the Allen Institute, founded by Jody Allen – chair and co-founder of Allen Family Philanthropies, and the late Paul G. Allen – investor, philanthropist, and co-founder of Microsoft. We gratefully acknowledge their vision and generosity, which make this work possible.

= Author contribution matrix
#let hi = 100
#let mid = 50
#let lo = 20
#contribution-matrix(
  ([Author 1\*], [Author 2\*], [Author 3], [Author 4], [Author 5], [Author 6], [Author 7],
    [Author 8], [Author 9], [Author 10#super[†]], [Author 11#super[†]]),
  ([Conceptualization], [Formal analysis], [Investigation], [Methodology], [Resources],
    [Software], [Writing---Original Draft], [Writing---Reviewing and Editing],
    [Funding acquisition]),
  (
    (hi, hi, lo, 0, 0, 0, 0, 0, 0, hi, hi),
    (hi, 0, hi, 0, 0, 0, mid, mid, mid, 0, mid),
    (hi, lo, 0, hi, hi, mid, 0, 0, 0, 0, mid),
    (hi, lo, 0, 0, 0, 0, 0, 0, 0, 0, 0),
    (lo, hi, 0, 0, 0, 0, 0, 0, 0, lo, 0),
    (hi, mid, 0, 0, 0, 0, 0, 0, 0, mid, 0),
    (hi, hi, 0, 0, 0, 0, 0, 0, 0, mid, 0),
    (hi, hi, 0, 0, 0, 0, 0, 0, 0, mid, lo),
    (0, 0, 0, 0, 0, 0, 0, 0, lo, hi, hi),
  ),
  note: [\*, #super[†] these authors contributed equally],
)

#pagebreak()
#references(bibliography("references.bib"))

#pagebreak()
= Methods <sec:methods>

#lorem-sentence #lorem-sentence #lorem-sentence

#show: supplement

#pagebreak()
#figure(
  table-notes(
    table(
      columns: 4,
      toprule,
      table.header[Column head 1][Column head 2][Column head 3][Column head 4],
      midrule,
      [One#super[a]], [Two], [three three], [four],
      midrule,
      [Three], [Four], [three three#super[b]], [four],
      bottomrule,
    ),
    ([], [Table note]),
    ([a], [First note]),
    ([b], [Another table note]),
  ),
  caption: [*Title of this table.* Description of this table.],
  placement: top,
) <tab:example>

#figure(
  image("figures/full-page-figure.svg", width: 100%),
  caption: [*This title should summarize the contents of the figure.* *a,* Description of first panel. *b,* Description of second panel. *c,* Description of third panel. *d,* Description of fourth panel. *e-g*, Description of multiple panels. See the "Figure guidelines" section of `README.md` for formatting recommendations.],
  placement: auto,
) <fig:supp-wide>
