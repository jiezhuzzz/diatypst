// Diatypst theme for Touying
// A Touying-based rewrite of the diatypst slide template

#import "@preview/touying:0.6.1": *

#let layouts = (
  "small": ("height": 9cm, "space": 1.4cm),
  "medium": ("height": 10.5cm, "space": 1.6cm),
  "large": ("height": 12cm, "space": 1.8cm),
)

// ============================================================
// Slide Functions
// ============================================================

/// Default slide function for the presentation.
#let slide(
  config: (:),
  repeat: auto,
  setting: body => body,
  composer: auto,
  ..bodies,
) = touying-slide-wrapper(self => {
  let self = utils.merge-dicts(
    self,
    config-common(subslide-preamble: self.store.subslide-preamble),
  )
  touying-slide(
    self: self,
    config: config,
    repeat: repeat,
    setting: setting,
    composer: composer,
    ..bodies,
  )
})

/// Title slide for the presentation
#let title-slide(
  config: (:),
  title: none,
  subtitle: none,
  authors: (),
  co-authors: (),
  date: none,
  logo: none,
) = touying-slide-wrapper(self => {
  let title-color = self.colors.primary
  let bg-color = self.colors.neutral-lightest
  let space = self.store.space

  if (type(authors) != array) {
    authors = (authors,)
  }

  let content = {
    set page(footer: none, header: none, margin: 0cm)
    block(
      inset: (x: 0.5 * space, y: 1em),
      fill: title-color,
      width: 100%,
      height: 60%,
      align(bottom)[#text(2.0em, weight: "bold", fill: bg-color, title)]
    )
    block(
      height: 30%,
      width: 100%,
      inset: (x: 0.5 * space, top: 0cm, bottom: 1em),
      if subtitle != none {[
        #text(1.4em, fill: title-color, weight: "bold", subtitle)
      ]} +
      if subtitle != none and date != none { text(1.4em)[ \ ] } +
      if date != none {text(1.1em, date)} +
      align(left + bottom, [
        #text(1.2em, fill: black, weight: "bold", authors.join(", ", last: " & "))
        #if co-authors != () {
          [\ #co-authors.join(", ", last: " and ")]
        }
      ])
    )
    if logo != none {
      place(
        bottom + right,
        dx: -0.3 * space,
        dy: -0.3 * space,
        logo
      )
    }
  }

  touying-slide(
    self: utils.merge-dicts(
      self,
      config-common(freeze-slide-counter: true),
      config-page(margin: 0cm, header: none, footer: none),
    ),
    config: config,
    content
  )
})

/// Section slide (level 1 heading)
#let section-slide(config: (:), body) = touying-slide-wrapper(self => {
  let title-color = self.colors.primary
  let bg-color = self.colors.neutral-lightest

  let content = {
    set page(header: none, footer: none, margin: 0cm)
    set align(horizon)
    grid(
      columns: (1fr, 3fr),
      inset: 10pt,
      align: (right, left),
      fill: (title-color, bg-color),
      [#block(height: 100%)],
      [#text(1.2em, weight: "bold", fill: title-color)[#body]]
    )
  }

  touying-slide(
    self: utils.merge-dicts(
      self,
      config-page(margin: 0cm, header: none, footer: none),
    ),
    config: config,
    content
  )
})

/// Centered slide
#let centered-slide(config: (:), ..args) = touying-slide-wrapper(self => {
  touying-slide(self: self, ..args.named(), config: config, align(
    center + horizon,
    args.pos().sum(default: none),
  ))
})

// ============================================================
// Header and Footer Components
// ============================================================

