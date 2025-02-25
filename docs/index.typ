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

#show: doc => article(
  title: [Adult ADHD Systematic Review],
  authors: (
    ( name: [Joey W. Trampush, Ph.D.],
      affiliation: [University of Southern California],
      email: [] ),
    ),
  date: [2025-02-25],
  toc_title: [Table of contents],
  toc_depth: 3,
  cols: 1,
  doc,
)

= Introduction
<introduction>
Attention-Deficit/Hyperactivity Disorder (ADHD) in adults presents a significant challenge in clinical practice due to its complex presentation, high comorbidity, and the varying responses to treatment. Clinicians, patients, and stakeholders must navigate several decisional dilemmas when diagnosing and treating ADHD in adults. Here, we address the key decisional dilemmas and current controversies and challenges in diagnosing ADHD in adults.

Attention-deficit/hyperactivity disorder (ADHD) is a neurodevelopmental condition characterized by persistent patterns of inattention, hyperactivity, and impulsivity. While it is commonly diagnosed in children, ADHD frequently persists into adulthood, presenting unique challenges for diagnosis and management. This section explores the key decisional dilemmas faced by clinicians, patients, and stakeholders in diagnosing and treating adult ADHD.

= Background
<background>
== Trajectory of ADHD across development
<trajectory-of-adhd-across-development>
ADHD typically presents early in life, most often diagnosed and treated between early childhood and adolescence. Less commonly, ADHD can insidiously emerge in adulthood in individuals with no history of inattention, hyperactivity, or impulsivity in childhood. Notably, longitudinal data from the MTA ADHD Treatment Study suggests 90-95% of "adult-onset ADHD" is better accounted for by comorbid psychopathology, personality disorders, and/or substance use disorders #emph[misdiagnosed] as ADHD @sibley2017. The later-onset expression of ADHD thus appears to be a syndrome distinct from childhood-onset ADHD.

== Executive dysfunction in emerging adulthood
<executive-dysfunction-in-emerging-adulthood>
Seeking evaluation and treatment for ADHD #emph[for the first time] continues to increase, and is especially salient on college campuses, where the use/misuse of prescription stimulant medication as a cognitive-enhancing drug is rising faster than the actual incidence of the disorder @benson2015. The volume of college students seeking an evaluation for ADHD to obtain test-taking and other academic accommodations has increased in parallel.

Critically, interconnected heteromodal networks of association cortex that control higher executive cognitive functions are still maturing during college @sydnorNeurodevelopmentAssociationCortices2021. It is therefore plausible that generalized #emph[executive dysfunction];, not undiagnosed ADHD per se, is underlying most clinical referrals for ADHD in college students. As such, we posit executive dysfunction is at the core of the real-world problems facing college students who self-refer for ADHD evaluation and treatment, which accentuates the comorbid difficulties these students face such as problematic drug and alcohol use, emotional dysregulation, and school failure.

== Limited diagnostic tools to assess ADHD and executive functioning in college students
<limited-diagnostic-tools-to-assess-adhd-and-executive-functioning-in-college-students>
Independent of when symptoms first present, the proliferation of adult-onset ADHD, whether real or feigned, signifies an increase in the demand to evaluate and treat ADHD across the lifespan. However, #emph[clinicians do not have evidence-based, objective psychodiagnostic tools] (e.g., rating scales, neuropsychological measures) available to evaluate ADHD/EF in this specific population #emph[that grows each year];. Poor diagnostic tools lead to inaccurate and misleading conclusions, which can result in clinicians making wasteful/cost-ineffective, inappropriate, or potentially even harmful treatment recommendations. If we fail to implement clinical assessment tools sensitive to #emph[symptom validity] and #emph[performance validity] during evaluations, we will continue to #emph[overdiagnose] and treat college students and adults from the community faking ADHD for secondary gain, and #emph[underdiagnose] those with actual ADHD who need medical and/or academic intervention.

== Diagnostic Tools and Approaches
<diagnostic-tools-and-approaches>
- #strong[Use of Standardized Tools];: Reliable diagnosis requires standardized rating scales and input from multiple informants, including self-reports, and observations by family members and colleagues.

- #strong[Clinical Judgment vs.~Standardized Assessment];: Clinician judgment, while essential, may be supplemented by objective tools such as neuropsychological tests and behavioral assessments to enhance diagnostic accuracy.

== Differential Diagnosis
<differential-diagnosis>
- #strong[Comorbidity with Other Disorders];: Adults with ADHD often present with comorbid psychiatric conditions such as depression, anxiety, and substance use disorders, complicating the diagnostic process. Accurate differentiation between ADHD and these conditions is crucial.

- #strong[Overlap with Other Symptoms];: Symptoms of ADHD, such as inattention, can overlap with those of other psychiatric disorders, making differential diagnosis challenging.

== Cultural and Socioeconomic Factors
<cultural-and-socioeconomic-factors>
- #strong[Bias and Accessibility];: Diagnostic practices may be influenced by cultural biases and socioeconomic factors, leading to disparities in diagnosis rates among different demographic groups. It is important to consider these factors to ensure equitable access to diagnosis and treatment.

