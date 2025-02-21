// Some definitions presupposed by pandoc's typst output.
#let blockquote(body) = [
  #set text( size: 0.92em )
  #block(inset: (left: 1.5em, top: 0.2em, bottom: 0.2em))[#body]
]

#let horizontalrule = [
  #line(start: (25%,0%), end: (75%,0%))
]

#let endnote(num, contents) = [
  #stack(dir: ltr, spacing: 3pt, super[#num], contents)
]

#show terms: it => {
  it.children
    .map(child => [
      #strong[#child.term]
      #block(inset: (left: 1.5em, top: -0.4em))[#child.description]
      ])
    .join()
}

// Some quarto-specific definitions.

#show raw.where(block: true): set block(
    fill: luma(230),
    width: 100%,
    inset: 8pt,
    radius: 2pt
  )

#let block_with_new_content(old_block, new_content) = {
  let d = (:)
  let fields = old_block.fields()
  fields.remove("body")
  if fields.at("below", default: none) != none {
    // TODO: this is a hack because below is a "synthesized element"
    // according to the experts in the typst discord...
    fields.below = fields.below.amount
  }
  return block.with(..fields)(new_content)
}

#let empty(v) = {
  if type(v) == "string" {
    // two dollar signs here because we're technically inside
    // a Pandoc template :grimace:
    v.matches(regex("^\\s*$")).at(0, default: none) != none
  } else if type(v) == "content" {
    if v.at("text", default: none) != none {
      return empty(v.text)
    }
    for child in v.at("children", default: ()) {
      if not empty(child) {
        return false
      }
    }
    return true
  }

}

// Subfloats
// This is a technique that we adapted from https://github.com/tingerrr/subpar/
#let quartosubfloatcounter = counter("quartosubfloatcounter")

#let quarto_super(
  kind: str,
  caption: none,
  label: none,
  supplement: str,
  position: none,
  subrefnumbering: "1a",
  subcapnumbering: "(a)",
  body,
) = {
  context {
    let figcounter = counter(figure.where(kind: kind))
    let n-super = figcounter.get().first() + 1
    set figure.caption(position: position)
    [#figure(
      kind: kind,
      supplement: supplement,
      caption: caption,
      {
        show figure.where(kind: kind): set figure(numbering: _ => numbering(subrefnumbering, n-super, quartosubfloatcounter.get().first() + 1))
        show figure.where(kind: kind): set figure.caption(position: position)

        show figure: it => {
          let num = numbering(subcapnumbering, n-super, quartosubfloatcounter.get().first() + 1)
          show figure.caption: it => {
            num.slice(2) // I don't understand why the numbering contains output that it really shouldn't, but this fixes it shrug?
            [ ]
            it.body
          }

          quartosubfloatcounter.step()
          it
          counter(figure.where(kind: it.kind)).update(n => n - 1)
        }

        quartosubfloatcounter.update(0)
        body
      }
    )#label]
  }
}