#let make-header(self) = {
  let title-color = self.colors.primary
  let bg-color = self.colors.neutral-lightest
  let space = self.store.space
  let theme = self.store.theme
  let count-type = self.store.count
  let fill-color = self.colors.fill

  // Section heading display  
  context {  
    let current-slide = utils.slide-counter.get().first()  
    let headings = query(selector(heading.where(level: 2)))  
    let heading = headings.rev().find(x => {  
      utils.slide-counter.at(x.location()).first() <= current-slide  
    })  
    
    if heading != none {  
      let heading-slide = utils.slide-counter.at(heading.location()).first()  
      set align(top)  
      if (theme == "full") {  
        block(  
          width: 100%,  
          fill: title-color,  
          height: space * 0.85,  
          outset: (x: 0.5 * space)  
        )[  
          #set text(1.4em, weight: "bold", fill: bg-color)  
          #v(space / 2)  
          #heading.body  
          #if heading-slide != current-slide [  
            #{numbering("(i)", current-slide - heading-slide + 1)}  
          ]  
        ]  
      } else if (theme == "normal") {  
        set text(1.4em, weight: "bold", fill: title-color)  
        v(space / 2)  
        heading.body  
        if heading-slide != current-slide [  
          #{numbering("(i)", current-slide - heading-slide + 1)}  
        ]  
      }  
    }  
  }

  // Page counter
  if count-type == "dot" {
    set align(right + top)
    context {
      let last = utils.last-slide-counter.final().first()
      let current = utils.slide-counter.get().first()
      let limit = calc.ceil(last / 2)

      if last > 20 {
        v(-space / 1.3)
        for i in range(1, limit + 1) {
          if i <= current {
            link((page: i, x: 0pt, y: 0pt))[
              #box(circle(radius: 0.06cm, fill: fill-color, stroke: 1pt + fill-color))
            ]
          } else {
            link((page: i, x: 0pt, y: 0pt))[
              #box(circle(radius: 0.06cm, stroke: 1pt + fill-color))
            ]
          }
        }
        v(-space / 1.6)
        linebreak()
        for i in range(limit + 1, last + 1) {
          if i <= current {
            link((page: i, x: 0pt, y: 0pt))[
              #box(circle(radius: 0.06cm, fill: fill-color, stroke: 1pt + fill-color))
            ]
          } else {
            link((page: i, x: 0pt, y: 0pt))[
              #box(circle(radius: 0.06cm, stroke: 1pt + fill-color))
            ]
          }
        }
      } else {
        v(-space / 1.5)
        for i in range(1, last + 1) {
          if i <= current {
            link((page: i, x: 0pt, y: 0pt))[
              #box(circle(radius: 0.08cm, fill: fill-color, stroke: 1pt + fill-color))
            ]
          } else {
            link((page: i, x: 0pt, y: 0pt))[
              #box(circle(radius: 0.08cm, stroke: 1pt + fill-color))
            ]
          }
        }
      }
    }
  } else if count-type == "dot-section" {
    v(-space / 1.5)
    set align(right + top)
    context {
      let last = utils.last-slide-counter.final().first()
      let current = utils.slide-counter.get().first()
      let sections = query(selector(heading).where(level: 1))

      // Find current section by checking slide counter
      let current-section-idx = 0
      for (idx, sec) in sections.enumerate() {
        let sec-slide = utils.slide-counter.at(sec.location()).first()
        if sec-slide <= current {
          current-section-idx = idx
        }
      }

      let current-section-slide = if sections.len() > 0 {
        utils.slide-counter.at(sections.at(current-section-idx).location()).first()
      } else { 1 }

      let next-section-slide = if current-section-idx + 1 < sections.len() {
        utils.slide-counter.at(sections.at(current-section-idx + 1).location()).first()
      } else { last }

      // Display section-specific counter
      if next-section-slide - current-section-slide >= 3 {
        // Show section navigation with dots
        for i in range(current-section-slide, calc.min(next-section-slide, last) + 1) {
          if i == current {
            box(circle(radius: 0.08cm, fill: fill-color, stroke: 1pt + fill-color))
          } else if i < current {
            box(circle(radius: 0.06cm, fill: fill-color.lighten(30%), stroke: 1pt + fill-color))
          } else {
            box(circle(radius: 0.08cm, stroke: 1pt + fill-color))
          }
        }
      }
    }
  } else if count-type == "number" {
    v(-space / 1.5)
    set align(right + top)
    context {
      let last = utils.last-slide-counter.final().first()
      let current = utils.slide-counter.get().first()
      set text(weight: "bold")
      set text(fill: bg-color) if theme == "full"
      set text(fill: title-color) if theme == "normal"
      [#current / #last]
    }
  }
}

