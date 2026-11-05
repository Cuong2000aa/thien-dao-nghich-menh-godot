extends RefCounted
class_name SessionManager

## ==============================================================================
## TDNM — BUILD 11: HYBRID MULTIPLAYER SESSION MANAGER
## Manages Room Creation (Host), Room Joining (Client), Offline Fallback,
## Member Tracking, Lifecycle Events, Failure Handling, and Co-op Authority.
## ==============================================================================

enum Mode {
	OFFLINE = 0,         # Độc Bộ Tu Chân (Chơi đơn offline mặc định)
	HOST = 1,            # Khai Mở Tiên Cảnh (Chủ phòng - Host)
	CLIENT = 2,          # Cảm Ứng Tọa Độ (Đạo lữ gia nhập - Remote Client)
	DEDICATED_SERVER = 3 # Máy Chủ Độc Lập (Dedicated Server Ready)
}

enum SessionState {
	DISCONNECTED = 0,
	HOSTING = 1,
	CONNECTING = 2,
	IN_LOBBY = 3,
	IN_GAME = 4,
	CONNECTION_FAILED = 5,
	HOST_DISCONNECTED = 6
}

# Session Configuration
static var currentMode : Mode = Mode.OFFLINE
static var currentState : SessionState = SessionState.DISCONNECTED

static var isHosting : bool = false
static var isClientSession : bool = false

static var listenPort : int = 7777
static var maxPlayers : int = 3
static var roomName : String = "Tiên Cảnh Trúc Sơn"

static var targetHost : String = "127.0.0.1"
static var targetPort : int = 7777

# Active Members in Room: Dictionary[peerID, MemberData]
# MemberData: { "peerID": int, "nick": String, "realm": String, "level": int, "hp": int, "maxHp": int, "isHost": bool, "mapId": int, "ping": int }
static var sessionMembers : Dictionary = {}

# Signals / Callbacks through internal static call or node bridge
# (Using static Callable dictionaries for cross-engine reactivity without singleton requirement)
static var listeners : Array[Callable] = []

# Rate limiting for combat requests: Dictionary[peerID_actionKey, timestamp_msec]
static var attackRequestTimestamps : Dictionary = {}
const COMBAT_REQUEST_DEBOUNCE_MS : int = 120 # Chống spam duplicate attack request trong 120ms

# ==============================================================================
# 1. SESSION LIFECYCLE (HOST / JOIN / LEAVE)
# ==============================================================================

## Tạo phòng Host (Khai Mở Tiên Cảnh)
static func CreateHostRoom(port : int = 7777, roomMax : int = 3, name : String = "Tiên Cảnh Trúc Sơn") -> Dictionary:
	listenPort = port
	maxPlayers = clampi(roomMax, 2, 4)
	roomName = name
	
	isHosting = true
	isClientSession = false
	currentMode = Mode.HOST
	currentState = SessionState.HOSTING
	sessionMembers.clear()
	attackRequestTimestamps.clear()
	
	# Register Host (Peer 1) as room owner
	var hostNick = "Đạo Chủ"
	if Launcher.Player:
		hostNick = Launcher.Player.nick
	elif Launcher.GUI and Launcher.GUI.characterPanel and Launcher.GUI.characterPanel.characterNameDisplay:
		var txt = Launcher.GUI.characterPanel.characterNameDisplay.get_text()
		if not txt.is_empty(): hostNick = txt
		
	var hostMember = {
		"peerID": NetworkCommons.PeerAuthorityID,
		"nick": hostNick,
		"realm": "Phàm Thân • Sơ Nhập",
		"level": 1,
		"hp": 100,
		"maxHp": 100,
		"isHost": true,
		"mapId": 1841251538,
		"status": "Chủ Phòng"
	}
	sessionMembers[NetworkCommons.PeerAuthorityID] = hostMember
	_NotifySessionChanged()
	
	Util.PrintLog("SessionManager", "Khai mở phòng Tiên Cảnh thành công! Cổng: %d, Số người tối đa: %d, Chủ phòng: %s" % [listenPort, maxPlayers, hostNick])
	return {
		"success": true,
		"mode": "HOST",
		"port": listenPort,
		"maxPlayers": maxPlayers,
		"roomName": roomName,
		"message": "Khai mở Tiên Cảnh thành công! Đang lắng nghe đạo hữu gia nhập..."
	}

