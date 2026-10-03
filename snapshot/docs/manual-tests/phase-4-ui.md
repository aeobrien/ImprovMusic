# Phase 4 Manual Test Brief — UI

## Prerequisites
- Xcode 16.3 installed
- Project open: `open ImprovMusic.xcodeproj`
- Select "iPhone 16 Pro" as run destination

## Tests

### 1. Launch and landscape
1. Press Cmd+R to build and run
2. **Expected:** App launches in landscape showing keyboard, "C Major" as current key
3. **Pass criteria:** Landscape only, no portrait rotation

### 2. Keyboard display
1. Verify the piano keyboard is visible with one octave (C to B)
2. **Expected:** White and black keys rendered, scale notes highlighted in green, tonic (C) has orange border, note names displayed on keys
3. **Pass criteria:** All 7 notes of C major highlighted, other keys neutral

### 3. Generate a challenge
1. Tap the "Next" button
2. **Expected:** A target key appears (e.g., "G Major"), keyboard shows three-way colour overlay (green = current only, purple = target only, blue = both), tier badge shows
3. **Pass criteria:** Target differs from current, overlay is visible

### 4. Advancement
1. Tap "Next" again
2. **Expected:** Current key updates to previous target, new target issued
3. **Pass criteria:** Current key name changes

### 5. Hint system
1. After generating a challenge, tap "Hint"
2. **Expected:** Hint overlay appears showing route with technique label and evidence (e.g., "Pivot Chord: Am: vi → ii")
3. For multi-step routes, tap "Reveal next step" to see progressive disclosure
4. **Pass criteria:** Hints show, can be toggled off with "Hide"

### 6. Difficulty tiers
1. Set tier to "1" using the segmented control
2. Tap "Next" several times
3. **Expected:** Challenges are modal shifts (same tonic, different mode) or close due to sparse fallback
4. Set tier to "5" and tap "Next"
5. **Expected:** Distant modulations offered

### 7. Timer mode
1. Switch trigger mode to "Timer"
2. Select "15s" interval
3. Wait 15 seconds
4. **Expected:** Challenge auto-fires, current key advances to previous target, new target issued
5. Switch back to "Tap"
6. **Expected:** Timer stops

### 8. Starting key picker
1. Tap the music note icon in controls
2. **Expected:** Key picker sheet appears with all keys and modes
3. Select "B♭ Major"
4. **Expected:** Keyboard updates to show B♭ major notes, "B♭ Major" displayed as current key
5. Tap "Randomise"
6. **Expected:** A random key/mode is selected

### 9. Settings persistence
1. Set tier to 4, switch to timer mode, generate a challenge
2. Kill the app (Cmd+Shift+H twice, swipe up)
3. Relaunch
4. **Expected:** Tier 4 restored, timer mode restored, current key restored

### 10. Readability (if physical device available)
1. Place iPhone on piano music stand
2. **Expected:** Key names, keyboard notes, and tier badge readable at arm's length (~60-80cm)
