extends Node

var totalAssertions : int = 0
var passedAssertions : int = 0
var failedAssertions : int = 0

func assert_true(condition : bool, testName : String):
	totalAssertions += 1
	if condition:
		passedAssertions += 1
		print("  [PASS] %s" % testName)
	else:
		failedAssertions += 1
		print("  [FAIL] %s" % testName)

func assert_eq(actual, expected, testName : String):
	totalAssertions += 1
	if actual == expected:
		passedAssertions += 1
		print("  [PASS] %s" % testName)
	else:
		failedAssertions += 1
		print("  [FAIL] %s (Expected: %s, Got: %s)" % [testName, str(expected), str(actual)])

class MockGui extends ServiceBase:
	var bossTracker : Control = null

func _ready():
	print("==================================================================")
	print("=== PHASE 4.2.2 BOSS TRACKER LIFECYCLE RECONCILIATION SUITE ===")
	print("==================================================================")
	
	var entityScene = load("res://presets/entities/Entity.tscn")
	var trackerBarScene = load("res://presets/gui/BossTracker.tscn")
	
	var splatynaData : EntityData = load("res://presets/entities/Splatyna.tres")
	var xakelbaelData : EntityData = load("res://presets/entities/Xakelbael.tres")
	var frostData : EntityData = load("res://presets/entities/Frost.tres")
	var redQueenData : EntityData = load("res://presets/entities/Red Queen.tres")
	var batData : EntityData = load("res://presets/entities/Bat.tres")
	
	# Instantiate BossTrackerBar UI node
	var trackerBar = trackerBarScene.instantiate()
	add_child(trackerBar)
	
	# Wire mock GUI so Entity._ready() binds to trackerBar
	var mockGui = MockGui.new()
	mockGui.bossTracker = trackerBar
	Launcher.GUI = mockGui
	
	# ==================================================================
	# TEST 1: Splatyna registers -> Tracker accepts valid Boss
	# ==================================================================
	print("\n--- TEST 1: Splatyna registers ---")
	var bossSplatyna : Entity = entityScene.instantiate()
	bossSplatyna.agentRID = 1001
	bossSplatyna.type = ActorCommons.Type.MONSTER
	bossSplatyna.data = splatynaData
	bossSplatyna.nick = "Splatyna"
	bossSplatyna.stat.health = 1200
	bossSplatyna.stat.current.maxHealth = 1200
	Entities.Add(bossSplatyna, bossSplatyna.agentRID)
	add_child(bossSplatyna)
	
	trackerBar.OnStatsUpdated(bossSplatyna.agentRID)
	assert_eq(trackerBar.currentBossRID, bossSplatyna.agentRID, "Tracker accepts Splatyna as active boss")
	assert_eq(trackerBar.label.text, "Splatyna", "Tracker displays Splatyna nickname")
	assert_eq(trackerBar.bar.targetValue, 1200.0, "Tracker bar stat displays 1200 HP")
	
	# Reset tracker for next test
	trackerBar.DisconnectBoss(bossSplatyna.agentRID)
	trackerBar.Clear()
	assert_eq(trackerBar.currentBossRID, DB.UnknownHash, "Tracker reset to UnknownHash")

	# ==================================================================
	# TEST 2: Xakelbael registers -> Tracker accepts valid Boss
	# ==================================================================
	print("\n--- TEST 2: Xakelbael registers ---")
	var bossXakelbael : Entity = entityScene.instantiate()
	bossXakelbael.agentRID = 1002
	bossXakelbael.type = ActorCommons.Type.MONSTER
	bossXakelbael.data = xakelbaelData
	bossXakelbael.nick = "Xakelbael"
	bossXakelbael.stat.health = 2500
	bossXakelbael.stat.current.maxHealth = 2500
	Entities.Add(bossXakelbael, bossXakelbael.agentRID)
	add_child(bossXakelbael)
	
	trackerBar.OnStatsUpdated(bossXakelbael.agentRID)
	assert_eq(trackerBar.currentBossRID, bossXakelbael.agentRID, "Tracker accepts Xakelbael as active boss")
	assert_eq(trackerBar.label.text, "Xakelbael", "Tracker displays Xakelbael nickname")
	assert_eq(trackerBar.bar.targetValue, 2500.0, "Tracker bar stat displays 2500 HP")
	
	trackerBar.DisconnectBoss(bossXakelbael.agentRID)
	trackerBar.Clear()

	# ==================================================================
	# TEST 3: Frost registers -> Rejected
	# ==================================================================
	print("\n--- TEST 3: Frost registers ---")
	var npcFrost : Entity = entityScene.instantiate()
	npcFrost.agentRID = 1003
	npcFrost.type = ActorCommons.Type.NPC
	npcFrost.data = frostData
	npcFrost.nick = "Frost"
	npcFrost.stat.health = 500
	npcFrost.stat.current.maxHealth = 500
	Entities.Add(npcFrost, npcFrost.agentRID)
	add_child(npcFrost)
	
	trackerBar.OnStatsUpdated(npcFrost.agentRID)
	assert_eq(trackerBar.currentBossRID, DB.UnknownHash, "Tracker strictly rejected Frost (NPC, non-boss)")

	# ==================================================================
	# TEST 4: Red Queen registers -> Rejected
	# ==================================================================
	print("\n--- TEST 4: Red Queen registers ---")
	var npcRedQueen : Entity = entityScene.instantiate()
	npcRedQueen.agentRID = 1004
	npcRedQueen.type = ActorCommons.Type.NPC
	npcRedQueen.data = redQueenData
	npcRedQueen.nick = "Red Queen"
	npcRedQueen.stat.health = 600
	npcRedQueen.stat.current.maxHealth = 600
	Entities.Add(npcRedQueen, npcRedQueen.agentRID)
	add_child(npcRedQueen)
	
	trackerBar.OnStatsUpdated(npcRedQueen.agentRID)
	assert_eq(trackerBar.currentBossRID, DB.UnknownHash, "Tracker strictly rejected Red Queen (NPC, non-boss)")

	# ==================================================================
	# TEST 5: Bat registers -> Rejected
	# ==================================================================
	print("\n--- TEST 5: Bat registers ---")
	var mobBat : Entity = entityScene.instantiate()
	mobBat.agentRID = 1005
	mobBat.type = ActorCommons.Type.MONSTER
	mobBat.data = batData
	mobBat.nick = "Bat"
	mobBat.stat.health = 25
	mobBat.stat.current.maxHealth = 25
	Entities.Add(mobBat, mobBat.agentRID)
	add_child(mobBat)
	
	trackerBar.OnStatsUpdated(mobBat.agentRID)
	assert_eq(trackerBar.currentBossRID, DB.UnknownHash, "Tracker strictly rejected Bat (MONSTER, non-boss)")

	# ==================================================================
	# TEST 6: Boss A updates -> A's tracker updates
	# ==================================================================
	print("\n--- TEST 6: Boss A updates ---")
	trackerBar.OnStatsUpdated(bossSplatyna.agentRID)
	assert_eq(trackerBar.currentBossRID, bossSplatyna.agentRID, "Boss A (Splatyna) is active tracker")
	
	bossSplatyna.stat.health = 850
	trackerBar.OnStatsUpdated(bossSplatyna.agentRID)
	assert_eq(trackerBar.bar.targetValue, 850.0, "Boss A tracker updated health to 850")

	# ==================================================================
	# TEST 7: Multi-Boss Contention & Player Targeting Policy
	# ==================================================================
	print("\n--- TEST 7: Multi-Boss Contention & Targeting Policy ---")
	Entities.target = null # Player has not targeted Boss B
	bossXakelbael.stat.health = 1800
	trackerBar.OnStatsUpdated(bossXakelbael.agentRID)
	assert_eq(trackerBar.currentBossRID, bossSplatyna.agentRID, "Boss A remains active tracker despite Boss B update")
	assert_eq(trackerBar.label.text, "Splatyna", "Label remains Splatyna")
	assert_eq(trackerBar.bar.targetValue, 850.0, "Health remains Boss A's 850 HP")
	
	print("  Subtest 7b: Player targets Boss B")
	Entities.target = bossXakelbael
	trackerBar.OnStatsUpdated(bossXakelbael.agentRID)
	assert_eq(trackerBar.currentBossRID, bossXakelbael.agentRID, "Tracker switched to targeted Boss B (Xakelbael)")
	assert_eq(trackerBar.label.text, "Xakelbael", "Label updated to Xakelbael")
	assert_eq(trackerBar.bar.targetValue, 1800.0, "Health updated to Boss B's 1800 HP")
	
	print("  Subtest 7c: Player targets Boss A back")
	Entities.target = bossSplatyna
	trackerBar.OnStatsUpdated(bossSplatyna.agentRID)
	assert_eq(trackerBar.currentBossRID, bossSplatyna.agentRID, "Tracker switched back to targeted Boss A (Splatyna)")
	assert_eq(trackerBar.label.text, "Splatyna", "Label restored to Splatyna")
	assert_eq(trackerBar.bar.targetValue, 850.0, "Health restored to 850 HP")
	Entities.target = null

	# ==================================================================
	# TEST 8: Boss A dies -> Only A's tracker hides, Boss B unaffected
	# ==================================================================
	print("\n--- TEST 8: Boss A dies ---")
	bossSplatyna.stat.health = 0
	trackerBar.OnStatsUpdated(bossSplatyna.agentRID)
	assert_eq(trackerBar.currentBossRID, DB.UnknownHash, "Tracker reset to UnknownHash upon Boss A death")
	assert_eq(bossXakelbael.stat.health, 1800, "Boss B health remains completely intact (1800 HP)")

	# ==================================================================
	# TEST 9: Entity Exit Lifecycle Order & Despawn
	# ==================================================================
	print("\n--- TEST 9: Entity Exit Lifecycle Order & Despawn ---")
	var bossDespawn : Entity = entityScene.instantiate()
	bossDespawn.agentRID = 1006
	bossDespawn.type = ActorCommons.Type.MONSTER
	bossDespawn.data = splatynaData
	bossDespawn.nick = "DespawnBoss"
	bossDespawn.stat.health = 1000
	bossDespawn.stat.current.maxHealth = 1000
	Entities.Add(bossDespawn, bossDespawn.agentRID)
	add_child(bossDespawn)
	
	trackerBar.OnStatsUpdated(bossDespawn.agentRID)
	assert_eq(trackerBar.currentBossRID, bossDespawn.agentRID, "DespawnBoss registered as active")
	
	# Verify that during tree_exiting, Entities.Get(agentRID) is still available before removal
	var exitState = {"entities_available": false}
	bossDespawn.tree_exiting.connect(func():
		exitState.entities_available = (Entities.Get(1006) != null)
	)
	
	remove_child(bossDespawn)
	assert_true(exitState.entities_available, "Entities.Get(agentRID) was available when tree_exiting fired")
	assert_eq(trackerBar.currentBossRID, DB.UnknownHash, "Tracker automatically cleaned up via tree_exiting on despawn")
	bossDespawn.queue_free()

	# ==================================================================
	# TEST 10: Repeated Registration (Direct Invocation vs Engine Lifecycle)
	# ==================================================================
	print("\n--- TEST 10: Repeated Registration & Engine Lifecycle ---")
	var bossIdempotent : Entity = entityScene.instantiate()
	bossIdempotent.agentRID = 1007
	bossIdempotent.type = ActorCommons.Type.MONSTER
	bossIdempotent.data = xakelbaelData
	add_child(bossIdempotent)
	
	# Direct method invocation test
	bossIdempotent._ready()
	assert_true(bossIdempotent.stat.vital_stats_updated.is_connected(bossIdempotent.bossTrackerCallable), "Direct _ready() preserves single valid signal connection")
	
	# Engine scene-tree exit lifecycle test
	remove_child(bossIdempotent)
	assert_true(not bossIdempotent.stat.vital_stats_updated.is_connected(bossIdempotent.bossTrackerCallable), "Signal cleanly disconnected via engine _exit_tree() on remove_child")
	
	# Engine scene-tree re-entry lifecycle test (using Godot's request_ready contract)
	bossIdempotent.request_ready()
	add_child(bossIdempotent)
	assert_true(bossIdempotent.stat.vital_stats_updated.is_connected(bossIdempotent.bossTrackerCallable), "Signal cleanly re-connected via engine _ready() on add_child with request_ready")
	
	remove_child(bossIdempotent)
	bossIdempotent.queue_free()

	# ==================================================================
	# TEST 11: Stale Callback & Tracker Identity Isolation
	# ==================================================================
	print("\n--- TEST 11: Stale Callback & Tracker Identity Isolation ---")
	# Re-create Boss A and register
	var bossIsoA : Entity = entityScene.instantiate()
	bossIsoA.agentRID = 1010
	bossIsoA.type = ActorCommons.Type.MONSTER
	bossIsoA.data = splatynaData
	bossIsoA.nick = "BossIsoA"
	bossIsoA.stat.health = 1000
	bossIsoA.stat.current.maxHealth = 1000
	Entities.Add(bossIsoA, bossIsoA.agentRID)
	add_child(bossIsoA)
	trackerBar.OnStatsUpdated(bossIsoA.agentRID)
	
	# Boss B takes ownership via targeting
	var bossIsoB : Entity = entityScene.instantiate()
	bossIsoB.agentRID = 1011
	bossIsoB.type = ActorCommons.Type.MONSTER
	bossIsoB.data = xakelbaelData
	bossIsoB.nick = "BossIsoB"
	bossIsoB.stat.health = 2000
	bossIsoB.stat.current.maxHealth = 2000
	Entities.Add(bossIsoB, bossIsoB.agentRID)
	add_child(bossIsoB)
	Entities.target = bossIsoB
	trackerBar.OnStatsUpdated(bossIsoB.agentRID)
	Entities.target = null
	
	# Boss A exits the scene tree afterward
	remove_child(bossIsoA)
	Entities.Erase(bossIsoA.agentRID)
	bossIsoA.queue_free()
	
	# Verify Boss A's exit did NOT hide Boss B's tracker
	assert_eq(trackerBar.currentBossRID, bossIsoB.agentRID, "Boss A exit did NOT hide Boss B tracker")
	assert_eq(trackerBar.label.text, "BossIsoB", "Label remains BossIsoB")
	
	# Now Boss B exits the tree -> cleanup occurs
	remove_child(bossIsoB)
	Entities.Erase(bossIsoB.agentRID)
	bossIsoB.queue_free()
	assert_eq(trackerBar.currentBossRID, DB.UnknownHash, "Boss B exit cleanly resets tracker to UnknownHash")

	# ==================================================================
	# TEST 12: Entity Freed & Headless Safety
	# ==================================================================
	print("\n--- TEST 12: Entity Freed & Headless Safety ---")
	var bossFreed : Entity = entityScene.instantiate()
	bossFreed.agentRID = 1008
	bossFreed.type = ActorCommons.Type.MONSTER
	bossFreed.data = splatynaData
	Entities.Add(bossFreed, bossFreed.agentRID)
	add_child(bossFreed)
	trackerBar.OnStatsUpdated(bossFreed.agentRID)
	
	remove_child(bossFreed)
	Entities.Erase(bossFreed.agentRID)
	bossFreed.free() # Entity freed
	
	trackerBar.OnStatsUpdated(1008)
	trackerBar.DisconnectBoss(1008)
	assert_eq(trackerBar.currentBossRID, DB.UnknownHash, "OnStatsUpdated/DisconnectBoss on freed entity safely preserves UnknownHash")
	
	# Headless startup safety
	var originalGUI = Launcher.GUI
	Launcher.GUI = null
	var headlessBoss : Entity = entityScene.instantiate()
	headlessBoss.agentRID = 1009
	headlessBoss.type = ActorCommons.Type.MONSTER
	headlessBoss.data = splatynaData
	add_child(headlessBoss)
	assert_true(not headlessBoss.bossTrackerCallable.is_valid(), "bossTrackerCallable is invalid when Launcher.GUI is null")
	remove_child(headlessBoss)
	headlessBoss.queue_free()
	Launcher.GUI = originalGUI

	# ==================================================================
	# TEST 13: GUI Recreation & Reconnection
	# ==================================================================
	print("\n--- TEST 13: GUI Recreation & Reconnection ---")
	var bossRecreate : Entity = entityScene.instantiate()
	bossRecreate.agentRID = 1012
	bossRecreate.type = ActorCommons.Type.MONSTER
	bossRecreate.data = splatynaData
	bossRecreate.nick = "RecreateBoss"
	bossRecreate.stat.health = 1500
	bossRecreate.stat.current.maxHealth = 1500
	Entities.Add(bossRecreate, bossRecreate.agentRID)
	add_child(bossRecreate)
	
	# Create new Tracker Bar (simulating new GUI instance)
	var newTrackerBar = trackerBarScene.instantiate()
	add_child(newTrackerBar)
	var newMockGui = MockGui.new()
	newMockGui.bossTracker = newTrackerBar
	Launcher.GUI = newMockGui
	
	# Existing entity calls ReconnectBossTracker() (or re-enters scene tree)
	bossRecreate.ReconnectBossTracker()
	assert_eq(bossRecreate.bossTrackerCallable.get_object(), newTrackerBar, "bossTrackerCallable re-bound to new tracker instance")
	
	bossRecreate.stat.health = 1100
	bossRecreate.stat.vital_stats_updated.emit()
	assert_eq(newTrackerBar.currentBossRID, bossRecreate.agentRID, "New tracker bar accepted update from existing entity")
	assert_eq(newTrackerBar.bar.targetValue, 1100.0, "New tracker bar displays updated HP (1100)")
	
	remove_child(bossRecreate)
	Entities.Erase(bossRecreate.agentRID)
	bossRecreate.queue_free()
	remove_child(newTrackerBar)
	newTrackerBar.queue_free()
	Launcher.GUI = mockGui # Restore original mockGui

	# ==================================================================
	# TEST 14: New Boss after cleanup -> Tracker works again
	# ==================================================================
	print("\n--- TEST 14: New Boss after cleanup ---")
	assert_eq(trackerBar.currentBossRID, DB.UnknownHash, "Tracker is currently clean (DB.UnknownHash)")
	assert_true(bossXakelbael.stat.health > 0, "Boss B (Xakelbael) is alive with HP > 0")
	
	trackerBar.OnStatsUpdated(bossXakelbael.agentRID)
	assert_eq(trackerBar.currentBossRID, bossXakelbael.agentRID, "New Boss (Xakelbael) successfully registered after Boss A cleanup")
	assert_eq(trackerBar.bar.targetValue, 1800.0, "Tracker displays Xakelbael health (1800 HP)")
	
	# Cleanup living entities
	Entities.Erase(bossSplatyna.agentRID)
	Entities.Erase(bossXakelbael.agentRID)
	Entities.Erase(npcFrost.agentRID)
	Entities.Erase(npcRedQueen.agentRID)
	Entities.Erase(mobBat.agentRID)
	
	remove_child(bossSplatyna)
	remove_child(bossXakelbael)
	remove_child(npcFrost)
	remove_child(npcRedQueen)
	remove_child(mobBat)
	
	bossSplatyna.queue_free()
	bossXakelbael.queue_free()
	npcFrost.queue_free()
	npcRedQueen.queue_free()
	mobBat.queue_free()
	
	Launcher.GUI = null
	
	# Final tally
	print("\n==================================================================")
	print("=== BOSS TRACKER VERIFICATION COMPLETE: %d/%d ASSERTIONS PASSED ===" % [passedAssertions, totalAssertions])
	if failedAssertions > 0:
		print("=== TOTAL FAILURES: %d ===" % failedAssertions)
	print("==================================================================")
	
	get_tree().quit(0 if failedAssertions == 0 else 1)