## Tham gia phòng (Cảm Ứng Tọa Độ - Remote Client)
static func JoinHostRoom(hostAddress : String = "127.0.0.1", port : int = 7777) -> Dictionary:
	targetHost = hostAddress.strip_edges()
	targetPort = port
	
	isHosting = false
	isClientSession = true
	currentMode = Mode.CLIENT
	currentState = SessionState.CONNECTING
	sessionMembers.clear()
	attackRequestTimestamps.clear()
	
	NetworkCommons.IsLocal = (targetHost == "127.0.0.1" or targetHost == "localhost")
	_NotifySessionChanged()
	
	Util.PrintLog("SessionManager", "Đang cảm ứng tọa độ Tiên Cảnh tại [%s:%d]..." % [targetHost, targetPort])
	return {
		"success": true,
		"mode": "CLIENT",
		"targetHost": targetHost,
		"targetPort": targetPort,
		"message": "Đang kết nối tới Tiên Vực của Đạo Hữu..."
	}

## Rời phòng (Thoái Xuất Tiên Cảnh)
static func LeaveRoom() -> Dictionary:
	var prevMode = currentMode
	
	# If Host is leaving, notify all peers and close session
	if isHosting:
		Util.PrintLog("SessionManager", "Chủ phòng đã giải tán Tiên Cảnh.")
		for pId in sessionMembers.keys():
			if pId != NetworkCommons.PeerAuthorityID and pId != NetworkCommons.PeerOfflineID:
				Network.CallClient("OnHostClosedRoom", [], pId)
				
	# If Client is leaving (still connected)
	elif isClientSession and Network.Client and Network.IsServerReachable():
		Util.PrintLog("SessionManager", "Đã rời khỏi Tiên Cảnh của Đạo Hữu.")
		Network.CallServer("OnClientLeaveRoom", [], NetworkCommons.PeerAuthorityID)
		
	ForceResetOffline()
	
	return {
		"success": true,
		"previousMode": prevMode,
		"currentMode": Mode.OFFLINE,
		"message": "Đã trở về trạng thái Độc Bộ Tu Chân (Offline Single-Player)."
	}

## Clear co-op flags without RPCs (host crash / connection lost).
static func ForceResetOffline() -> void:
	isHosting = false
	isClientSession = false
	currentMode = Mode.OFFLINE
	currentState = SessionState.DISCONNECTED
	sessionMembers.clear()
	attackRequestTimestamps.clear()
	_NotifySessionChanged()

# ==============================================================================
# 2. MEMBER TRACKING & SYNCHRONIZATION
# ==============================================================================

## Cập nhật hoặc thêm thành viên vào danh sách phòng
static func RegisterMember(peerID : int, nick : String, level : int = 1, realm : String = "Phàm Thân • Sơ Nhập", hp : int = 100, maxHp : int = 100, isHostMember : bool = false, mapId : int = 0) -> void:
	sessionMembers[peerID] = {
		"peerID": peerID,
		"nick": nick,
		"realm": realm,
		"level": level,
		"hp": hp,
		"maxHp": maxHp,
		"isHost": isHostMember,
		"mapId": mapId,
		"status": "Chủ Phòng" if isHostMember else "Đạo Lữ Đồng Hành"
	}
	currentState = SessionState.IN_GAME
	_NotifySessionChanged()
	BroadcastRoster()
	Util.PrintLog("SessionManager", "Thành viên [%s] (Peer: %d, Cảnh giới: %s) đã tham gia phòng!" % [nick, peerID, realm])

## Cập nhật trạng thái sinh mệnh / cảnh giới của thành viên
static func UpdateMemberStats(peerID : int, currentHp : int, maxHp : int, level : int = -1, realm : String = "") -> void:
	if sessionMembers.has(peerID):
		sessionMembers[peerID]["hp"] = currentHp
		sessionMembers[peerID]["maxHp"] = maxHp
		if level > 0: sessionMembers[peerID]["level"] = level
		if not realm.is_empty(): sessionMembers[peerID]["realm"] = realm
		_NotifySessionChanged()
		BroadcastRoster()

## Xóa thành viên khi ngắt kết nối (Despawn & Cleanup)
static func UnregisterMember(peerID : int) -> String:
	var memberNick = ""
	if sessionMembers.has(peerID):
		memberNick = sessionMembers[peerID].get("nick", "Đạo Hữu")
		sessionMembers.erase(peerID)
		_NotifySessionChanged()
		BroadcastRoster()
		Util.PrintLog("SessionManager", "Thành viên [%s] (Peer: %d) đã rời khỏi phòng." % [memberNick, peerID])
	return memberNick

## Host → clients: push full room roster for TeamHud / MultiplayerWindow
static func BroadcastRoster() -> void:
	if not isHosting:
		return
	if Network.ENetServer == null and Network.WebSocketServer == null:
		return
	var roster : Array = []
	for m in sessionMembers.values():
		roster.append(m.duplicate(true))
	for pId in sessionMembers.keys():
		if pId == NetworkCommons.PeerAuthorityID or pId == NetworkCommons.PeerOfflineID:
			continue
		Network.SyncSessionMembers(roster, pId)