== Impact
<impact>
ADHD remains improperly diagnosed and treated in tens of thousands of promising college students, younger adults, and older adults. The consequences of aberrant diagnosis and treatment of ADHD during this critical stage of emerging adulthood and beyond can lead to functional impairments in school/work performance, educational attainment, career development, social-emotional development, and family and community life. The need for evidence-based diagnostic tools specific to this rapidly growing clinical population is urgently stronger than ever.

= Key Decisional Dilemmas
<key-decisional-dilemmas>
The primary decisional dilemmas for clinicians, patients, and stakeholders in diagnosing and managing ADHD in adults involve the following considerations:

- #strong[Diagnosis Challenges];: Clinicians must decide whether presenting symptoms are due to ADHD or other comorbid conditions such as anxiety, depression, or substance use disorders @kooij2010.
- #strong[Treatment Initiation];: Decisions regarding who should initiate treatment (e.g., primary care vs.~specialty care) and when to start treatment are crucial @nice2018.
- #strong[Treatment Alternatives];: Providers need to determine the most effective treatment modalities, including pharmacological and non-pharmacological interventions @cortese2018. Further, clinicians must weigh the benefits and risks of stimulant medications versus non-stimulant medications @bolea2014.
- #strong[Patient Characteristics];: Treatment effectiveness may vary based on individual patient characteristics such as age, sex, and comorbid conditions @faraone2015.
- #strong[Cultural Considerations];: Cultural differences may impact the presentation, diagnosis, and treatment of ADHD in adults @bruss2012.
- #strong[Unintended Consequences];: The potential for stimulant diversion and misuse is a significant concern when prescribing stimulant medications @wilens2008.
- #strong[Identification and Assessment];: What are the most effective and reliable methods for diagnosing ADHD in adults? Considerations include standardized diagnostic criteria, use of rating scales, and the role of clinical interviews. Further, referral for neuropsychological evaluation for adult ADHD is increasingly common, given the complexity and heterogeneity of the disorder. @barkley2008
- #strong[Differential Diagnosis];: How can clinicians distinguish ADHD from other psychiatric conditions such as anxiety, depression, or personality disorders @kooij2010?
- #strong[Cultural and Socioeconomic Factors];: How do cultural perceptions and socioeconomic status affect the diagnosis of ADHD in adults @ramos-quiroga2012?
- #strong[Stigma and Misdiagnosis];: What impact does stigma have on the diagnosis of ADHD in adults, and how can misdiagnosis be minimized @timimi2005?

= Controversies and Challenges
<controversies-and-challenges>
Diagnosing ADHD in adults is inherently challenging. Symptoms such as inattention, hyperactivity, and impulsivity often overlap with other psychiatric conditions, making differential diagnosis difficult. Clinicians must consider the chronicity of symptoms from childhood through adulthood and assess functional impairment in various settings @culpepper2008.

- #strong[Different Practices];: There is significant variability in diagnostic practices. While some clinicians use structured diagnostic interviews and validated rating scales, others rely on clinical judgment. This inconsistency can lead to both over-diagnosis and under-diagnosis of ADHD @culpepper2008.
- #strong[Diagnostic Criteria];: There is debate over whether the DSM-5 criteria for ADHD, primarily developed for children, are fully applicable to adults @asherson2016.
- #strong[Overdiagnosis vs.~Underdiagnosis];: Controversy exists over the extent to which ADHD is overdiagnosed or underdiagnosed in adult populations @faraone2021.
- #strong[Gender Differences];: The diagnosis of ADHD in women may be underrepresented due to differences in symptom presentation and societal expectations @quinn2014.
- #strong[Comorbidity];: High rates of comorbidity with other psychiatric disorders complicate the diagnosis of ADHD in adults @kessler2006.
- #strong[Diagnostic Criteria and Symptom Manifestation];: Adult ADHD diagnosis is complicated by the persistence and transformation of symptoms from childhood. Symptoms such as inattention and impulsivity may persist, while hyperactivity may manifest differently in adults.
- #strong[Diagnostic Criteria Adaptation];: Current diagnostic criteria (e.g., DSM-5) are based primarily on childhood symptoms, which may not fully capture adult presentations. There is a need for criteria that reflect adult-specific symptoms and impairments.

= Conclusion
<conclusion>
The accurate diagnosis of ADHD in adults presents several decisional dilemmas for clinicians and patients. These include the adaptation of diagnostic criteria, the use of standardized tools, consideration of comorbidities, and the hard truth that many individuals are blatantly feigning their symptoms.

adhd\_systematic\_review/ ├── \_quarto.yml \# Project configuration ├── index.qmd \# Project overview ├── data/ │ ├── raw\_pdfs/ \# Original PDFs │ ├── processed/ \# Extracted text and metadata │ └── metadata.csv \# Study tracking spreadsheet ├── R/ │ ├── 01\_pdf\_processing.R \# PDF text extraction │ ├── 02\_metadata\_extract.R \# Structured data extraction │ ├── 03\_quality\_assessment.R \# Study quality metrics │ └── 04\_analysis.R \# Final analysis scripts ├── outputs/ │ ├── tables/ │ └── figures/ └── docs/ \# Generated reports

#bibliography("references.bib")

