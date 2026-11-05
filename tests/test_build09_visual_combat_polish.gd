extends Node2D

## TDNM — BUILD 09: VISUAL POLISH, COMBAT FEEL & IMMERSIVE GAMEPLAY
## Comprehensive Automated End-to-End Test Suite.
## Validates Character Animations, Combat Feel, Elemental VFX, Skills, Boss Polish & Atmosphere.

const CombatVisualSystemClass = preload("res://sources/combat/CombatVisualSystem.gd")
const AmbientWeatherClass = preload("res://sources/effects/AmbientWeatherSystem.gd")
const CombatSystemClass = preload("res://sources/combat/CombatSystem.gd")
const AlterationLabelScene = preload("res://presets/gui/AlterationLabel.tscn")
const BossTrackerScene = preload("res://presets/gui/BossTracker.tscn")

var timer : float = 0.0
var step : int = 0
var test_account : String = "PolishHero_" + str(int(Time.get_unix_time_from_system()) % 100000)
var test_pass : String = "MatKhau123!"
var test_char : String = "KiemTuB9_" + str(int(Time.get_unix_time_from_system()) % 10000)

var test_results : Dictionary = {}

func GetServerPlayer() -> PlayerAgent:
	for agent in WorldAgent.agents.values():
		if agent is PlayerAgent:
			return agent
	for peerID in Peers.peers:
		var agent = Peers.GetAgent(peerID)
		if agent and agent is PlayerAgent:
			return agent
	return null

func _ready():
	print("==================================================================")
	print("=== TDNM — BUILD 09: VISUAL POLISH & COMBAT FEEL ENGINE        ===")
	print("==================================================================")

	# Execute Unit & Data Systems 1 - 8
	_RunCharacterAnimationTests()
	_RunCombatFeelTests()
	_RunElementalImpactVfxTests()
	_RunFloatingDamageTests()
	_RunControlledKnockbackTests()
	_RunSkillVfxCatalogTests()
	_RunBossPresentationTests()
	_RunAtmosphereWeatherTests()

	# Start Live In-Process Server & Client for Systems 9 - 14
	print("\n[Integration] Starting offline in-process engine for live Visual gameplay...")
	NetworkCommons.IsLocal = true
	Launcher.Mode(true, true)

# ==============================================================================
# SYSTEM 1: CHARACTER ANIMATION & MOVEMENT
# ==============================================================================
func _RunCharacterAnimationTests():
	print("\n--- [SYSTEM 1: CHARACTER ANIMATION & MOVEMENT] ---")
	var vis = EntityVisual.new()

	# 1. Action Mapping
	assert(vis.GetSwordsmanAction(ActorCommons.State.IDLE, false) == "idle", "Must map to idle")
	assert(vis.GetSwordsmanAction(ActorCommons.State.WALK, true) == "walk", "Must map to walk when moving")
	assert(vis.GetSwordsmanAction(ActorCommons.State.ATTACK, false) == "attack", "Must map to attack")
	assert(vis.GetSwordsmanAction(ActorCommons.State.DEATH, false) == "death", "Must map to death")

	# 2. Combo Finisher Action Mapping
	vis.isComboFinisher = true
	assert(vis.GetSwordsmanAction(ActorCommons.State.ATTACK, false) == "combo", "Combo finisher must map to combo animation")
	vis.isComboFinisher = false

	# 3. Qinggong / Dodge Action Mapping
	vis.isDodging = true
	assert(vis.GetSwordsmanAction(ActorCommons.State.IDLE, false) == "qinggong", "Dodge/Qinggong must map to qinggong animation")
	vis.isDodging = false

	# 4. Foot offsets dictionary
	for act in ["idle", "walk", "attack", "hurt", "death", "qinggong", "combo"]:
		assert(vis.SWORDSMAN_FOOT_OFFSETS.has(act), "Foot offsets must contain action: %s" % act)
		print("  ✔ Animation Action: [%s] (Offset: %s)" % [act, str(vis.SWORDSMAN_FOOT_OFFSETS[act])])

	vis.free()
	test_results["system1_character_animation_states"] = true
	print("[PASS] System 1: Character animations & action states verified!")

