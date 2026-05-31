# paper/figures/

Figures reach the paper by one of three routes. There is no `figure`
skill — every plot is either claim-attached, a static schematic, or
still exploratory.

## (a) Claim-attached analysis figures

A figure that backs a result is produced by the `build` pipeline that
produced that result. It is listed in the claim's `Attachments`, and
`draft` wires it into the section that cites the claim. These do **not**
live here — they live with their producing code/output and are pulled in
by reference.

## (b) Static schematics — committed here

Diagrams, photographs, hand-drawn figures, screenshots: anything not
produced by `src/`. Commit the file straight into this directory and
reference it from a section. Its description lives inline in the section
prose (or the outline), not in a registry file.

```typst
#figure(
  image("figures/architecture.png", width: 80%),
  caption: [System architecture: data flow from raw input through
            morphism to output space.],
)
```

## (c) Exploratory plots — stay in playground/

A throwaway plot stays in `playground/` until it earns a place in the
paper. When a non-claim plot becomes durable, promote it by routing it
through (a): attach it to the claim it supports rather than dropping a
loose image here.
