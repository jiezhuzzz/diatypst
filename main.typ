#import "@preview/touying:0.6.1": *
#import "@preview/codly:1.3.0": *
#import "@preview/cetz:0.4.2"
#import "@preview/cetz-plot:0.1.3": plot, chart
#import "@preview/pinit:0.2.2": *
#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge
#import themes.metropolis: *

#let uchicago-maroon = rgb("#7A0019")
#show: codly-init.with()

#codly(lang-format: none, stroke: 2pt + gray)

#let cetz-canvas = touying-reducer.with(reduce: cetz.canvas, cover: cetz.draw.hide.with(bounds: true))

#let fletcher-diagram = touying-reducer.with(reduce: fletcher.diagram, cover: fletcher.hide)


#let callout(title: none, body) = {  
  rect(  
    fill: luma(95%),  
    stroke: 2pt + blue,  
    radius: 4pt,  
    inset: 1em,  
    width: 100%,  
    [  
      #if title != none [  
        *#title*  
        #v(0.5em)  
      ]  
      #body  
    ]  
  )  
}

#codly(
  languages: (
    rust: (name: "Rust", icon: "🦀", color: rgb("#CE412B")),
  )
)

// #show: diatypst-theme.with(
//   aspect-ratio: "16-9",
//   layout: "medium",
//   title-color: uchicago-maroon,
//   count: "dot",
//   footer: true,
//   toc: false,
//   theme: "normal",
//   logo: image("assets/logo.svg", width: 5cm),
//   config-info(
//     title: "Locus",
//     subtitle: "Synthesizing Fine-grained Predicates for Curriculum Fuzzing",
//     author: "Jie Zhu",
//     date: datetime.today().display(),
//   ),
// )

// #title-slide(
//   title: "Locus",
//   subtitle: "Synthesizing Fine-grained Predicates for Curriculum Fuzzing",
//   authors: ("Jie Zhu",),
//   co-authors: ("Chihao Shen", "Ziyang Li", "Jiahao Yu", "Yizheng Chen", "Kexin Pei"),
//   date: datetime.today().display(),
//   logo: image("assets/logo.svg", width: 5cm),
// )

#show: metropolis-theme.with(
  aspect-ratio: "16-9",
  footer: self => self.info.institution,
  config-info(
    title: [Locus],
    subtitle: [Synthesizing Fine-grained Predicates for Curriculum Fuzzing],
    author: [Jie Zhu],
    date: datetime.today(),
    institution: image("assets/logo/Maroon.svg",height:5em),
    logo: image("assets/seal/DarkGreystoneBorder_WhiteBorder.svg", height:1.5em),
  ),
  config-colors(
  primary: rgb("#eb811b"),
  primary-light: rgb("#d6c6b7"),
  secondary: uchicago-maroon,
  neutral-lightest: rgb("#fafafa"),
  neutral-dark: rgb("#23373b"),
  neutral-darkest: rgb("#23373b"),
)
)

#title-slide()

#speaker-note[
  Thanks for inviting me to this talk.
  Today I'm gonna present my latest work Locus, it will be published at the ICSE 26.
]

= Large Language Model for Vulnerability Reasoning

#speaker-note[
  To start with, we already know there are lots of opportunies for using large language model for vulnerability reasoning.
]

== Great promise of LLMs in vulnerability study

#slide(composer: grid.with(columns: 3, rows: 2, gutter: 1em))[
  #image("figs/agents/aardvark.jpg")
][
  #pause
  #image("figs/agents/bigsleep.jpg")  
][
  #pause
  #image("figs/agents/copilot.jpg")  
][
  #pause
  #image("figs/agents/codemender.jpg")  
][
  #pause
  #image("figs/agents/runsybil.jpg")  
][
  #pause
  #image("figs/agents/xbow.jpg")  
]