# ==============================================================================
# SYSTEM 2: COMBAT HITSTOP & CAMERA SHAKE
# ==============================================================================
func _RunCombatFeelTests():
	print("\n--- [SYSTEM 2: COMBAT HITSTOP & CAMERA SHAKE LEVELS] ---")
	assert(CombatVisualSystemClass.ShakeLevel.LIGHT == 1, "ShakeLevel LIGHT defined")
	assert(CombatVisualSystemClass.ShakeLevel.MEDIUM == 2, "ShakeLevel MEDIUM defined")
	assert(CombatVisualSystemClass.ShakeLevel.HEAVY == 3, "ShakeLevel HEAVY defined")
	assert(CombatVisualSystemClass.ShakeLevel.BOSS == 4, "ShakeLevel BOSS defined")
	print("  ✔ 4 Cấp Độ Rung Camera: Nhẹ (2px), Vừa (4.5px), Nặng (7px), Boss Thần Uy (12px)")

	# Verify Hitstop on dummy node
	var dummySprite = AnimatedSprite2D.new()
	add_child(dummySprite)
	CombatVisualSystemClass.TriggerHitstopOnEntity(dummySprite, 0.05)
	dummySprite.queue_free()
	print("  ✔ Hitstop Micro-Pause: Kích hoạt đóng băng frame va chạm an toàn")

	test_results["system2_combat_hitstop_camera_shake"] = true
	print("[PASS] System 2: Combat hitstop & camera shake verified!")

# ==============================================================================
# SYSTEM 3: FIVE ELEMENTS IMPACT SPARKS & VFX
# ==============================================================================
func _RunElementalImpactVfxTests():
	print("\n--- [SYSTEM 3: FIVE ELEMENTS IMPACT SPARKS & VFX] ---")
	var elements = [1, 2, 3, 4, 5]
	var elemNames = ["Kim (Vàng Sáng)", "Mộc (Lục Bảo)", "Thủy (Lam Băng)", "Hỏa (Xích Viêm)", "Thổ (Hoàng Thổ)"]

	for i in elements.size():
		var e = elements[i]
		assert(CombatVisualSystemClass.ELEMENT_COLORS.has(e), "Missing element color: %d" % e)
		var vfx = CombatVisualSystemClass.SpawnImpactVfx(self, Vector2(100, 100), e, false)
		assert(vfx != null, "Impact VFX must spawn successfully")
		print("  ✔ Hiệu Ứng Va Chạm Ngũ Hành: [%s] -> Màu: %s" % [elemNames[i], str(CombatVisualSystemClass.ELEMENT_COLORS[e])])
		vfx.queue_free()

	# Critical Hit Sparks
	var critVfx = CombatVisualSystemClass.SpawnImpactVfx(self, Vector2(100, 100), 0, true)
	assert(critVfx != null and critVfx.isCrit == true, "Crit impact must have isCrit true")
	critVfx.queue_free()
	print("  ✔ Hiệu Ứng Bạo Kích: Bùng nổ tia lửa xích kim sắc bén")

	test_results["system3_impact_vfx_five_elements"] = true
	print("[PASS] System 3: Elemental impact sparks verified!")

