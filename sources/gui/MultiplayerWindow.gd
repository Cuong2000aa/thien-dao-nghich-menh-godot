extends WindowPanel
class_name MultiplayerWindow

## ==============================================================================
## TDNM — BUILD 11: MULTIPLAYER CO-OP WINDOW (ĐẠO LỮ ĐỒNG HÀNH)
## Supports Mode Selection (Offline / Host / Join), Room Member List,
## Connection Status, and Vietnamese Xianxia Localization.
## ==============================================================================

var tabContainer : TabContainer = null

# Tab 1: Sảnh Kết Nối
var tabLobby : VBoxContainer = null
var lblStatus : Label = null
var btnOffline : Button = null
var spinPortHost : SpinBox = null
var spinMaxPlayers : SpinBox = null
var btnHost : Button = null
var lineEditJoinIP : LineEdit = null
var spinPortJoin : SpinBox = null
var btnJoin : Button = null

# Tab 2: Danh Sách Đồng Đạo
var tabMembers : VBoxContainer = null
var membersListContainer : VBoxContainer = null
var lblRoomTitle : Label = null
var btnLeave : Button = null

func _init():
	name = "MultiplayerWindow"
	custom_minimum_size = Vector2(460, 420)
	size = Vector2(480, 440)
	floating = true
	draggable = true
	visible = false

func _ready():
	_BuildUI()
	# BUILD 12 — restrained jade/gold accents (keep SoM layout)
	var ThemeClass = preload("res://sources/gui/XianxiaUiTheme.gd")
	ThemeClass.AttachJadeFrame(self)
	if lblStatus:
		ThemeClass.AccentLabel(lblStatus, true)
	if btnHost:
		ThemeClass.AccentButton(btnHost)
	if btnJoin:
		ThemeClass.AccentButton(btnJoin)
	if btnOffline:
		ThemeClass.AccentButton(btnOffline)
	if btnLeave:
		ThemeClass.AccentButton(btnLeave)
	SessionManager.AddListener(_OnSessionUpdated)
	Refresh()

func _exit_tree():
	SessionManager.RemoveListener(_OnSessionUpdated)

