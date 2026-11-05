extends NpcScript

# Behaviour
const ThresholdHandValue : int			= 17

# Card utilities
static var RANKS : PackedStringArray	= ["A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"]
static var SUITS : PackedStringArray	= [
	"[outline_size=2][outline_color=white][color=#635994]♠[/color][/outline_color][/outline_size]",
	"[outline_size=2][outline_color=white][color=#f8312f]♥[/color][/outline_color][/outline_size]",
	"[outline_size=2][outline_color=white][color=#f8312f]♦[/color][/outline_color][/outline_size]",
	"[outline_size=2][outline_color=white][color=#635994]♣[/color][/outline_color][/outline_size]"
]

# Game state
var deck : Array						= []
var playerHand : Array					= []
var dealerHand : Array					= []

# Helper
static func _CardName(card : int) -> String:
	return "%s %s" % [RANKS[card % 13], SUITS[floori(card / 13.0)]]

static func _CardValue(card : int) -> int:
	var rank : int = card % 13
	if rank == 0: return 11
	if rank >= 10: return 10
	return rank + 1

static func _HandValue(hand : Array) -> int:
	var value : int = 0
	var aces : int = 0
	for card : int in hand:
		value += _CardValue(card)
		if card % 13 == 0:
			aces += 1
	while value > 21 and aces > 0:
		value -= 10
		aces -= 1
	return value

static func _HandStr(hand : Array) -> String:
	var parts : PackedStringArray = []
	for card : int in hand:
		parts.append(_CardName(card))
	return ", ".join(parts) + " (%d)" % _HandValue(hand)

static func _NewDeck() -> Array:
	var d : Array = []
	d.resize(52)
	for i : int in range(52):
		d[i] = i
	d.shuffle()
	return d

# General flow
func OnStart():
	Mes("Hoan nghênh! Đạo hữu đến chơi bài?")
	Mes("Biết blackjack không? Ta là người nghĩ ra trò đó!")
	Mes("Ngồi xuống. Cho ta xem tay đạo hữu. Bài đang chờ.")
	DisplayChoices()

func DisplayChoices():
	Choice("Thách Hyland", StartDealer)
	Choice("Tìm đối thủ xứng tầm", StartPvP)
	Choice("Luật chơi", ShowRules)
	Choice("Hôm nay thôi", Decline)

func ShowRules():
	Mes("Luật đơn giản. Ta biết — ta đặt ra mà!")
	Mes("Gần 21 nhất mà không vượt.")
	Mes("Bài số theo mặt, J Q K là 10, Át... Át khó. 1 hoặc 11, tùy đạo hữu.")
	Mes("Thắng ta, ta gật mũ. Quá 21 là bust. Vậy thôi.")
	Mes("Lính canh cũng học được — nói lên tầm dễ.")
	DisplayChoices()

func Decline():
	Chat("Muốn chơi cứ tìm ta.")

func OnQuit():
	if npc and npc.ownScript:
		npc.ownScript.call("LeavePvP", own)
	super.OnQuit()

# Player vs Dealer Mode
func StartDealer():
	deck = _NewDeck()
	playerHand = [deck.pop_back(), deck.pop_back()]
	dealerHand = [deck.pop_back(), deck.pop_back()]
	_DealerTurn()

func _DealerTurn():
	if _HandValue(playerHand) == 21:
		_DealerReveal()
	else:
		Mes("Bài đạo hữu: %s" % _HandStr(playerHand))
		Mes("Ta lật: %s." % _CardName(dealerHand[0]))
		Choice("Rút", _DealerHit)
		Choice("Dừng", _DealerReveal)

func _DealerHit():
	playerHand.append(deck.pop_back())
	var value : int = _HandValue(playerHand)
	if value > 21:
		Mes("Bài đạo hữu: %s" % _HandStr(playerHand))
		Mes("Ồ hò, bust! Tham lam vậy đó. Ta thấy nghìn lần rồi.")
		Choice("Chơi lại", StartDealer)
		Choice("Rời bàn", Decline)
	elif value == 21:
		_DealerReveal()
	else:
		_DealerTurn()

func _DealerReveal():
	while _HandValue(dealerHand) < ThresholdHandValue:
		dealerHand.append(deck.pop_back())
	var pv : int = _HandValue(playerHand)
	var dv : int = _HandValue(dealerHand)
	Mes("Bài đạo hữu: %s" % _HandStr(playerHand))
	Mes("Bài ta: %s" % _HandStr(dealerHand))
	if dv > 21:
		Mes("Bah! Kể cả cao thủ cũng vượt đôi khi. Hay lắm.")
	elif pv > dv:
		Mes("Heh... Không tệ.")
	elif dv > pv:
		Mes("Kinh nghiệm thắng lại. Đừng buồn — đa số thua ta.")
	else:
		Mes("Hòa %d! Gan dạ đấy." % pv)
	Choice("Chơi lại", StartDealer)
	Choice("Rời bàn", Decline)

