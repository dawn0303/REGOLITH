extends Node

const PORT = 9999
const MAX = 10

func _ready():
	pass

func join_server(ADRESS: String = "127.0.0.1"):
	
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(ADRESS, PORT)
	multiplayer.multiplayer_peer = peer
	#
	#multiplayer.connected_to_server.connect(connection_success)
	#multiplayer.connection_failed.connect(connection_fail)
	#
#
#func connection_success():
	#print("JOINED")
#func connection_fail():
	#print("FAILED2JOIN")

@rpc
func instance_player(id, location):
	get_tree().root.get_child(1).add_player(id)

@rpc
func delete_player(id):
	get_tree().root.get_child(1).remove_player(id)