func _BuildUI():
	# Root margin & container
	var margin = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_top", 32)
	margin.add_theme_constant_override("margin_bottom", 12)
	add_child(margin)

	tabContainer = TabContainer.new()
	tabContainer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tabContainer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	margin.add_child(tabContainer)

	# --------------------------------------------------------------------------
	# TAB 1: SẢNH KẾT NỐI
	# --------------------------------------------------------------------------
	tabLobby = VBoxContainer.new()
	tabLobby.name = "Sảnh Kết Nối"
	tabLobby.add_theme_constant_override("separation", 10)
	tabContainer.add_child(tabLobby)

	# Status Banner
	lblStatus = Label.new()
	lblStatus.text = "Trạng thái: [Độc Bộ Tu Chân — Chơi Đơn]"
	lblStatus.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tabLobby.add_child(lblStatus)

	var sep1 = HSeparator.new()
	tabLobby.add_child(sep1)

	# 1. Chơi đơn button
	btnOffline = Button.new()
	btnOffline.text = "• Độc Bộ Tu Chân (Offline Single-Player)"
	btnOffline.pressed.connect(_OnOfflinePressed)
	tabLobby.add_child(btnOffline)

	# 2. Khai Mở Tiên Cảnh (Tạo Phòng / Host)
	var grpHost = VBoxContainer.new()
	grpHost.add_theme_constant_override("separation", 4)
	var lblHostTitle = Label.new()
	lblHostTitle.text = "⚡ Khai Mở Tiên Cảnh (Tạo Phòng Host — 2-3 Người):"
	grpHost.add_child(lblHostTitle)

	var hBoxHost = HBoxContainer.new()
	hBoxHost.add_theme_constant_override("separation", 8)
	var lblPortH = Label.new()
	lblPortH.text = "Cổng (Port):"
	hBoxHost.add_child(lblPortH)
	spinPortHost = SpinBox.new()
	spinPortHost.min_value = 1024
	spinPortHost.max_value = 65535
	spinPortHost.value = 7777
	hBoxHost.add_child(spinPortHost)

	var lblMaxP = Label.new()
	lblMaxP.text = "Tối đa:"
	hBoxHost.add_child(lblMaxP)
	spinMaxPlayers = SpinBox.new()
	spinMaxPlayers.min_value = 2
	spinMaxPlayers.max_value = 4
	spinMaxPlayers.value = 3
	hBoxHost.add_child(spinMaxPlayers)
	grpHost.add_child(hBoxHost)

	btnHost = Button.new()
	btnHost.text = "Khai Mở Phòng Tiên Cảnh"
	btnHost.pressed.connect(_OnHostPressed)
	grpHost.add_child(btnHost)
	tabLobby.add_child(grpHost)

	var sep2 = HSeparator.new()
	tabLobby.add_child(sep2)

	# 3. Cảm Ứng Tọa Độ (Tham Gia Phòng / Join)
	var grpJoin = VBoxContainer.new()
	grpJoin.add_theme_constant_override("separation", 4)
	var lblJoinTitle = Label.new()
	lblJoinTitle.text = "🌐 Cảm Ứng Tọa Độ (Gia Nhập Tiên Vực Của Đạo Hữu):"
	grpJoin.add_child(lblJoinTitle)

	var hBoxJoin = HBoxContainer.new()
	hBoxJoin.add_theme_constant_override("separation", 8)
	var lblIP = Label.new()
	lblIP.text = "Địa Chỉ IP:"
	hBoxJoin.add_child(lblIP)
	lineEditJoinIP = LineEdit.new()
	lineEditJoinIP.text = "127.0.0.1"
	lineEditJoinIP.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hBoxJoin.add_child(lineEditJoinIP)

	var lblPortJ = Label.new()
	lblPortJ.text = "Cổng:"
	hBoxJoin.add_child(lblPortJ)
	spinPortJoin = SpinBox.new()
	spinPortJoin.min_value = 1024
	spinPortJoin.max_value = 65535
	spinPortJoin.value = 7777
	hBoxJoin.add_child(spinPortJoin)
	grpJoin.add_child(hBoxJoin)

	btnJoin = Button.new()
	btnJoin.text = "Liên Kết Gia Nhập Tiên Cảnh"
	btnJoin.pressed.connect(_OnJoinPressed)
	grpJoin.add_child(btnJoin)
	tabLobby.add_child(grpJoin)

	# --------------------------------------------------------------------------
	# TAB 2: DANH SÁCH ĐỒNG ĐẠO
	# --------------------------------------------------------------------------
	tabMembers = VBoxContainer.new()
	tabMembers.name = "Đồng Đạo Trong Phòng"
	tabMembers.add_theme_constant_override("separation", 8)
	tabContainer.add_child(tabMembers)

	lblRoomTitle = Label.new()
	lblRoomTitle.text = "Tiên Cảnh Đồng Tu (0 Đạo Lữ)"
	lblRoomTitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tabMembers.add_child(lblRoomTitle)

	var scroll = ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	tabMembers.add_child(scroll)

	membersListContainer = VBoxContainer.new()
	membersListContainer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	membersListContainer.add_theme_constant_override("separation", 6)
	scroll.add_child(membersListContainer)

	btnLeave = Button.new()
	btnLeave.text = "Rời Khỏi Tiên Vực (Leave Room)"
	btnLeave.pressed.connect(_OnLeavePressed)
	tabMembers.add_child(btnLeave)

