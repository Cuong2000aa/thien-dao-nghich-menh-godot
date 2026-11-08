#!/usr/bin/env python3
"""Pack and import heroes into Jianghu-style sheets + characters.json."""
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

# --- Palette Maps for Variant Heroes ---
SWORD_FAIRY_MAP = {
	(93, 102, 138, 255): (235, 220, 250, 255),
	(65, 73, 104, 255): (188, 162, 226, 255),
	(45, 49, 73, 255): (138, 112, 180, 255),
	(228, 230, 224, 255): (250, 245, 255, 255),
	(210, 196, 168, 255): (190, 248, 235, 255),
	(184, 170, 143, 255): (128, 222, 204, 255),
	(131, 118, 101, 255): (72, 178, 160, 255),
	(107, 95, 82, 255): (38, 128, 112, 255),
	(224, 123, 95, 255): (255, 180, 210, 255),
	(200, 72, 58, 255): (240, 120, 170, 255),
	(142, 47, 42, 255): (195, 70, 125, 255),
	(95, 33, 38, 255): (140, 35, 85, 255),
	(188, 197, 200, 255): (220, 252, 255, 255),
	(143, 156, 166, 255): (120, 220, 245, 255),
	(240, 201, 162, 255): (255, 236, 224, 255),
	(210, 159, 121, 255): (240, 198, 182, 255),
}

DAOIST_MAP = {
	(93, 102, 138, 255): (250, 215, 90, 255),
	(65, 73, 104, 255): (215, 165, 35, 255),
	(45, 49, 73, 255): (160, 115, 15, 255),
	(228, 230, 224, 255): (210, 235, 250, 255),
	(210, 196, 168, 255): (120, 145, 190, 255),
	(184, 170, 143, 255): (75, 100, 150, 255),
	(131, 118, 101, 255): (45, 65, 110, 255),
	(107, 95, 82, 255): (25, 40, 75, 255),
	(224, 123, 95, 255): (255, 90, 80, 255),
	(200, 72, 58, 255): (220, 45, 40, 255),
	(142, 47, 42, 255): (160, 25, 25, 255),
	(95, 33, 38, 255): (100, 15, 15, 255),
	(188, 197, 200, 255): (255, 235, 140, 255),
	(143, 156, 166, 255): (195, 140, 60, 255),
}

DEMONIC_MAP = {
	(93, 102, 138, 255): (75, 25, 35, 255),
	(65, 73, 104, 255): (45, 15, 22, 255),
	(45, 49, 73, 255): (25, 8, 12, 255),
	(228, 230, 224, 255): (170, 70, 85, 255),
	(210, 196, 168, 255): (110, 95, 115, 255),
	(184, 170, 143, 255): (75, 60, 80, 255),
	(131, 118, 101, 255): (50, 38, 55, 255),
	(107, 95, 82, 255): (30, 22, 35, 255),
	(224, 123, 95, 255): (255, 50, 75, 255),
	(200, 72, 58, 255): (215, 10, 45, 255),
	(142, 47, 42, 255): (145, 5, 30, 255),
	(95, 33, 38, 255): (85, 0, 15, 255),
	(188, 197, 200, 255): (255, 90, 120, 255),
	(143, 156, 166, 255): (210, 30, 60, 255),
}


def ensure_dir(p: Path) -> None:
	p.mkdir(parents=True, exist_ok=True)


def remap_palette(im: Image.Image, color_map: dict[tuple[int, int, int, int], tuple[int, int, int, int]]) -> Image.Image:
	im = im.convert("RGBA")
	out = im.copy()
	px = out.load()
	w, h = out.size
	for y in range(h):
		for x in range(w):
			c = px[x, y]
			if c in color_map:
				px[x, y] = color_map[c]
	return out


def write_png_import(png_path: Path) -> None:
	rel_res = f"res://assets/characters/{png_path.parent.name}/{png_path.name}"
	import_content = f"""[remap]

importer="texture"
type="CompressedTexture2D"
uid="uid://{abs(hash(rel_res)):012x}"

[deps]

source_file="{rel_res}"

[params]

compress/mode=0
compress/high_quality=false
compress/lossy_quality=0.7
compress/uastc_level=0
compress/rdo_quality_loss=0.0
compress/hdr_compression=1
compress/normal_map=0
compress/channel_pack=0
mipmaps/generate=false
mipmaps/limit=-1
roughness/mode=0
roughness/src_normal=""
process/channel_remap/red=0
process/channel_remap/green=1
process/channel_remap/blue=2
process/channel_remap/alpha=3
process/fix_alpha_border=true
process/premult_alpha=false
process/normal_map_invert_y=false
process/hdr_as_srgb=false
process/hdr_clamp_exposure=false
process/size_limit=0
detect_3d/compress_to=1
"""
	import_path = png_path.with_suffix(".png.import")
	if not import_path.exists():
		import_path.write_text(import_content, encoding="utf-8")


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
	cw = ch = 0
	for frames in frames_by_dir.values():
		for im in frames:
			cw = max(cw, im.width)
			ch = max(ch, im.height)
	if cell:
		cw, ch = cell
	cw += cw % 2
	ch += ch % 2
	sheet = Image.new("RGBA", (cw * max_frames, ch * len(DIRS)), (0, 0, 0, 0))
	for row, d in enumerate(DIRS):
		frames = frames_by_dir.get(d, [])
		if not frames and frames_by_dir:
			frames = frames_by_dir.get("south", next(iter(frames_by_dir.values())))
		for col in range(max_frames):
			src = frames[min(col, len(frames) - 1)]
			canvas = Image.new("RGBA", (cw, ch), (0, 0, 0, 0))
			ox = (cw - src.width) // 2
			oy = ch - src.height
			canvas.paste(src, (ox, oy), src)
			sheet.paste(canvas, (col * cw, row * ch), canvas)
	ensure_dir(out_sheet.parent)
	sheet.save(out_sheet)
	write_png_import(out_sheet)
	return cw, ch, max_frames