#speaker-note[
  Large language Model proposed lots of new opportunities in the software security. And Many compnay comes up their security agent.
  + [click] OpenAI just released their first security agent, Aardvark. Aardvark calls external tools (e.g. language servers, linters) to uncover vulnerabilities. In early trials, it has reported 72 security fixes to open source projects.
  + [click] Google's Big Sleep framework uses LLM agents for variant analysis of known fixes. The LLM is given a diff or commit for a fixed bug and asked to search the similar issues inside the codebase.
    todo: given a vulnearbility, generalized the pattern from the patched vulnerability.
  + [click] Microsoft’s Security Copilot is also assisting security analysis. In one research case study, Redmond used Copilot to speed up the audit of open-source bootloaders.
  + [click] CodeMender is another security agent from Google. It uses multi-agent critique loops and is integrated with other advanced security tools.
  + [click] RunSybil is a startup founded by former OpenAI security researcher Ariel Herbert-Voss. It focuses on penetration testing. In a WIRED demo, RunSybil discovered an admin  leakage; another chained together exploits until it “broke something meaningful” on a dummy e-commerce site
  + [click] XBOW is a commercial AI-powered pentesting service. And already find more than 1000 zero-day vulnerabilities.
  So far, the typical ways of utilizing LLMs to detect vulnerabilities are still from static analyses. 
  most of the agent are devloped to find new patterns,
  and the 
]


#focus-slide[
  Are these vulnerabilities exploitable?
]

#speaker-note[
  
  A simple question to this could be: [content]
]

== LLM is awesome, but ...

#slide(composer: (1fr, 1fr, 1fr))[ 
  - Need manual inspection
  - High false positive rate

  
  #image("figs/x/p1.png")  
  #image("figs/x/p2.png")  
][  
  #image("figs/x/p5.png")  
][  
  #image("figs/x/p4.png")  
]

#speaker-note[
LLM used most as Static analysis is scalable but can have a high false positive rate.
In fact, there have been emerging complaints about AI-generated bug reports. For example, the core developer of cURL noted an influx of submissions where people run code through an LLM and then file the output as a security report.
The famous opent source project FFmpeg also complains about google abuse their security agent.
// – only for it to “mix and match facts and details from old security issues, creating and making up something new that has no connection with reality”
]

== Alerts are cheap, show me the PoV!

#callout(title: [Proof of vulnerability (PoV) generation
])[PoVs serve as the foundation of the AIxCC scoring system because they demonstrate that vulnerabilities can actually be triggered. #highlight[PoV+patch combinations earn significantly higher point values than patches submitted without PoV.] The competition’s scoring system also rewards speed and accuracy. Furthermore, PoVs can be used to bypass other teams’ patches and reduce competitors’ accuracy multipliers, which adds an interesting game theory element to the competition.
]

#speaker-note[
  That’s why this year AIxCC asks for not only patches but also the proof of vulnerability, like the concrete inputs that can trigger the vulnerability.
  In the competition, having both PoV and patches can actually earn significantly more points. 
  More interestingly, having some tricky PoVs can also potentially help bypass the other teams’ patches, basically showing their patches are incomplete. These could also reduce competitors' scores.
]

== Typical ways to generate PoV

#slide(composer: (1fr, 1fr))[
=== Fuzzing
  #v(1em)
  #fletcher-diagram(    
  // node-stroke: none,  // Remove node outlines  
  // node-fill: none,    // Remove node fills  
  spacing: (15mm, 10mm),
  node-corner-radius: 5pt, 
  node-stroke: 1pt,
  edge-stroke: 1pt,    
      
  node((1,0), [Input Generator], name: <gen>),    
  edge("->"),    
  node((2.5,0), [Fuzzer], name: <fuzzer>),    
  // edge(<gen>, <fuzzer>, "->", label: `execution()`),  
  node((1,3), [Reward], name: <reward>),
  node((2.5,3), [Program], name: <program>),   
  
      
  edge(<reward>, <gen>, "->", label: `feedback()`),  
  edge(<fuzzer>, <program>, "->", label: `execute()`),
  edge(<program>, <reward>, "->", label: `compute()`),

  pause,
  node((1,4), [Coverage], name: <coverage>),
  edge(<reward>, <coverage>, "-"), 
  pause,
  node((2,4), [Distance to target], name: <distance>),    
  edge(<reward>, <distance>, "-"),    
)
#v(1em)
What if we already suspect a vulnerability location? And we want to generate the PoV.
][
#pause

#alternatives-match((  
  "1-4": [
=== Typical task formulation
```c
scanf("%d", &n); 
int a[10];



a[n] = 1; // target
``` 
  
],  
  "5-": [
=== A better example

#codly(
  annotation-format: none,
  annotations: (
    (
      start: 3,
      end: 5,
      content: block(
        width: 5em,
        // Rotate the element to make it look nice
        align(box(width: 100pt)[`Canary`])
      )
    ), 
  )
)

```c
scanf("%d", &n); 
int a[10];
if (n < 0 || n > 9) {
  // target
}
a[n] = 1;
```
  ],  
))
// === Path constraints
// $  
//     y &= n^2 + 2z + 1  \  
//     z  &> (x + 1)^2  \  
//   pause a &< 0
// $

