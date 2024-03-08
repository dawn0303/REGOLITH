extends Node

const DEV = true

var multiplayer_peer = ENetMultiplayerPeer.new()
var url : String = "your-prod.url"
const PORT = 9009
const Player = preload("res://player.tscn")

var connected_peer_ids = []


func _ready():
	if DEV == true:
		url = "127.0.0.1"
	multiplayer_peer.create_server(PORT)
	multiplayer.multiplayer_peer = multiplayer_peer
	multiplayer_peer.peer_connected.connect(_on_peer_connected)
	multiplayer_peer.peer_disconnected.connect(_on_peer_disconnected)
	print("Server is up and running.")


func _on_peer_connected(new_peer_id : int) -> void:
	print("Player " + str(new_peer_id) + " is joining...")
	# The connect signal fires before the client is added to the connected
	# clients in multiplayer.get_peers(), so we wait for a moment.
	await get_tree().create_timer(1).timeout
	add_player(new_peer_id)


func add_player(new_peer_id : int) -> void:
	connected_peer_ids.append(new_peer_id)
	var player = Player.instantiate()
	player.set_multiplayer_authority(new_peer_id)
	add_child(player)
	print("Player " + str(new_peer_id) + " joined.")
	print("Currently connected Players: " + str(connected_peer_ids))
	rpc("sync_player_list", connected_peer_ids)


func _on_peer_disconnected(leaving_peer_id : int) -> void:
	# The disconnect signal fires before the client is removed from the connected
	# clients in multiplayer.get_peers(), so we wait for a moment.
	await get_tree().create_timer(1).timeout 
	remove_player(leaving_peer_id)


func remove_player(leaving_peer_id : int) -> void:
	var peer_idx_in_peer_list : int = connected_peer_ids.find(leaving_peer_id)
	if peer_idx_in_peer_list != -1:
		connected_peer_ids.remove_at(peer_idx_in_peer_list)
	var leavingPlayer = get_node_or_null(str(leaving_peer_id))
	if leavingPlayer:
		leavingPlayer.queue_free()
	print("Player " + str(leaving_peer_id) + " disconnected.")
	rpc("sync_player_list", connected_peer_ids)


@rpc
func sync_player_list(updated_connected_peer_ids):
	pass # only implemented in client (but still has to exist here)
	


#@rpc("any_peer", "call_local", "reliable")
#func spawn(Name, pos, rot, vel, player):
	#var unit = load(Name).instantiate()
	#unit.position = pos
	#unit.rotation = rot
	#unit.linear_velocity = vel
	#unit.player = player
	##unit.team = team
	##print(str(unit.player))
	##var world = get_tree().root.get_node("Networking")
	#
	#add_child(unit, true)
#


