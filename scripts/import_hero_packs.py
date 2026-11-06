#!/usr/bin/env python3
"""Pack Black Assassin + Wuxia RTS Swordsman into Jianghu-style sheets + characters.json."""
from __future__ import annotations

import json
import os
import re
import shutil
from collections import defaultdict
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
INCOMING = ROOT / "assets" / "_incoming_chars"
OUT_CHARS = ROOT / "assets" / "characters"

DIRS = [
	"south",
	"south-east",
	"east",
	"north-east",
	"north",
	"north-west",
	"west",
	"south-west",
]

WUXIA_DIR = {
	"South": "south",
	"SouthEast": "south-east",
	"East": "east",
	"NorthEast": "north-east",
	"North": "north",
	"NorthWest": "north-west",
	"West": "west",
	"SouthWest": "south-west",
}


def ensure_dir(p: Path) -> None:
	p.mkdir(parents=True, exist_ok=True)


def trim_alpha(im: Image.Image, pad: int = 2) -> Image.Image:
	if im.mode != "RGBA":
		im = im.convert("RGBA")
	bbox = im.getbbox()
	if not bbox:
		return im
	l, t, r, b = bbox
	l = max(0, l - pad)
	t = max(0, t - pad)
	r = min(im.width, r + pad)
	b = min(im.height, b + pad)
	return im.crop((l, t, r, b))


def pack_anim(
	frames_by_dir: dict[str, list[Image.Image]],
	out_sheet: Path,
	cell: tuple[int, int] | None = None,
) -> tuple[int, int, int]:
	"""Return (cell_w, cell_h, frame_count)."""
	max_frames = max((len(v) for v in frames_by_dir.values()), default=0)
	if max_frames <= 0:
		raise RuntimeError(f"No frames for {out_sheet}")
	# Normalize cell from largest trimmed frame
	cw = ch = 0
	for frames in frames_by_dir.values():
		for im in frames:
			cw = max(cw, im.width)
			ch = max(ch, im.height)
	if cell:
		cw, ch = cell
	# Even sizes
	cw += cw % 2
	ch += ch % 2
	sheet = Image.new("RGBA", (cw * max_frames, ch * len(DIRS)), (0, 0, 0, 0))
	for row, d in enumerate(DIRS):
		frames = frames_by_dir.get(d, [])
		if not frames and frames_by_dir:
			# Mirror fallback: reuse south
			frames = frames_by_dir.get("south", next(iter(frames_by_dir.values())))
		for col in range(max_frames):
			src = frames[min(col, len(frames) - 1)]
			canvas = Image.new("RGBA", (cw, ch), (0, 0, 0, 0))
			ox = (cw - src.width) // 2
			oy = ch - src.height  # feet toward bottom
			canvas.paste(src, (ox, oy), src)
			sheet.paste(canvas, (col * cw, row * ch), canvas)
	ensure_dir(out_sheet.parent)
	sheet.save(out_sheet)
	return cw, ch, max_frames