#callout(title: [Canary
])[
  A specification that satisfiying its condition implies the vulnearbility will be triggered.
]
]
#speaker-note[
  You can never prove you find a vulnerability until you find a PoV.

  So how do we find PoVs? A common practice is to leverage fuzzing, which is a mature technique with extensive system support.
  In fact, five out of six teams in AIxCC final adopt this technique.
  Fuzzing is a search procedure.
  A typical reward, coverage, is like finding a path cover to cover all control flow graph; typical directed fuzzing, assume you know where you want to reach, using a bunch of generic distance metrics, like branch distances, graph distances in the control flow graph, etc

  [click]
  The latter metrics are typically used for fuzzing towards a specified program state, a.k.a. directed fuzzing.
  In directed fuzzing, program states are represented by a specified prorgam point.
  And it's indeed a series of path constraints.
  [click]
  todo: however, not all program states can be represented by control flow information. 
  That's why we apply canary as an indicator for the targeted program states.
]

== Limitations[WIP]

Missing fine-grained states to feedback reward for the searcher (fuzzer).

The guidance can still be too sparse
- e.g., CVE-2018-13785 in libpng requires a PNG file to satisfy:
- valid signature
- correct chunk layout
- specific IHDR fields (e.g., bit depth, color type)
- a magic image width (0x55555555) 

--- 

Specialized stateful guidance:
- Temporal memory safety bug (linear temporal logic): 
- allocate–free–use sequence for use-after-free (UAF)
- Specified by human expert
- Specialized for one bug type with one pattern and may not generalize

#speaker-note[
  
The problem is sometimes these distance feedback can be still too sparse. There are often a lot of very nuanced and tricky preconditions needed for the execution to satisfy in order to trigger the vulnerability. Not all of these conditions are explicitly specified as the branches in the code. 
For example, in order to trigger 
a precise sequence of preconditions: 
They still rely on existing branches in the code, which does not necessarily give a fine-grained feedback towards triggering the bug. 
Human expert needs domain expertise and manual effort, and often times the entire technique is so specialized to one bug type and may not generalize to another

[maybe two slides] better with animation to illustrate these points, shall we use 

]

= Large Language Model for Fuzzing

== Where to put the LLM?

#slide[
  #fletcher-diagram(    
  // node-stroke: none,  // Remove node outlines  
  // node-fill: none,    // Remove node fills  
  spacing: (15mm, 10mm),
  node-corner-radius: 5pt, 
  node-stroke: 1pt,
  edge-stroke: 1pt,    

  node((1,-3), [LLM], name: <llm>),
  node((1,0), [Input Generator], name: <gen>),    
  edge("->"),    
  node((2,0), [Fuzzer], name: <fuzzer>),    
  // edge(<gen>, <fuzzer>, "->", label: `execution()`),    
  node((2,2), `Reward`, name: <reward>),    
      
  edge(<reward>, <gen>, "->", bend: 30deg, label: `feedback()`),  
  edge(<fuzzer>, <reward>, "->", label: `execute()`), 
    
  edge("-"),  
  node((1,4), [Coverage], name: <coverage>),    
  node((2,4), [Branch], name: <branch>),    
  edge(<reward>, <branch>, "-"),
  pause,
  edge(<llm>, <gen>, "->", label: `+mutation`),
  pause,
  edge(<llm>, <gen>, "->", bend: 40deg, label: `+grammar learning`),
)
]





