#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Automatic version bumper for Thiên Đạo Nghịch Mệnh.
Updates version across project.godot and export_presets.cfg.

Usage:
    py scripts/bump_version.py           # Bumps patch (0.1.0 -> 0.1.1, code 1000 -> 1001)
    py scripts/bump_version.py --minor   # Bumps minor (0.1.0 -> 0.2.0, code 1000 -> 1100)
    py scripts/bump_version.py --major   # Bumps major (0.1.0 -> 1.0.0, code 1000 -> 2000)
    py scripts/bump_version.py --set 0.2.5
"""

import sys
import os
import re
import argparse

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PROJECT_GODOT = os.path.join(BASE_DIR, "project.godot")
EXPORT_PRESETS = os.path.join(BASE_DIR, "export_presets.cfg")

def get_current_version():
    with open(PROJECT_GODOT, "r", encoding="utf-8") as f:
        content = f.read()
    m = re.search(r'config/version="([^"]+)"', content)
    if m:
        return m.group(1)
    return "0.1.0"

def get_current_code():
    if not os.path.exists(EXPORT_PRESETS):
        return 1000
    with open(EXPORT_PRESETS, "r", encoding="utf-8") as f:
        content = f.read()
    m = re.search(r'version/code=(\d+)', content)
    if m:
        return int(m.group(1))
    return 1000

def bump(ver_str, bump_type):
    parts = [int(p) for p in ver_str.split(".")]
    while len(parts) < 3:
        parts.append(0)
    major, minor, patch = parts[0], parts[1], parts[2]
    if bump_type == "major":
        major += 1
        minor = 0
        patch = 0
    elif bump_type == "minor":
        minor += 1
        patch = 0
    else: # patch
        patch += 1
    return f"{major}.{minor}.{patch}"

def update_project_godot(new_ver):
    with open(PROJECT_GODOT, "r", encoding="utf-8") as f:
        content = f.read()
    if 'config/version=' in content:
        content = re.sub(r'config/version="[^"]+"', f'config/version="{new_ver}"', content)
    else:
        content = re.sub(r'(\[application\][\r\n]+)', f'\\1config/version="{new_ver}"\n', content)
    with open(PROJECT_GODOT, "w", encoding="utf-8") as f:
        f.write(content)

def update_export_presets(new_ver, new_code):
    if not os.path.exists(EXPORT_PRESETS):
        return
    with open(EXPORT_PRESETS, "r", encoding="utf-8") as f:
        content = f.read()

    content = re.sub(r'version/code=\d+', f'version/code={new_code}', content)
    content = re.sub(r'version/name="[^"]+"', f'version/name="{new_ver}"', content)
    content = re.sub(r'application/version="[^"]+"', f'application/version="{new_ver}"', content)
    content = re.sub(r'application/short_version="[^"]+"', f'application/short_version="{new_ver}"', content)
    content = re.sub(r'application/file_version="[^"]+"', f'application/file_version="{new_ver}.0"', content)
    content = re.sub(r'application/product_version="[^"]+"', f'application/product_version="{new_ver}.0"', content)

    with open(EXPORT_PRESETS, "w", encoding="utf-8") as f:
        f.write(content)

def main():
    parser = argparse.ArgumentParser(description="Bump game project version.")
    parser.add_argument("--major", action="store_true", help="Bump major version")
    parser.add_argument("--minor", action="store_true", help="Bump minor version")
    parser.add_argument("--patch", action="store_true", help="Bump patch version (default)")
    parser.add_argument("--set", type=str, default="", help="Set exact version")
    args = parser.parse_args()

    cur_ver = get_current_version()
    cur_code = get_current_code()

    if args.set:
        new_ver = args.set
        new_code = cur_code + 1
    elif args.major:
        new_ver = bump(cur_ver, "major")
        new_code = cur_code + 1000
    elif args.minor:
        new_ver = bump(cur_ver, "minor")
        new_code = cur_code + 100
    else:
        new_ver = bump(cur_ver, "patch")
        new_code = cur_code + 1

    update_project_godot(new_ver)
    update_export_presets(new_ver, new_code)
    print(f"Bumped version: {cur_ver} -> {new_ver} (code: {cur_code} -> {new_code})")

if __name__ == "__main__":
    main()
