extends "res://sources/scripts/xianxia/GatheringNode.gd"
class_name OreGatheringNode

func _init(_npc : NpcAgent = null, _own : BaseAgent = null):
	super(_npc, _own)
	itemName = "Huyen Thiet Khoang"
	itemDisplayName = "Huyền Thiết Khoáng"
	expReward = 20
	respawnCooldown = 15.0
