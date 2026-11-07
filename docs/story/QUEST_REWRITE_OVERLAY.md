# Quest / Story Rewrite Overlay (v1)

Giữ nguyên: quest ID (hash `name`), map, spawn nick kỹ thuật, state machine, skip/abandon.
Viết lại: mô tả, dialogue, Localization hiển thị, phần thưởng chữ, premise xuyên không.

## Premise

Người chơi xuyên không bất ngờ bằng thân xác thật (D-01). Không nhớ rõ vì sao tới.
Làm nhiệm vụ quanh vùng → quen người → mở dần ký ức (clue) + sức mạnh tu luyện (Tu Vi / đan / bí kíp).
Không đoạt xá. Không cheat UI. Không linh căn ẩn thức tỉnh.

## Trục địa lý (giữ map)

1. **Thanh Sa Cảng (Tulimshar*)** — tỉnh dậy, sống sót, Tutorial + side SoM-slot.
2. **Ngoại vi / mỏ / đồi** — thám hiểm, thu thập, ký ức mảnh.
3. **Thanh Vân / Trúc Sơn** — MQ + tông môn + NQ.
4. **Ship / Splatyna / Snake Pit** — vùng nguy hiểm muộn / ẩn.

## NPC nick kỹ thuật → tên hiển thị

| Nick (spawn/hash) | Hiển thị Việt | Vai |
|-------------------|---------------|-----|
| Elanore | Ái Lan | Dược sư cổng Thanh Sa, người đầu gặp sau xuyên không |
| Nina | Ni Na | Thủ hộ linh thạch / Menhir — giải thích linh khí |
| Kael | Kha Nhĩ | Tuần phòng trong thành |
| Ekinu | Nghê Khôn | Tuần phòng cổng nam |
| Nathan | Na Thiên | Thợ mỏ thiếu nước |
| Naem | Nẫm Công | Thợ mỏ cần mũ |
| Peter | Bạch Đạt | Tiêu sư trên linh thuyền |

NPC xianxia (Liễu Thanh Y, Hà Thiết Thủ, Diệp Tử Lăng, Mặc Lão Nhân, Trần Phương, Đạo Huyền, Tiếp Dẫn…) giữ nguyên.

## Phần thưởng

- Text `reward` phải khớp script cấp thưởng (hết "Chưa biết").
- MQ/SQ: thêm lớp "Mảnh Ký Ức" (flag clue StorySystem) — không thay XP cheat.
- Skip quest = Completed, **không** chạy script thưởng (đã có trong Progress.gd).

## Skip / Abandon

- Skip → `CompletedProgress`, không thưởng.
- Abandon → `UnknownProgress`, nhận lại từ NPC.
- Không đổi logic; chỉ bảo đảm dialogue không bắt buộc state trung gian khi đã skip (NPC xử lý `>= OBJECTIVE_MET` / `Completed` an toàn).
