# Research Plan — Improv Music

## Central Question

What are the rules governing key relationships, modal relationships, and modulation between them, and how can these rules be encoded into a system that generates modulation challenges at varying difficulty levels?

The output of this research must be comprehensive enough that Claude Code can implement the modulation engine without needing further music theory consultation.

## Sub-Questions

**1. Key and mode distance metrics**
How should the "distance" between two keys or modes be measured? The circle of fifths captures relationships between major/minor keys but doesn't naturally account for modes. A note-difference approach (counting how many pitches change between two scales) might provide a unified metric that works across keys and modes alike. The research should evaluate whether note difference alone is a sufficient measure of modulation difficulty, or whether other factors (harmonic function, cadence patterns, common chord availability) mean that equal note distances don't always correspond to equal difficulty.

**2. Modulation techniques**
What are the established techniques for modulating between keys and modes? This should cover at least: pivot chord modulation, common-tone modulation, direct modulation, and any other standard approaches. For each technique, the research should explain how it works, when it's appropriate, and what makes it easier or harder to execute.

**3. Difficulty ranking**
How should modulation difficulty be ranked for the purposes of a practice tool? This needs to produce a concrete, implementable framework — not just "closer keys are easier." The framework should account for the distance metric (however that's defined), the availability of smooth modulation techniques between the two points, and any asymmetries (is modulating from A to B the same difficulty as B to A?).

**4. Modal modulation**
How does modulation involving modes (Dorian, Mixolydian, Lydian, etc.) compare to modulation between standard major and minor keys? Specifically: is moving from G major to G Mixolydian fundamentally the same kind of problem as moving from G major to C major? Can modes be incorporated into the same distance and difficulty framework as major/minor keys, or do they require separate treatment?

**5. Modulation pathfinding**
For modulations that are too distant to execute in a single step, what determines a good intermediate path? The app needs to suggest multi-step routes (e.g., G major → A minor → F major → G minor → Eb major). The research should cover how to identify good intermediate keys, what makes one path better than another, and whether standard pedagogical guidance exists for constructing modulation paths.

**6. Available libraries and tools**
What existing music theory libraries or frameworks could support this project? The app is built in Swift/SwiftUI, so native Swift libraries are ideal, but Python or other libraries are worth documenting if their concepts or data structures could be ported. Key questions: does any library already encode scale relationships, note-difference calculations, or modulation rules? How much of the theory would need to be implemented from scratch versus leveraged from existing work?

## Sources and Methods

The primary research method will be commissioning a detailed research report from an LLM (Claude or ChatGPT), using this document as the brief. The report should draw on established music theory — the kind found in university-level harmony and composition textbooks — rather than informal or simplified explanations.

For the library survey (sub-question 6), a combination of LLM knowledge and direct investigation of package repositories (Swift Package Manager, PyPI, GitHub) will be needed.

## Success Criteria

The research is complete when:

1. A clear, implementable distance/difficulty metric exists that covers both keys and modes, validated against musical intuition and established theory.
2. Modulation techniques are catalogued with enough detail that code can recommend appropriate techniques for a given modulation.
3. A difficulty framework exists that can rank any modulation (key-to-key, key-to-mode, mode-to-mode) on a scale that maps to the app's difficulty tiers.
4. The rules for constructing multi-step modulation paths are defined clearly enough to implement as a pathfinding algorithm.
5. The library landscape is surveyed and a recommendation is made on build-vs-leverage.
6. All of the above is documented in a form that Claude Code can use directly as a reference during implementation.

## Application

The research output will serve as the foundational reference for the app's modulation engine. It will directly inform:

- The data model for representing keys, modes, and their relationships
- The algorithm for calculating modulation difficulty
- The challenge generation logic (selecting appropriate target keys at each difficulty tier)
- The hint system (generating and presenting multiple modulation routes)
- The technical brief, which will be produced after this research is complete and will translate these findings into an architecture and implementation plan