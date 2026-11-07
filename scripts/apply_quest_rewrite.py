#!/usr/bin/env python3
"""Apply narrative rewrite to presets/quests/*.tres — keep name (hash) & giver nick."""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
QUEST_DIR = ROOT / "presets" / "quests"

# file stem -> fields to set (name MUST stay unless ProgressCommons updated)
UPDATES: dict[str, dict[str, str]] = {
    "MQ_Chuong1_TinhLacDiGioi": {
        "description": "Xuyên không bất ngờ — tỉnh dậy giữa sơn môn lạ lẫm, ký ức đứt đoạn. Gặp Tiếp Dẫn Chấp Sự để nhận diện thân xác phàm trần mang Ngũ Hành Tạp Căn và bắt đầu tìm hiểu thế giới này.",
        "giverLocation": "Trúc Sơn Tiên Cảnh — Sơn Môn",
        "target": "Nói chuyện với Tiếp Dẫn Chấp Sự, kiểm tra đan điền, ghi nhận trạng thái hiện tại",
        "targetLocation": "Trúc Sơn Tiên Cảnh",
        "reward": "100 Tu Vi, 50 Linh Thạch, Khăn Vải Thô, Mảnh Ký Ức I",
    },
    "MQ_Chuong2_ConDuongTuDao": {
        "description": "Học cách cảm ứng linh khí, làm quen chấp sự sơn môn. Đọc Trúc Sơn Cổ Bi — mảnh ký ức hiện đại xen với minh văn cổ, hé lộ dị thường linh khí.",
        "reward": "150 Tu Vi, 100 Linh Thạch, 1 Hồi Xuân Đan, Mảnh Ký Ức II",
    },
    "MQ_Chuong3_DauVetDiBien": {
        "description": "Yêu thú ngoại vi cuồng loạn. Cùng Diệp Tử Lăng điều tra — mỗi dấu dị biến kích hoạt một mảnh nhớ: vì sao mình bị kéo vào thế giới này.",
        "reward": "250 Tu Vi, 200 Linh Thạch, 30 Điểm Cống Hiến, Mảnh Ký Ức III",
    },
    "MQ_Chuong4_BiMatCoTich": {
        "description": "Thâm nhập Hiên Viên Cổ Động theo chỉ dẫn Mặc Lão Nhân. Cổ tịch mâu thuẫn lịch sử tông môn; trận văn lệch quỹ đạo — ký ức về quy tắc Trái Đất và Thiên Đạo bắt đầu khớp nhau.",
        "reward": "400 Tu Vi, 350 Linh Thạch, 1 Bạch Ngân Kiếm, Mảnh Ký Ức IV",
    },
    "MQ_Chuong5_ThienDaoCoKhuyet": {
        "description": "Linh mạch cổ trận chấn động. Ghép đủ mảnh ký ức: Thiên Đạo vốn có khuyết — không phải ác thần, mà quy tắc vũ trụ bị rạn. Đưa ra lựa chọn nghịch mệnh đầu tiên.",
        "reward": "600 Tu Vi, 500 Linh Thạch, Danh Hiệu [Nghịch Mệnh Sơ Tâm], Ký Ức Hoàn Chỉnh",
    },
    "Tutorial": {
        "description": "Tỉnh dậy ngoài tường Thanh Sa Cảng trong trạng thái mất phương hướng. Ái Lan (dược sư cổng thành) cứu giúp, chỉ cách sinh tồn và làm quen giao diện cơ bản.",
        "giver": "Elanore",
        "giverLocation": "Cổng Thành Thanh Sa (Tulimshar)",
        "target": "Làm theo hướng dẫn Ái Lan, gặp tuần phòng Kha Nhĩ rồi Nghê Khôn",
        "targetLocation": "Thanh Sa Cảng",
        "reward": "Bình Nước, Kẹo Xương Rồng, Áo Vải Thô, Quần Vải, 50 Tu Vi",
    },
    "ElanorePotion": {
        "description": "Ái Lan cần nguyên liệu pha đan hồi sinh cho lính canh và dân thành. Thu thập dịch trùng linh (Maggot Slime), nước và thanh long đổi lấy đan xương rồng.",
        "giver": "Elanore",
        "giverLocation": "Cổng Thành Thanh Sa",
        "target": "6 Dịch Trùng Linh + 1 Bình Nước + 1 Thanh Long / mỗi bình đan",
        "targetLocation": "Ngoại thành Thanh Sa / Đông Lĩnh",
        "reward": "Đan Xương Rồng (Cactus Potion) × số bình pha",
    },
    "NinaHungry": {
        "description": "Ni Na canh giữ linh thạch thành, đói nhưng không rời vị trí. Mang một bánh sừng bò (Croissant) từ chợ Thanh Sa đến cho nàng — đổi lời giải thích về linh khí.",
        "giver": "Nina",
        "giverLocation": "Cổng Thành Thanh Sa — Linh Thạch",
        "target": "Croissant ×1 giao cho Ni Na",
        "targetLocation": "Chợ Thanh Sa Trấn",
        "reward": "Đan Xương Rồng ×10, 100 Linh Thạch",
    },
    "DesertSeed": {
        "description": "Hạt giống linh mộc sa mạc cần người mang đi tìm Ni Na / Manayir. Cơ duyên nhỏ giúp hiểu linh khí đất Thanh Sa.",
        "giver": "Mana Tree",
        "giverLocation": "Sa mạc / Cây Linh Mộc",
        "target": "Đưa hạt tới đúng người tiếp nhận",
        "targetLocation": "Thanh Sa / Manayir",
        "reward": "80 Tu Vi, 50 Linh Thạch, hiểu biết Linh Mộc",
    },
    "GrainInTheDesert": {
        "description": "Thương hộ / nông dân ven sa mạc nhờ thu thập lúa mì chịu hạn — sống sót bằng lao động chân tay nơi đất lạ.",
        "giverLocation": "Sa mạc Thanh Sa",
        "target": "Thu thập lúa mì sa mạc theo yêu cầu",
        "reward": "100 Tu Vi, 80 Linh Thạch, ít lương khô",
    },
    "MineExploration": {
        "description": "Thám sát khoáng trường sa mạc: ghi nhận lối đi, nguy hiểm và dấu dị thường linh khí dưới lòng đất.",
        "giverLocation": "Khu mỏ sa mạc",
        "target": "Khám phá các tầng mỏ và báo cáo",
        "reward": "120 Tu Vi, 100 Linh Thạch, 1 khoáng thạch thường",
    },
    "SandstormNathanWater": {
        "description": "Thợ mỏ Na Thiên khô cổ giữa bão cát. Đưa nước sạch — đổi lời chỉ đường trong nham động.",
        "giver": "Nathan",
        "giverLocation": "Mỏ Bão Cát",
        "target": "Giao nước cho Na Thiên",
        "reward": "50 Tu Vi, 100 Linh Thạch",
    },
    "SandstormNaemHelmet": {
        "description": "Nẫm Công cần mũ thợ mỏ để tiếp tục đào. Giúp một việc nhỏ, nhận trang bị đầu đơn giản.",
        "giver": "Naem",
        "giverLocation": "Mỏ Bão Cát",
        "target": "Mang mũ thợ mỏ cho Nẫm Công",
        "reward": "Mũ Thợ Mỏ (Miner Helmet)",
    },
    "SandstormMineAbandonedTreasure": {
        "description": "Tin đồn bảo vật trong mỏ hoang — khám phá ẩn, cẩn thận yêu thú. Phần thưởng dị vật chiến đấu.",
        "giverLocation": "Mỏ Bão Cát — khu bỏ hoang",
        "target": "Tìm bảo vật mỏ hoang",
        "reward": "Piou Slayer (dị binh), 80 Tu Vi",
    },
    "TulimsharEasternHillsChest": {
        "description": "Rương bị bỏ quên trên Đông Lĩnh Thanh Sa. Mở ra khi đi tuần / thám hiểm ngoại thành — quest ẩn sống sót.",
        "giverLocation": "Thanh Sa — Đông Lĩnh",
        "target": "Mở rương Đông Lĩnh",
        "reward": "Khiên Sa Mạc (Desert Shield)",
    },
    "TulimsharGlassmaking": {
        "description": "Thợ kính Thanh Sa cần cát tinh / nguyên liệu thổi chai. Việc chân tay đổi vật dụng chứa đan.",
        "giverLocation": "Thanh Sa Trấn",
        "target": "Giúp hoàn tất mẻ kính",
        "reward": "Chai rỗng ×3, 100 Tu Vi",
    },
    "TulimsharOldFriendship": {
        "description": "Một cố nhân ở Thanh Sa nhờ chuyển lời / vật kỷ niệm — mối quan hệ phàm trần giữa dòng tu chân.",
        "giverLocation": "Thanh Sa Cảng",
        "target": "Hoàn tất lời nhờ của cố nhân",
        "reward": "1000 Linh Thạch",
    },
    "ShipPeterBounty": {
        "description": "Tiêu sư Bạch Đạt trên linh thuyền treo thưởng diệt Ratto — chứng tỏ bản lĩnh trước khi vào tử địa sâu hơn.",
        "giver": "Peter",
        "giverLocation": "Linh Thuyền (Ship)",
        "target": "Hạ Ratto Ship rồi báo Bạch Đạt",
        "reward": "100 Tu Vi, 500 Linh Thạch",
    },
    "SnakePitBitingThrist": {
        "description": "Trong Hố Rắn, khát cháy họng. Tìm nguồn nước / đan giải khát để sống sót — bài học tử địa.",
        "giverLocation": "Hố Rắn (Snake Pit)",
        "target": "Giải quyết cơn khát trong Hố Rắn",
        "reward": "150 Tu Vi, 100 Linh Thạch, 2 Bình Nước",
    },
    "SnakePitThief": {
        "description": "Kẻ trộm lẩn trong Hố Rắn. Truy tìm / đối chất — phần thưởng nhỏ và manh mối địa mạch.",
        "giverLocation": "Hố Rắn",
        "target": "Xử lý kẻ trộm Hố Rắn",
        "reward": "180 Tu Vi, 150 Linh Thạch",
    },
    "SplatynaOffering": {
        "description": "Cống phẩm / nghi thức phong ấn Vạn Yêu Quật (Splatyna). Quest muộn — đụng chạm D-02 qua nghi lễ cổ.",
        "giverLocation": "Vạn Yêu Quật (Splatyna)",
        "target": "Hoàn tất cống phẩm phong ấn",
        "reward": "300 Tu Vi, 250 Linh Thạch, 50 Điểm Cống Hiến",
    },
    "VeteranCaveExplorer": {
        "description": "Lão thám hiểm chỉ điểm hang động. Quest ẩn: lắng nghe rồi tự đi xác minh — mở góc nhìn địa mạch.",
        "giverLocation": "Hang động Thanh Sa / Candor",
        "target": "Theo chỉ dẫn thám hang và trở về",
        "reward": "120 Tu Vi, 80 Linh Thạch, bản đồ hang sơ",
    },
    "NhapMonKhaoNghiem": {
        "description": "Người ngoài vừa tới môn phái, ký ức còn mơ hồ. Vượt khảo nghiệm nhập môn để có thân phận Tạp Dịch — chỗ đứng hợp pháp trong sơn môn.",
        "reward": "Thân Phận Tạp Dịch, Tạp Dịch Lệnh Bài, 30 Tu Vi, 50 Linh Thạch, 20 Điểm Cống Hiến",
    },
    "KhaoHachNgoaiMon": {
        "description": "Chứng minh đã quen sơn môn: khảo hạch Ngoại Môn mở Tụ Linh Trận và Tàng Kinh Các — sức mạnh mở bằng công sức, không phải thiên tư.",
    },
    "KhaoHachNoiMon": {
        "description": "Thăng Nội Môn: trách nhiệm nặng hơn, tài nguyên sâu hơn. Ký ức về quy tắc thế giới ngày một rõ.",
    },
    "TruyenThuaTongMon": {
        "description": "Nhận truyền thừa kiếm quyết / bí kíp tông môn — bước ngoặt sức mạnh có nguồn gốc rõ ràng.",
    },
    "TuanTraSonMon": {
        "description": "Tuần tra sơn môn: quen địa hình, gặp đồng môn, củng cố chỗ đứng của kẻ ngoại lai.",
    },
    "CongHienDuocThao": {
        "description": "Cống hiến dược thảo cho Dược Đường — đổi điểm cống hiến và đan sơ cấp.",
    },
    "CongHienKhoangThach": {
        "description": "Cống hiến khoáng thạch cho Luyện Khí — đổi điểm cống hiến và tinh thiết.",
    },
    "DietTruMaVat": {
        "description": "Diệt trừ ma vật quấy phá ngoại vi — bảo vệ thôn / môn, tích lũy thực chiến.",
    },
    "ThanhTruLinhTrung": {
        "description": "Thanh trừ Linh Trùng quanh sơn môn theo lệnh Đạo Huyền — nhiệm vụ ngoại môn kinh điển.",
    },
    "ThuThapLinhThao": {
        "description": "Thu thập linh thảo theo danh sách Dược Đường — học nhận biết dược liệu bản địa bằng mắt và tay.",
    },
    "ThuThapKhoangThach": {
        "description": "Khai thác / thu thập khoáng thạch chỉ định — nguyên liệu luyện khí và cống hiến.",
    },
    "LuyenDanNhapMon": {
        "description": "Học luyện đan nhập môn: không lấy hóa học Trái Đất thay linh dược — phải làm đúng quy tắc nơi này.",
    },
    "KhamPhaCoBi": {
        "description": "Khám phá Trúc Sơn Cổ Bi — quest bán ẩn gắn MQ2; tàn quyển kích hoạt mảnh ký ức phụ.",
        "reward": "150 Tu Vi, 200 Linh Thạch, Trúc Sơn Cổ Bi Tàn Quyển, Mảnh Ký Ức Phụ",
    },
    "ThaoPhatThuVuong": {
        "description": "Thảo phạt thú vương ngoại vi — thử thách thực lực trước khi chạm dị biến lớn hơn.",
    },
    "NQ_LieuThanhY_1": {
        "description": "Liễu Thanh Y nhờ tìm Ngân Linh Thảo và U Hồn Thảo chữa kinh mạch đệ tử mới — người ngoài học cách giúp đỡ để được chấp nhận.",
    },
    "NQ_LieuThanhY_2": {
        "description": "Tiếp tục hỗ trợ Dược Đường; hảo cảm Liễu Thanh Y mở lời khuyên về tạp căn và đan dược.",
    },
    "NQ_HaThietThu_1": {
        "description": "Hà Thiết Thủ thử thách thân thủ — spar / thu thập theo yêu cầu để chứng minh không phải kẻ ăn bám.",
    },
    "NQ_HaThietThu_2": {
        "description": "Nhiệm vụ chiến đấu sâu hơn với Hà Thiết Thủ; hảo cảm mở chỉ điểm thực chiến.",
    },
    "NQ_DiepTuLang_1": {
        "description": "Diệp Tử Lăng giao việc ngoại vi — mắt thám sát dị biến, gắn với mạch MQ3.",
    },
    "NQ_DiepTuLang_2": {
        "description": "Điều tra sâu dấu dị biến cùng Diệp Tử Lăng; hảo cảm và manh mối yêu đan.",
    },
    "NQ_MacLaoNhan_1": {
        "description": "Mặc Lão Nhân thử lòng kẻ muốn đọc cổ tịch — kiên nhẫn hơn bạo lực.",
    },
    "NQ_MacLaoNhan_2": {
        "description": "Giải mã thêm trận văn / cổ thư; mở đường cho MQ4.",
    },
    "NQ_TranPhuong_1": {
        "description": "Trần Phương gặp nạn / cần giúp quanh suối — lựa chọn cứu người hay đuổi dị tượng (Story choice).",
    },
    "NQ_TranPhuong_2": {
        "description": "Củng cố tình đồng môn với Trần Phương sau lần cứu viện.",
    },
    "SQ_HienVienBiMat": {
        "description": "[Ẩn] Bí mật Hiên Viên — chỉ lộ khi đủ flag / tới đúng POI. Thưởng khoáng và manh mối cổ.",
        "reward": "180 Tu Vi, 200 Linh Thạch, 2 Bạch Ngân Khoáng, Mảnh Ký Ức Ẩn",
    },
    "SQ_UHonTramBao": {
        "description": "[Ẩn] U Hồn Trảm Bảo — dị vật / thảo dược tử khí. Không hiện journal cho đến khi kích hoạt.",
        "reward": "160 Tu Vi, 150 Linh Thạch, 3 U Hồn Thảo, Mảnh Ký Ức Ẩn",
    },
    "SQ_NguHanhThachTran": {
        "description": "[Ẩn] Ngũ Hành Thạch Trận — liên hệ tạp căn của đạo hữu với trận đá cổ.",
        "reward": "250 Tu Vi, 200 Linh Thạch, 1 Kim Cang Đan, Mảnh Ký Ức Ẩn",
    },
    "SQ_BietVienDuocDien": {
        "description": "[Ẩn] Biệt viện dược điền — tìm khi quen Liễu Thanh Y / đi đúng lối.",
    },
    "SQ_LienHoaCoThiet": {
        "description": "[Ẩn] Liên Hoa Cổ Thiết — khoáng trận ẩn trong địa mạch.",
    },
    "SQ_PhongAnDiaHa": {
        "description": "[Ẩn] Phong ấn địa hạ dưới Tàng Kinh Các — Bạch Hạc Chân Nhân mới giao khi đủ tin.",
    },
    "SQ_TienNhanDiThu": {
        "description": "[Ẩn] Di thư tiền nhân — chữ viết kích hoạt ký ức mạnh.",
        "reward": "400 Tu Vi, 300 Linh Thạch, 1 Linh Thạch Thượng Phẩm, Mảnh Ký Ức Ẩn",
    },
    "SQ_DuPhuongGiaoThuong": {
        "description": "Giao thương với Khang Vạn Kim — học giá trị linh thạch và mạng lưới phàm/tu.",
    },
    "EQ_YeuThuTrieu": {
        "description": "Sự kiện: yêu thú triều — thế giới đáp ứng khi đạo hữu đã có chỗ đứng.",
    },
    "EQ_LinhKhiDiTuong": {
        "description": "Sự kiện: linh khí dị tượng — gợi ý D-02 trước khi MQ5.",
    },
    "EQ_CoTranBatOn": {
        "description": "Sự kiện: cổ trận bất ổn — tiền đề cao trào Thiên Đạo có khuyết.",
    },
}