def import_assassin() -> None:
	src = INCOMING / "black_assassin" / "animations"
	dst = OUT_CHARS / "assassin"
	if dst.exists():
		shutil.rmtree(dst)
	ensure_dir(dst)

	# Map pack actions → game actions (aliases for missing)
	action_map = {
		"idle": "idle",
		"walk": "walk",
		"dagger-slash": "attack",
		"run": "walk_run_src",  # intermediate
		"jump": "qinggong",
		"throw": "combo",
	}
	# We'll build idle/walk/attack/qinggong/combo then alias hurt/death

	built: dict[str, dict] = {}
	for src_anim, game_anim in action_map.items():
		anim_dir = src / src_anim
		if not anim_dir.is_dir():
			continue
		by_dir: dict[str, list[Image.Image]] = defaultdict(list)
		for d in DIRS:
			dpath = anim_dir / d
			if not dpath.is_dir():
				continue
			files = sorted(dpath.glob("frame_*.png"))
			for f in files:
				im = trim_alpha(Image.open(f).convert("RGBA"), pad=1)
				# Scale down 256 → ~48 visual height like swordsman
				scale = 48 / max(im.height, 1)
				nw = max(1, int(im.width * scale))
				nh = max(1, int(im.height * scale))
				im = im.resize((nw, nh), Image.Resampling.NEAREST)
				by_dir[d].append(im)
		if not by_dir:
			continue
		if game_anim == "walk_run_src":
			continue  # skip run as separate; walk enough
		cw, ch, nframes = pack_anim(by_dir, dst / f"{game_anim}_sheet.png")
		fps = {"idle": 6, "walk": 10, "attack": 12, "qinggong": 12, "combo": 12}.get(game_anim, 10)
		built[game_anim] = {
			"cell": [cw, ch],
			"frames": nframes,
			"fps": fps,
			"loop": game_anim in ("idle", "walk"),
			"foot_px": [cw // 2, ch - 2],
			"hold_last_ms": 200 if game_anim in ("attack", "combo") else (1200 if game_anim == "death" else None),
			"sheet": f"{game_anim}_sheet.png",
		}

	# Aliases: hurt/death from idle sheet (duplicate file)
	if "idle" in built:
		for alias, hold in (("hurt", None), ("death", 1200)):
			src_sheet = dst / built["idle"]["sheet"]
			dst_sheet = dst / f"{alias}_sheet.png"
			shutil.copy2(src_sheet, dst_sheet)
			cfg = dict(built["idle"])
			cfg["sheet"] = f"{alias}_sheet.png"
			cfg["loop"] = False
			cfg["fps"] = 8
			cfg["hold_last_ms"] = hold
			built[alias] = cfg

	meta = {
		"name": "assassin",
		"label": "Black Assassin",
		"rows": DIRS,
		"mirrored_from": {},
		"signature": "combo",
		"anims": built,
		"_notes": {
			"source": "Black Assassin FREE — elie automata",
			"scale": "trimmed + nearest downscale ~48px tall",
		},
	}
	(dst / "characters.json").write_text(json.dumps(meta, indent=1, ensure_ascii=False) + "\n", encoding="utf-8")
	print(f"assassin → {dst} anims={list(built)}")


def import_wuxia_swordsman() -> None:
	src_root = (
		INCOMING
		/ "wuxia_rts_lite"
		/ "Wuxia_RTS_Pixel_Lite_v1.0"
		/ "01_Characters"
		/ "Core_Units"
		/ "Swordsman"
		/ "Game_Ready_Frames"
	)
	dst = OUT_CHARS / "wuxia_swordsman"
	if dst.exists():
		shutil.rmtree(dst)
	ensure_dir(dst)

	# Parse Bandit_Idle_South_01 style → Unit_Action_Dir_NN
	pat = re.compile(r"^Swordsman_([A-Za-z]+)_([A-Za-z]+)_(\d+)\.png$")
	bucket: dict[str, dict[str, list[tuple[int, Path]]]] = defaultdict(lambda: defaultdict(list))
	for f in sorted(src_root.glob("Swordsman_*.png")):
		m = pat.match(f.name)
		if not m:
			continue
		action, dirc, idx = m.group(1), m.group(2), int(m.group(3))
		if dirc not in WUXIA_DIR:
			continue
		bucket[action][WUXIA_DIR[dirc]].append((idx, f))

	action_map = {
		"Idle": "idle",
		"Walk": "walk",
		"Attack": "attack",
		"Death": "death",
	}
	built: dict[str, dict] = {}
	for src_action, game_anim in action_map.items():
		if src_action not in bucket:
			continue
		by_dir: dict[str, list[Image.Image]] = {}
		for d, items in bucket[src_action].items():
			items = sorted(items, key=lambda x: x[0])
			frames = []
			for _, path in items:
				im = trim_alpha(Image.open(path).convert("RGBA"), pad=1)
				scale = 44 / max(im.height, 1)
				nw = max(1, int(im.width * scale))
				nh = max(1, int(im.height * scale))
				frames.append(im.resize((nw, nh), Image.Resampling.NEAREST))
			by_dir[d] = frames
		cw, ch, nframes = pack_anim(by_dir, dst / f"{game_anim}_sheet.png")
		fps = {"idle": 6, "walk": 9, "attack": 12, "death": 8}.get(game_anim, 10)
		built[game_anim] = {
			"cell": [cw, ch],
			"frames": nframes,
			"fps": fps,
			"loop": game_anim in ("idle", "walk"),
			"foot_px": [cw // 2, ch - 2],
			"hold_last_ms": 200 if game_anim == "attack" else (1200 if game_anim == "death" else None),
			"sheet": f"{game_anim}_sheet.png",
		}

	# Aliases
	if "attack" in built:
		for alias in ("combo", "qinggong"):
			shutil.copy2(dst / built["attack"]["sheet"], dst / f"{alias}_sheet.png")
			cfg = dict(built["attack"])
			cfg["sheet"] = f"{alias}_sheet.png"
			cfg["loop"] = False
			built[alias] = cfg
	if "idle" in built:
		shutil.copy2(dst / built["idle"]["sheet"], dst / "hurt_sheet.png")
		cfg = dict(built["idle"])
		cfg["sheet"] = "hurt_sheet.png"
		cfg["loop"] = False
		cfg["fps"] = 8
		built["hurt"] = cfg

	meta = {
		"name": "wuxia_swordsman",
		"label": "Wuxia Swordsman",
		"rows": DIRS,
		"mirrored_from": {},
		"signature": "attack",
		"anims": built,
		"_notes": {
			"source": "Wuxia RTS Pixel Lite — DQYYY",
			"scale": "trimmed + nearest ~44px tall",
		},
	}
	(dst / "characters.json").write_text(json.dumps(meta, indent=1, ensure_ascii=False) + "\n", encoding="utf-8")
	print(f"wuxia_swordsman → {dst} anims={list(built)}")


def main() -> None:
	import_assassin()
	import_wuxia_swordsman()
	print("Done.")


if __name__ == "__main__":
	main()
