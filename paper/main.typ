// paper/main.typ — Root document.
//
// Compile with: make paper
//
// This file imports the template and lists sections in compile order.
// The `draft` skill maintains the include list below: when it writes a
// new section into sections/, it adds the matching `#include` line and
// orders it to match the outline. You can also edit the list directly
// to reorder, exclude, or add sections. To exclude a section from
// compilation, comment it out or remove it from the list.
//
// The file compiles with zero active includes — uncomment a section (or
// let `draft` add one) once it exists in sections/.

#import "template.typ": paper-template

#show: paper-template.with(
  title: "Your Paper Title",
  author: "Your Name",
  affiliation: "Your Affiliation",
)

// Sections in compile order. `draft` maintains this list automatically.

// #include "sections/abstract.typ"
// #include "sections/introduction.typ"
// #include "sections/methods.typ"
// #include "sections/results.typ"
// #include "sections/discussion.typ"
// #include "sections/conclusion.typ"

#bibliography("bibliography.bib", style: "apa")
