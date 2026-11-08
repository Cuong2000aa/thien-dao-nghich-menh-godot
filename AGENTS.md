# Quy Tắc Phát Triển Thiên Đạo Nghịch Mệnh (AGENTS.md)

## 1. Quy Tắc Tự Động Tăng Version Khi Push (Bắt Buộc)
Mỗi lần commit và push code lên remote repository (`git push`), trợ lý AI **BẮT BUỘC** phải tăng version của game:

1. **Thực thi script tăng version tự động**:
   ```powershell
   py scripts/bump_version.py
   ```
   *(Mặc định tăng số patch, ví dụ: `0.1.0` ➔ `0.1.1`, code: `1000` ➔ `1001`)*.
2. **Các file cấu hình được cập nhật tự động**:
   - `project.godot` (`config/version`)
   - `export_presets.cfg` (`version/code`, `version/name`, `application/version`, `application/short_version`, `application/file_version`, `application/product_version`)
3. **Hiển thị Watermark trong game**:
   - [`sources/gui/Gui.gd`](file:///D:/thien-dao-nghich-menh-godot/sources/gui/Gui.gd) tự động đọc `application/config/version` và hiển thị góc dưới bên trái: `v{ver} · {Platform}`.
4. **Quy trình git**:
   - Luôn thêm `project.godot` và `export_presets.cfg` vào commit.
   - Chạy test đảm bảo không lỗi trước khi push.
   - Push lên branch hiện tại (`git push origin tdnm-web`).