// callout rendering
// this is a figure show rule because callouts are crossreferenceable
#show figure: it => {
  if type(it.kind) != "string" {
    return it
  }
  let kind_match = it.kind.matches(regex("^quarto-callout-(.*)")).at(0, default: none)
  if kind_match == none {
    return it
  }
  let kind = kind_match.captures.at(0, default: "other")
  kind = upper(kind.first()) + kind.slice(1)
  // now we pull apart the callout and reassemble it with the crossref name and counter

  // when we cleanup pandoc's emitted code to avoid spaces this will have to change
  let old_callout = it.body.children.at(1).body.children.at(1)
  let old_title_block = old_callout.body.children.at(0)
  let old_title = old_title_block.body.body.children.at(2)

  // TODO use custom separator if available
  let new_title = if empty(old_title) {
    [#kind #it.counter.display()]
  } else {
    [#kind #it.counter.display(): #old_title]
  }

  let new_title_block = block_with_new_content(
    old_title_block, 
    block_with_new_content(
      old_title_block.body, 
      old_title_block.body.body.children.at(0) +
      old_title_block.body.body.children.at(1) +
      new_title))

  block_with_new_content(old_callout,
    block(below: 0pt, new_title_block) +
    old_callout.body.children.at(1))
}

// 2023-10-09: #fa-icon("fa-info") is not working, so we'll eval "#fa-info()" instead
#let callout(body: [], title: "Callout", background_color: rgb("#dddddd"), icon: none, icon_color: black) = {
  block(
    breakable: false, 
    fill: background_color, 
    stroke: (paint: icon_color, thickness: 0.5pt, cap: "round"), 
    width: 100%, 
    radius: 2pt,
    block(
      inset: 1pt,
      width: 100%, 
      below: 0pt, 
      block(
        fill: background_color, 
        width: 100%, 
        inset: 8pt)[#text(icon_color, weight: 900)[#icon] #title]) +
      if(body != []){
        block(
          inset: 1pt, 
          width: 100%, 
          block(fill: white, width: 100%, inset: 8pt, body))
      }
    )
}



#let article(
  title: none,
  subtitle: none,
  authors: none,
  date: none,
  abstract: none,
  abstract-title: none,
  cols: 1,
  margin: (x: 1.25in, y: 1.25in),
  paper: "us-letter",
  lang: "en",
  region: "US",
  font: "linux libertine",
  fontsize: 11pt,
  title-size: 1.5em,
  subtitle-size: 1.25em,
  heading-family: "linux libertine",
  heading-weight: "bold",
  heading-style: "normal",
  heading-color: black,
  heading-line-height: 0.65em,
  sectionnumbering: none,
  toc: false,
  toc_title: none,
  toc_depth: none,
  toc_indent: 1.5em,
  doc,
) = {
  set page(
    paper: paper,
    margin: margin,
    numbering: "1",
  )
  set par(justify: true)
  set text(lang: lang,
           region: region,
           font: font,
           size: fontsize)
  set heading(numbering: sectionnumbering)
  if title != none {
    align(center)[#block(inset: 2em)[
      #set par(leading: heading-line-height)
      #if (heading-family != none or heading-weight != "bold" or heading-style != "normal"
           or heading-color != black or heading-decoration == "underline"
           or heading-background-color != none) {
        set text(font: heading-family, weight: heading-weight, style: heading-style, fill: heading-color)
        text(size: title-size)[#title]
        if subtitle != none {
          parbreak()
          text(size: subtitle-size)[#subtitle]
        }
      } else {
        text(weight: "bold", size: title-size)[#title]
        if subtitle != none {
          parbreak()
          text(weight: "bold", size: subtitle-size)[#subtitle]
        }
      }
    ]]
  }

  if authors != none {
    let count = authors.len()
    let ncols = calc.min(count, 3)
    grid(
      columns: (1fr,) * ncols,
      row-gutter: 1.5em,
      ..authors.map(author =>
          align(center)[
            #author.name \
            #author.affiliation \
            #author.email
          ]
      )
    )
  }

  if date != none {
    align(center)[#block(inset: 1em)[
      #date
    ]]
  }

  if abstract != none {
    block(inset: 2em)[
    #text(weight: "semibold")[#abstract-title] #h(1em) #abstract
    ]
  }

  if toc {
    let title = if toc_title == none {
      auto
    } else {
      toc_title
    }
    block(above: 0em, below: 2em)[
    #outline(
      title: toc_title,
      depth: toc_depth,
      indent: toc_indent
    );
    ]
  }

  if cols == 1 {
    doc
  } else {
    columns(cols, doc)
  }
}

#set table(
  inset: 6pt,
  stroke: none
)
#import "@preview/fontawesome:0.1.0": *

#show: doc => article(
  title: [Methodological Evaluation Criteria for Risk of Bias Assessment in Adult ADHD Diagnostic Studies],
  toc_title: [Table of contents],
  toc_depth: 3,
  cols: 1,
  doc,
)

