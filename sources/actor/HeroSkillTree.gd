extends RefCounted
class_name HeroSkillTree

## Class skill trees — full cultivation ladder (Phàm → Độ Kiếp).
## Skill "name" must match presets/cells/skills/*.tres `name` (DB hash key).

const NODE_MELEE := {
	"name": "Melee",
	"title": "Kiếm Căn Bản",
	"desc": "Đòn cận chiến nền tảng. Mọi Hình Thể đều luyện từ ngày nhập đạo — sát thương theo công kích cơ bản.",
	"vfx": "pixel",
}
const NODE_RUN := {
	"name": "Run",
	"title": "Khinh Thân",
	"desc": "Bật/tắt chạy nhanh, tiêu hao thể lực. Dùng để cơ động trên chiến trường và né chiêu.",
	"vfx": "pixel",
}

## min_level maps Cultivation.REALMS (see docs/HERO_SKILL_TREES.md).
const TREES : Dictionary = {
	"swordsman": {
		"label": "Kiếm Khách",
		"summary": "Kiếm đạo tông môn — trận pháp, hộ thể, vạn kiếm đồng quy. Phong cách ổn định, clear pack, có thuẫn.",
		"nodes": [
			{
				"min_level": 1,
				"realm_label": "Phàm Thân",
				"skills": [
					NODE_MELEE,
					NODE_RUN,
					{
						"name": "Thanh Phong Kiếm Khí",
						"title": "Thanh Phong Kiếm Khí",
						"desc": "Ngưng Mộc khí thành một đạo kiếm khí phóng xa. Xuyên nhẹ, làm chậm cảm giác — chiêu mở đầu của ngoại môn Trúc Sơn.",
						"vfx": "pixel",
					},
				],
			},
			{
				"min_level": 4,
				"realm_label": "Tụ Khí • Tầng 3 (Sơ Kỳ)",
				"skills": [
					{
						"name": "Đạp Phong Bộ",
						"title": "Đạp Phong Bộ",
						"desc": "Thân pháp đạp gió: lướt ngắn, thoáng vô địch. Dùng engage, né đòn hoặc bắt lưng.",
						"vfx": "pixel",
					},
				],
			},
			{
				"min_level": 10,
				"realm_label": "Tụ Khí • Tầng 9 (Viên Mãn)",
				"skills": [
					{
						"name": "Trúc Sơn Kiếm Trận",
						"title": "Trúc Sơn Kiếm Trận",
						"desc": "Cắm kiếm chỉ thiên, lục đạo kiếm quang xoay thành trận sát phạt quanh thân — phá giáp, kiểm soát đám đông.",
						"vfx": "pixel",
					},
				],
			},
			{
				"min_level": 11,
				"realm_label": "Thông Mạch • Sơ Kỳ",
				"skills": [
					{
						"name": "Quy Nguyên Hộ Thể Thuẫn",
						"title": "Quy Nguyên Hộ Thể Thuẫn",
						"desc": "Dẫn Thổ khí ngưng kim quang hộ thể, hấp thụ thương tổn trong vài giây. Trụ cột sinh tồn của Kiếm Khách.",
						"vfx": "pixel",
					},
				],
			},
			{
				"min_level": 19,
				"realm_label": "Đạo Cơ • Sơ Kỳ",
				"skills": [
					{
						"name": "Thánh Quang Hộ Đạo",
						"title": "Thánh Quang Hộ Đạo",
						"desc": "Thánh quang hộ đạo: hồi khí huyết và thanh tẩy ngoại ma. Bổ sung sau khi đã có thuẫn.",
						"vfx": "pixel",
					},
				],
			},
			{
				"min_level": 27,
				"realm_label": "Huyền Đan • Sơ Kỳ",
				"skills": [
					{
						"name": "Vạn Kiếm Quy Tông",
						"title": "Vạn Kiếm Quy Tông",
						"desc": "Tuyệt học: triệu trận kiếm quang, vạn kiếm xoay không rồi đồng quy điểm giữa — sát phạt diện rộng Kim hệ.",
						"vfx": "pixel",
					},
				],
			},
			{
				"min_level": 35,
				"realm_label": "Nguyên Thần • Sơ Kỳ",
				"skills": [
					{
						"name": "Hỏa Long Phun Tức",
						"title": "Hỏa Long Phun Tức",
						"desc": "Kiếm ý dẫn Hỏa: ngưng long tức phun lửa phía trước. Bổ sung sát thương Hỏa khi trận kiếm chưa đủ nóng.",
						"vfx": "pixel",
					},
				],
			},
			{
				"min_level": 43,
				"realm_label": "Thiên Nhân • Sơ Kỳ",
				"skills": [
					{
						"name": "Địa Long Phá Sơn",
						"title": "Địa Long Phá Sơn",
						"desc": "Thổ quyền/kiếm ý chấn địa — địa long trồi lên phá núi. AoE nặng, bổ sung khi đã vững trụ.",
						"vfx": "pixel",
					},
				],
			},
			{
				"min_level": 51,
				"realm_label": "Quy Hư • Sơ Kỳ",
				"skills": [
					{
						"name": "Mana Burst",
						"title": "Linh Bộc",
						"desc": "Dị thuật SoM: bộc phát linh lực quanh thân. Dùng khi cần sóng pháp lực thuần túy (VFX particle cổ).",
						"vfx": "som",
					},
				],
			},
			{
				"min_level": 61,
				"realm_label": "Độ Kiếp • Sơ Kỳ",
				"skills": [
					{
						"name": "Hư Không Hấp Tinh",
						"title": "Hư Không Hấp Tinh",
						"desc": "Thiên giai: mở hư không hấp tinh trận — nuốt linh khí vào điểm vô cực. Chiêu tối thượng của Kiếm Khách.",
						"vfx": "pixel",
					},
				],
			},
		],
	},
	"wuxia_swordsman": {
		"label": "Kiếm Sĩ",
		"summary": "Một kiếm phá thế — hàn kiếm, lôi liên hoàn, trảm thiên môn. Burst / kite, ít thuẫn hơn Kiếm Khách.",
		"nodes": [
			{
				"min_level": 1,
				"realm_label": "Phàm Thân",
				"skills": [
					NODE_MELEE,
					NODE_RUN,
					{
						"name": "Hàn Băng Thiên Kiếm",
						"title": "Hàn Băng Thiên Kiếm",
						"desc": "Ngưng hàn thành kiếm khí xuyên thấu. Thủy hệ — chậm địch, poke từ xa trước khi áp sát.",
						"vfx": "pixel",
					},
				],
			},
			{
				"min_level": 4,
				"realm_label": "Tụ Khí • Tầng 3 (Sơ Kỳ)",
				"skills": [
					{
						"name": "Đạp Phong Bộ",
						"title": "Đạp Phong Bộ",
						"desc": "Lướt vào tầm một kiếm hoặc rút ra sau burst. Cốt lõi nhịp võ hiệp.",
						"vfx": "pixel",
					},
				],
			},
			{
				"min_level": 10,
				"realm_label": "Tụ Khí • Tầng 9 (Viên Mãn)",
				"skills": [
					{
						"name": "Tử Lôi Liên Hoàn",
						"title": "Tử Lôi Liên Hoàn",
						"desc": "Kiếm ý dẫn lôi: tử lôi nhảy giữa mục tiêu. Clear nhanh, giữ nhịp khi kite.",
						"vfx": "pixel",
					},
				],
			},
			{
				"min_level": 11,
				"realm_label": "Thông Mạch • Sơ Kỳ",
				"skills": [
					{
						"name": "Thanh Phong Kiếm Khí",
						"title": "Thanh Phong Kiếm Khí",
						"desc": "Thêm đường kiếm khí Mộc linh động — sóng phụ khi Hàn Băng đang CD.",
						"vfx": "pixel",
					},
				],
			},
			{
				"min_level": 19,
				"realm_label": "Đạo Cơ • Sơ Kỳ",
				"skills": [
					{
						"name": "Nhất Kiếm Trảm Thiên Môn",
						"title": "Nhất Kiếm Trảm Thiên Môn",
						"desc": "Signature: ngưng kiếm ý xé thiên môn — một kiếm trảm, lôi quang Kim sát phạt rộng. CD dài, sát thương cực cao.",
						"vfx": "pixel",
					},
				],
			},
			{
				"min_level": 27,
				"realm_label": "Huyền Đan • Sơ Kỳ",
				"skills": [
					{
						"name": "Lôi Phạt Cửu Thiên",
						"title": "Lôi Phạt Cửu Thiên",
						"desc": "Triệu cửu thiên lôi phạt giáng xuống. Finisher diện rộng sau Nhất Kiếm hoặc khi địch dồn cụm.",
						"vfx": "pixel",
					},
				],
			},
			{
				"min_level": 35,
				"realm_label": "Nguyên Thần • Sơ Kỳ",
				"skills": [
					{
						"name": "Bát Hoang Liệt Không Quyền",
						"title": "Bát Hoang Liệt Không Quyền",
						"desc": "Quyền kình cận chiến — choáng địch khi đã lướt vào. Bổ sung nếu kiếm khí bị kháng.",
						"vfx": "pixel",
					},
				],
			},
			{
				"min_level": 43,
				"realm_label": "Thiên Nhân • Sơ Kỳ",
				"skills": [
					{
						"name": "Spitfire",
						"title": "Liệt Hỏa Phún",
						"desc": "Dị thuật SoM: phun lửa phía trước. Thêm Hỏa khi lôi/hàn chưa đủ đa dạng thuộc tính.",
						"vfx": "som",
					},
				],
			},
			{
				"min_level": 51,
				"realm_label": "Quy Hư • Sơ Kỳ",
				"skills": [
					{
						"name": "Sonic Wave",
						"title": "Âm Lang Kiếm",
						"desc": "Sóng âm SoM phóng thẳng — poke thêm khi cần khoảng cách an toàn.",
						"vfx": "som",
					},
				],
			},
			{
				"min_level": 61,
				"realm_label": "Độ Kiếp • Sơ Kỳ",
				"skills": [
					{
						"name": "Flar",
						"title": "Hỏa Châu",
						"desc": "Hỏa châu SoM tầm xa. Chiêu kết thúc Độ Kiếp — đốt nốt sinh lực còn lại.",
						"vfx": "som",
					},
				],
			},
		],
	},
	"assassin": {
		"label": "Ảnh Sát",
		"summary": "Lén, độc, hút hồn, thân pháp ẩn — hit-and-run. Nhiều VFX SoM (Poison/Morph/Inma/Betsanc).",
		"nodes": [
			{
				"min_level": 1,
				"realm_label": "Phàm Thân",
				"skills": [
					NODE_MELEE,
					NODE_RUN,
					{
						"name": "Đạp Phong Bộ",
						"title": "Đạp Phong Bộ",
						"desc": "Thân ảnh lướt vào lưng địch hoặc thoát vòng vây. Skill mở đầu bắt buộc của Ảnh Sát.",
						"vfx": "pixel",
					},
				],
			},
			{
				"min_level": 4,
				"realm_label": "Tụ Khí • Tầng 3 (Sơ Kỳ)",
				"skills": [
					{
						"name": "Poison",
						"title": "Ẩn Độc",
						"desc": "Tẩm độc ẩn: mòn khí huyết theo thời gian (SoM Poison). Kết hợp đánh thường để rút máu dài.",
						"vfx": "som",
					},
				],
			},
			{
				"min_level": 10,
				"realm_label": "Tụ Khí • Tầng 9 (Viên Mãn)",
				"skills": [
					{
						"name": "Huyền Âm Thôn Hồn",
						"title": "Huyền Âm Thôn Hồn",
						"desc": "Huyền âm rút linh — hút sinh cơ địch. Sustain chính khi đã dính độc.",
						"vfx": "pixel",
					},
				],
			},
			{
				"min_level": 11,
				"realm_label": "Thông Mạch • Sơ Kỳ",
				"skills": [
					{
						"name": "Morph",
						"title": "Ảo Ảnh Thân",
						"desc": "Biến ảo thân hình (SoM Morph) — tái vị trí, thoát khóa mục tiêu, tạo nhịp ẩn sát.",
						"vfx": "som",
					},
				],
			},
			{
				"min_level": 19,
				"realm_label": "Đạo Cơ • Sơ Kỳ",
				"skills": [
					{
						"name": "Inma",
						"title": "Hàn Độc Chỉ",
						"desc": "Dị thuật Inma: chạm linh / hồi nhẹ (PixelFX blessing + heal AoE). Poke tầm trung sau khi ẩn.",
						"vfx": "pixel",
					},
				],
			},
			{
				"min_level": 27,
				"realm_label": "Huyền Đan • Sơ Kỳ",
				"skills": [
					{
						"name": "Betsanc",
						"title": "Bế Tán Chú",
						"desc": "Bùa dị SoM: tăng phòng/né trong thời gian dài, cast nặng. Dùng trước giao tranh lớn.",
						"vfx": "som",
					},
				],
			},
			{
				"min_level": 35,
				"realm_label": "Nguyên Thần • Sơ Kỳ",
				"skills": [
					{
						"name": "Jump",
						"title": "Túng Địa Dược",
						"desc": "Nhảy địa hình SoM — thoát AoE, leo cao, tạo góc đánh. Bổ sung cơ động ngoài Đạp Phong.",
						"vfx": "som",
					},
				],
			},
			{
				"min_level": 43,
				"realm_label": "Thiên Nhân • Sơ Kỳ",
				"skills": [
					{
						"name": "Sonic Scream",
						"title": "Phá Âm Tiếu",
						"desc": "Tiếng hét siêu âm SoM — choáng/sát gần. Dùng khi bị vây sau khi lộ hình.",
						"vfx": "som",
					},
				],
			},
			{
				"min_level": 51,
				"realm_label": "Quy Hư • Sơ Kỳ",
				"skills": [
					{
						"name": "Leaf Blades",
						"title": "Lạc Diệp Nhẫn",
						"desc": "Mưa lá kiếm SoM tầm xa — kite khi không muốn áp sát.",
						"vfx": "som",
					},
				],
			},
			{
				"min_level": 61,
				"realm_label": "Độ Kiếp • Sơ Kỳ",
				"skills": [
					{
						"name": "Archer",
						"title": "U Ảnh Tiễn",
						"desc": "Tiễn đạo SoM tầm cực xa — kết thúc Độ Kiếp: hạ từ bóng tối, không lộ kiếm khí.",
						"vfx": "som",
					},
				],
			},
		],
	},
}

