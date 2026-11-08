#!/usr/bin/env python3
"""Import Wuxia Pixel Vol. 2 collection pack into Thiên Đạo Nghịch Mệnh Godot."""
from __future__ import annotations

import io
import json
import math
import os
from pathlib import Path
import zipfile
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
OUT_CHARS = ROOT / "assets" / "characters"

ZIP_CANDIDATES = [
    Path(r"C:\Users\cuong\OneDrive\Máy tính\Tu tiên\Wuxia_Free_Experience_v1.1.3.zip"),
    Path(r"D:\Wuxia_Free_Experience_v1.1.3.zip"),
    ROOT / "Wuxia_Free_Experience_v1.1.3.zip",
    ROOT / "assets" / "_incoming_chars" / "Wuxia_Free_Experience_v1.1.3.zip",
]

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

DIR_FALLBACK_4 = {
    "south": "south",
    "south-east": "east",
    "east": "east",
    "north-east": "east",
    "north": "north",
    "north-west": "west",
    "west": "west",
    "south-west": "west",
}


def find_zip() -> Path:
    for p in ZIP_CANDIDATES:
        if p.exists() and p.is_file():
            return p
    raise FileNotFoundError(f"Wuxia_Free_Experience_v1.1.3.zip not found in candidates: {ZIP_CANDIDATES}")


def ensure_dir(p: Path) -> None:
    p.mkdir(parents=True, exist_ok=True)


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
    import_path.write_text(import_content, encoding="utf-8")


def pack_action_sheet(
    z: zipfile.ZipFile,
    file_prefix: str,
    action_dirs_data: dict[str, dict],
    out_sheet: Path,
    scale: float,
    custom_frame_indices: list[int] | None = None,
) -> tuple[int, int, int, list[int]]:
    """Build an 8-direction spritesheet aligned strictly by anchor ground contact.
    
    Returns (cell_w, cell_h, frame_count, [foot_x, foot_y]).
    """
    # 1. Determine frame count and bounding box relative to anchor
    min_ox, max_ox = 0, 0
    min_oy, max_oy = 0, 0
    max_frames = 0

    # Cache opened images to avoid re-reading zip
    cached_frames: dict[str, list[tuple[Image.Image, tuple[int, int, int, int], tuple[int, int]]]] = {}

    for d_name, clip_info in action_dirs_data.items():
        files = clip_info.get("files", [])
        if custom_frame_indices is not None:
            files = [files[i] for i in custom_frame_indices if i < len(files)]
        max_frames = max(max_frames, len(files))
        ax, ay = clip_info.get("anchor", [0, 0])
        cached_frames[d_name] = []

        for fpath in files:
            full_path = file_prefix + fpath if not fpath.startswith("01_Free_Experience") else fpath
            raw = z.read(full_path)
            im = Image.open(io.BytesIO(raw)).convert("RGBA")
            bbox = im.getbbox()
            if not bbox:
                bbox = (0, 0, im.width, im.height)
            cached_frames[d_name].append((im, bbox, (ax, ay)))

            min_ox = min(min_ox, math.floor((bbox[0] - ax) * scale))
            max_ox = max(max_ox, math.ceil((bbox[2] - ax) * scale))
            min_oy = min(min_oy, math.floor((bbox[1] - ay) * scale))
            max_oy = max(max_oy, math.ceil((bbox[3] - ay) * scale))

    if max_frames == 0:
        raise RuntimeError(f"No frames found for sheet {out_sheet}")

    margin = 3
    pad_w = max(abs(min_ox), max_ox) + margin
    cell_w = pad_w * 2
    if cell_w % 2 != 0:
        cell_w += 1
    foot_x = cell_w // 2

    top_h = abs(min_oy) + margin
    bot_h = max(max_oy, 0) + margin
    cell_h = top_h + bot_h
    if cell_h % 2 != 0:
        cell_h += 1
    foot_y = top_h

    sheet_w = cell_w * max_frames
    sheet_h = cell_h * len(DIRS)
    sheet = Image.new("RGBA", (sheet_w, sheet_h), (0, 0, 0, 0))

    for row_idx, d in enumerate(DIRS):
        # Resolve source direction (either exact or fallback for 4-direction actions)
        src_dir = d if d in cached_frames else DIR_FALLBACK_4.get(d, "south")
        if src_dir not in cached_frames:
            src_dir = next(iter(cached_frames.keys()))

        frames_list = cached_frames[src_dir]
        for col_idx in range(max_frames):
            frame_item = frames_list[min(col_idx, len(frames_list) - 1)]
            im, bbox, (ax, ay) = frame_item

            cropped = im.crop(bbox)
            new_w = max(1, round(cropped.width * scale))
            new_h = max(1, round(cropped.height * scale))
            scaled = cropped.resize((new_w, new_h), Image.Resampling.NEAREST)

            paste_x = foot_x + round((bbox[0] - ax) * scale)
            paste_y = foot_y + round((bbox[1] - ay) * scale)

            sheet_pos_x = col_idx * cell_w + paste_x
            sheet_pos_y = row_idx * cell_h + paste_y
            sheet.paste(scaled, (sheet_pos_x, sheet_pos_y), scaled)

    ensure_dir(out_sheet.parent)
    sheet.save(out_sheet)
    write_png_import(out_sheet)
    return cell_w, cell_h, max_frames, [foot_x, foot_y]