def patch_tres(path: Path, fields: dict[str, str]) -> bool:
    text = path.read_text(encoding="utf-8")
    orig = text
    for key, val in fields.items():
        # escape for tres string
        esc = val.replace("\\", "\\\\").replace('"', '\\"')
        pat = re.compile(rf'(^{key}\s*=\s*")(.*?)("\s*$)', re.M)
        if pat.search(text):
            text = pat.sub(lambda m: m.group(1) + esc + m.group(3), text, count=1)
        else:
            # insert before metadata or at end of [resource] block
            insert = f'{key} = "{esc}"\n'
            if "metadata/_custom_type_script" in text:
                text = text.replace("metadata/_custom_type_script", insert + "metadata/_custom_type_script", 1)
            else:
                if not text.endswith("\n"):
                    text += "\n"
                text += insert
    if text != orig:
        path.write_text(text, encoding="utf-8")
        return True
    return False


def main() -> None:
    changed = 0
    missing = []
    for stem, fields in UPDATES.items():
        path = QUEST_DIR / f"{stem}.tres"
        if not path.exists():
            missing.append(stem)
            continue
        if patch_tres(path, fields):
            changed += 1
            print("updated", stem)
        else:
            print("noop", stem)
    print(f"DONE changed={changed} missing={missing}")


if __name__ == "__main__":
    main()