func Refresh():
	# Update Status Banner
	match SessionManager.currentState:
		SessionManager.SessionState.CONNECTION_FAILED:
			lblStatus.text = "Trạng thái: [Thất Bại — Không Cảm Ứng Được Chủ Phòng]"
			btnLeave.disabled = true
		SessionManager.SessionState.HOST_DISCONNECTED:
			lblStatus.text = "Trạng thái: [Chủ Phòng Đã Ngắt — Đã Về Offline]"
			btnLeave.disabled = true
		_:
			match SessionManager.currentMode:
				SessionManager.Mode.OFFLINE:
					lblStatus.text = "Trạng thái: [Độc Bộ Tu Chân — Chơi Đơn]"
					btnLeave.disabled = true
				SessionManager.Mode.HOST:
					lblStatus.text = "Trạng thái: [Chủ Phòng — Đang Khai Mở Cổng %d]" % SessionManager.listenPort
					btnLeave.disabled = false
				SessionManager.Mode.CLIENT:
					lblStatus.text = "Trạng thái: [Đạo Lữ — Kết Nối Tới %s:%d]" % [SessionManager.targetHost, SessionManager.targetPort]
					btnLeave.disabled = false

	# Update Member List
	for child in membersListContainer.get_children():
		child.queue_free()

	var members = SessionManager.GetMembers()
	lblRoomTitle.text = "Tiên Cảnh Đồng Tu (%d Đạo Lữ)" % members.size()

	if members.is_empty():
		var emptyLbl = Label.new()
		emptyLbl.text = "(Chưa có đạo hữu nào gia nhập phòng)"
		emptyLbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		membersListContainer.add_child(emptyLbl)
	else:
		for m in members:
			var card = _CreateMemberCard(m)
			membersListContainer.add_child(card)

func _CreateMemberCard(memberData : Dictionary) -> PanelContainer:
	var panel = PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_top", 6)
	margin.add_theme_constant_override("margin_bottom", 6)
	panel.add_child(margin)

	var hBox = HBoxContainer.new()
	hBox.add_theme_constant_override("separation", 12)
	margin.add_child(hBox)

	var roleBadge = "[Chủ Phòng]" if memberData.get("isHost", false) else "[Đạo Lữ]"
	var lblInfo = Label.new()
	lblInfo.text = "%s %s • Cảnh giới: %s (Cấp %d) • Khí Huyết: %d/%d" % [
		roleBadge,
		memberData.get("nick", "Đạo Hữu"),
		memberData.get("realm", "Phàm Thân"),
		memberData.get("level", 1),
		memberData.get("hp", 100),
		memberData.get("maxHp", 100)
	]
	lblInfo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hBox.add_child(lblInfo)

	return panel

func _OnOfflinePressed():
	SessionManager.LeaveRoom()
	SessionManager.ApplyNetworkTopology()
	Refresh()
	if Launcher.GUI:
		Network.PushNotification("Đã chuyển về trạng thái Độc Bộ Tu Chân.")

func _OnHostPressed():
	var port = int(spinPortHost.value)
	var maxP = int(spinMaxPlayers.value)
	var res = SessionManager.CreateHostRoom(port, maxP)
	# Must restart Network AFTER SessionManager.isHosting is set so ENet binds listenPort
	var topologyOk : bool = SessionManager.ApplyNetworkTopology()
	Refresh()
	tabContainer.current_tab = 1 # Switch to members tab
	if Launcher.GUI:
		if topologyOk:
			Network.PushNotification(res["message"])
		else:
			Network.PushNotification("Không thể khai mở cổng Tiên Cảnh. Kiểm tra cổng %d." % port)

func _OnJoinPressed():
	var ip = lineEditJoinIP.text.strip_edges()
	var port = int(spinPortJoin.value)
	if ip.is_empty():
		if Launcher.GUI:
			Network.PushNotification("Cần nhập địa chỉ IP của Chủ Phòng.")
		return
	var res = SessionManager.JoinHostRoom(ip, port)
	# Client-only Mode connects to SessionManager.targetHost:targetPort
	var topologyOk : bool = SessionManager.ApplyNetworkTopology()
	Refresh()
	tabContainer.current_tab = 1
	if Launcher.GUI:
		if topologyOk:
			Network.PushNotification(res["message"])
		else:
			Network.PushNotification("Không thể kết nối tới %s:%d." % [ip, port])

func _OnLeavePressed():
	var res = SessionManager.LeaveRoom()
	SessionManager.ApplyNetworkTopology()
	Refresh()
	tabContainer.current_tab = 0
	if Launcher.GUI:
		Network.PushNotification(res["message"])

func _OnSessionUpdated():
	Refresh()
