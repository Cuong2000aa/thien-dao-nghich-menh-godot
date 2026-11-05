extends NpcScript
class_name BiCanhPortal

const DUNGEON_MAP_ID : int = 4111682275 # Candor Arena (Linh Khí Bí Cảnh)
const DUNGEON_SPAWN_POS : Vector2 = Vector2(2032, 752)

func OnAreaEnter(player : PlayerAgent):
	if player and not player.ownScript and not player.isWarping:
		TryEnterDungeon(player)

func OnStart():
	if not IsPlayer():
		return
	Mes("Trước mặt đạo hữu là Cổng Bí Cảnh cổ xưa, linh khí ngút trời xoay tròn tạo thành một vòng xoáy không gian huyền ảo.")
	Choice("Tiến nhập Linh Khí Bí Cảnh", TryEnterDungeon.bind(own))
	Choice("Rời đi")

func TryEnterDungeon(player : PlayerAgent):
	if not player or not is_instance_valid(player):
		return
	var level : int = player.stat.level if player.stat else 1
	var bossQ : int = player.progress.GetQuest(ProgressCommons.Quest.THAO_PHAT_THU_VUONG)
	
	if level >= 2 or bossQ >= ProgressCommons.THAO_PHAT_THU_VUONG.STARTED:
		NpcCommons.PushNotification(player, "Không gian chuyển dời... Đang tiến nhập Linh Khí Bí Cảnh!")
		NpcCommons.Warp(player, DUNGEON_MAP_ID, DUNGEON_SPAWN_POS, ActorCommons.Direction.DOWN)
	else:
		NpcCommons.PushNotification(player, "Cấm chế phong ấn chưa khai mở! Cần tu vi Tụ Khí Tầng 1 (Cấp 2) mới có thể vào.")