== Room for improvement (LLM for fuzzing)

LLM tries to constrain the search space, but at the input level. Space for improvements:

- Reasoning burden
  - From deeply nested target state _all the way to input_
  - Long context reasoning across distant procedures
- Input-only constraints
  - Some are hard to check at the input level
- Hallucination
  - How to verify whether the LLM-generated generator is correct?
  - Worst case scneario: what if the grammar specified in the input prevents the execution from reaching the target?


#focus-slide[
  Not use LLM for fuzzer, but use for the program instead?
]
  
== Program Smoothing

#cetz-canvas({
    import cetz.draw: *
    
  plot.plot(  
    size: (6, 2),  
    axis-style: none,  
    x-min: -3, x-max: 3,  
    y-min: 0, y-max: 2,  
    {  
      // Add a dummy invisible data point to establish bounds  
      plot.add(((0, 0),), style: (stroke: none))  
        
      plot.annotate({  
        line((-3, 0), (3, 0))  
        line((0, 0), (0, 1))  
        content((-3, 0), anchor: "east", padding: 0.2, [x])  
        content((0, -0.5), [0xdeadbeef])
      })  
    }  
  ) 
})
#pause
#cetz-canvas({
    import cetz.draw: *
    
  plot.plot(  
    size: (6, 4),  
    axis-style: none,  
    x-min: 0, x-max: 6,  
    y-min: -3, y-max: 3,  
    {  
      // Add a dummy data point to establish bounds  
      plot.add(((0, 0),), style: (stroke: none))  
        
      // Add the V-shaped function instead of vertical line  
      plot.add(  
        domain: (0, 6),  
        x => if x < 3 { -x + 3 } else { x - 3 },  
        samples: 100,
        style: (stroke: black)
      )  
        
      plot.annotate({  
        // Horizontal line (x-axis)  
        line((0, 0), (6, 0))  
          
        // Labels  
        content((0, 0), anchor: "east", padding: 0.2, [x])  
        content((3, -0.5), [0xdeadbeef])  
      })  
    }  
  )
})
#pause
#cetz-canvas({
  import cetz.draw: * 
  plot.plot(    
  size: (6, 4),    
  axis-style: none,    
  x-min: -3, x-max: 3,    
  y-min: 0, y-max: 2,    
  {    
    // 添加虚拟数据点以建立边界  
    plot.add(((0, 0),), style: (stroke: none))    
      
    plot.add(  
    domain: (-3, 3),  
    x => {  
      let stdev = 1.0  
      let gaussian = (1 / calc.sqrt(2 * calc.pi * calc.pow(stdev, 2))) * calc.exp(-(x * x) / (2 * calc.pow(stdev, 2)))  
      let max_value = 1 / calc.sqrt(2 * calc.pi * calc.pow(stdev, 2))  
      max_value - gaussian  // 反转：最大值减去高斯值  
    },  
    samples: 100,  
    style: (stroke: black)  
  )
        
    plot.annotate({    
      line((-3, 0), (3, 0))    
      content((-3, 0), anchor: "east", padding: 0.2, [x])    
      content((0, -0.5), [0xdeadbeef])  
    })    
  }    
)
  
})

#speaker-note[
  Before I jump to how Locus different with previous attempts, let's take a look at something interesting.
  To reach a new program state, here the variable x has to be the exact value 0xdeadbeef.
  the reward from the search is either 0 or 1.
  [click] And to make this search smooth, we consider a reward function that can measure the distance between the current value to our target.
  [click] This can be further improved, to make the program more smooth and more suitable to search.
]


== Program Smoothing: curriculum waypoints

