extends Node2D

func _ready():
	if not DB.isInitialized:
		await Launcher.dbInitialized

	print("==================================================")
	print("=== PHASE 4.1.1 VERIFICATION & HARDENING SUITE ===")
	print("==================================================")

	var all_passed = true

	# 1. VERIFY DEFAULT SPAWN RESTORATION
	print("\n--- TEST 1: DEFAULT SPAWN RESTORATION ---")
	var expected_tulimshar_hash = "Tulimshar".hash()
	print("DefaultStartMapID: ", LauncherCommons.DefaultStartMapID, " (Expected Tulimshar: ", expected_tulimshar_hash, ")")
	if LauncherCommons.DefaultStartMapID != expected_tulimshar_hash:
		print("FAILED: DefaultStartMapID is not Tulimshar!")
		all_passed = false
	else:
		print("PASSED: DefaultStartMapID is restored to Tulimshar.")

	print("DefaultStartPos: ", LauncherCommons.DefaultStartPos, " (Expected: (2176, 2560))")
	if LauncherCommons.DefaultStartPos != Vector2i(2176, 2560):
		print("FAILED: DefaultStartPos is not Vector2i(2176, 2560)!")
		all_passed = false
	else:
		print("PASSED: DefaultStartPos is restored to (2176, 2560).")

	print("DefaultStartOffset: ", LauncherCommons.DefaultStartOffset, " (Expected: (64, 32))")
	if LauncherCommons.DefaultStartOffset != Vector2i(64, 32):
		print("FAILED: DefaultStartOffset is not Vector2i(64, 32)!")
		all_passed = false
	else:
		print("PASSED: DefaultStartOffset is restored to (64, 32).")

	# 2. VERIFY LOCATION NAMING ARCHITECTURE
	print("\n--- TEST 2: LOCATION NAMING LOOKUP METHODS ---")
	var t_by_str = LocationNaming.GetDisplayName("Tulimshar")
	print("Lookup by String 'Tulimshar': ", t_by_str)
	if t_by_str != "Thanh Sa Cảng":
		print("FAILED: Expected 'Thanh Sa Cảng', got: ", t_by_str)
		all_passed = false
	else:
		print("PASSED: Lookup by String succeeded.")

	var t_by_hash = LocationNaming.GetDisplayName(expected_tulimshar_hash)
	print("Lookup by Hash ID: ", t_by_hash)
	if t_by_hash != "Thanh Sa Cảng":
		print("FAILED: Expected 'Thanh Sa Cảng', got: ", t_by_hash)
		all_passed = false
	else:
		print("PASSED: Lookup by Hash ID succeeded.")

	var tulimshar_map_data : MapData = DB.MapsDB.get(expected_tulimshar_hash, null)
	if tulimshar_map_data:
		var t_by_data = LocationNaming.GetDisplayName(tulimshar_map_data)
		print("Lookup by MapData object: ", t_by_data)
		if t_by_data != "Thanh Sa Cảng":
			print("FAILED: Expected 'Thanh Sa Cảng', got: ", t_by_data)
			all_passed = false
		else:
			print("PASSED: Lookup by MapData object succeeded.")

		var t_by_method = tulimshar_map_data.GetDisplayName()
		print("Lookup by MapData.GetDisplayName(): ", t_by_method)
		if t_by_method != "Thanh Sa Cảng":
			print("FAILED: Expected 'Thanh Sa Cảng', got: ", t_by_method)
			all_passed = false
		else:
			print("PASSED: MapData.GetDisplayName() method succeeded.")

	# 3. VERIFY FALLBACK BEHAVIOR
	print("\n--- TEST 3: FALLBACK BEHAVIOR ---")
	var fallback_str = LocationNaming.GetDisplayName("NonExistentMapName")
	print("Fallback for unmapped string: ", fallback_str)
	if fallback_str != "NonExistentMapName":
		print("FAILED: Fallback did not return original string!")
		all_passed = false
	else:
		print("PASSED: Graceful fallback on unmapped string verified.")

	var fallback_int = LocationNaming.GetDisplayName(123456789)
	print("Fallback for unmapped int: ", fallback_int)
	if fallback_int != "123456789":
		print("FAILED: Fallback did not return stringified id!")
		all_passed = false
	else:
		print("PASSED: Graceful fallback on unmapped int verified.")

	# 4. AUDIT ALL 42 REGISTERED MAPS
	print("\n--- TEST 4: AUDIT ALL REGISTERED MAPS IN DB.MapsDB ---")
	print("Total maps in DB.MapsDB: ", DB.MapsDB.size())
	if DB.MapsDB.size() != 42:
		print("WARNING: Expected 42 maps, found ", DB.MapsDB.size())

	var approved_count = 0
	var proposed_count = 0
	var pending_count = 0
	var missing_count = 0

	for map_id in DB.MapsDB:
		var md : MapData = DB.MapsDB[map_id]
		var internal_name = md._name
		var display_name = LocationNaming.GetDisplayName(md)
		var status = LocationNaming.GetStatus(md)
		var info = LocationNaming.GetLocationInfo(md)

		if display_name.is_empty():
			print("FAILED: Empty display name for map: ", internal_name)
			missing_count += 1
			all_passed = false
		elif status == LocationNaming.STATUS_APPROVED:
			approved_count += 1
		elif status == LocationNaming.STATUS_PROPOSED:
			proposed_count += 1
		elif status == LocationNaming.STATUS_PENDING:
			pending_count += 1
		else:
			print("UNKNOWN STATUS: ", status, " for map: ", internal_name)

	print("Audit Results:")
	print("  - APPROVED locations: ", approved_count, " (Expected: 32)")
	print("  - PROPOSED locations: ", proposed_count, " (Expected: 9)")
	print("  - PENDING locations: ", pending_count, " (Expected: 1)")
	print("  - MISSING/ERROR: ", missing_count)

	if approved_count != 32 or proposed_count != 9 or pending_count != 1:
		print("FAILED: Location counts do not match expected (32 APPROVED, 9 PROPOSED, 1 PENDING)!")
		all_passed = false

	if missing_count > 0:
		all_passed = false

	# 5. VERIFY KEY CORE & PHASE 4.1.2 LOCATIONS
	print("\n--- TEST 5: OWNER APPROVED & UPDATED PROPOSED LOCATIONS ---")
	var required_checks = {
		# Core approved
		"Tulimshar": "Thanh Sa Cảng",
		"Tulimshar Center": "Thanh Sa Trấn",
		"Tulimshar Bay": "Thanh Sa Vịnh",
		"Tulimshar Beach": "Nguyệt Sa Hải Than",
		"Tulimshar Castle": "Thành Chủ Phủ",
		"Overworld": "Trung Thổ Bình Nguyên",
		"Artis": "Cổ Thành Vân Châu",
		"Artis Sewer": "Địa Đạo Cổ Thành",
		"Candor Cave": "Hàn Thạch Động",
		"Ocean": "Đông Hải",
		"TanThuThon": "Thanh Vân Thôn",
		# Phase 4.1.2 Newly approved
		"Sandstorm": "Cuồng Sa Hoang Địa",
		"Desert Mines": "Cuồng Sa Khoáng Quật",
		"Desert Deep Level": "U Minh Thâm Tầng",
		"Desert Mountains": "Xích Nham Sơn Mạch",
		"Snake Pit": "Vạn Xà Khanh",
		"Manayir": "Linh Sa Cổ Trấn",
		"Candor Arena": "Hàn Băng Diễn Võ Đài",
		"Ship Nard's Room": "Linh Thuyền - Thuyền Trưởng Thất",
		# Phase 4.1.2 Updated proposed
		"Desert Abandoned Level": "Phế Khoáng Đạo",
		"Desert Mountain Cave": "Xích Nham Thạch Động",
		"Desert Pit": "Xích Sa Hãm Cốc",
		"Manayir Beach": "Linh Sa Hải Than",
		"Ship Alige Hide": "Linh Thuyền - Mật Thất",
		"Splatyna's Dorian Dead End": "Vạn Yêu Quật - Tuyệt Bích",
		"Splatyna's Gabriel Pit": "Vạn Yêu Quật - U Minh Uyên Khanh",
		"Splatyna's Marvin Hole": "Vạn Yêu Quật - Dị Linh Bí Quật",
		"Drazil": "U Minh Di Tích",
		# Phase 4.1.2 Pending
		"SacredSectHub": "Thánh Tông Tổng Đàn"
	}

	for req_name in required_checks:
		var expected_val = required_checks[req_name]
		var actual_val = LocationNaming.GetDisplayName(req_name)
		if actual_val != expected_val:
			print("FAILED: ", req_name, " expected '", expected_val, "', got '", actual_val, "'")
			all_passed = false
		else:
			print("  [OK] ", req_name, " -> ", actual_val)

	print("\n==================================================")
	if all_passed:
		print("=== ALL PHASE 4.1.1 UNIT & AUDIT TESTS PASSED ===")
		print("==================================================")
		get_tree().quit(0)
	else:
		print("=== SOME TESTS FAILED! ===")
		print("==================================================")
		get_tree().quit(1)
