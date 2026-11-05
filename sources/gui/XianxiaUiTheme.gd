extends RefCounted
class_name XianxiaUiTheme

## TDNM — BUILD 12/13: Shared Xianxia UI design system
## Jade / bronze / gold / ngũ hành — restrained, readable Vietnamese UI.
## Apply on top of SoM WindowPanel layouts; do not fork per-window themes.

const JADE := Color(0.45, 0.78, 0.62, 1.0)
const JADE_DIM := Color(0.28, 0.52, 0.42, 1.0)
const BRONZE := Color(0.72, 0.55, 0.28, 1.0)
const GOLD_SOFT := Color(0.86, 0.74, 0.42, 1.0)
const INK := Color(0.12, 0.14, 0.16, 1.0)
const PAPER := Color(0.93, 0.90, 0.82, 1.0)
const WOOD := Color(0.22, 0.16, 0.12, 0.92)
const DANGER := Color(0.95, 0.28, 0.22, 1.0)
const WARN := Color(1.0, 0.72, 0.28, 1.0)

## Ngũ Hành accent
const ELEMENT := {
	0: Color(0.92, 0.92, 0.92),
	1: Color(1.0, 0.90, 0.25),   # Kim
	2: Color(0.30, 0.90, 0.40),   # Mộc
	3: Color(0.30, 0.75, 1.0),    # Thủy
	4: Color(1.0, 0.40, 0.18),    # Hỏa
	5: Color(0.88, 0.65, 0.30),   # Thổ
}

## Phẩm chất (derived from buyPrice — no schema change)
enum Rarity { PHAM = 0, LINH = 1, BAO = 2, TIEN = 3 }
const RARITY_NAME := {
	Rarity.PHAM: "Phàm Phẩm",
	Rarity.LINH: "Linh Phẩm",
	Rarity.BAO: "Bảo Phẩm",
	Rarity.TIEN: "Tiên Phẩm",
}
const RARITY_COLOR := {
	Rarity.PHAM: Color(0.78, 0.78, 0.78),
	Rarity.LINH: Color(0.35, 0.85, 0.55),
	Rarity.BAO: Color(0.40, 0.70, 1.0),
	Rarity.TIEN: Color(1.0, 0.78, 0.28),
}

static func InferRarity(buyPrice : int) -> int:
	if buyPrice >= 2000:
		return Rarity.TIEN
	if buyPrice >= 500:
		return Rarity.BAO
	if buyPrice >= 100:
		return Rarity.LINH
	return Rarity.PHAM

static func RarityBb(buyPrice : int) -> String:
	var r : int = InferRarity(buyPrice)
	var c : Color = RARITY_COLOR[r]
	return "[color=#%s][%s][/color]" % [c.to_html(false), RARITY_NAME[r]]

static func AccentLabel(lbl : Label, gold : bool = false) -> void:
	if lbl == null:
		return
	lbl.add_theme_color_override("font_color", GOLD_SOFT if gold else JADE)
	lbl.add_theme_color_override("font_outline_color", INK)
	lbl.add_theme_constant_override("outline_size", 2)

static func AccentRichText(rtl : RichTextLabel) -> void:
	if rtl == null:
		return
	rtl.add_theme_color_override("default_color", PAPER)

static func AccentButton(btn : Button) -> void:
	if btn == null:
		return
	btn.add_theme_color_override("font_color", PAPER)
	btn.add_theme_color_override("font_hover_color", GOLD_SOFT)
	btn.add_theme_color_override("font_pressed_color", JADE)
	btn.add_theme_color_override("font_disabled_color", Color(0.55, 0.55, 0.55))

static func AccentSeparator(sep : HSeparator) -> void:
	if sep == null:
		return
	sep.add_theme_color_override("separator_color", Color(BRONZE.r, BRONZE.g, BRONZE.b, 0.55))

static func AttachJadeFrame(host : Control) -> ColorRect:
	if host == null:
		return null
	var existing = host.get_node_or_null("XianxiaJadeWash")
	if existing:
		return existing as ColorRect
	var wash := ColorRect.new()
	wash.name = "XianxiaJadeWash"
	wash.color = Color(JADE_DIM.r, JADE_DIM.g, JADE_DIM.b, 0.12)
	wash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	wash.set_anchors_preset(Control.PRESET_FULL_RECT)
	host.add_child(wash)
	host.move_child(wash, 0)
	return wash

## Soft bronze edge line under title areas
static func AttachHeaderRule(host : Control, y : float = 28.0) -> ColorRect:
	if host == null:
		return null
	var existing = host.get_node_or_null("XianxiaHeaderRule")
	if existing:
		return existing as ColorRect
	var rule := ColorRect.new()
	rule.name = "XianxiaHeaderRule"
	rule.color = Color(BRONZE.r, BRONZE.g, BRONZE.b, 0.55)
	rule.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rule.position = Vector2(8, y)
	rule.size = Vector2(maxf(host.size.x - 16.0, 120.0), 1.5)
	host.add_child(rule)
	return rule

## Walk common interactive children and apply accents
static func PolishWindow(host : Control) -> void:
	if host == null:
		return
	AttachJadeFrame(host)
	_PolishRecursive(host, 0)

static func _PolishRecursive(node : Node, depth : int) -> void:
	if depth > 6:
		return
	if node is Button:
		AccentButton(node)
	elif node is Label and depth <= 3:
		# Only light-touch top labels; avoid recoloring every grid cell
		pass
	elif node is HSeparator:
		AccentSeparator(node)
	for child in node.get_children():
		_PolishRecursive(child, depth + 1)

static func TintProgressLowHp(barHost : Control, ratio : float) -> void:
	if barHost == null:
		return
	var label = barHost.get_node_or_null("Label")
	if label is Label:
		if ratio <= 0.25:
			label.add_theme_color_override("font_color", DANGER)
		elif ratio <= 0.45:
			label.add_theme_color_override("font_color", WARN)
		# else leave default SoM color

## NPC dialogue hierarchy accents (title inferred from display name keywords)
static func NpcTitleColor(npcName : String) -> Color:
	var n : String = npcName.to_lower()
	if "trưởng lão" in n or "tông chủ" in n or "chưởng môn" in n:
		return GOLD_SOFT
	if "chấp sự" in n or "trưởng" in n or "sư" in n:
		return JADE
	if "thương" in n or "điếm" in n:
		return BRONZE
	return PAPER

static func NpcTitleTag(npcName : String) -> String:
	var n : String = npcName.to_lower()
	if "trưởng lão" in n or "tông chủ" in n or "chưởng môn" in n:
		return "【Cao Thủ】 "
	if "chấp sự" in n or "trưởng" in n:
		return "【Chức Sự】 "
	if "thương" in n or "điếm" in n:
		return "【Thương Nhân】 "
	return "【Đồng Đạo】 "
