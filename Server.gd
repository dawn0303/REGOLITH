extends Node

const PORT = 9999
const MAX = 10
var players = []

func _ready():
	start_server()

func start_server():
	var peer = ENetMultiplayerPeer.new()
	if peer.create_server(PORT, MAX) != OK:
		print("ERROR CREATING SERVER")
		get_tree().quit()
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(instance_player)
	multiplayer.peer_disconnected.connect(delete_player)
	

@rpc
func instance_player(id: int):
	players.append(id)
	rpc_id(0, "instance_player", id, Vector3(200,0,200))

@rpc
func delete_player(id: int):
	players.erase(id)
	rpc_id(0, "delete_player", id)

