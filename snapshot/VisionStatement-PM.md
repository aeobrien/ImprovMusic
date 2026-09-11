# Vision Statement — Improv Music

## Purpose

An iOS app for piano improvisation practice, focused on key recognition and modulation skills. The app serves as a practice companion — you set it on the piano and it guides you through key changes of varying difficulty, building your ability to move fluidly between keys while improvising.

## Core Concept

The app is built around a single modulation challenge engine. At its simplest, it shows you a key and highlights the notes on a visual keyboard. At its most involved, it challenges you to modulate to a new key at a configured difficulty level, either on demand or on a timer, and can show you multiple possible routes to get there when you're stuck.

The core loop is: see a key, improvise in it, receive a modulation challenge, navigate to the new key, repeat.

## Audience

Primarily built for personal use. May be published to the App Store if it reaches a level of polish that warrants it, but that's not a driving goal.

## Scope

**In scope:**
- Visual keyboard display showing the notes in the current key
- Randomisation across major keys, minor keys, and potentially modes (pending research)
- A modulation challenge engine with configurable difficulty tiers, where difficulty is determined by the distance/complexity of the modulation
- Two trigger modes: user tap (manual) and timer (automatic, configurable interval)
- A hint system that presents multiple possible modulation routes, not a single "correct" answer
- Difficulty settings that control how far the engine will ask you to modulate from your current position

**Out of scope (for now):**
- Audio input or listening features
- Backing tracks or accompaniment
- Any form of assessment or scoring
- Android or non-iOS platforms

## Design Principles

1. **Musical accuracy over simplicity.** The underlying theory must be rigorous. If the modulation engine encounters genuine complexity, it handles that complexity rather than glossing over it. The app should never give bad musical advice.

2. **Focused interface.** The user experience stays centred on the core loop. No feature bloat, no settings sprawl. You open it, you play, it challenges you.

3. **Multiple valid paths.** Modulation is not a single-answer problem. The hint system reflects this by offering options rather than prescribing a route, respecting whatever musical direction the player was already exploring.

4. **Research before assumptions.** Open questions about music theory (particularly around modal modulation and difficulty ranking) are resolved through dedicated research, not guesswork during development.

## Definition of Done

The app is done when it can be set on a piano during practice and used comfortably. Specifically:
- It displays any key with a clear visual keyboard showing which notes are in that key
- It can randomly select a new key to modulate to, respecting the configured difficulty level
- Modulation challenges can be triggered by tap or by a configurable timer
- When stuck, the user can request hints showing multiple possible modulation routes to the target key
- The music theory underpinning the engine is accurate and validated

It does not need App Store polish, marketing materials, or onboarding flows. It needs to work correctly and be pleasant to use during practice.

## Technical Approach

iOS app built in SwiftUI, with Claude Code handling the majority of implementation. Music theory rules will be encoded based on dedicated research — existing libraries may inform the approach but are unlikely to provide the pedagogical modulation knowledge needed out of the box.