#slide(composer: grid.with(columns: 2, rows: 2))[
  #cetz-canvas({
    import cetz.draw: *
    
  plot.plot(  
    size: (6, 2),  
    axis-style: none,  
    x-min: -3, x-max: 3,  
    y-min: 0, y-max: 2,  
    {  
      // Add a dummy invisible data point to establish bounds  
      plot.add(((0, 0),), style: (stroke: none))
        
      plot.annotate({  
        line((-3, 0), (3, 0))  
        line((0, 0), (0, 1))  
        content((-3, 0), anchor: "east", padding: 0.2, [x])  
        content((0, -0.5), [0xdeadbeef])
      })  
    }  
  ) 
})

#cetz.canvas({    
    import cetz.draw: *    
        
  plot.plot(      
    size: (6, 2),      
    axis-style: none,      
    x-min: -3, x-max: 3,      
    y-min: 0, y-max: 2,      
    {      
      // 左右各四个台阶的阶梯图数据    
      plot.add(    
        (    
          (-3, 0),    
          (-2.5, 0.3),    
          (-2, 0.5),    
          (-1.5, 0.7),    
          (-1, 0.9),    
          (0, 1.2),    
          (1, 0.9),    
          (1.5, 0.7),    
          (2, 0.5),    
          (2.5, 0.3),    
          (3, 0)    
        ),    
        line: "hvh"    
      )    
            
      plot.annotate({      
        line((-3, 0), (3, 0))      
        line((0, 0), (0, 1.2))      
        content((-3, 0), anchor: "east", padding: 0.2, [x])      
        content((0, -0.5), [0xdeadbeef])    
      })      
    }      
  )     
})


][
```c
if (x == 0xdeadbeef):
  crash();
```

```c
if (x[0] != 0xef)
	exit()
if (x[1] != 0xbe)
	exit()
...
if (x == 0xdeadbeef)
  crash()

```
]


== Key insight: curriculum predicate synthesis

#slide(composer: (1fr, 1fr))[
  ```c
if x > 10:
  crash()
```

#codly(
  annotations: (
    (
      start: 1,
      end: 4,
      content: block(
        width: 7em,
        // Rotate the element to make it look nice
        rotate(
          align(center, box(width: 100pt)[Predicate])
        )
      )
    ), 
  )
)

```c
if x > 5:
  continue
else: 
  exit
...
if x > 10:
  crash()

```
][
*Hard* to generate:
- Need understand target semantics
- Need creativity
- Qualitative, no rules for “best”
but *easy* to verify:
- Symbolic execution
- E.g., Is there a path that violates synthesized predicates but satisfies the target condition?
Great fit for LLM (agents)
]

// == Key insight: curriculum predicate synthesis

// 圆锥 -》 两个圆环

= Locus

== Pipeline

#alternatives[
  #image("figs/pipeline/1.svg")
][
  #image("figs/pipeline/2.svg")
][
  #image("figs/pipeline/3.svg") 
][
  #image("figs/pipeline/4.svg") 
][
  #image("figs/pipeline/5.svg") 
][
  #image("figs/pipeline/6.svg")
][
  #image("figs/pipeline/7.svg")
]

== Evaluation

- Magma benchmark: 
  - libpng, libsndfile, libtiff, libxml2, lua, poppler, openssl, sqlite3, php
- Fuzzers:
  - Undirected: AFL, AFL++, MOPT, Fox
  - Directed: AFLGo, SelectFuzz, Beacon, Titan
- Targets:
  - Canary condition
  - Patch
- Metrics:
  - Time to exposure (TTE)

== Results

#cetz-canvas({
    import cetz.draw: * 

    set-style(  
    axes: (  
      tick: (  
        label: (  
        offset: 1cm, 
          angle: 45deg,  // 旋转 45 度  
          anchor: "north-east"  // 调整锚点  
        )  
      )  
    )  
  ) 
    
  chart.columnchart(  
    (  
      ("AFLGo", 40466.35, 9724.3),  
      ("SelectFuzz", 18402.47619, 4646.857143),  
      ("Beacon", 13001.61538, 3891.307692),  
      ("Titan", 28920.72222, 14294),  
      ("AFL", 37576, 11171),  
      ("AFL++", 10832, 6569),  
      ("MOPT", 4740, 427.52),  
      ("Fox", 8804, 2871),  
    ),  
    label-key: 0,  
    value-key: (1, 2),  
    mode: "clustered",  
    size: (20, 8),  
    y-label: [Time to Exploit (TTE)],  
    labels: ("Original", "Origin + Locus")  
  ) 
})