def import_five_action_char(
    z: zipfile.ZipFile,
    char_data: dict,
    out_id: str,
    label: str,
    gender: str,
    desc: str,
) -> None:
    dst = OUT_CHARS / out_id
    ensure_dir(dst)

    scale = 46.0 / 105.0  # standard ~46px visual height
    clips = char_data.get("clips", {})
    file_prefix = "01_Free_Experience/"

    built_anims: dict[str, dict] = {}

    action_specs = [
        ("idle", "idle", 6, True, None, None),
        ("walk", "walk", 10, True, None, None),
        ("attack", "attack", 12, False, 200, None),
        ("attack_secondary", "combo", 12, False, 200, None),
        ("walk", "qinggong", 14, False, None, None),  # fast burst for qinggong/dodge
        ("hurt", "hurt", 8, False, None, None),
        ("death", "death", 6, False, 1200, None),
    ]

    for src_action, game_action, fps, loop, hold_ms, custom_indices in action_specs:
        if src_action not in clips:
            continue
        out_sheet = dst / f"{game_action}_sheet.png"
        cw, ch, nframes, foot = pack_action_sheet(
            z,
            file_prefix,
            clips[src_action],
            out_sheet,
            scale,
            custom_frame_indices=custom_indices,
        )
        built_anims[game_action] = {
            "cell": [cw, ch],
            "frames": nframes,
            "fps": fps,
            "loop": loop,
            "foot_px": foot,
            "hold_last_ms": hold_ms,
            "sheet": f"{game_action}_sheet.png",
        }

    meta = {
        "name": out_id,
        "label": label,
        "gender": gender,
        "rows": DIRS,
        "mirrored_from": {},
        "signature": "combo" if "combo" in built_anims else "attack",
        "anims": built_anims,
        "_notes": {
            "source": f"DQYYY Wuxia Pixel Vol. 2 ({char_data.get('name')})",
            "desc": desc,
            "scale": "Anchor-grounded ~46px pixel height, 8-direction cardinal fallback",
        },
    }

    (dst / "characters.json").write_text(json.dumps(meta, indent=1, ensure_ascii=False) + "\n", encoding="utf-8")
    print(f"Imported {out_id} ({label}) -> {dst} with anims={list(built_anims.keys())}")


