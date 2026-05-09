SHVAPE — Ein Mutschelbach-Abenteuer
===================================

EINFACH SPIELEN:
  Doppelklick auf index.html (oder shvape.html — gleiches Spiel). Fertig.

EMPFOHLEN (für Teilen-Button auf dem Death-Screen):
  Doppelklick auf start-server.bat
  Dann im Browser: http://localhost:8000/
  (Benötigt Python — die meisten Windows-Rechner haben das schon.)

ONLINE STELLEN (GitHub Pages / Netlify / Vercel / S3 / etc.):
  Lade einfach index.html in dein Hosting hoch. Mehr ist nicht nötig —
  alles ist inline (Code, Styles). Tone.js und Google Fonts kommen vom
  CDN; bei Ausfall fällt das Spiel automatisch auf System-Fonts und
  Stumm-Modus zurück. Auch der KSC-Spielstand kommt von einem
  öffentlichen API; bei CORS-Block bleibt der Schal-Pip einfach grau.

  Auf GitHub Pages MUSS die Datei "index.html" heißen (nicht
  shvape.html), sonst zeigt GitHub einen 404 für die Root-URL.

DATEIEN (alle ins Hosting hochladen, nebeneinander):
  index.html               Spiel (gleiches wie shvape.html)
  shvape.html              Spiel (alternativer Dateiname)
  favicon.svg              Vape-Pen mit "AY"-Wolke (Browser-Tab)
  favicon.png              PNG-Fallback für alte Browser
  apple-touch-icon.png     iOS-Bookmarks (180x180)
  og-image.png             WhatsApp / Twitter / Discord Preview (1200x630)
  manifest.webmanifest     PWA-Manifest, "zum Home-Screen hinzufügen"
  README.txt               Diese Datei
  TECH_REVIEW.md           Aktueller Tech-Audit-Stand
  start-server.bat         Lokaler Server-Launcher (Windows)


WAS DU SPIELST
==============

Bin Run Schwape, 15, Hauptschüler in Mutschelbach, KSC-Treu. Der
Familienname ist ein Versehen aus 1952. Niemand will den Eintrag
ändern. Drei Generationen leben damit.

Du rennst durch sechs reale Stadtteile (Mutschelbach, Karlsbad-
Langensteinbach, Industriegebiet Ittersbach, Waldbronn-Albtal-Therme,
Ettlingen-Marktplatz, Völkersbach/Schwarzwald-Rand), kämpfst gegen 7
Hauptbosse, verfolgst dein Vape-Akku, dei Aura, dei Pfand-Konto.

Ende: 10:00 Uhr früh. Gutes Ende erreicht. Wenn du Mutter besiegst —
und das hat noch fast niemand — kommt Akt II.


DIE DREI AKTIONEN — DER KERN-TRADE-OFF
======================================

JUMP   — kostet nichts. Defensiv. Aber Airtime engt dein Insult-
         Fenster ein.
VAPE   — füllt Akku, kleine Aura. Spammen = Cringe-Strafe.
INSULT — große Aura, +5% Vape zurück bei Treffer; aber 8% Vape Kosten,
         0.4s Sperre (verwundbar), "GEGEN DIE LUFT" wenn kein NPC.

Jede Aktion an einer anderen Ecke des Survival/Cool-Spektrums.


STEUERUNG (TASTATUR)
====================

  ↑ / W / SPACE        Sprung (halten = höher)
  ↓ / S                ducken / sliden
  ← / A oder → / D     Speed-Nudge
  V                    manuell dampfen
  B / E / R            INSULT (NPC anvisieren!)
  P / ESC              Pause
  M                    Stumm
  F                    Respekt zollen (Death-Screen)
  T                    Death-Screen teilen (Bild in Zwischenablage)
  TAB / G              Vitrine (Achievements) auf Death-Screen


STEUERUNG (MOBILE / TOUCH)
==========================

  Linke Bildschirmhälfte    bewegen (touch+halten)
  Rechte Bildschirmhälfte   SPRUNG
  Pinker Knopf             INSULT
  Grüner Knopf             VAPE
  DUCK-Pille               ducken
  Wischen ↓                ducken (alternative)


AURA-TIERS
==========

  OPFER             ×0.25-0.5    bieder, cringe
  MID               ×1.0         ok
  HART              ×1.5         läuft
  HART AM RIZZ      ×2.5         feuer
  WAHRER SIGMA      ×4.0         95+ Aura, NPCs starren


6 ABILITIES + 6 CURSES
======================

Jeder Boss-Sieg gibt eine Fähigkeit UND einen Fluch. Beide reset jede
Runde:

  B1 ZEUGNIS      → KRASS-DASH      + SCHULSTRESS (Vape -1.3×)
  B2 CLIQUE       → TRIPLE-JUMP     + PEER PRESSURE (OPFER ×0.25)
  B3 DREXLER      → WALL-SLIDE      + SCHULORDNUNG (V>2s = Drexler)
  B4 POLIZEI      → STEALTH         + AKTENZEICHEN (Passat-Patrouillen)
  B5 RUDOLF       → SIGH CANCEL     + GENERATIONELLER FLUCH
                                       (+ MAMA-ANRUF-EVENT)
  B6 SCHWARZWALD  → PFIFFERLING-SINN + SCHATTEN
  B7 MUTTER       → (geheim) → AKT II


TÄGLICHE MUTATIONEN
===================

Jeder Kalender-Tag rollt eine Variante: SCHWOBA-TAG, AURA-GIER,
VAPE-TROCKEN, STILLE-BELEIDIGUNG, KEHRWOCHE, OPFER-TAG, SIGMA-TAG,
STUTTGART-WIND, PRESSE-TAG, HABIBI-TAG, PFAND-TAG, KSC-GEDENKEN.

Sondertage überschreiben die Tagesrolle: Neujahr, Valentinstag,
Weltfrauentag, Tag der Arbeit, Sommersonnenwende, Tag der Einheit,
Halloween, 11.11. Karneval, Nikolaus, Heiligabend, Silvester.


COSMETICS (LIFETIME)
====================

  1.000     GOLD CHAIN       (chest chain dicker + glänzt)
  10.000    HOODIE LOGO      (kleines "S" auf Brust)
  100.000   GOLD ADILETTEN   (Sandalen werden goldfarben)
  1.000.000 GOLD VAPE        (Vape-Pen wird gold)


VAPE-GESCHMÄCKER (8)
====================

  erdbeer (häufig)        +1 Aura/Sek tickend
  bubblegum               leichtere Schwerkraft (×0.85)
  tabak                   Pfand-Wert ×1.5
  wassermelone            Drain-Rate ×0.7
  energy                  Speed-Cap ×1.2
  mystery (selten)        Steuerung invertiert 5s
  heiliger_hauch (selten) Sigma-Popup → +5 Aura jedesmal
  spaetzle (sehr selten)  CURSED — Aura-Tier −1, dafür +35 Vape


ACHIEVEMENTS (29)
=================

Press TAB oder G auf dem Death-Screen für die Vitrine.


ZIEL
====

Überleben. Krass sein. Pfand sammeln. NPCs cool beleidigen. Mutter
ist (anscheinend) unbesiegbar. 10:00 = gutes Ende. Mutter wirklich
besiegen = Akt II (Finanzamt → Tod-Skat → Honeycutt → Mir Sin Alle
Mutschelbacher).

Dei Großvater dreht sich em Grab um — egal was du machsch.

— gebaut mit Liebe für Bin Run Schwape, Mutschelbach.
