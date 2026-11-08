---
trigger: always_on
description: Luôn tăng version của game trong project.godot và export_presets.cfg trước mỗi lần git push.
---

# Quy Tắc Tăng Version Khi Push Git

Trước mỗi lần đẩy code (`git push`) lên remote repository:
1. Trợ lý AI bắt buộc phải chạy lệnh tăng version:
   ```powershell
   py scripts/bump_version.py
   ```
2. Kiểm tra `project.godot` và `export_presets.cfg` đã được cập nhật số version mới và `version/code` mới.
3. Đưa các thay đổi version vào git commit và tiến hành push.
