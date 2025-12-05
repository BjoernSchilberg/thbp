#import "blockly_hathi.typ": *

#set text(font: "Liberation Sans", size: 11pt)

// Custom icon for alternative character
#let hartmut = read("svg/hartmut.svg")

= Typst Hathi Blockly Package

== Einfache Hathi-Blöcke

#gehe-vor()
#v(5pt)
#drehe(richtung: "links")

#v(5pt)
#drehe(richtung: "rechts")

== Blöcke mit benutzerdefiniertem Icon

#gehe-vor(icon: hartmut)
#v(5pt)
#drehe(richtung: "links", icon: hartmut)
#v(5pt)
#gehe-n-mal(n: "3", icon: hartmut)

== Blöcke zusammenfassen
#stack(spacing: 0pt, gehe-vor(), drehe(richtung: "links"))

#v(15pt)

== Gehe n-mal vor

#gehe-n-mal(n: "99")

#v(15pt)

== Reporter/Bedingungsblock

#vorne-frei()

#v(5pt)

#steht-vor(objekt: "Bananen")

#v(5pt)

#steht-vor(objekt: "Kiste")

#v(5pt)

#reporter-dropdown("Trägt", "Bananen")

#v(15pt)

== Logik-Block: nicht

#nicht()

#v(5pt)

#nicht(condition: vorne-frei())

#v(15pt)

== Hauptprogramm (leer)

#hauptprogramm()

#v(15pt)

== Falls-Block (leer)

#falls()

#v(15pt)

== Wiederhole-Block

#wiederhole-fortlaufend()

#v(15pt)

== Wiederhole solange (kopfgesteuert)

#wiederhole-solange()

#wiederhole-solange(condition: vorne-frei())

#v(15pt)

== Wiederhole solange mit nicht

#wiederhole-solange(condition: nicht(condition: vorne-frei()), nested: (
  gehe-vor(),
))

#v(15pt)

== Falls mit nicht

#falls(condition: nicht(condition: vorne-frei()), nested: (
  drehe-links(),
))

#v(15pt)

== Falls-Sonst mit nicht

#falls-sonst(
  condition: nicht(condition: vorne-frei()),
  nested-if: (gehe-vor(),),
  nested-else: (drehe-links(),),
)

#v(15pt)

== Wiederhole solange mit nested Content

#wiederhole-solange(condition: vorne-frei(), nested: (
  gehe-vor(),
))

#wiederhole-solange(condition: vorne-frei(), nested: (
  gehe-vor(),
  falls(condition: vorne-frei(), nested: (
    gehe-vor(),
  )),
  drehe-links(),
))

#v(15pt)

== Wiederhole fortlaufend mit nested Content

#wiederhole-fortlaufend(nested: (
  falls(condition: vorne-frei(), nested: (
    gehe-vor(),
  )),
  drehe-links(),
))

#v(15pt)

== Wiederhole n-mal Block (mit lila Zahlenblock)

#wiederhole-n-mal(n: "4")

#v(15pt)

== Wiederhole n-mal mit nested Content

#wiederhole-n-mal(n: "10", nested: (
  gehe-vor(),
  drehe-links(),
))

#v(15pt)

== Falls-Sonst Block

#falls-sonst(
  condition: vorne-frei(),
  nested-if: (gehe-vor(),),
  nested-else: (drehe-links(),),
)

#v(15pt)

== Falls-Sonst im Hauptprogramm

#hauptprogramm(nested: (
  falls-sonst(
    condition: vorne-frei(),
    nested-if: (gehe-vor(),),
    nested-else: (drehe-links(),),
  ),
))

#v(15pt)

== Falls-Sonst mit verschachtelten Falls-Blöcken

#falls-sonst(
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
)

== Einfaches Programm mit Hauptprogramm und Bewegungsblöcken

#hauptprogramm(nested: (
  gehe-vor(),
  gehe-vor(),
))

#v(15pt)

== Falls vorne frei, gehe vor

#falls(condition: vorne-frei(), nested: (
  gehe-vor(),
))

#falls(condition: steht-vor(objekt: "Bananen"), nested: (
  gehe-vor(),
))

== Hauptprogramm mit einem falls-Block

#hauptprogramm(nested: (
  falls(condition: vorne-frei(), nested: (
    gehe-vor(),
  )),
  falls(condition: vorne-frei(), nested: (
    gehe-vor(),
  )),
  falls(condition: vorne-frei(), nested: (
    gehe-vor(),
  )),
))

#v(15pt)

== Verschachtelte Falls-Blöcke

#hauptprogramm(nested: (
  falls(condition: vorne-frei(), nested: (
    falls(condition: vorne-frei(), nested: (
      gehe-vor(),
      drehe-links(),
    )),
    gehe-vor(),
    drehe(richtung: "rechts"),
  )),
))


#wiederhole-n-mal(n: "11", nested: (
  gehe-vor(),
  drehe-links(),
  falls(condition: vorne-frei(), nested: (
    falls(condition: vorne-frei(), nested: (
      gehe-vor(),
      drehe-links(),
    )),
    gehe-vor(),
    drehe(richtung: "links"),
  )),
))

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

#setze-auf()

#v(5pt)

#setze-auf(name: "counter", wert: "42")

#v(15pt)

== Beispiel: Falls vorne frei, setze auf

#falls(condition: vorne-frei(), nested: (
  setze-auf(name: "<Name>", wert: "0"),
))

#v(15pt)

== Erhöhe Block (Variablen)

#erhoehe()

#v(5pt)

#erhoehe(name: "counter")

#v(15pt)

== Beispiel: Falls vorne frei mit setze-auf und erhöhe

#falls(condition: vorne-frei(), nested: (
  setze-auf(name: "<Name>", wert: "0"),
  erhoehe(name: "<Name>"),
))

#v(15pt)

== Beispiel: Gehe Variable mal vor

#gehe-variable-mal()

#v(5pt)

#gehe-variable-mal(variable: "counter")

#v(15pt)

== Beispiel

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