def import_assassin() -> None:
	src = INCOMING / "black_assassin" / "animations"
	dst = OUT_CHARS / "assassin"
	if not src.exists():
		if dst.exists():
			print(f"assassin source not found at {src}, keeping existing {dst}")
			return
		print(f"assassin source not found at {src}, skipping")
		return
	if dst.exists():
		shutil.rmtree(dst)
	ensure_dir(dst)

	action_map = {
		"idle": "idle",
		"walk": "walk",
		"dagger-slash": "attack",
		"run": "walk_run_src",
		"jump": "qinggong",
		"throw": "combo",
	}

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
				scale = 48 / max(im.height, 1)
				nw = max(1, int(im.width * scale))
				nh = max(1, int(im.height * scale))
				im = im.resize((nw, nh), Image.Resampling.NEAREST)
				by_dir[d].append(im)
		if not by_dir:
			continue
		if game_anim == "walk_run_src":
			continue
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

	if "idle" in built:
		for alias, hold in (("hurt", None), ("death", 1200)):
			src_sheet = dst / built["idle"]["sheet"]
			dst_sheet = dst / f"{alias}_sheet.png"
			shutil.copy2(src_sheet, dst_sheet)
			write_png_import(dst_sheet)
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
	print(f"assassin -> {dst} anims={list(built)}")


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
	if not src_root.exists():
		if dst.exists():
			print(f"wuxia swordsman source not found at {src_root}, keeping existing {dst}")
			return
		print(f"wuxia swordsman source not found at {src_root}, skipping")
		return
	if dst.exists():
		shutil.rmtree(dst)
	ensure_dir(dst)

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

	if "attack" in built:
		for alias in ("combo", "qinggong"):
			dst_sheet = dst / f"{alias}_sheet.png"
			shutil.copy2(dst / built["attack"]["sheet"], dst_sheet)
			write_png_import(dst_sheet)
			cfg = dict(built["attack"])
			cfg["sheet"] = f"{alias}_sheet.png"
			cfg["loop"] = False
			built[alias] = cfg
	if "idle" in built:
		dst_sheet = dst / "hurt_sheet.png"
		shutil.copy2(dst / built["idle"]["sheet"], dst_sheet)
		write_png_import(dst_sheet)
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
	print(f"wuxia_swordsman -> {dst} anims={list(built)}")