#let make-footer(self) = {
  let title-color = self.colors.primary
  let bg-color = self.colors.neutral-lightest
  let space = self.store.space
  let theme = self.store.theme
  let fill-color = self.colors.fill
  let body-color = self.colors.body

  let footer-title-text = if self.store.footer-title != none {
    self.store.footer-title
  } else {
    self.info.title
  }

  let footer-subtitle-text = if self.store.footer-subtitle != none {
    self.store.footer-subtitle
  } else if self.info.subtitle != none {
    self.info.subtitle
  } else if self.info.author != none {
    if type(self.info.author) == array {
      self.info.author.join(", ", last: " and ")
    } else {
      self.info.author
    }
  } else if self.info.date != none {
    self.info.date
  }

  set text(0.7em)
  if (theme == "full") {
    columns(2, gutter: 0cm)[
      #align(left)[#block(
        width: 100%,
        outset: (left: 0.5 * space, bottom: 0cm),
        height: 0.3 * space,
        fill: fill-color,
        inset: (right: 3pt)
      )[
        #v(0.1 * space)
        #set align(right)
        #smallcaps()[#footer-title-text]
      ]]
      #align(right)[#block(
        width: 100%,
        outset: (right: 0.5 * space, bottom: 0cm),
        height: 0.3 * space,
        fill: body-color,
        inset: (left: 3pt)
      )[
        #v(0.1 * space)
        #set align(left)
        #footer-subtitle-text
      ]]
    ]
  } else if (theme == "normal") {
    box()[#line(length: 50%, stroke: 2pt + fill-color)]
    box()[#line(length: 50%, stroke: 2pt + body-color)]
    v(-0.33cm)
    grid(
      columns: (1fr, 1fr),
      align: (right, left),
      inset: 4pt,
      [#smallcaps()[#footer-title-text]],
      [#footer-subtitle-text],
    )
  }
}

// ============================================================
// Main Theme Function
// ============================================================

/// Diatypst theme for Touying
///
/// Example:
/// ```typst
/// #show: diatypst-theme.with(
///   aspect-ratio: "16-9",
///   layout: "medium",
///   config-info(
///     title: "My Presentation",
///     subtitle: "A great talk",
///     author: "John Doe",
///     date: datetime.today().display(),
///   ),
/// )
/// ```
#let diatypst-theme(
  aspect-ratio: 4/3,
  layout: "medium",
  title-color: none,
  bg-color: white,
  count: "dot",
  footer: true,
  toc: true,
  theme: "normal",
  footer-title: none,
  footer-subtitle: none,
  logo: none,
  ..args,
  body,
) = {
  // Validate and parse layout
  if layout not in layouts {
    panic("Unknown layout " + layout)
  }
  let layout-config = layouts.at(layout)
  let height = layout-config.height
  let space = layout-config.space

  if count not in (none, "dot", "number", "dot-section") {
    panic("Unknown Count, valid counts are 'dot', 'number', 'dot-section', or none")
  }

  if theme not in ("normal", "full") {
    panic("Unknown Theme, valid themes are 'full' and 'normal'")
  }

  // Set up colors
  if title-color == none {
    title-color = blue.darken(50%)
  }
  let block-color = title-color.lighten(90%)
  let body-color = title-color.lighten(80%)
  let header-color = title-color.lighten(65%)
  let fill-color = title-color.lighten(50%)

  // Convert aspect-ratio if string
  let ratio = if type(aspect-ratio) == str {
    if aspect-ratio == "16-9" { 16/9 }
    else if aspect-ratio == "4-3" { 4/3 }
    else { eval(aspect-ratio) }
  } else { aspect-ratio }

  let width = ratio * height

  show: touying-slides.with(
    config-page(
      paper: "presentation-" + aspect-ratio,
      width: width,
      height: height,
      margin: (x: 0.5 * space, top: space, bottom: 0.6 * space),
      header: if footer { make-header } else { none },
      footer: if footer { make-footer } else { none },
      header-ascent: 0%,
      footer-descent: 0.3 * space,
      fill: bg-color,
    ),
    config-common(
      slide-fn: slide,
      new-section-slide-fn: section => {
        touying-slide-wrapper(self => {
          let title-color = self.colors.primary
          let bg-color = self.colors.neutral-lightest
          touying-slide(
            self: utils.merge-dicts(
              self,
              config-page(margin: 0cm, header: none, footer: none),
            ),
            {
              set align(horizon)
              grid(
                columns: (1fr, 3fr),
                inset: 10pt,
                align: (right, left),
                fill: (title-color, bg-color),
                [#block(height: 100%)],
                [#text(1.2em, weight: "bold", fill: title-color)[#utils.display-current-heading(level: 1)]]
              )
            },
          )
        })
      },
      slide-level: 2,
      zero-margin-header: false,
      zero-margin-footer: false,
    ),
    config-methods(
      init: (self: none, body) => {
        show footnote.entry: set text(size: .6em)
        // set heading(numbering: "1.a")

        // Slide breaks (level 2)
        show heading.where(level: 2): it => pagebreak(weak: true)
        show heading: set text(1.1em, fill: title-color)

        // Terms
        show terms.item: it => {
          set block(width: 100%, inset: 5pt)
          stack(
            block(fill: header-color, radius: (top: 0.2em, bottom: 0cm), strong(it.term)),
            block(fill: block-color, radius: (top: 0cm, bottom: 0.2em), it.description),
          )
        }

        // Code
        show raw.where(block: false): it => {
          box(fill: block-color, inset: 1pt, radius: 1pt, baseline: 1pt)[#text(it)]
        }
        show raw.where(block: true): it => {
          block(radius: 0.5em, fill: block-color, width: 100%, inset: 1em, it)
        }

        // Lists
        show list: set list(marker: (
          text(fill: title-color)[•],
          text(fill: title-color)[‣],
          text(fill: title-color)[-],
        ))

        // Enums
        let color-number(nrs) = text(fill: title-color)[*#nrs.*]
        set enum(numbering: color-number)

        // Tables
        show table: set table(
          stroke: (x, y) => (
            x: none,
            bottom: 0.8pt + black,
            top: if y == 0 {0.8pt + black} else if y == 1 {0.4pt + black} else { 0pt },
          )
        )
        show table.cell.where(y: 0): set text(style: "normal", weight: "bold")
        set table.hline(stroke: 0.4pt + black)
        set table.vline(stroke: 0.4pt)

        // Quotes
        set quote(block: true)
        show quote.where(block: true): it => {
          v(-5pt)
          block(
            fill: block-color, inset: 5pt, radius: 1pt,
            stroke: (left: 3pt + fill-color), width: 100%,
            outset: (left: -5pt, right: -5pt, top: 5pt, bottom: 5pt)
          )[#it]
          v(-5pt)
        }

        // Links
        show link: it => {
          if type(it.dest) != str {
            it
          } else {
            underline(stroke: 0.5pt + title-color)[#it]
          }
        }

        // Outline
        set outline(indent: auto)
        show outline: set heading(level: 2)

        // Bibliography
        set bibliography(title: none)

        body
      },
      alert: utils.alert-with-primary-color,
    ),
    config-colors(
      neutral-light: gray,
      neutral-lightest: bg-color,
      neutral-darkest: black,
      primary: title-color,
      fill: fill-color,
      body: body-color,
      header: header-color,
      block: block-color,
    ),
    config-store(
      space: space,
      theme: theme,
      count: count,
      footer-title: footer-title,
      footer-subtitle: footer-subtitle,
      logo: logo,
      subslide-preamble: none
    ),
    ..args,
  )

  body
}
