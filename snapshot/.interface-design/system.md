# ImprovMusic Design System

## Spacing

- **Base unit:** 4pt
- **Scale:** 2, 4, 8, 12, 16, 20
- **Primary values:** 4, 8, 12, 16 (most frequent)
- All spacing must land on this scale. Use 0 only for flush layouts (e.g. `VStack(spacing: 0)`).

## Corner Radius

| Context       | Value     |
|---------------|-----------|
| Keys (small)  | 2-3pt     |
| Cards/panels  | 10pt      |
| Badges/pills  | Capsule   |

## Depth

- **Strategy:** Borders-only. No shadows.
- **Overlays:** `.ultraThinMaterial` for floating panels (e.g. hint overlay).
- **Keyboard borders:** `.stroke()` with `lineWidth: 1` (normal) or `3` (tonic emphasis).

## Typography

| Role            | Style                                          |
|-----------------|------------------------------------------------|
| Key names       | `.system(size: 28, weight: .bold)`                   |
| Primary button  | `.body.bold()`                                 |
| Secondary button| `.body`                                        |
| Tertiary button | `.caption`                                     |
| Section labels  | `.subheadline`                                 |
| Labels          | `.caption`                                     |
| Badges          | `.caption2.bold()`                             |
| Technique label | `.subheadline.bold()` (single-step) / `.caption.bold()` (detail) |
| Route keys      | `.subheadline.bold()`                          |
| Route arrows    | `.caption2` with `chevron.right`               |

## Colors

### Semantic Palette

| Name    | SwiftUI         | Usage                                        |
|---------|-----------------|----------------------------------------------|
| Green   | `.green`        | Tonic key fill, modal-shift tier, current key name |
| Highlight white | `Color(red: 0.65, green: 0.85, blue: 0.65)` | Scale tone on white keys (opaque) |
| Highlight black | `Color(red: 0.3, green: 0.55, blue: 0.3)` | Scale tone on black keys (opaque) |
| Purple  | `.purple`       | Target key name, remote tier                 |
| Blue    | `.blue`         | Closely-related tier, technique labels, checkmarks |
| Orange  | `.orange`       | Moderate tier                                |
| Red     | `.red`          | Distant tier                                 |

### Tier Color Mapping

| Tier            | Color   |
|-----------------|---------|
| Modal Shift     | Green   |
| Closely Related | Blue    |
| Moderate        | Orange  |
| Distant         | Red     |
| Remote          | Purple  |

### Neutrals

| Value                    | Usage                  |
|--------------------------|------------------------|
| `Color(.systemBackground)` | App background       |
| `.primary`               | Body text              |
| `.secondary`             | Labels, subdued text   |
| `Color(white: 0.15)`    | Black key fill         |
| `Color(white: 0.25)`    | Tonic border           |
| `Color(white: 0.45)`    | Normal key border      |
| `.white`                 | White key fill         |

## Button Patterns

| Level     | Style               | Font           | Size              |
|-----------|----------------------|----------------|-------------------|
| Primary   | `.borderedProminent` | `.body.bold()` | Default           |
| Secondary | `.bordered`          | `.body`        | Default           |
| Tertiary  | `.bordered`          | `.caption`     | `.controlSize(.small)` |

- Buttons may include a leading `Image(systemName:)` icon alongside text.

## Layout

- **Orientation:** Landscape-only (locked)
- **Main structure:** `VStack(spacing: 0)` with internal padding per section
- **Key display zone:** 12pt top, 8pt bottom — breathing room for the focal information
- **Bottom bar:** `HStack(spacing: 16)` with `.padding(.horizontal, 16)`, 8pt top + 12pt bottom
- **Keyboard:** `GeometryReader`, 14 white keys spanning full width
- **Readability distance:** ~60-80cm (piano music stand)

## Patterns

### Key Display
- `HStack(spacing: 20)` with current/target `VStack(spacing: 4)` pairs
- Key names at 28pt rounded bold
- Labels at `.subheadline` (readable at 60-80cm)
- Arrow icon `.title2.weight(.semibold)`, `.tertiary` (present but not competing)
- Tier badge inline after target key (keeps current/target vertically aligned)

### Hint Card
- `VStack(alignment: .leading, spacing: 8)`
- `.padding(.horizontal, 12)` + `.padding(.vertical, 8)`
- `.background(.ultraThinMaterial)`
- `.clipShape(RoundedRectangle(cornerRadius: 10))`

### Tier Badge
- `.padding(.horizontal, 8)` + `.padding(.vertical, 2)`
- Background: tier color at `0.15` opacity
- Foreground: tier color at full
- `.clipShape(Capsule())`

### Controls Bar
- `HStack(spacing: 12)` with `Divider().frame(height: 20)` separators
- Segmented picker at `width: 110`
- Menu-style dropdowns for tier and timer

## Anti-Patterns

- No shadows (borders-only depth)
- No gamification UI (scores, streaks, progress bars)
- No portrait layouts
- No custom font families (system only)