static func GetTree(heroId : String) -> Dictionary:
	return TREES.get(heroId, TREES["swordsman"])

static func GetTreeByIndex(heroIndex : int) -> Dictionary:
	var HeroLib = preload("res://sources/actor/HeroLibrary.gd")
	var hero : Dictionary = HeroLib.Get(heroIndex)
	return GetTree(String(hero.get("id", "swordsman")))

static func GetTreeByShape(shapeHash : int) -> Dictionary:
	var HeroLib = preload("res://sources/actor/HeroLibrary.gd")
	var idx : int = HeroLib.FindIndexByShape(shapeHash)
	if idx < 0:
		idx = 0
	return GetTreeByIndex(idx)

static func ResolveSkillId(skillName : String) -> int:
	if skillName.is_empty():
		return DB.UnknownHash
	if DB.HasCellHash(skillName):
		return DB.GetCellHash(skillName)
	for id in DB.SkillsDB:
		var cell : SkillCell = DB.SkillsDB[id]
		if cell and cell.name == skillName:
			return cell.id
	return skillName.hash()

static func GetUnlockedSkillNames(heroId : String, level : int) -> PackedStringArray:
	var out : PackedStringArray = []
	var tree : Dictionary = GetTree(heroId)
	for node in tree.get("nodes", []):
		if int(node.get("min_level", 999)) > level:
			continue
		for sk in node.get("skills", []):
			var n : String = String(sk.get("name", ""))
			if not n.is_empty() and not out.has(n):
				out.append(n)
	return out

