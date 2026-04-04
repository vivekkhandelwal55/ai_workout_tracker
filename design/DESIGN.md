# Design System Document: Minimalist Brutalism for High-Performance Athletics

## 1. Overview & Creative North Star
**Creative North Star: "The Precision Engine"**

This design system is engineered for the elite athlete who demands clarity over decoration. It rejects the "app-y" clutter of typical fitness trackers in favor of a high-end, editorial experience. We call this **Minimalist Brutalism**: a philosophy where the raw data is the hero, framed by aggressive negative space and architectural precision.

The system breaks the standard "mobile template" look through **Intentional Asymmetry**. Instead of centering all content, we use heavy left-aligned typographic anchors and sweeping white space to create a sense of momentum. This isn't just a tracker; it is a high-performance instrument.

---

## 2. Colors & Tonal Depth
The palette is rooted in a monochromatic "Deep Void" to minimize retinal fatigue during high-intensity sessions, punctuated by a singular, high-vis "Neon Kinetic" lime for action.

### The Palette (Material Design Tokens)
*   **Surface/Background:** `#131313` (The void)
*   **Primary (Action):** `#CCFF00` (Neon Kinetic)
*   **On-Primary:** `#283500` (Contrast for legibility)
*   **Secondary (Subtle UI):** `#b5d25e`
*   **Surface Containers:** Range from `#0E0E0E` (Lowest) to `#353534` (Highest)

### The "No-Line" Rule
Traditional 1px solid borders are strictly prohibited for sectioning. Boundaries must be defined solely through background color shifts. To separate a workout set from the rest of the routine, place a `surface-container-low` card against a `surface` background. The change in "blackness" is the boundary.

### Surface Hierarchy & Nesting
Treat the UI as a series of physical layers of precision-cut obsidian.
*   **Base Layer:** `surface` (#131313)
*   **Secondary Content:** `surface-container-low` (#1C1B1B)
*   **Active/Elevated Elements:** `surface-container-highest` (#353534)

### Signature Textures
To avoid a "flat" digital look, use **Radial Kinetic Gradients**. For primary CTAs or progress rings, transition from `primary` (#CCFF00) to `primary-container` (#C3F400). This subtle shift mimics the glow of high-end gym equipment displays.

---

## 3. Typography
We use **Lexend** exclusively. Its hyper-legible, geometric construction feels engineered rather than drawn.

*   **Display (3.5rem):** Used for "PR" (Personal Record) numbers or rest timers. These should have `-0.02em` tracking to feel dense and powerful.
*   **Headline (2rem):** Used for workout names. Always bold.
*   **Title (1.125rem - 1.375rem):** Used for exercise names in a list.
*   **Body (0.875rem - 1rem):** Used for instructional text and secondary data.
*   **Label (0.6875rem):** Used for "Weight," "Reps," and "Sets" headers. **Requirement:** All labels must be Uppercase with `0.1em` letter spacing to evoke a technical, industrial aesthetic.

---

## 4. Elevation & Depth
In this system, "Up" does not mean "Shadowed." It means "Luminous."

### The Layering Principle
Depth is achieved by stacking. A `surface-container-lowest` card (#0E0E0E) nested inside a `surface-container-high` (#2A2A2A) section creates a "carved out" effect, making the data feel embedded in the interface.

### Ambient Shadows
If a floating element (like a FAB) is required, use a "Neon Wash" shadow. The shadow color should be `primary` (#CCFF00) at 5% opacity with a `48px` blur. It should look like a glow, not a shadow.

### Glassmorphism & Depth
For overlays (e.g., a "Workout Complete" modal), use `surface` at 80% opacity with a `20px` backdrop-blur. This keeps the athlete connected to their data while focusing on the immediate task.

### The "Ghost Border" Fallback
Where separation is functionally required for high-density data, use a **Ghost Border**: `outline-variant` (#444933) at 15% opacity. It should be felt, not seen.

---

## 5. Components

### Buttons
*   **Primary:** Sharp 0px corners. Background: `primary`. Text: `on-primary` (Bold). No icons unless necessary for direction.
*   **Tertiary:** Transparent background. Ghost Border (15% opacity). Text: `primary`.

### Cards & Lists
*   **The Divider Ban:** Never use lines to separate list items. Use `16px` of vertical negative space or alternating tonal shifts (`surface` to `surface-container-low`).
*   **Low-Profile Cards:** Exercise cards should have 0px radius. Use a `3px` left-accent border of `primary` color to indicate the currently active set.

### Inputs
*   **Data Entry:** Large `headline-lg` text for numeric inputs. No box; only a `primary` color underline (2px) that glows when focused.
*   **Labels:** Floating above the input in `label-sm`, Uppercase, `primary` color.

### Kinetic Progress Bars
*   Thin (2px) bars using `primary` against a `surface-container-highest` track. No rounded caps; everything is squared off to maintain the "Brutalist" edge.

---

## 6. Do's and Don'ts

### Do
*   **DO** use extreme negative space. If it feels "too empty," add 8px more space.
*   **DO** align text to a strict vertical axis to create a "spine" for the design.
*   **DO** use the `primary` color sparingly. It is a "laser," not a "paint." It should only exist where action is required or success is achieved.

### Don't
*   **DON'T** use border-radius. Every corner in this system is 0px (Sharp).
*   **DON'T** use standard grey shadows. They look "dirty" against the deep black surface.
*   **DON'T** use icons for things that words can describe. This system prioritizes bold typography over generic iconography.
*   **DON'T** use centered layouts. Content should feel like it's built on a technical grid, favoring left-aligned "Editoral" compositions.