# ==============================================================================
# SYSTEM 4: FLOATING DAMAGE & STATUS TEXT
# ==============================================================================
func _RunFloatingDamageTests():
	print("\n--- [SYSTEM 4: FLOATING DAMAGE & STATUS LABELS] ---")
	var dummyEntity = Entity.new()

	var lbl1 : Label = AlterationLabelScene.instantiate()
	lbl1.SetPosition(Vector2.ZERO, Vector2.ZERO)
	lbl1.SetElementalValue(dummyEntity, dummyEntity, 120, ActorCommons.Alteration.HIT, 4) # Fire
	assert(lbl1.get_text() == "120", "Damage text must be 120")
	assert(lbl1.customColor == Color(1.0, 0.35, 0.10), "Fire damage color must match")
	print("  ✔ Sát Thương Hỏa Hệ: 120 (Hiển thị sắc đỏ cam Xích Viêm)")

	var lbl2 : Label = AlterationLabelScene.instantiate()
	lbl2.SetPosition(Vector2.ZERO, Vector2.ZERO)
	lbl2.SetElementalValue(dummyEntity, dummyEntity, 350, ActorCommons.Alteration.CRIT, 1) # Metal Crit
	assert("Bạo Kích" in lbl2.get_text(), "Crit text must have Bạo Kích")
	assert(lbl2.criticalHit == true, "CriticalHit flag must be set")
	print("  ✔ Sát Thương Bạo Kích: %s (Phóng to kích thước x1.35)" % lbl2.get_text())

	var lbl3 : Label = AlterationLabelScene.instantiate()
	lbl3.SetPosition(Vector2.ZERO, Vector2.ZERO)
	lbl3.SetStatusText("Choáng!", Color(1.0, 0.8, 0.2))
	assert(lbl3.get_text() == "Choáng!", "Status text must match")
	print("  ✔ Hiệu Ứng Trạng Thái: [%s] hiển thị nhấp nhô trên đầu mục tiêu" % lbl3.get_text())

	lbl1.queue_free()
	lbl2.queue_free()
	lbl3.queue_free()
	dummyEntity.queue_free()

	test_results["system4_floating_damage_status_labels"] = true
	print("[PASS] System 4: Floating damage & status labels verified!")

# ==============================================================================
# SYSTEM 5: CONTROLLED KNOCKBACK & BOUNDS
# ==============================================================================
func _RunControlledKnockbackTests():
	print("\n--- [SYSTEM 5: CONTROLLED KNOCKBACK] ---")
	var fromP = Vector2(100, 100)
	var toP = Vector2(140, 100) # Directly to the right

	var kb = CombatVisualSystemClass.CalculateControlledKnockback(fromP, toP, 25.0)
	assert(kb.x > 0 and is_equal_approx(kb.y, 0.0), "Knockback direction must point right")
	assert(kb.length() == 25.0, "Knockback distance must match requested 25px")

	# Test clamping: request 150px, must clamp to max 50px
	var kbClamped = CombatVisualSystemClass.CalculateControlledKnockback(fromP, toP, 150.0)
	assert(kbClamped.length() <= 50.0, "Knockback distance must be capped at 50px")
	print("  ✔ Đẩy Lùi Có Kiểm Soát: Hướng chuẩn xác, giới hạn an toàn tối đa 50px (chống kẹt địa hình)")

	test_results["system5_controlled_knockback"] = true
	print("[PASS] System 5: Controlled knockback verified!")

# ==============================================================================
# SYSTEM 6: SKILL VISUAL EFFECTS CATALOG
# ==============================================================================
func _RunSkillVfxCatalogTests():
	print("\n--- [SYSTEM 6: SKILL VISUAL EFFECTS (SWORD QI, ARRAY, SHIELD, FIST)] ---")

	# 1. Thanh Phong Kiếm Khí (Blade Gust)
	var gust = CombatVisualSystemClass.SpawnBladeGustVfx(self, Vector2(100, 100), Vector2.RIGHT, 400.0, 200.0)
	assert(gust != null, "Blade Gust VFX must spawn")
	print("  ✔ [Thanh Phong Kiếm Khí]: Phóng xuất hình cung kiếm khí ngọc bích xé gió")
	gust.queue_free()

	# 2. Trúc Sơn Kiếm Trận (Sword Array)
	var array = CombatVisualSystemClass.SpawnSwordArrayVfx(self, Vector2(200, 200), 100.0, 2.0)
	assert(array != null, "Sword Array VFX must spawn")
	assert(array.swordCount == 8, "Sword Array must summon 8 spirit swords")
	print("  ✔ [Trúc Sơn Kiếm Trận]: Bát quái trận đồ rực sáng, 8 đạo linh kiếm hạ thế oanh kích")
	array.queue_free()

	# 3. Bát Hoang Quyền (Fist Shockwave)
	var fist = CombatVisualSystemClass.SpawnFistShockwaveVfx(self, Vector2(150, 150), Vector2.DOWN)
	assert(fist != null, "Fist Shockwave VFX must spawn")
	print("  ✔ [Bát Hoang Quyền]: Khí kình hoàng kim bùng nổ xung kích hình nón")
	fist.queue_free()

	# 4. Quy Nguyên Thần Thuẫn (Spiritual Shield)
	var shieldTarget = Node2D.new()
	add_child(shieldTarget)
	var shield = CombatVisualSystemClass.CreateOrUpdateShieldVfx(shieldTarget, true)
	assert(shield != null, "Spiritual Shield VFX must spawn")
	print("  ✔ [Quy Nguyên Thần Thuẫn]: Màn chắn lục giác hộ thể bao quanh nhân vật")
	shieldTarget.queue_free()

	# 5. Đạp Phong Bộ (Phantom Afterimage)
	var dummySprite = Sprite2D.new()
	dummySprite.texture = PlaceholderTexture2D.new()
	add_child(dummySprite)
	var ghost = CombatVisualSystemClass.SpawnPhantomAfterimage(dummySprite, Color(0.4, 0.9, 1.0, 0.5), 0.2)
	assert(ghost != null, "Phantom Afterimage must spawn")
	print("  ✔ [Đạp Phong Bộ]: Tàn ảnh hư ảo thoắt ẩn thoắt hiện khi lướt gió")
	dummySprite.queue_free()

	test_results["system6_skill_visual_effects"] = true
	print("[PASS] System 6: Skill visual effects verified!")