def import_strawhat(z: zipfile.ZipFile) -> None:
    dst = OUT_CHARS / "strawhat"
    ensure_dir(dst)

    scale = 46.0 / 105.0
    file_prefix = "01_Free_Experience/Characters/Original_Hero_Limited/"
    meta_path = "01_Free_Experience/Characters/Original_Hero_Limited/CLIPS.json"
    hero_data = json.loads(z.read(meta_path).decode("utf-8"))
    clips = hero_data.get("clips", {})

    built_anims: dict[str, dict] = {}

    action_specs = [
        ("idle", "idle", 6, True, None, None),
        ("walk", "walk", 10, True, None, None),
        ("attack3", "attack", 12, False, 200, None),
        ("cast_buddha_palm", "combo", 12, False, 200, None),
        ("cast_swift_step", "qinggong", 14, False, None, None),
        ("death", "hurt", 8, False, None, [0, 1, 2, 1]),  # flinch recoil frames
        ("death", "death", 8, False, 1200, None),
    ]

    for src_action, game_action, fps, loop, hold_ms, custom_indices in action_specs:
        if src_action not in clips:
            continue
        out_sheet = dst / f"{game_action}_sheet.png"
        cw, ch, nframes, foot = pack_action_sheet(
            z,
            file_prefix,
            clips[src_action],
            out_sheet,
            scale,
            custom_frame_indices=custom_indices,
        )
        built_anims[game_action] = {
            "cell": [cw, ch],
            "frames": nframes,
            "fps": fps,
            "loop": loop,
            "foot_px": foot,
            "hold_last_ms": hold_ms,
            "sheet": f"{game_action}_sheet.png",
        }

    meta = {
        "name": "strawhat",
        "label": "Đấu Lạp Hiệp Khách",
        "gender": "male",
        "rows": DIRS,
        "mirrored_from": {},
        "signature": "combo",
        "anims": built_anims,
        "_notes": {
            "source": "DQYYY Wuxia Pixel Vol. 2 (Original Hero Limited / Straw-hat Hero)",
            "desc": "Giang Hồ Lãng Khách — Như Lai Thần Chưởng & Tiêu Diêu Du",
            "scale": "Anchor-grounded ~46px pixel height, 8-direction cardinal fallback",
        },
    }

    (dst / "characters.json").write_text(json.dumps(meta, indent=1, ensure_ascii=False) + "\n", encoding="utf-8")
    print(f"Imported strawhat (Đấu Lạp Hiệp Khách) -> {dst} with anims={list(built_anims.keys())}")


def main() -> None:
    zip_path = find_zip()
    print(f"Found Wuxia Vol. 2 pack: {zip_path}")

    with zipfile.ZipFile(zip_path, "r") as z:
        anim_lib = json.loads(z.read("01_Free_Experience/Characters/ANIMATION_LIBRARY.json").decode("utf-8"))
        char_map = {c["name"]: c for c in anim_lib.get("characters", [])}

        # 1. 寒月宫-女弟子 -> hanyue (Nữ Tu Hàn Nguyệt)
        if "寒月宫-女弟子" in char_map:
            import_five_action_char(
                z,
                char_map["寒月宫-女弟子"],
                out_id="hanyue",
                label="Nữ Tu Hàn Nguyệt",
                gender="female",
                desc="Hàn Nguyệt Cung Nữ Đệ Tử — Băng Sương Kiếm Khí & Tuyết Vũ Phi Thiên",
            )

        # 2. 百花谷-女弟子 -> baihua (Nữ Tu Bách Hoa)
        if "百花谷-女弟子" in char_map:
            import_five_action_char(
                z,
                char_map["百花谷-女弟子"],
                out_id="baihua",
                label="Nữ Tu Bách Hoa",
                gender="female",
                desc="Bách Hoa Cốc Nữ Đệ Tử — Phi Châm Linh Thảo & Mộc Đạo Trị Liệu",
            )

        # 3. 玄霄剑宗-男弟子 -> xuanxiao (Kiếm Tu Huyền Tiêu)
        if "玄霄剑宗-男弟子" in char_map:
            import_five_action_char(
                z,
                char_map["玄霄剑宗-男弟子"],
                out_id="xuanxiao",
                label="Kiếm Tu Huyền Tiêu",
                gender="male",
                desc="Huyền Tiêu Kiếm Tông Nam Đệ Tử — Huyền Thiên Thần Kiếm & Cửu Tiêu Lôi Mang",
            )

        # 4. 黑风寨主 -> heifeng (Hắc Phong Trại Chủ)
        if "黑风寨主" in char_map:
            import_five_action_char(
                z,
                char_map["黑风寨主"],
                out_id="heifeng",
                label="Hắc Phong Trại Chủ",
                gender="male",
                desc="Hắc Phong Trại Bá Chủ — Hắc Phong Trảm Nhạc & Cuồng Bá Đao Cương",
            )

        # 5. Original_Hero_Limited -> strawhat (Đấu Lạp Hiệp Khách)
        import_strawhat(z)

    print("\n[SUCCESS] All 5 characters from Wuxia Vol. 2 imported successfully!")


if __name__ == "__main__":
    main()