static func CountSkillsInTree(heroId : String) -> int:
	return GetUnlockedSkillNames(heroId, 99).size()

static func GetStarterSkillPayload(heroId : String) -> Array[Dictionary]:
	var payload : Array[Dictionary] = []
	for skillName in GetUnlockedSkillNames(heroId, 1):
		var sid : int = ResolveSkillId(skillName)
		if sid != DB.UnknownHash:
			payload.append({"skill_id": sid, "level": 1})
	if payload.is_empty():
		payload.append({"skill_id": SkillCommons.SkillMeleeName.hash(), "level": 1})
		payload.append({"skill_id": SkillCommons.SkillRunName.hash(), "level": 1})
	return payload

static func GetStarterSkillPayloadByShape(shapeHash : int) -> Array[Dictionary]:
	var HeroLib = preload("res://sources/actor/HeroLibrary.gd")
	var idx : int = HeroLib.FindIndexByShape(shapeHash)
	if idx < 0:
		idx = 0
	var heroId : String = String(HeroLib.Get(idx).get("id", "swordsman"))
	return GetStarterSkillPayload(heroId)

static func GrantSkillsToActor(actor : Actor, level : int, notify : bool = true) -> PackedStringArray:
	var granted : PackedStringArray = []
	if actor == null or actor.progress == null or actor.stat == null:
		return granted
	var shapeHash : int = actor.stat.shape if actor.stat.shape != DB.UnknownHash else actor.stat.currentShape
	var HeroLib = preload("res://sources/actor/HeroLibrary.gd")
	var idx : int = HeroLib.FindIndexByShape(shapeHash)
	if idx < 0:
		idx = 0
	var heroId : String = String(HeroLib.Get(idx).get("id", "swordsman"))
	for skillName in GetUnlockedSkillNames(heroId, level):
		var sid : int = ResolveSkillId(skillName)
		if sid == DB.UnknownHash or not DB.SkillsDB.has(sid):
			continue
		var cell : SkillCell = DB.SkillsDB[sid]
		if cell == null:
			continue
		if actor.progress.HasSkill(cell, 1):
			continue
		actor.progress.AddSkill(cell, 1, true)
		granted.append(String(cell.name))
		if notify and actor is PlayerAgent:
			Network.PushNotification("Lĩnh ngộ: %s" % _FindTitle(heroId, skillName), actor.peerID)
	return granted