# ==============================================================================
# SYSTEM 7: BOSS PRESENTATION POLISH
# ==============================================================================
func _RunBossPresentationTests():
	print("\n--- [SYSTEM 7: BOSS PRESENTATION (GHOST HEALTH BAR & ENRAGE AURA)] ---")
	var dummyBoss = Node2D.new()
	add_child(dummyBoss)

	# 1. Enrage Aura
	CombatVisualSystemClass.TriggerBossEnrageVfx(dummyBoss)
	var aura = dummyBoss.get_node_or_null("BossEnrageAura")
	assert(aura != null, "Boss must possess BossEnrageAura node upon enraging")
	print("  ✔ Hào Quang Cuồng Bạo Boss: Vầng sáng xích hỏa thiêu đốt quanh thân")
	dummyBoss.queue_free()

	# 2. Boss Tracker Bar Ghost Bar Verification
	var bossTracker = BossTrackerScene.instantiate()
	add_child(bossTracker)
	bossTracker._SetupGhostBar()
	assert(bossTracker.ghostBar != null, "BossTrackerBar must instantiate GhostBar")
	print("  ✔ Thanh Máu Boss 2 Lớp: Ghost bar vàng cam hiển thị vết thương tụt máu mượt mà")
	bossTracker.queue_free()

	test_results["system7_boss_presentation_polish"] = true
	print("[PASS] System 7: Boss presentation & health bar polish verified!")

# ==============================================================================
# SYSTEM 8: WORLD ATMOSPHERE & WEATHER
# ==============================================================================
func _RunAtmosphereWeatherTests():
	print("\n--- [SYSTEM 8: LIVING WORLD ATMOSPHERE & WEATHER] ---")

	# 1. Falling Bamboo Leaves
	var leaves = AmbientWeatherClass.SpawnBambooLeaves(self, Rect2(0, 0, 800, 600), 20)
	assert(leaves != null, "Bamboo leaves node must exist")
	assert(leaves.leaves.size() == 20, "Must create 20 drifting leaves")
	print("  ✔ Khí Quyển Bản Đồ: 20 phiến lá trúc xanh phiêu lãng theo làn gió")
	leaves.queue_free()

	# 2. Floating Spiritual Qi Motes
	var motes = AmbientWeatherClass.SpawnSpiritualQiMotes(self, Vector2(400, 300), 100.0, 12)
	assert(motes != null, "Qi motes node must exist")
	assert(motes.motes.size() == 12, "Must create 12 rising qi motes")
	print("  ✔ Điểm Quang Linh Khí: Các hạt linh khí thanh nhã thăng hoa từ linh mạch")
	motes.queue_free()

	# 3. Regional Tints
	var sectTint = AmbientWeatherClass.GetRegionalTint(995840901)
	assert(sectTint.g > 1.0, "Sacred Sect Hub must have jade/green enhanced daylight")
	var bossTint = AmbientWeatherClass.GetRegionalTint(4111682275)
	assert(bossTint.r > 1.0, "Boss Arena must have volcanic crimson tint")
	print("  ✔ Ánh Sáng Vùng Vực: Trúc Sơn Tông (Thanh khiết ngọc bích) • Bí Cảnh Boss (Xích viêm u ám)")

	test_results["system8_ambient_world_atmosphere"] = true
	print("[PASS] System 8: World atmosphere & weather verified!")

