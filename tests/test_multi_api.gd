extends SceneTree

func _init():
	var node1 = Node.new()
	node1.name = "Client1"
	root.add_child(node1)
	
	var mp1 = SceneMultiplayer.new()
	var peer1 = ENetMultiplayerPeer.new()
	var err1 = peer1.create_client("127.0.0.1", 6119)
	mp1.multiplayer_peer = peer1
	set_multiplayer(mp1, node1.get_path())
	
	print("Peer 1 created, status: ", err1)
	quit(0)
