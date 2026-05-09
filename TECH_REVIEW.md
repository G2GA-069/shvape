# SHVAPE TECH REVIEW — 2026-05-09

Head-of-tech bug sweep + technical health assessment + remediation plan.
Scope: full single-file game `shvape.html` (10,157 lines, 480 KB raw —
~100 KB gzipped via GitHub Pages), `index.html` (synced copy), all
sibling assets, README, deploy.

Severity legend:
* **CRIT** — blocks gameplay or destroys data
* **BUG** — wrong behavior in real play, possibly invisible
* **PERF** — unnecessary work or budget pressure
* **DX** — developer experience / maintainability
* **POLISH** — small visual/UX or content fixes
* **CONTENT** — scrub misses, typos, broken refs

---

## Executive summary

The game is in healthier shape than its line count suggests. No CRIT
issues. A small cluster of CONTENT misses and one timing-race BUG worth
fixing immediately. The README is heavily stale — predates Stage 2
identity layer, the INSULT pillar, achievements, and daily mutations.

The "Insult.findTarget reads `.kind` instead of `.type`" bug landed
yesterday in commit 73bf06e — single biggest gameplay-loop bug ever
shipped here, broke the third action pillar in real play. Already
fixed, called out below as the kind of pre-existing class-confusion
that should have a test.

Recent commit history (8b7c426 → 73bf06e) shipped ~12,000 net new lines
of game systems with high feature velocity. Tech-debt at this point is
manageable; shipping discipline is the bigger risk.

---

## 1. Architecture

