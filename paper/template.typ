// paper/template.typ — Default styling for the paper.
//
// Customise this file to change fonts, margins, heading styles, etc.
// To use an institutional template instead, replace this file's
// contents with the institutional template and adjust the `#show`
// call in main.typ to match its function signature.

#let paper-template(
  title: "Untitled",
  author: "Anonymous",
  affiliation: "",
  body,
) = {
  set document(title: title, author: author)

  set page(
    paper: "a4",
    margin: 2.5cm,
    numbering: "1",
    number-align: center,
  )

  set text(
    font: "New Computer Modern",
    size: 11pt,
    lang: "en",
  )

  set par(
    justify: true,
    leading: 0.65em,
    first-line-indent: 1em,
  )

  set heading(numbering: "1.1")

  show heading.where(level: 1): it => [
    #v(1.5em)
    #text(size: 14pt, weight: "bold")[#it]
    #v(0.5em)
  ]

  show heading.where(level: 2): it => [
    #v(1em)
    #text(size: 12pt, weight: "bold", style: "italic")[#it]
    #v(0.3em)
  ]

  // Title block
  align(center)[
    #text(size: 18pt, weight: "bold")[#title]
    #v(0.4em)
    #text(size: 11pt)[#author]
    #if affiliation != "" [
      \
      #text(size: 10pt, style: "italic")[#affiliation]
    ]
    #v(0.3em)
    #text(size: 10pt)[#datetime.today().display()]
  ]

  v(2em)

  body
}