# Player vs Player Mode
func StartPvP():
	var result : int = npc.ownScript.call("JoinPvP", own)
	if result == 0:
		Mes("Được, xem ai đủ gan. Chờ chút.")
		Choice("Kiểm tra", _PvPCheck)
		Choice("Hủy", _PvPCancel)
	else:
		_PvPBegin()

func _PvPCheck():
	var game : Dictionary = npc.ownScript.call("GetGame", own)
	if game.is_empty():
		Mes("Kiên nhẫn... Tay bài giỏi biết chờ.")
		Choice("Kiểm tra", _PvPCheck)
		Choice("Hủy", _PvPCancel)
	elif game.has("result"):
		_PvPShowResult(game)
	else:
		_PvPBegin()

func _PvPCancel():
	npc.ownScript.call("LeavePvP", own)
	Chat("Không chơi? Tiếc. Biết đâu đạo hữu đổi ý.")
func _PvPBegin():
	playerHand = npc.ownScript.call("GetHand", own)
	Mes("Ha! Có trận! Xem hai người ra sao.")
	_PvPTurn()

func _PvPTurn():
	Mes("Bài đạo hữu: %s" % _HandStr(playerHand))
	if _HandValue(playerHand) == 21:
		Mes("Xì dách!")
		_PvPStand()
	else:
		Choice("Rút", _PvPHit)
		Choice("Dừng", _PvPStand)

func _PvPHit():
	var card : int = npc.ownScript.call("DrawCard", own)
	if card < 0:
		_PvPStand()
		return
	playerHand.append(card)
	var value : int = _HandValue(playerHand)
	if value > 21:
		Mes("Bài đạo hữu: %s" % _HandStr(playerHand))
		Mes("Quắc! Lẽ ra nghe linh cảm.")
		npc.ownScript.call("FinishHand", own, value, true)
		_PvPWait()
	elif value == 21:
		Mes("Bài đạo hữu: %s" % _HandStr(playerHand))
		_PvPStand()
	else:
		_PvPTurn()

func _PvPStand():
	npc.ownScript.call("FinishHand", own, _HandValue(playerHand), false)
	_PvPWait()

func _PvPWait():
	var game : Dictionary = npc.ownScript.call("GetGame", own)
	if game.has("result"):
		_PvPShowResult(game)
	else:
		Mes("Phần đạo hữu xong. Chờ đối thủ...")
		Choice("Kiểm tra", _PvPWaitCheck)
		Choice("Bỏ cuộc", _PvPForfeit)

func _PvPWaitCheck():
	var game : Dictionary = npc.ownScript.call("GetGame", own)
	if game.has("result"):
		_PvPShowResult(game)
	else:
		Mes("Vẫn suy nghĩ... Tay giỏi không vội!")
		Choice("Kiểm tra", _PvPWaitCheck)
		Choice("Bỏ cuộc", _PvPForfeit)

func _PvPShowResult(game : Dictionary):
	var isP1 : bool = game.get("p1") == own
	var myVal : int = game.get("p1Value") if isP1 else game.get("p2Value")
	var oppBust : bool = game.get("p2Busted") if isP1 else game.get("p1Busted")
	var oppHand : Array = game.get("p2Hand") if isP1 else game.get("p1Hand")
	var myBust : bool = game.get("p1Busted") if isP1 else game.get("p2Busted")
	Mes("Điểm đạo hữu: %d%s" % [myVal, " (Quắc)" if myBust else ""])
	Mes("Bài đối thủ: %s%s" % [_HandStr(oppHand), " (Quắc)" if oppBust else ""])
	var result : String = game.get("result", "")
	if result == "draw":
		Mes("Hòa! Ngang tài. Hiếm ở bàn ta.")
	elif (result == "p1" and isP1) or (result == "p2" and not isP1):
		Mes("Thắng! Hay lắm — bài nghiêng về đạo hữu hôm nay.")
	else:
		Mes("Tiếc. Bài hay đổi ý — nhưng luôn quay lại.")
	npc.ownScript.call("CleanupGame", own)
	Choice("Chơi lại", StartPvP)
	Choice("Rời bàn", Decline)

func _PvPForfeit():
	npc.ownScript.call("ForfeitPvP", own)
	Mes("Bỏ giữa ván? Hồi ta, mất một vòng rượu đấy.")
	Choice("Chơi lại", StartPvP)
	Choice("Rời bàn", Decline)
