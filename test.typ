#import "blockly_hathi.typ": *

#set page(height: auto)
#set text(font: "Liberation Sans", size: 11pt)

// Custom icon for alternative character
#let hartmut = read("svg/hartmut.svg")

// Scope for eval - all blockly functions
#let blockly-scope = (
  // Simple blocks
  gehe-vor: gehe-vor,
  drehe: drehe,
  drehe-links: drehe-links,
  drehe-rechts: drehe-rechts,
  gehe-n-mal: gehe-n-mal,
  gehe-variable-mal: gehe-variable-mal,
  hisse-flagge: hisse-flagge,
  hebe-bananen-auf: hebe-bananen-auf,
  hebe-tomaten-auf: hebe-tomaten-auf,
  lege-bananen-ab: lege-bananen-ab,
  nimm-auf: nimm-auf,
  lege-ab: lege-ab,
  sage: sage,
  // Variables
  setze-auf: setze-auf,
  erhoehe: erhoehe,
  // Reporter/conditions
  vorne-frei: vorne-frei,
  steht-vor: steht-vor,
  nicht: nicht,
  die-kiste-ist-zu: die-kiste-ist-zu,
  die-flagge-ist-gehisst: die-flagge-ist-gehisst,
  hat-sich-bewegt: hat-sich-bewegt,
  reporter-dropdown: reporter-dropdown,
  // Control blocks
  falls: falls,
  falls-sonst: falls-sonst,
  wiederhole-n-mal: wiederhole-n-mal,
  wiederhole-fortlaufend: wiederhole-fortlaufend,
  wiederhole-solange: wiederhole-solange,
  hauptprogramm: hauptprogramm,
  // Icons
  hathi-icon: hathi-icon,
  hartmut: hartmut,
)

// Helper function to show code and execute it
#let show-and-run(code) = {
  raw(code, lang: "typst", block: true)
  eval(code, mode: "markup", scope: blockly-scope)
}

= Typst Hathi Blockly Package

== Einfache Hathi-Blöcke


#show-and-run("#gehe-vor()")
#v(5pt)
#show-and-run("#drehe(richtung: \"links\")")

#v(5pt)
#show-and-run("#drehe(richtung: \"rechts\")")

== Blöcke mit benutzerdefiniertem Icon


#show-and-run("#gehe-vor(icon: hartmut)")
#v(5pt)
#show-and-run("#drehe(richtung: \"links\", icon: hartmut)")
#v(5pt)

#show-and-run("#gehe-n-mal(n: \"3\", icon: hartmut)")

== Blöcke zusammenfassen

#show-and-run("#stack(spacing: 0pt, 
gehe-vor(), 
drehe(richtung: \"links\"))")


#v(15pt)

== Gehe n-mal vor

#show-and-run("#gehe-n-mal(n: \"99\")")

#v(15pt)

== Reporter/Bedingungsblock

#show-and-run("#vorne-frei()")

#v(5pt)

#show-and-run("#steht-vor(objekt: \"Bananen\")")

#v(5pt)

#show-and-run("#steht-vor(objekt: \"Kiste\")")
#v(5pt)

#show-and-run("#reporter-dropdown(\"Trägt\", \"Bananen\")")

#v(15pt)

== Logik-Block: nicht

#show-and-run("#nicht()")

#v(5pt)

#show-and-run("#nicht(condition: vorne-frei())")
#v(15pt)

== Hauptprogramm (leer)

#show-and-run("#hauptprogramm()")

#v(15pt)

== Falls-Block (leer)

#show-and-run("#falls()")

#v(15pt)

== Wiederhole-Block

#show-and-run("#wiederhole-fortlaufend()")

#v(15pt)

== Wiederhole solange (kopfgesteuert)

#show-and-run("#wiederhole-solange()")

#show-and-run("#wiederhole-solange(condition: vorne-frei())")

#v(15pt)

== Wiederhole solange mit nicht

#show-and-run("#wiederhole-solange(condition: nicht(condition: vorne-frei()), nested: (
  gehe-vor(),
))")

#v(15pt)

== Falls mit nicht
#show-and-run("
#falls(condition: nicht(condition: vorne-frei()), nested: (
  drehe-links(),
))
"
)

#v(15pt)

== Falls-Sonst mit nicht
#show-and-run(
"
#falls-sonst(
  condition: nicht(condition: vorne-frei()),
  nested-if: (gehe-vor(),),
  nested-else: (drehe-links(),),
)
"
)

#v(15pt)

== Wiederhole solange mit nested Content

#show-and-run(
  "
#wiederhole-solange(condition: vorne-frei(), nested: (
  gehe-vor(),
))
  "
)

#show-and-run(
  "
#wiederhole-solange(condition: vorne-frei(), nested: (
  gehe-vor(),
  falls(condition: vorne-frei(), nested: (
    gehe-vor(),
  )),
  drehe-links(),
))
"
)


#v(15pt)

== Wiederhole fortlaufend mit nested Content

#show-and-run("#wiederhole-fortlaufend(nested: (
  falls(condition: vorne-frei(), nested: (
    gehe-vor(),
  )),
  drehe-links(),
))")

#v(15pt)

== Wiederhole n-mal Block (mit lila Zahlenblock)

#show-and-run("#wiederhole-n-mal(n: \"4\")")

#v(15pt)

== Wiederhole n-mal mit nested Content

#show-and-run("#wiederhole-n-mal(n: \"10\", nested: (
  gehe-vor(),
  drehe-links(),
))")

#v(15pt)

== Falls-Sonst Block

#show-and-run("#falls-sonst(
  condition: vorne-frei(),
  nested-if: (gehe-vor(),),
  nested-else: (drehe-links(),),
)")

#v(15pt)