## Client applies authoritative roster from Host
static func ApplyRoster(members : Array) -> void:
	sessionMembers.clear()
	for m in members:
		if typeof(m) != TYPE_DICTIONARY:
			continue
		var pid : int = int(m.get("peerID", 0))
		if pid == 0:
			continue
		sessionMembers[pid] = m.duplicate(true)
	if isClientSession:
		currentState = SessionState.IN_GAME
	_NotifySessionChanged()

## Lấy danh sách thành viên trong phòng
static func GetMembers() -> Array:
	return sessionMembers.values()

## Kiểm tra số lượng người chơi hiện tại trong phòng
static func GetMemberCount() -> int:
	return sessionMembers.size()

## Kiểm tra xem người chơi có đang trong session co-op không
static func IsCoopActive() -> bool:
	return (currentMode == Mode.HOST or currentMode == Mode.CLIENT) and sessionMembers.size() >= 1

## Kiểm tra người gọi có phải Host không
static func IsHost() -> bool:
	return currentMode == Mode.HOST or isHosting

## Apply SessionManager role onto Launcher/Network topology.
## Offline & Host → client+server (in-process vs listen socket via isHosting).
## Client → client-only connecting to targetHost:targetPort.
static func ApplyNetworkTopology() -> bool:
	match currentMode:
		Mode.HOST:
			return Launcher.Mode(true, true, true)
		Mode.CLIENT:
			return Launcher.Mode(true, false, true)
		_:
			# Offline-first: always restore embedded client+server in-process loop
			return Launcher.Mode(true, true, true)

# ==============================================================================
# 3. COMBAT AUTHORITY & ANTI-EXPLOIT VALIDATION
# ==============================================================================

## Xác thực tính hợp lệ của đòn tấn công Co-op trên Host/Server
## Trả về Dictionary: { "valid": bool, "reason": String }
static func ValidateCombatRequest(attacker : BaseAgent, target : BaseAgent, skill : SkillCell) -> Dictionary:
	if not attacker:
		return { "valid": false, "reason": "Người tấn công không tồn tại!" }
	if not target:
		return { "valid": false, "reason": "Mục tiêu không tồn tại!" }
		
	# 1. Trạng thái sống chết của kẻ tấn công
	if not ActorCommons.IsAlive(attacker):
		return { "valid": false, "reason": "Nhân vật đã trọng thương/tử vong, không thể xuất chiêu!" }
		
	# 2. Trạng thái sống chết của mục tiêu
	if not ActorCommons.IsAlive(target):
		return { "valid": false, "reason": "Mục tiêu đã tử vong!" }
		
	# 3. Kiểm tra Cooldown & Casting
	if SkillCommons.IsCoolingDown(attacker, skill):
		return { "valid": false, "reason": "Kỹ năng chưa hoàn tất hồi chiêu!" }
	if SkillCommons.IsCasting(attacker, skill):
		return { "valid": false, "reason": "Đang vận khí thi triển chiêu thức khác!" }
		
	# 4. Kiểm tra tầm đánh (Range Validation có dung sai an toàn)
	var maxAllowedRange : float = 120.0
	if skill and "range" in skill and skill.range > 0:
		maxAllowedRange = float(skill.range) + 60.0 # 60px network latency tolerance
	var dist = attacker.position.distance_to(target.position)
	if dist > maxAllowedRange:
		return { "valid": false, "reason": "Cự ly vượt quá tầm công kích (Khoảng cách: %.1f, Tối đa: %.1f)!" % [dist, maxAllowedRange] }
		
	# 5. Rate-limiting & Chống spam duplicate attack request
	var nowMsec = Time.get_ticks_msec()
	var requestKey = "%d_%d_%d" % [attacker.get_rid().get_id(), target.get_rid().get_id(), skill.id if skill else 0]
	if attackRequestTimestamps.has(requestKey):
		var lastTime = attackRequestTimestamps[requestKey]
		if nowMsec - lastTime < COMBAT_REQUEST_DEBOUNCE_MS:
			return { "valid": false, "reason": "Yêu cầu xuất chiêu quá dồn dập (Anti-Spam Debounce)!" }
			
	attackRequestTimestamps[requestKey] = nowMsec
	return { "valid": true, "reason": "Xác thực xuất chiêu thành công!" }

# ==============================================================================
# 4. EVENT LISTENER REGISTRATION
# ==============================================================================
static func AddListener(callback : Callable) -> void:
	if callback not in listeners:
		listeners.append(callback)

static func RemoveListener(callback : Callable) -> void:
	listeners.erase(callback)

static func _NotifySessionChanged() -> void:
	for cb in listeners:
		if cb.is_valid():
			cb.call()
