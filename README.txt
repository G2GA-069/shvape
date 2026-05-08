SHVAPE — Ein Mutschelbach-Abenteuer
===================================

EINFACH SPIELEN:
  Doppelklick auf index.html (oder shvape.html — gleiches Spiel). Fertig.

EMPFOHLEN (für Teilen-Button auf dem Death-Screen):
  Doppelklick auf start-server.bat
  Dann im Browser: http://localhost:8000/
  (Benoetigt Python — die meisten Windows-Rechner haben das schon.)

ONLINE STELLEN (GitHub Pages / Netlify / Vercel / S3 / etc.):
  Lade einfach index.html in dein Hosting hoch. Mehr ist nicht noetig —
  alles ist inline (Bilder, Code, Styles). Tone.js und Google Fonts
  kommen vom CDN; bei Ausfall faellt das Spiel automatisch auf
  System-Fonts und Stumm-Modus zurueck.

  Auf GitHub Pages MUSS die Datei "index.html" heissen (nicht shvape.html),
  sonst zeigt GitHub einen 404 fuer die Root-URL.

DATEIEN (alle ins Hosting hochladen, nebeneinander):
  index.html                Spiel (gleiches wie shvape.html — fuer Hosting-Defaults)
  shvape.html               Spiel (alternativer Dateiname)
  favicon.svg               Vape-Pen mit "AY"-Wolke (Browser-Tab-Icon)
  favicon.png               PNG-Fallback fuer alte Browser
  apple-touch-icon.png      iOS-Bookmarks (180x180)
  og-image.png              WhatsApp / Twitter / Discord / Slack Preview (1200x630)
  manifest.webmanifest      PWA-Manifest, "zum Home-Screen hinzufuegen"
  README.txt                Diese Datei
  start-server.bat          Lokaler Server-Launcher (Windows)

TEILEN:
  Wenn du den Link irgendwo postet (WhatsApp, Twitter, Discord, Slack,
  Facebook, LinkedIn, Telegram, Signal), siehst du automatisch die
  Vorschau mit Bin Run und dem "SHVAPE"-Banner. Funktioniert sobald der
  Link auf einem oeffentlichen Server liegt.

STEUERUNG (Tastatur):
  Pfeil ←/→ oder A/D    nudge speed
  Pfeil ↑ oder W oder Leertaste    Sprung (halten = höher)
  Pfeil ↓ oder S    ducken / sliden
  V    manuell dampfen
  P / ESC    Pause
  M    Stumm
  F    Respekt zollen (auf Death-Screen)
  T    Death-Screen teilen (Bild in Zwischenablage)

STEUERUNG (Mobile / Touch):
  Linke Bildschirmhälfte    bewegen (touch+halten)
  Rechte Bildschirmhälfte    SPRUNG
  Doppeltippen    manuell dampfen
  Wischen ↓    ducken

ZIEL:
  Überleben. Krass sein. Das Vape leerläuft -> du stirbst.
  Krassheit niedrig -> wenig Punkte (×0.5).
  Krassheit voll -> LEGENDE-Modus (×4 Punkte, aber Vape drainiert 50% schneller).
  Bei 10:00 erreicht das gute Ende. Schau mal nach.

Anthropic Claude — gebaut mit Liebe für Bin Run Shvape.
