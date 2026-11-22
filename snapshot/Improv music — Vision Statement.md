# Vision Statement — Improv Music

## Purpose

An iOS app for piano improvisation practice, focused on key recognition and modulation skills. The app serves as a practice companion — you set it on the piano and it guides you through key changes of varying difficulty, building your ability to move fluidly between keys while improvising. It is aimed at players who are already comfortable improvising in a key and want to improve their fluency at moving between tonal centres.

The app is a prompt generator, not an assessor. It has no audio input and cannot hear what the player is doing. It trusts the player to execute modulations and self-evaluate. Its value lies in selecting good challenges at appropriate difficulty and suggesting routes when the player is stuck.

## Core Concept

The app is built around a single modulation challenge engine. At its simplest, it shows you a key and highlights the notes on a visual keyboard. At its most involved, it challenges you to modulate to a new key at a configured difficulty level, either on demand or on a timer, and can show you multiple possible routes to get there when you're stuck.

The core loop is: see a key, improvise in it, receive a modulation challenge, navigate to the new key, repeat. When a new challenge is triggered (whether by tap or timer), the current key automatically updates to the previous target — the app assumes the player has arrived and moves on. There is no confirmation step.

## Audience

Primarily built for personal use. May be published to the App Store if it reaches a level of polish that warrants it, but that's not a driving goal.

## Scope

**In scope:**
- Visual keyboard display showing the notes in the current key
- Randomisation across major keys, natural minor keys, and the diatonic modes (Dorian, Phrygian, Lydian, Mixolydian — excluding Locrian, which cannot function as a stable tonal centre). Harmonic minor and melodic minor are deferred from the initial release; they add complexity to chord generation and distance computation without being core to the modulation practice loop
- A modulation challenge engine with configurable difficulty tiers, where difficulty is determined by the distance/complexity of the modulation
- Two trigger modes: user tap (manual) and timer (automatic, configurable interval). When the timer fires, any in-progress challenge is replaced — the current key advances to the previous target and a new challenge is issued
- A hint system that presents multiple possible modulation routes using genuinely different techniques (e.g., one route via pivot chords, another via common tones), not just minor cost variations of the same approach
- Difficulty settings that control how far the engine will ask you to modulate from your current position
- User-selectable starting key (or randomise) to support focused practice on modulations from a specific tonal centre
- iPhone only, landscape orientation, optimised for readability at music-stand distance

**Out of scope (for now):**
- Audio input or listening features
- Backing tracks or accompaniment
- Any form of assessment or scoring
- Android or non-iOS platforms

## Design Principles

1. **Musical accuracy over simplicity.** The underlying theory must be rigorous. If the modulation engine encounters genuine complexity, it handles that complexity rather than glossing over it. The app should give theory-grounded, musically plausible suggestions and avoid false certainty where multiple valid interpretations exist.

2. **Focused interface.** The user experience stays centred on the core loop. No feature bloat, no settings sprawl. You open it, you play, it challenges you.

3. **Multiple valid paths.** Modulation is not a single-answer problem. The hint system reflects this by offering genuinely diverse routes — different techniques, not just different intermediate keys — rather than prescribing a single "correct" answer.

4. **Research before assumptions.** Open questions about music theory (particularly around modal modulation and difficulty ranking) are resolved through dedicated research, not guesswork during development.

## Definition of Done

The app is done when it can be set on a piano during practice and used comfortably. Specifically:
- It displays any key or mode with a clear visual keyboard showing which notes are in that scale
- It can randomly select a new key or mode to modulate to, respecting the configured difficulty level
- The user can choose a starting key or randomise
- Modulation challenges can be triggered by tap or by a configurable timer
- When stuck, the user can request hints showing multiple possible modulation routes to the target key, with each hint step identifying the technique and (where applicable) the specific pivot chord and its function in both keys
- The music theory underpinning the engine is accurate, validated against known exemplar modulations, and tested through real practice sessions

It does not need App Store polish, marketing materials, or onboarding flows. It needs to work correctly and be pleasant to use during practice.

## Technical Approach

iOS app built in SwiftUI, targeting iPhone in landscape orientation. Claude Code handles the majority of implementation. Music theory rules will be encoded based on dedicated research — existing libraries (notably AudioKit's Tonic) may provide pitch, scale, and chord primitives, but the app's own theory layer must remain authoritative. If a library proves insufficient, it should be replaced with a thin custom layer rather than worked around.