== Cost Analysis
#align(center)[
  #table(
    columns: 9,
    align: (left, center, center, center, center, center, center, center, center),
    // Header row
    [*Target*], [*PNG*], [*SND*], [*TIF*], [*LUA*], [*XML*], [*SSL*], [*PHP*], [*SQL*],
    
    [Size (LoC)], [95k], [83k], [95k], [21k], [320k], [630k], [1.6M], [387k],
    // Separator
    // Index, Synthesis, Validation, Total rows
    [Index], [11], [34], [82], [9], [76], [146], [244], [137],
    [Synthesis], [373], [331], [212], [178], [215], [384], [412], [349],
    [Validation], [261], [133], [231], [280], [475], [824], [353], [407],
    [Total], [645], [498], [525], [467], [766], [1354], [1009], [893],
    // Separator
    // #Tokens row
    [Tokens (k)], [309], [303], [256], [176], [653], [598], [894], [467],
    // Separator
    // AFLGo, SelectFuzz, Beacon, Titan rows
    [AFLGo], [122], [673], [2689], [85], [5608], [24799], [T.O.], [15630],
    [SelectFuzz], [84], [199], [1167], [44], [807], [2597], [4554], [383],
    [Beacon], [64], [113], [171], [35], [1656], [T.O.], [T.O.], [3721],
    [Titan], [96], [186], [967], [49], [2936], [T.O.], [T.O.], [4965],
  )
]

== New Vulnerabilities

#align(center)[
  #table(
    columns: 6,
    align: (left, left, center, center, center, center),
    
    // // Header
    // table.hline(stroke: 1.5pt), // \toprule
    // rowspan(2, [ID]), rowspan(2, [Vul. Type]), colspan(2, [AFL++]), colspan(2, [SelectFuzz]),
    // table.cline(x: 2, colspan: 2, stroke: 1pt), // \cmidrule
    // table.cline(x: 4, colspan: 2, stroke: 1pt), // \cmidrule
    // [origin], [pname], [origin], [pname],
    // table.hline(), // \midrule
  
    [*Keyword*], [*Description*], [*Default*], [*as*], [*12*],[*12*],
    
    // Body
    [VLC-29163], [Memory leak], [T.O.], [30847], [T.O.], [26317],
    [VLC-29162], [OOB access], [T.O.], [74835], [T.O.], [T.O.],
    [VLC-29238], [Memory leak], [T.O.], [21085], [53872], [24766],
    [VLC-29239], [Use-after-free], [43680], [3946], [22983], [5405],
    [libming-365], [Null deref], [T.O.], [80241], [T.O.], [T.O.],
    [libarchive-hvqg], [Null deref], [83622], [34327], [62748], [18309],
    [libarchive-fm54], [OOB access], [T.O.], [16397], [46577], [23280],
    
  )
]

== Case Study

```diff
diff --git a/read_format_rar.c b/read_format_rar.c
index 2dd0ea34..7f0ad199 100644
@@ -3708,6 +3708,8 @@ filter_delta(filter *f, ...
     uint8_t lastbyte = 0;
     for (idx = i; idx < length; idx += channels) {
+      if (src >= dst)
+        return 0;
       lastbyte = dst[idx] = lastbyte - *src++;
     }

```

== Summary

- Decompose the search in fuzzing as intermediate, curriculum, and gradual milestones
- Relax reasoning burden at local program context
- The output modality (predicates) is amenable to: 
  - Symbolic validator (ensure correctness)
  - Training (how good in terms of the guidance)
- Friendly interface to many existing program analyzers
  - Fuzzers
  - Static analyzers
  - Formal verification (proof synthesis, etc.)

#focus-slide[
  Q & A
]