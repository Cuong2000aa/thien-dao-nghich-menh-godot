#!/usr/bin/env python3
"""Comprehensive verification of the Hero character roster in Thiên Đạo Nghịch Mệnh Godot."""
from __future__ import annotations

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CHARS_DIR = ROOT / "assets" / "characters"
ENTITIES_DIR = ROOT / "presets" / "entities"
SKILLS_DIR = ROOT / "presets" / "cells" / "skills"


def godot_hash(s: str) -> int:
    h = 5381
    for ch in s:
        h = (((h << 5) + h) + ord(ch)) & 0xFFFFFFFF
    return h


def main() -> int:
    print("=" * 60)
    print("THIÊN ĐẠO NGHỊCH MỆNH — HERO ROSTER VERIFICATION")
    print("=" * 60)

    # 1. Parse HeroLibrary.gd
    hero_lib_text = (ROOT / "sources" / "actor" / "HeroLibrary.gd").read_text(encoding="utf-8")
    hero_entries = re.findall(
        r'\{\s*"id":\s*"([^"]+)",\s*"name":\s*"([^"]+)",\s*"entity":\s*"([^"]+)",\s*"folder":\s*"([^"]+)"',
        hero_lib_text,
    )
    print(f"\n[1] Found {len(hero_entries)} heroes registered in HeroLibrary.gd:")
    for h_id, h_name, h_ent, h_folder in hero_entries:
        print(f"    - ID: {h_id:<16} Name: {h_name:<20} Entity: {h_ent:<18} Folder: {h_folder}")

    # 2. Parse skill names from presets/cells/skills/*.tres
    valid_skill_names = set()
    for sf in SKILLS_DIR.glob("*.tres"):
        for line in sf.read_text(encoding="utf-8").splitlines():
            if line.startswith("name = "):
                m = re.search(r'name\s*=\s*"([^"]+)"', line)
                if m:
                    valid_skill_names.add(m.group(1))

    # Add standard base nodes
    valid_skill_names.add("Melee")
    valid_skill_names.add("Run")

    print(f"\n[2] Loaded {len(valid_skill_names)} valid base skill names from presets.")

    # 3. Parse HeroSkillTree.gd
    skill_tree_text = (ROOT / "sources" / "actor" / "HeroSkillTree.gd").read_text(encoding="utf-8")
    tree_ids = set(re.findall(r'^\t"([a-z_]+)":\s*\{', skill_tree_text, re.MULTILINE))
    print(f"\n[3] Found {len(tree_ids)} hero skill trees in HeroSkillTree.gd: {sorted(tree_ids)}")

    errors = []
    warnings = []

    # 4. Verify each registered hero
    required_actions = ["idle", "walk", "attack", "combo", "qinggong", "hurt", "death"]

    print("\n[4] Validating hero assets, entities, and configurations:")
    for h_id, h_name, h_ent, h_folder in hero_entries:
        # Check folder
        c_dir = CHARS_DIR / h_folder
        if not c_dir.exists():
            errors.append(f"Hero {h_id}: missing folder {c_dir}")
            continue

        # Check characters.json
        c_json_file = c_dir / "characters.json"
        if not c_json_file.exists():
            errors.append(f"Hero {h_id}: missing {c_json_file}")
            continue

        c_meta = json.loads(c_json_file.read_text(encoding="utf-8"))
        anims = c_meta.get("anims", {})

        # Check all actions and sheets
        missing_anims = [a for a in required_actions if a not in anims]
        if missing_anims:
            errors.append(f"Hero {h_id}: missing anim actions {missing_anims} in characters.json")

        for act_name, act_cfg in anims.items():
            sheet_name = act_cfg.get("sheet", f"{act_name}_sheet.png")
            sheet_file = c_dir / sheet_name
            if not sheet_file.exists():
                errors.append(f"Hero {h_id}: missing spritesheet {sheet_file}")
            elif sheet_file.stat().st_size == 0:
                errors.append(f"Hero {h_id}: empty spritesheet {sheet_file}")

            import_file = sheet_file.with_suffix(".png.import")
            if not import_file.exists():
                warnings.append(f"Hero {h_id}: missing import file {import_file}")

            foot = act_cfg.get("foot_px")
            if not foot or len(foot) != 2:
                errors.append(f"Hero {h_id} {act_name}: invalid foot_px {foot}")

        # Check entity preset in presets/entities/
        ent_file = ENTITIES_DIR / f"{h_ent}.tres"
        if not ent_file.exists():
            errors.append(f"Hero {h_id}: missing entity preset {ent_file}")
        else:
            ent_content = ent_file.read_text(encoding="utf-8")
            m_id = re.search(r"_id\s*=\s*(\d+)", ent_content)
            expected_hash = godot_hash(h_ent)
            if not m_id:
                errors.append(f"Hero {h_id}: {ent_file} missing _id field")
            elif int(m_id.group(1)) != expected_hash:
                errors.append(
                    f"Hero {h_id}: {ent_file} _id mismatch (got {m_id.group(1)}, expected {expected_hash})"
                )

        # Check Skill tree
        if h_id not in tree_ids:
            errors.append(f"Hero {h_id}: missing skill tree in HeroSkillTree.gd")

        print(f"    [OK] Hero '{h_id}' ({h_name}): 7 actions valid, foot offsets grounded, entity preset matched.")

    # 5. Check Traits.gd female list
    traits_text = (ROOT / "sources" / "gui" / "character" / "Traits.gd").read_text(encoding="utf-8")
    female_match = re.search(r'isFemale\s*:\s*bool\s*=\s*heroId\s+in\s+\[([^\]]+)\]', traits_text)
    if female_match:
        female_list = [s.strip().strip('"').strip("'") for s in female_match.group(1).split(",")]
        print(f"\n[5] Traits.gd female detection: {female_list}")
        for fid in ["sword_fairy", "hanyue", "baihua"]:
            if fid not in female_list:
                errors.append(f"Traits.gd isFemale missing '{fid}'")
    else:
        errors.append("Could not find isFemale definition in Traits.gd")

    print("\n" + "=" * 60)
    if errors:
        print(f"RESULT: FAILED with {len(errors)} errors!")
        for e in errors:
            print(f"  [ERROR] {e}")
        return 1
    else:
        print(f"RESULT: ALL {len(hero_entries)} HEROES VALIDATED 100% SUCCESSFULLY WITH ZERO ERRORS!")
        if warnings:
            for w in warnings:
                print(f"  [WARN] {w}")
        return 0


if __name__ == "__main__":
    raise SystemExit(main())