static func GrantSkillsBetweenLevels(actor : Actor, oldLevel : int, newLevel : int) -> void:
	if newLevel <= oldLevel:
		return
	GrantSkillsToActor(actor, newLevel, true)

static func _FindTitle(heroId : String, skillName : String) -> String:
	var tree : Dictionary = GetTree(heroId)
	for node in tree.get("nodes", []):
		for sk in node.get("skills", []):
			if String(sk.get("name", "")) == skillName:
				return String(sk.get("title", skillName))
	return skillName

static func FlattenNodesForDisplay(heroId : String) -> Array:
	return GetTree(heroId).get("nodes", [])

## Build a short combat-stats line from SkillCell modifiers + timings.
static func FormatSkillStats(cell : SkillCell) -> String:
	if cell == null:
		return ""
	var parts : PackedStringArray = []
	var atk : float = 0.0
	var mana : float = 0.0
	var stam : float = 0.0
	var heal : float = 0.0
	if cell.modifiers and cell.modifiers._modifiers:
		for mod in cell.modifiers._modifiers:
			if mod == null:
				continue
			match int(mod._effect):
				CellCommons.Modifier.Attack, CellCommons.Modifier.MAttack:
					atk += float(mod._value)
				CellCommons.Modifier.Mana:
					mana += float(mod._value)
				CellCommons.Modifier.Stamina:
					stam += float(mod._value)
				CellCommons.Modifier.Health:
					heal += float(mod._value)
				_:
					pass
	if atk != 0.0:
		parts.append("ATK %.0f" % atk)
	if heal != 0.0:
		parts.append("Hồi %.0f" % heal)
	if mana != 0.0:
		parts.append("LP %.0f" % mana)
	if stam != 0.0:
		parts.append("TL %.0f" % stam)
	if cell.cooldownTime > 0.0:
		parts.append("CD %.1fs" % cell.cooldownTime)
	if cell.castTime > 0.0:
		parts.append("Cast %.1fs" % cell.castTime)
	if cell.skillRange > 0:
		parts.append("Tầm %d" % cell.skillRange)
	return " · ".join(parts)