def import_bandit() -> None:
	"""Import InFreak Jianghu Bandit asset pack as playable Thể Tu."""
	candidates = [
		INCOMING / "bandit",
		Path(r"c:\Users\cuong\OneDrive\Máy tính\Tu tiên\bộ asset\Jianghu_Lite_v1.0\Jianghu_Lite\Godot\wuxia\32\enemies\bandit"),
	]
	src_dir: Path | None = None
	for c in candidates:
		if c.exists() and (c / "idle_sheet.png").exists():
			src_dir = c
			break
	if not src_dir:
		print("Bandit source not found, skipping bandit import")
		return

	dst = OUT_CHARS / "bandit"
	ensure_dir(dst)

	shutil.copy2(src_dir / "idle_sheet.png", dst / "idle_sheet.png")
	write_png_import(dst / "idle_sheet.png")

	shutil.copy2(src_dir / "walk_sheet.png", dst / "walk_sheet.png")
	write_png_import(dst / "walk_sheet.png")

	shutil.copy2(src_dir / "attack_sheet.png", dst / "attack_sheet.png")
	write_png_import(dst / "attack_sheet.png")

	shutil.copy2(dst / "attack_sheet.png", dst / "combo_sheet.png")
	write_png_import(dst / "combo_sheet.png")

	shutil.copy2(dst / "walk_sheet.png", dst / "qinggong_sheet.png")
	write_png_import(dst / "qinggong_sheet.png")

	shutil.copy2(dst / "idle_sheet.png", dst / "hurt_sheet.png")
	write_png_import(dst / "hurt_sheet.png")

	shutil.copy2(dst / "idle_sheet.png", dst / "death_sheet.png")
	write_png_import(dst / "death_sheet.png")

	meta = {
		"name": "bandit",
		"label": "Thể Tu",
		"rows": DIRS,
		"mirrored_from": {},
		"signature": "attack",
		"anims": {
			"idle": {
				"cell": [40, 40],
				"frames": 4,
				"fps": 5,
				"loop": True,
				"foot_px": [20, 37],
				"hold_last_ms": None,
				"sheet": "idle_sheet.png",
			},
			"walk": {
				"cell": [40, 40],
				"frames": 6,
				"fps": 9,
				"loop": True,
				"foot_px": [20, 37],
				"hold_last_ms": None,
				"sheet": "walk_sheet.png",
			},
			"attack": {
				"cell": [64, 64],
				"frames": 10,
				"fps": 12,
				"loop": False,
				"foot_px": [32, 50],
				"hold_last_ms": 200,
				"sheet": "attack_sheet.png",
			},
			"combo": {
				"cell": [64, 64],
				"frames": 10,
				"fps": 14,
				"loop": False,
				"foot_px": [32, 50],
				"hold_last_ms": 200,
				"sheet": "combo_sheet.png",
			},
			"qinggong": {
				"cell": [40, 40],
				"frames": 6,
				"fps": 12,
				"loop": False,
				"foot_px": [20, 37],
				"hold_last_ms": None,
				"sheet": "qinggong_sheet.png",
			},
			"hurt": {
				"cell": [40, 40],
				"frames": 4,
				"fps": 8,
				"loop": False,
				"foot_px": [20, 37],
				"hold_last_ms": None,
				"sheet": "hurt_sheet.png",
			},
			"death": {
				"cell": [40, 40],
				"frames": 4,
				"fps": 6,
				"loop": False,
				"foot_px": [20, 37],
				"hold_last_ms": 1200,
				"sheet": "death_sheet.png",
			},
		},
		"_notes": {
			"source": "Jianghu Lite v1.0 — InFreak (Enemy Bandit adapted to Player Thể Tu)",
			"scale": "native Jianghu 40px cell",
		},
	}
	(dst / "characters.json").write_text(json.dumps(meta, indent=1, ensure_ascii=False) + "\n", encoding="utf-8")
	print(f"bandit -> {dst} anims={list(meta['anims'])}")


def import_hero_variant(
	char_id: str,
	label: str,
	color_map: dict[tuple[int, int, int, int], tuple[int, int, int, int]],
	notes_source: str,
) -> None:
	"""Generate a full Jianghu-style hero variant from swordsman with customized palette."""
	src = OUT_CHARS / "swordsman"
	if not src.exists():
		raise RuntimeError(f"Swordsman base missing at {src}")

	dst = OUT_CHARS / char_id
	ensure_dir(dst)

	src_json_path = src / "characters.json"
	src_meta = json.loads(src_json_path.read_text(encoding="utf-8"))

	sheets = [
		"idle_sheet.png",
		"walk_sheet.png",
		"attack_sheet.png",
		"combo_sheet.png",
		"qinggong_sheet.png",
		"hurt_sheet.png",
		"death_sheet.png",
	]

	for sheet_name in sheets:
		s_path = src / sheet_name
		d_path = dst / sheet_name
		if not s_path.exists():
			continue
		im = Image.open(s_path)
		remapped = remap_palette(im, color_map)
		remapped.save(d_path)
		write_png_import(d_path)

	meta = dict(src_meta)
	meta["name"] = char_id
	meta["label"] = label
	meta["_notes"] = {
		"source": notes_source,
		"palette": f"Remapped {len(color_map)} tone channels from Jianghu Swordsman base",
	}

	(dst / "characters.json").write_text(json.dumps(meta, indent=1, ensure_ascii=False) + "\n", encoding="utf-8")
	print(f"{char_id} ({label}) -> {dst} anims={list(meta['anims'])}")


def main() -> None:
	import_assassin()
	import_wuxia_swordsman()
	import_bandit()
	import_hero_variant(
		"sword_fairy",
		"Nữ Kiếm Tiên",
		SWORD_FAIRY_MAP,
		"Jianghu / InFreak — Celestial White/Lavender & Jade Sword Fairy variant",
	)
	import_hero_variant(
		"daoist",
		"Đạo Sĩ",
		DAOIST_MAP,
		"Jianghu / InFreak — Imperial Gold & Indigo Taoist Sage variant",
	)
	import_hero_variant(
		"demonic_blade",
		"Ma Kiếm",
		DEMONIC_MAP,
		"Jianghu / InFreak — Obsidian Shadow & Blood Crimson Demonic Sword variant",
	)
	print("All heroes imported successfully.")


if __name__ == "__main__":
	main()