= Systematic Framework for Bias Evaluation
<systematic-framework-for-bias-evaluation>
== I. Established Criteria - QUADAS-2 Framework
<i.-established-criteria---quadas-2-framework>
The Quality Assessment of Diagnostic Accuracy Studies-2 (QUADAS-2) tool provides the foundational framework for evaluating risk of bias, specifically adapted for adult ADHD diagnostic studies.

#block[
#heading(
level: 
3
, 
numbering: 
none
, 
[
Domain 1: Patient Selection
]
)
]
#block[
#callout(
body: 
[
- Consecutive or random sampling explicitly documented
- Case-control design avoided or appropriately justified
- Inappropriate exclusions avoided
- Clear documentation of recruitment strategy

]
, 
title: 
[
Low Risk Criteria
]
, 
background_color: 
rgb("#dae6fb")
, 
icon_color: 
rgb("#0758E5")
, 
icon: 
fa-info()
)
]
#block[
#callout(
body: 
[
- Insufficient description of sampling methodology
- Ambiguous selection criteria
- Limited documentation of recruitment process
- Unclear timeline of participant enrollment

]
, 
title: 
[
Unclear Risk Indicators
]
, 
background_color: 
rgb("#fcefdc")
, 
icon_color: 
rgb("#EB9113")
, 
icon: 
fa-exclamation-triangle()
)
]
#block[
#callout(
body: 
[
- Non-consecutive or non-random sampling
- Inappropriate case-control design
- Inappropriate exclusions affecting representativeness
- Substantial selection bias evident

]
, 
title: 
[
High Risk Markers
]
, 
background_color: 
rgb("#f7dddc")
, 
icon_color: 
rgb("#CC1914")
, 
icon: 
fa-exclamation()
)
]
#block[
#heading(
level: 
3
, 
numbering: 
none
, 
[
Domain 2: Index Test
]
)
]
#block[
#callout(
body: 
[
- Test conducted according to standardized protocol
- Threshold pre-specified
- Test interpreters blinded to reference standard
- Clear documentation of test administration

]
, 
title: 
[
Low Risk Criteria
]
, 
background_color: 
rgb("#dae6fb")
, 
icon_color: 
rgb("#0758E5")
, 
icon: 
fa-info()
)
]
#block[
#heading(
level: 
3
, 
numbering: 
none
, 
[
Domain 3: Reference Standard
]
)
]
#block[
#callout(
body: 
[
- DSM-5/ICD-10 criteria properly implemented
- Reference standard results interpreted blind to index test
- Standardized diagnostic protocol followed
- Multi-informant data collection

]
, 
title: 
[
Low Risk Criteria
]
, 
background_color: 
rgb("#dae6fb")
, 
icon_color: 
rgb("#0758E5")
, 
icon: 
fa-info()
)
]
#block[
#heading(
level: 
3
, 
numbering: 
none
, 
[
Domain 4: Flow and Timing
]
)
]
#block[
#callout(
body: 
[
- Appropriate interval between index test and reference standard
- All participants receive same reference standard
- All participants included in analysis
- Clear documentation of assessment timeline

]
, 
title: 
[
Low Risk Criteria
]
, 
background_color: 
rgb("#dae6fb")
, 
icon_color: 
rgb("#0758E5")
, 
icon: 
fa-info()
)
]
== II. Inter-rater Reliability Assessment
<ii.-inter-rater-reliability-assessment>
=== Structured Evaluation Protocol
<structured-evaluation-protocol>
+ Initial Documentation Review:
  - Abstract screening
  - Methods section analysis
  - Results interpretation
  - Limitations acknowledgment
+ Systematic Data Extraction:

#block[
#strong[Study Characteristics Form:]

- ☐ Sample size calculation documented
- ☐ Inclusion/exclusion criteria specified
- ☐ Recruitment strategy detailed
- ☐ Timeline of assessments provided
- ☐ Diagnostic protocol described
- ☐ Blinding procedures documented
- ☐ Statistical analyses appropriate

]
#block[
#set enum(numbering: "1.", start: 3)
+ Quality Metrics Assessment:
]

