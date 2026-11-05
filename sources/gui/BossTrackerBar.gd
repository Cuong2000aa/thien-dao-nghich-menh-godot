extends TrackerBar

#
var currentBossRID : int = DB.UnknownHash
var previousHealth : int = -1
var ghostBar : TextureProgressBar = null
var ghostTween : Tween = null

func _ready():
	_SetupGhostBar()
	var ThemeClass = preload("res://sources/gui/XianxiaUiTheme.gd")
	if label:
		ThemeClass.AccentLabel(label, true)

func _SetupGhostBar():
	if ghostBar or not bar:
		return
	var mainBar = bar.get_node_or_null("Bar")
	if mainBar and mainBar is TextureProgressBar:
		ghostBar = mainBar.duplicate()
		ghostBar.name = "GhostBar"
		ghostBar.modulate = Color(1.0, 0.8, 0.25, 0.85)
		bar.add_child(ghostBar)
		bar.move_child(ghostBar, mainBar.get_index())

# Accessors
func OnStatsUpdated(agentRID : int):
	var entity : Entity = Entities.Get(agentRID)
	if not entity or not is_instance_valid(entity):
		return

	if not entity.data or not entity.data._isBoss:
		return

	if currentBossRID == DB.UnknownHash:
		if entity.stat.health > 0:
			ConnectBoss(entity)
		else:
			return
	elif currentBossRID == agentRID:
		pass
	elif Entities.target and agentRID == Entities.target.agentRID and entity.stat.health > 0:
		if currentBossRID != agentRID:
			DisconnectBoss(currentBossRID)
			ConnectBoss(entity)
	else:
		return

	if entity.stat.health <= 0:
		OnHide(agentRID)
	else:
		_SetupGhostBar()
		var currentHp = entity.stat.health
		var maxHp = entity.stat.current.maxHealth
		
		# Animate ghost damage trailing bar
		if previousHealth > 0 and currentHp < previousHealth and ghostBar and maxHp > 0:
			if ghostTween:
				ghostTween.kill()
			ghostTween = create_tween()
			ghostTween.tween_interval(0.25)
			ghostTween.tween_property(ghostBar, "value", (float(currentHp) / float(maxHp)) * 100.0, 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		elif ghostBar and maxHp > 0:
			ghostBar.value = (float(currentHp) / float(maxHp)) * 100.0
			
		previousHealth = currentHp
		bar.SetStat(currentHp, maxHp)

func OnHide(agentRID : int):
	if currentBossRID != agentRID:
		return
	DisconnectBoss(agentRID)
	previousHealth = -1
	Clear()

# Boss handling
func ConnectBoss(entity : Entity):
	if currentBossRID != DB.UnknownHash and currentBossRID != entity.agentRID:
		DisconnectBoss(currentBossRID)
	currentBossRID = entity.agentRID
	previousHealth = entity.stat.health
	_SetupGhostBar()
	if ghostBar and entity.stat.current.maxHealth > 0:
		ghostBar.value = (float(entity.stat.health) / float(entity.stat.current.maxHealth)) * 100.0
	var callable : Callable = OnHide.bind(currentBossRID)
	if not entity.tree_exiting.is_connected(callable):
		entity.tree_exiting.connect(callable, CONNECT_ONE_SHOT)
	Display(entity.nick, entity.stat.health, entity.stat.current.maxHealth)

func DisconnectBoss(agentRID : int):
	if currentBossRID != agentRID:
		return

	var entity : Entity = Entities.Get(agentRID)
	if entity and is_instance_valid(entity):
		var callable : Callable = OnHide.bind(agentRID)
		if entity.tree_exiting.is_connected(callable):
			entity.tree_exiting.disconnect(callable)

	currentBossRID = DB.UnknownHash
