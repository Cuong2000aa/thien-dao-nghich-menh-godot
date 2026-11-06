# PixelFX assets (TDNM)

Sprite sheets from https://github.com/patch-gg/pixelfx (MIT)
exported via `../tools/pixelfx/export_tdnm_*.sh` (`node tools/render.mjs … --sheet --no-actor`).

- Batch 1–3: full PixelFX catalog synced into this folder for Thiên Đạo Nghịch Mệnh.
- Custom TDNM sheets: `cultivation/`, `sword/` (not from PixelFX).

Do not commit the PixelFX JS runtime into the Godot project.
Tool checkout: `../tools/pixelfx` (sibling under Tu đạo/).

Catalog keys: `sources/effects/PixelFxLibrary.gd` → `CATALOG`.

## Upgrade policy (keep game core)

Combat / placement / aim stay on PixelFX + `CombatVisualSystem`.
Ngũ hành hit/cast polish remaps to **existing** catalog sheets (slash, thorns, hit_flash…).

External packs (optional, not wired by default):
- itch sprite packs (cs5475, IceMaan, Willosuna) — import sheets into this tree only if nearest-filter + padding match PixelFX.
- https://github.com/kai777123/godot-4-free-vfx — shader/code samples (MIT); mostly 3D nodes, do **not** replace 2D PixelFX pipeline.