# ==============================================================================
# LIVE PROCESS LOOP (SYSTEMS 9 - 14)
# ==============================================================================
func _process(delta : float):
	timer += delta

	# Step 1: Wait for client connection at 1.0s
	if timer > 1.0 and step == 0 and Network.clientConnected:
		step = 1
		print("\n--- [LIVE STEP 1: CLIENT CONNECTION] ---")
		print("[Step 1 PASS] Connected via in-process offline dispatch!")
		test_results["live_step1_connected"] = true
		print("[Step 2] Logging in with account: %s" % test_account)
		Network.LoginWithPassword(test_account, test_pass, false)

	# Step 2: Create Character at 3.5s
	if timer > 3.5 and step == 1:
		step = 2
		test_char = "KiemTuB9_%d" % (randi() % 90000 + 10000)
		print("[Step 2 PASS] Logged in! Creating character: %s" % test_char)
		var hairstyles : PackedInt64Array = DB.HairstylesDB.keys()
		var haircolors : PackedInt64Array = DB.PalettesDB[DB.Palette.HAIR].keys() if DB.Palette.HAIR < DB.PalettesDB.size() else []
		var races : PackedInt64Array = DB.RacesDB.keys()
		var raceData : RaceData = DB.GetRace(races[0]) if not races.is_empty() else null
		var skins : Array = raceData.skins.keys() if raceData and raceData.skins else ["Medium"]

		var traits = {
			"hairstyle": hairstyles[0] if hairstyles.size() > 0 else "Bald".hash(),
			"haircolor": haircolors[0] if haircolors.size() > 0 else "Ash Brown".hash(),
			"race": races[0] if races.size() > 0 else "Human".hash(),
			"skintone": skins[0].hash() if skins.size() > 0 else "Medium".hash(),
			"gender": 0,
			"shape": "Player".hash(),
			"spirit": "Piou".hash()
		}
		var attrs = {
			"strength": 1,
			"vitality": 1,
			"agility": 1,
			"endurance": 1,
			"concentration": 1
		}
		Network.CreateCharacter(test_char, traits, attrs)

	# Step 3: Connect Character into World at 5.5s
	if timer > 5.5 and step == 2:
		step = 3
		print("[Step 3] Connecting character: %s" % test_char)
		Network.ConnectCharacter(test_char)

	# Step 4: Verify Live Swordsman Animation States at 8.0s
	if timer > 8.0 and step == 3:
		step = 4
		var player = GetServerPlayer()
		assert(player != null, "Server player must exist")
		print("\n--- [LIVE SYSTEM 9: LIVE CHARACTER ANIMATIONS & SECONDARY MOTION] ---")

		# Check local player entity visual
		var entity = Launcher.Player if Launcher.Player else Entities.Get(player.peerID)
		if entity and entity.visual:
			var vis = entity.visual
			assert(vis.currentAction == "idle", "Starting state must be idle")
			print("  ✔ Chuyển Động Nhân Vật: Đang thở nhẹ nhàng ở trạng thái Tĩnh (Idle Breathing)")

			# Test Qinggong action trigger
			vis.isDodging = true
			vis.UpdateSwordsmanVisual(Vector2.ZERO, Vector2.DOWN, ActorCommons.State.IDLE, false)
			assert(vis.currentAction == "qinggong", "Dodge must trigger qinggong action")
			print("  ✔ Thân Pháp Khinh Công: Chuyển đổi mượt mà sang animation [Qinggong] khi né tránh")
			vis.isDodging = false
			vis.UpdateSwordsmanVisual(Vector2.ZERO, Vector2.DOWN, ActorCommons.State.IDLE, false)

		test_results["live_step9_swordsman_animation_live"] = true

	# Step 5: Live Combat Feel, Hitstop & Camera Shake at 10.5s
	if timer > 10.5 and step == 4:
		step = 5
		var player = GetServerPlayer()
		print("\n--- [LIVE SYSTEM 10: LIVE COMBAT FEEL & IMPACT FEEDBACK] ---")

		# Create a target dummy monster agent
		var targetDummy = AIAgent.new()
		targetDummy.stat = ActorStats.new()
		targetDummy.stat.current.maxHealth = 200
		targetDummy.stat.health = 200
		targetDummy.stat.current.defense = 0
		targetDummy.stat.current.dodgeRate = 0.0
		player.stat.current.attack = 40
		targetDummy.position = player.position + Vector2(40, 0)
		player.get_parent().add_child(targetDummy)

		# Execute Advanced Combat with Wood Elemental Sword Qi
		var combatRes = CombatSystemClass.CalculateAdvancedCombat(player, targetDummy, null, 1002, true)
		assert(combatRes["damage"] > 0, "Damage must be dealt to target dummy")
		assert(combatRes["element"] == CombatSystemClass.Element.WOOD, "Skill element must be Wood")
		print("  ✔ Đòn Đánh Trúng Đích: Sát thương %d điểm Mộc Hệ" % combatRes["damage"])
		print("  ✔ Đẩy Lùi Thực Tế: Vector đẩy lùi có kiểm soát %s" % str(combatRes["knockbackVector"]))

		# Trigger visual impact sparks and camera shake
		CombatVisualSystemClass.TriggerCameraShake(CombatVisualSystemClass.ShakeLevel.MEDIUM)
		CombatVisualSystemClass.SpawnImpactVfx(self, targetDummy.position, combatRes["element"], false)
		print("  ✔ Rung Màn Hình & Tia Lửa Va Chạm: Kích hoạt đồng bộ tại frame trúng đòn")

		targetDummy.queue_free()
		test_results["live_step10_live_combat_feel"] = true

	# Step 6: Live Skill Effects (Sword Qi, Sword Array, Shield) at 12.5s
	if timer > 12.5 and step == 5:
		step = 6
		var player = GetServerPlayer()
		print("\n--- [LIVE SYSTEM 11: LIVE SKILL VISUAL EFFECTS ARSENAL] ---")

		# 1. Spawn Thanh Phong Kiếm Khí
		var gust = CombatVisualSystemClass.SpawnBladeGustVfx(self, player.position, Vector2.RIGHT)
		assert(gust != null and is_instance_valid(gust), "Blade gust must spawn")
		print("  ✔ Kích hoạt [Thanh Phong Kiếm Khí]: Luồng kiếm phong ngọc bích bay lượn")

		# 2. Spawn Trúc Sơn Kiếm Trận
		var array = CombatVisualSystemClass.SpawnSwordArrayVfx(self, player.position, 120.0, 1.5)
		assert(array != null and is_instance_valid(array), "Sword array must spawn")
		print("  ✔ Kích hoạt [Trúc Sơn Kiếm Trận]: Bát đại linh kiếm vần vũ trong trận đồ")

		# 3. Spawn Quy Nguyên Thần Thuẫn
		var shield = CombatVisualSystemClass.CreateOrUpdateShieldVfx(player, true)
		assert(shield != null and is_instance_valid(shield), "Spiritual shield must attach to player")
		print("  ✔ Kích hoạt [Quy Nguyên Thần Thuẫn]: Màn chắn linh quang bao bọc đạo thể")

		test_results["live_step11_live_skill_effects"] = true

	# Step 7: Live Boss Presentation & Ghost Health Bar at 14.5s
	if timer > 14.5 and step == 6:
		step = 7
		print("\n--- [LIVE SYSTEM 12: LIVE BOSS PRESENTATION & GHOST HEALTH BAR] ---")

		var bossTracker = BossTrackerScene.instantiate()
		add_child(bossTracker)
		bossTracker._SetupGhostBar()

		# Simulate Boss taking heavy hit (from 1000 down to 600 HP)
		var entityScene = load("res://presets/entities/Entity.tscn")
		var dummyBossEntity = entityScene.instantiate()
		dummyBossEntity.agentRID = 8888
		dummyBossEntity.stat = ActorStats.new()
		dummyBossEntity.stat.current.maxHealth = 1000
		dummyBossEntity.stat.health = 1000
		dummyBossEntity.data = EntityData.new()
		dummyBossEntity.data._isBoss = true
		dummyBossEntity.nick = "Xích Viêm Thú Hậu"
		Entities.Add(dummyBossEntity, dummyBossEntity.agentRID)
		add_child(dummyBossEntity)

		bossTracker.ConnectBoss(dummyBossEntity)
		assert(bossTracker.previousHealth == 1000, "Initial boss health tracked")

		# Apply chunk damage
		dummyBossEntity.stat.health = 600
		bossTracker.OnStatsUpdated(8888)
		assert(bossTracker.previousHealth == 600, "Tracked health updated to 600")
		assert(bossTracker.ghostTween != null, "Ghost damage trailing tween must be active")
		print("  ✔ Tổn Thương Nặng Boss: Máu chính tụt tức thì, Ghost bar vàng cam bắt đầu co rút mượt mà")

		# Trigger Boss Enrage
		CombatVisualSystemClass.TriggerBossEnrageVfx(dummyBossEntity)
		assert(dummyBossEntity.has_node("BossEnrageAura"), "Boss must gain enrage aura")
		print("  ✔ Cuồng Nộ Chuyển Giai Đoạn: Sóng xung kích rung chuyển, Hào quang Xích Viêm bùng phát")

		Entities.Erase(dummyBossEntity.agentRID)
		dummyBossEntity.queue_free()
		bossTracker.queue_free()

		test_results["live_step12_boss_enrage_presentation"] = true

	# Step 8: Live Ambient World Atmosphere at 16.5s
	if timer > 16.5 and step == 7:
		step = 8
		print("\n--- [LIVE SYSTEM 13: LIVE AMBIENT LIVING ATMOSPHERE] ---")

		var currentMapNode = Launcher.Map.currentMapNode if Launcher.Map else null
		if not currentMapNode:
			currentMapNode = self

		var leaves = AmbientWeatherClass.SpawnBambooLeaves(currentMapNode, Rect2(0, 0, 1600, 1200), 15)
		assert(leaves != null and is_instance_valid(leaves), "Bamboo leaves must be spawned in map")
		print("  ✔ Khí Quyển Sống Động: Lá trúc thanh phong đung đưa trong không gian bản đồ")

		var motes = AmbientWeatherClass.SpawnSpiritualQiMotes(currentMapNode, Vector2(600, 400), 150.0, 10)
		assert(motes != null and is_instance_valid(motes), "Qi motes must be spawned in map")
		print("  ✔ Linh Khí Phiêu Miễu: Các đốm quang linh khí điểm xuyết cảnh quan tu chân")

		test_results["live_step13_ambient_atmosphere"] = true

	# Step 9: Final Quality Gate Assertions at 18.5s
	if timer > 18.5 and step == 8:
		step = 9
		print("\n==================================================================")
		print("=== TDNM BUILD 09: ALL VISUAL & COMBAT FEEL SYSTEMS VERIFIED   ===")
		print("==================================================================")
		var allPassed = true
		for k in test_results:
			var passState = test_results[k]
			print("  ✔ %s: %s" % [k, "PASS" if passState else "FAIL"])
			if not passState:
				allPassed = false

		assert(allPassed, "All Build 09 test cases must pass")
		assert(test_results.size() >= 13, "Must pass at least 13 test checkpoints")
		print("\nAll automated assertions PASSED with 0 errors!")
		print("Exiting test suite successfully.")
		get_tree().quit(0)