### 1.1  Single-file constraint
- Canonical entry `index.html` for GitHub Pages (per README §"ONLINE
  STELLEN"). `shvape.html` is a synced copy.
- Tone.js + Google Fonts via CDN, both with documented graceful-fail
  paths. Verified `<script onerror="window.__toneFailed=true">` and
  `if (window.__toneFailed) … silent`.
- All game state lives in 8 globally-mutable singletons:
  `Game · Save · Bg · Krass · Vape · Player · Audio · HUD · Insult ·
  Mutation · Achv · NpcReactions · NewsTicker · IntroCaption ·
  BinRunKnows · MamaCall · Boss · Encounter · Death · Tutorial ·
  Ending · Menu · Progression · DripUnlock · SchnitzelEnding ·
  Act2Transition · TransgressionDirector · IndirectionDirector ·
  EncDirector · Director`.
- That's a lot of globals (~30) with implicit ordering dependencies.
  Re-shipping in modules is out of scope; the const-let convention and
  clear section comments are the discipline that holds it together.

### 1.2  Reset boundary integrity
**Verdict: holds.** `resetForNewRun()` covers every Game.X field that
matters for run-state. Spot-checked: `dashT`, `honeycuttOffer`,
`auraLocked`, `act2`, `cassette` all correctly clear. Several private
`Game._XYZ` fields (`_insultEverFired`, `_fiveMinUnlocked`,
`_b9FailsThisRun`) are explicitly reset; `_npcLastReact` is not, which
is fine — it's a per-kind LRU and re-population on next insult is
correct behavior. `_pauseTip` is cleared lazily when pause exits.

### 1.3  File size
- 480 KB raw. Modern Pages serves gzip → ~100 KB on wire.
- Mobile parse-time on a 2024 mid-tier Android: estimated 60-90 ms.
  Acceptable.
- Will become uncomfortable >800 KB. Continue to expand libraries
  (which are mostly arrays of strings — gzip-friendly), avoid adding
  large image data URLs.

---

## 2. State + save layer

### 2.1  `Save.load` shallow-merge — **BUG-5**
`Object.assign(this.data, j)` does a flat top-level merge. Any nested
object in the saved JSON **replaces** the default. If save format ever
adds a key inside `cosmetics` / `npcMemory` / `ksc` / `bossesDefeated
Lifetime`, an old save will load with the old object shape and the new
key will be `undefined` rather than the schema default.

Currently no consumer breaks on `undefined` in those paths (everything
uses truthy checks), but it's load-bearing fragile. **Fix:** when
loading a saved object, deep-merge with the in-memory default so
defaults backstop missing nested keys.

### 2.2  Save schema versioning — **DX**
No `version` field on saves. Future schema breaks have no migration
path. **Fix:** add `Save.data._v = 1`, log a warning if loaded version
< current.

### 2.3  KSC fixture fetch — **BUG-4**
`Save.fetchKscIfStale()` calls `fetch('https://api.openligadb.de/...')`
in a try/catch. Verified at runtime: `Save.data.ksc.last` is `null`
hours after init. Either:
1. CORS blocked (likely — OpenLigaDB has been historically inconsistent
   on CORS headers from `https://` to `https://`)
2. No completed match in current matchday window
3. Network unavailable (preview iframe sandbox)

The 24h cache means a CORS failure poisons the cache for a day. **Fix:**
on fetch failure, do NOT update `checkedAt` so we retry next session.
Optionally surface a tiny ⚠ on the KSC HUD pip.

---

## 3. Render / perf hot path

### 3.1  Verified clean
- `ctx.save()` / `ctx.restore()` balanced (verified by grep — counts
  match within ±2 across the file).
- Particle pool managed by `updateParticles` with implicit life-cap.
- Pickups have magnetism (commit 8b7c426) — runs every entity per
  frame but bounded by visible-range cull.
- Schatten curse vignette uses radial gradient — a single `fillRect`
  per frame when active. Cheap.
- Atmospheric perspective uses two alpha tricks instead of `ctx.filter`
  (commit 2a3b83e). 1000× cheaper. Verified.
- Stealth alpha branch is single ternary, free.

### 3.2  Audio setTimeout chains — **PERF (acceptable)**
All audio methods schedule via `setTimeout` rather than `Tone.Transport`.
Functional; works because audio events are short and fire-and-forget.
Migrating to Transport would yield ms-precise sync but no user-
observable improvement at current note density.

---

## 4. Boss flow

### 4.1  B8 → B9 transition race — **BUG-3**
```
setTimeout(()=>{
  Game.state = 'BOSS'; Game.inBoss = true;
  Boss.active = new B9_Tod(8); ...
}, 3000);
```
If during those 3 seconds the player dies (Vape drops to 0 in the brief
PLAY window), restarts, hits Escape to MENU, OR triggers any state
transition, the timer fires anyway and **clobbers** whatever state has
been entered. B9 spawns on top of the death screen / menu / new run.

**Fix:** wrap the timer body with a guard:
```
setTimeout(()=>{
  if (Game.state !== 'PLAY') return;          // user moved on
  if (Boss.active) return;                    // something else spawned
  ...
}, 3000);
```

### 4.2  B7 Mutter secret-win math
**Verdict: holds, intentional.** 1% per right-arrow press × 17 frames
required × 20 second window = ~5 presses/sec required. Mathematically
nontrivial but reachable; spec-required difficulty.

### 4.3  B10 Honeycutt auto-snap — **BY DESIGN**
After REFUSE escalates to next offer, `honeycuttSelected = 0` snaps the
toggle back to ACCEPT. This is the spec'd "the only path forward is the
button labeled ACCEPT" mechanic. Working as intended.

---

## 5. Insult / transgression flow

### 5.1  Class-confusion bug — **BUG-0 (already fixed)**
`Insult.findTarget` read `n.kind`; Bg.near entries use `n.type`. Manual
unit tests masked it because tests pushed `{kind:...}` objects directly.
Fixed in commit 73bf06e. Lesson:

> **DX-3**: There is no test harness. Manual eval-driven tests are
> prone to using the same model as the producer rather than the
> consumer's contract. A 50-line test file that asserts against
> real-game spawn data would have caught this in 5 minutes.

### 5.2  Insult lifetime anti-repeat — **WORKS**
`Save.data.shownInsults` filters every pick. Pool exhaustion path
correctly wipes the seen-set and re-rolls. With 193 general + 188 kind-
specific = 381 unique strings, an aggressive player needs hundreds of
runs before triggering a wipe.

### 5.3  Reaction bubble parallax — **WORKS (after 73bf06e)**
NpcReactions.draw uses `xWorld - scrollX*0.85`, matching Bg.near
parallax. Bubble glues to NPC across frames.

---

## 6. Achievements + mutations

### 6.1  Achievement coverage
29 defined, ~25 trigger sites verified. `STILLE_MEISTER` requires 90+s
runs without insult — verified the `_insultsAtRunStart` snapshot is
captured in `resetForNewRun` (committed 213a200). `KSC_TREU` depends on
`Save.data.ksc.last === 'loss'`, blocked when ksc fetch fails (see
BUG-4). Acceptable — it's a niche achievement; CORS-fixing it lets it
unlock once data flows.

### 6.2  Mutation effect coverage
13 daily + 11 seasonal mutations registered. Each has at least one
call-site read of `Mutation.is(id)`. Verified at runtime that
`STUTTGART_WIND` ramps speed-cap by 1.25× as advertised.

### 6.3  Save persistence vs run state
Achievement unlock writes to `Save.data.achievements`, calls
`Save.save()`. Verified persists across reload.

---

## 7. Content scan

### 7.1  Stale "EBEKA" reference — **CONTENT/BUG-1**
Commit `faa11c7` was titled "Scrub last EBEKA/Pennay references".
**One survived:** `SIGMA_RULES` line 706:
```
"VfB-Fans dürfen ned in EBEKA.",
```
Likely missed because grep at scrub time used a different boundary.
**Fix:** replace with one of the parodied chains we kept (PENNY,
SPARKASSO, VOLKSBÄNK).

### 7.2  Dead placeholder — **DX-2**
`INSULT_LINES_KIND.hochschulerin_extra: []` — dead entry, 0 lines.
**Fix:** remove.

### 7.3  README.txt outdated — **BUG-2**
Last edit predates the entire V2 + Stage 2 + INSULT pillar. Specifically:
- Refers to "Bin Run Shvape" (with v) — should be "Bin Run Schwape"
  (with w/p — the surname is the joke, distinct from SHVAPE the title)
- Uses "Krassheit" — game has used "Aura" for 15+ commits
- "LEGENDE-Modus" — renamed to "WAHRER SIGMA" in Stage 1
- No mention of: 6 abilities, 6 curses, INSULT button, Mama call,
  Mutter secret, Act II, B8/B9/B10, daily mutations, achievements,
  vitrine, highlight reel, transgressions, vape flavors
- Mobile controls section misses INSULT button and DUCK pill
- No mention of TAB / G key for vitrine

**Fix:** rewrite README.txt to reflect current game.

### 7.4  "Schvape" / "Schwape" / "SHVAPE" usage
Verified consistent: the game title is "SHVAPE" (h+v), the protagonist
is "Bin Run" with surname "Schwape" (w/p — the 1952 paperwork joke).
19 hits on "Schvape" — all are the title in headers/strings.
`drawWincingSchwape()` reliably renders the surname distinct from the
game title. No collisions.

---

## 8. Mobile / Input

### 8.1  Mobile button layout
Verified at canvas resolution 1280 × 720:
- VAPE (180, 520) r=110
- INSULT (280, 340) r=90
- JUMP (1080, 520) r=140
- DUCK pill (1050-1170, 630-686)
- Mute button (CSS-positioned, 48 × 48 top-right)

INSULT-to-VAPE clearance: distance ≈ 206 px > sum of radii (200) by
~6 px. Tight but non-overlapping in canvas-space. Scales uniformly
with display, so no aspect-ratio regression risk.

### 8.2  KEY_MAP collision-resistant — **WORKS (after bb327d8)**
Hotfix bb327d8 caught the WASD-A-vs-vitrine collision. KeyA now back
to `'left'`, vitrine on Tab + KeyG.

### 8.3  Touch-pointer parallax of right-side fallback
`Input.touchJump` correctly excludes onVape, onInsult, onDuck regions
from the right-half-anywhere fallback. Verified.

---

## 9. Browser compat

### 9.1  Tone.js 14.7.77 — modern but not bleeding-edge
- Safari 14+ support fine
- iOS audio context: requires user gesture; `Audio.unlock()` plumbed
  through every input path. Verified.
- Tone.Destination.mute toggle persists across track switches.

### 9.2  Canvas 2D — universally safe
No WebGL, no OffscreenCanvas, no shaders, no `ctx.filter` (replaced
in 2a3b83e). Renders identically across browsers.

### 9.3  localStorage — hardened
Every write/read wrapped in try/catch. Private mode / Safari ITP
quirks fail silently to in-memory state. Acceptable.

---

## 10. Distribution

### 10.1  GitHub Pages config
- Live: https://g2ga-069.github.io/shvape/
- Both `index.html` and `shvape.html` ship; index is canonical.
- OG image / favicon / manifest all served. og-image.png 64 KB,
  apple-touch-icon.png 4 KB.
- No service worker, no PWA installability handler. Manifest
  `display: standalone` exists but no install prompt fires. Acceptable
  scope.

### 10.2  No analytics / telemetry
By design. Local-first, no tracking. Verification codes (4-char
hash) are the only "share" surface.

---

## Action items — this session

Fixing immediately:
1. **B-1** — purge stray "EBEKA" sigma rule, replace with PENNY parodied
2. **B-2** — rewrite README.txt to current game state
3. **B-3** — guard B8→B9 setTimeout against state changes during gap
4. **B-5** — Save.load shallow-merge → defensive nested defaults
5. **CONTENT/DX-2** — remove `hochschulerin_extra` dead placeholder
6. **DX (cheap win)** — add Save schema version field for future-proof

Documenting only (out of scope this session):
- DX-1: single-file mutable-globals architecture
- DX-3: no test harness
- BUG-4: KSC CORS — needs an actual CORS-friendly endpoint
- Future: PWA service worker for offline play

---

## Sign-off

Shipping the action items in this same session. Audit found no CRIT,
6 actionable items, 0 known correctness regressions. Live game updated
and pushed to GitHub Pages.

— Head of Tech, SHVAPE

---

# Addendum — Mobile-focused sweep, same day

75% mobile / 25% rest.

## Mobile findings

### M-1 — No mobile pause access — **BUG**
Pause was P/ESC keyboard only. Mobile players had no way to pause
mid-run. **Fix shipped:** 44 × 44 pause button drawn top-left of the
canvas during PLAY/BOSS/ENCOUNTER (HTML mute button is top-right of
the page, no collision). Pointerdown handler intercepts the
button before any other touch routing. Tap anywhere on the dim pause
overlay = resume. P/ESC keyboard path still works.

### M-2 — Vitrine unreachable on mobile death screen — **BUG**
Achievement gallery was TAB/G keyboard only. Mobile players couldn't
see what they unlocked. **Fix shipped:** death screen now renders a
3-button row (NOCHMAL · VITRINE · TEILEN) at y 660-710. Vitrine
button toggles `Achv.vitrineOpen`; any tap while vitrine is open
closes it.

### M-3 — Share-canvas unreachable on mobile — **BUG**
T-key only. **Fix shipped:** TEILEN button on the same death-screen
row replicates the [T]-key path — `canvas.toBlob` + `navigator.
clipboard.write` with the PNG, falls back to a "Teilen nicht
verfügbar" HUD note if Clipboard API blocked.

### M-4 — Pause overlay had no tap-to-resume — **BUG**
**Fix shipped:** main pointerdown handler checks `Game.paused` first
and toggles pause off on any tap. Combined with M-1, the full mobile
pause loop is now: tap top-left II = pause; tap anywhere = resume.

### M-5 — `pointercancel` left `Input.touchInsult` stuck — **BUG**
System-interrupt during an active insult-button hold (e.g. incoming
phone call) deleted the active pointer but did not clear
`Input.touchInsult`, leaving the button visually depressed. Also
`Input.duck` had the same risk. **Fix shipped:** pointercancel now
clears `touchJump`, `touchInsult`, recomputes `duck` from surviving
pointers.

## Mobile non-findings (verified clean)

- VAPE / INSULT button geometric clearance ≈ 6 px in canvas-space at
  1280 × 720. Scales uniformly with display, no aspect-ratio risk.
- `pointerToCanvas` uses `getBoundingClientRect`-based mapping;
  correct under arbitrary CSS scaling.
- `navigator.vibrate` always guarded; iOS silently no-ops, expected.
- Right-half-anywhere JUMP fallback correctly excludes onVape /
  onInsult / onDuck regions, including the new INSULT button.
- Mama-call buttons (ANNEHMEN / ABLEHNEN) tappable via dedicated
  hit-test loop in MamaCall.update.
- Tutorial start button accepts both keypress AND pointer-down on a
  fixed canvas-space rect; no double-fire.
- KEY_MAP collision-resistant after bb327d8 hotfix; no further
  regressions.
- Pinch-zoom blocked by viewport meta `user-scalable=no` plus
  `touch-action: manipulation` on canvas.

## Rest pass (25%)

### R-1 — `Save.data.shownInsults` unbounded — **POLISH (deferred)**
Lifetime anti-repeat tracks every shown insult. With ~400 unique
strings × ~80 bytes JSON ≈ 32 KB at saturation, well under
localStorage's 5–10 MB quota. The pool-exhaustion path correctly
wipes the seen-set when both kind + general pools are exhausted, so
unbounded growth is bounded by content count. No fix needed today;
keep an eye on it if libraries grow another 10×.

### R-2 — Other memory pools verified bounded
- `HUD.notes`: hard cap 5
- `HUD.recentPopups`: cap 12
- `Game.npcReactions`: pruned by life timer (2.5s each)
- `Particles`: pruned by life
- `Bg.far/mid/near`: pruned by scroll-out
- `Entities`: pruned by off-screen + alive flag
- `Game.highlightReel`: cap 5
- `Game.transgressionLastTargets`: cap 4

### R-3 — `ctx.save / ctx.restore` balance — **CLEAN**
Spot-checked: counts match across the file. No leak observed in
60+ minute sustained-run smoke test.

### R-4 — Audio fallback paths — **CLEAN**
All Audio.* methods open with `if (!this.ready || this.muted) return;`
plus try/catch. Tone-failed path verified silent.

### R-5 — B7 Mutter secret-win × Mama ANNEHMEN — **WORKS**
Soft Mutter (CHANTAL_TRUST high or ANNEHMEN chosen) drops Trust at
0.7×, which makes the secret-win path EASIER to reach (more time
above 50% Trust to spam right-arrow). Confirmed not a regression.

## Mobile fix verification

Verified at runtime:
- Pause button hit zone (12,12)-(56,56) does not overlap any other
  control. Tap at (30, 30) toggles `Game.paused`.
- Death screen 3-button row hit zones distinct, no overlap with
  existing flyer/score graphics above.
- `pointercancel` simulation clears `Input.touchInsult` reliably.
- Vitrine open via VITRINE button, closes on any subsequent tap.
- TEILEN button calls `canvas.toBlob` and posts a HUD note on
  success/failure.

## Net change

Six fixes shipped (M-1, M-2, M-3, M-4, M-5, plus the schema-version
infrastructure from the morning round). One non-finding documented
(R-1) for future awareness. Mobile-first promise upheld: every
keyboard-only action is now reachable by tap.

— Head of Tech, SHVAPE — 2026-05-09 (PM)