#block[
#strong[Risk Assessment Checklist:]

#strong[PATIENT SELECTION]

- ☐ Sampling method: \_\_\_\_\_\_\_\_\_\_\_\_\_\_\_
- ☐ Selection criteria: \_\_\_\_\_\_\_\_\_\_\_\_\_\_
- ☐ Exclusions justified: \_\_\_\_\_\_\_\_\_\_\_
- ☐ Documentation complete: \_\_\_\_\_\_\_\_\_

#strong[INDEX TEST]

- ☐ Protocol standardized: \_\_\_\_\_\_\_\_\_\_
- ☐ Thresholds pre-specified: \_\_\_\_\_\_
- ☐ Blinding maintained: \_\_\_\_\_\_\_\_\_\_\_

#strong[REFERENCE STANDARD]

- ☐ Diagnostic criteria: \_\_\_\_\_\_\_\_\_\_\_
- ☐ Blinding procedures: \_\_\_\_\_\_\_\_\_\_
- ☐ Protocol adherence: \_\_\_\_\_\_\_\_\_\_\_

#strong[FLOW AND TIMING]

- ☐ Assessment intervals: \_\_\_\_\_\_\_\_\_
- ☐ Complete follow-up: \_\_\_\_\_\_\_\_\_\_
- ☐ Missing data handled: \_\_\_\_\_\_\_\_

]
== III. Inter-rater Agreement Procedures
<iii.-inter-rater-agreement-procedures>
+ Independent Assessment Phase:
  - Minimum two qualified raters
  - Standardized extraction forms
  - Blinded to other rater’s decisions
  - Documentation of rationale
+ Consensus Building Process:
  - Initial agreement calculation
  - Discrepancy identification
  - Structured resolution discussion
  - Final consensus determination
+ Statistical Analysis:
  - Kappa coefficient calculation
  - Percent agreement analysis
  - Systematic bias evaluation
  - Reliability metrics documentation

== IV. Quality Control Measures
<iv.-quality-control-measures>
#block[
#strong[Quality Assurance Checklist:]

- ☐ Rater qualification verified
- ☐ Training protocol completed
- ☐ Extraction forms standardized
- ☐ Regular calibration meetings
- ☐ Documentation requirements met
- ☐ Resolution process followed
- ☐ Statistical analysis completed
- ☐ Results interpretation agreed

]
== V. Recommended Documentation Format
<v.-recommended-documentation-format>
#block[
#strong[Study Quality Assessment Template:]

Study ID: \_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_ \
Primary Rater: \_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_ \
Secondary Rater: \_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_ \
Date of Assessment: \_\_\_\_\_\_\_\_\_\_\_\_\_

#strong[RISK OF BIAS DETERMINATION:]

Patient Selection: □Low □Unclear □High \
Evidence: \_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_ \
Rationale: \_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_

Index Test: □Low □Unclear □High \
Evidence: \_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_ \
Rationale: \_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_

Reference Standard: □Low □Unclear □High \
Evidence: \_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_ \
Rationale: \_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_

Flow and Timing: □Low □Unclear □High \
Evidence: \_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_ \
Rationale: \_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_

#strong[CONSENSUS DETERMINATION:] \
Initial Agreement: \_\_\_\_\_\_\_\_\_\_\_\_\_\_ \
Resolution Process: \_\_\_\_\_\_\_\_\_\_\_\_ \
Final Classification: \_\_\_\_\_\_\_\_\_\_

]
== VI. Clinical Implications
<vi.-clinical-implications>
The systematic implementation of these criteria ensures:

+ Standardized evaluation across studies
+ Reliable risk assessment
+ Transparent decision-making
+ Reproducible methodology
+ Clinical validity enhancement

This framework provides a structured approach to evaluating methodological rigor in adult ADHD diagnostic studies, facilitating reliable inter-rater assessment and maintaining consistency in bias evaluation.