== Falls-Sonst im Hauptprogramm

#show-and-run("#hauptprogramm(nested: (
  falls-sonst(
    condition: vorne-frei(),
    nested-if: (gehe-vor(),),
    nested-else: (drehe-links(),),
  ),
))")

#v(15pt)

== Falls-Sonst mit verschachtelten Falls-Blöcken

#show-and-run("#falls-sonst(
  condition: vorne-frei(),
  nested-if: (
    falls(condition: vorne-frei(), nested: (
      gehe-vor(),
    )),
    falls(condition: die-flagge-ist-gehisst(), nested: (
      drehe-links(),
    )),
  ),
  nested-else: (
    falls(condition: die-kiste-ist-zu(), nested: (
      drehe-rechts(),
    )),
    falls(condition: vorne-frei(), nested: (
      hisse-flagge(),
      hebe-bananen-auf(),
    )),
  ),
)")

== Einfaches Programm mit Hauptprogramm und Bewegungsblöcken

#show-and-run("#hauptprogramm(nested: (
  gehe-vor(),
  gehe-vor(),
))")

#v(15pt)

== Falls vorne frei, gehe vor

#show-and-run("#falls(condition: vorne-frei(), nested: (
  gehe-vor(),
))")

#show-and-run("#falls(condition: steht-vor(objekt: \"Bananen\"), nested: (
  gehe-vor(),
))")

== Hauptprogramm mit einem falls-Block

#show-and-run("#hauptprogramm(nested: (
  falls(condition: vorne-frei(), nested: (
    gehe-vor(),
  )),
  falls(condition: vorne-frei(), nested: (
    gehe-vor(),
  )),
  falls(condition: vorne-frei(), nested: (
    gehe-vor(),
  )),
))")

#v(15pt)

== Verschachtelte Falls-Blöcke

#show-and-run("#hauptprogramm(nested: (
  falls(condition: vorne-frei(), nested: (
    falls(condition: vorne-frei(), nested: (
      gehe-vor(),
      drehe-links(),
    )),
    gehe-vor(),
    drehe(richtung: \"rechts\"),
  )),
))")


#show-and-run("#wiederhole-n-mal(n: \"11\", nested: (
  gehe-vor(),
  drehe-links(),
  falls(condition: vorne-frei(), nested: (
    falls(condition: vorne-frei(), nested: (
      gehe-vor(),
      drehe-links(),
    )),
    gehe-vor(),
    drehe(richtung: \"links\"),
  )),
))")

#v(15pt)

== Beispiel 1

#scale(30%, reflow: true)[

  #hauptprogramm(nested: (
    wiederhole-n-mal(n: "2", nested: (
      hebe-tomaten-auf(),
      gehe-vor(),
      gehe-vor(),
      drehe(richtung: "rechts"),
      gehe-n-mal(n: "2"),
    )),
    drehe(richtung: "links"),
    drehe(richtung: "links"),
    wiederhole-n-mal(n: "2", nested: (
      gehe-n-mal(n: "3"),
      hebe-bananen-auf(),
      gehe-vor(),
      drehe(richtung: "links"),
    )),
  ))
]

#v(15pt)

== Setze-Auf Block (Variablen)

#show-and-run("#setze-auf()")

#v(5pt)

#show-and-run("#setze-auf(name: \"counter\", wert: \"42\")")

#v(15pt)

== Beispiel: Falls vorne frei, setze auf

#show-and-run("#falls(condition: vorne-frei(), nested: (
  setze-auf(name: \"<Name>\", wert: \"0\"),
))")

#v(15pt)

== Erhöhe Block (Variablen)

#show-and-run("#erhoehe()")

#v(5pt)

#show-and-run("#erhoehe(name: \"counter\")")

#v(15pt)

== Beispiel: Falls vorne frei mit setze-auf und erhöhe

#show-and-run("#falls(condition: vorne-frei(), nested: (
  setze-auf(name: \"<Name>\", wert: \"0\"),
  erhoehe(name: \"<Name>\"),
))")

#v(15pt)

== Beispiel: Gehe Variable mal vor

#show-and-run("#gehe-variable-mal()")

#v(5pt)

#show-and-run("#gehe-variable-mal(variable: \"counter\")")

#v(15pt)

== Verkleinertes Beispielprogramm

```typst
#scale(30%, reflow: true)[
  #hauptprogramm(nested: (
    setze-auf(name: "Bäume", wert: "0"),
    wiederhole-n-mal(n: "10", nested: (
      gehe-vor(),
      drehe(richtung: "links"),
      falls(condition: steht-vor(objekt: "Baum"), nested: (
        erhoehe(name: "Bäume"),
        drehe(richtung: "rechts"),
      )),
      drehe(richtung: "rechts"),
    )),
    gehe-vor(),
    drehe(richtung: "rechts"),
    gehe-n-mal(n: "3"),
    drehe(richtung: "rechts"),
    gehe-variable-mal(variable: "Bäume"),
    drehe(richtung: "rechts"),
    gehe-vor(),
  ))
]

```
#scale(30%, reflow: true)[
  #hauptprogramm(nested: (
    setze-auf(name: "Bäume", wert: "0"),
    wiederhole-n-mal(n: "10", nested: (
      gehe-vor(),
      drehe(richtung: "links"),
      falls(condition: steht-vor(objekt: "Baum"), nested: (
        erhoehe(name: "Bäume"),
        drehe(richtung: "rechts"),
      )),
      drehe(richtung: "rechts"),
    )),
    gehe-vor(),
    drehe(richtung: "rechts"),
    gehe-n-mal(n: "3"),
    drehe(richtung: "rechts"),
    gehe-variable-mal(variable: "Bäume"),
    drehe(richtung: "rechts"),
    gehe-vor(),
  ))
]