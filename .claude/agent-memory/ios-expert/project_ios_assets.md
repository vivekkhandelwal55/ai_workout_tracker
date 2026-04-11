---
name: iOS Assets — Distill failure root causes fixed
description: Documents what caused the "Distill failed" Xcode error in Assets.xcassets and what was fixed
type: project
---

The AppIcon.appiconset had 11 stray files (1024.png, 114.png, etc.) that were actually JPEG data with .png extensions, left over from a previous icon generation step. These were not referenced by Contents.json but were still parsed by Xcode's Distill tool.

The `Icon-App-*.png` files (all sizes except 1024) were palette/indexed-color PNGs. Xcode's asset compiler requires RGB or RGBA format. These were converted to RGB in-place using a pure Python PNG re-encoder.

The three LaunchImage PNGs (LaunchImage.png, LaunchImage@2x.png, LaunchImage@3x.png) were 0x0 pixel RGBA files — corrupt/empty. These were replaced with valid 1x1 white RGB PNGs.

**Why:** The stray JPEGs and 0x0 LaunchImages triggered Xcode's Distill step to fail with a generic "Distill failed for unknown reasons" message pointing at the whole Assets.xcassets directory.

**How to apply:** If Distill errors recur, audit all imagesets for: (1) non-PNG files with .png extensions, (2) palette/indexed color type PNGs, (3) 0x0 dimension PNGs. Use `python3 -c "import struct; ..."` to inspect PNG headers since `file` command identifies format but sips does not reliably convert palette PNGs.
