extends Node3D

const DEV = true

const Player = preload("res://player.tscn")
const Rock = preload("res://equipment/secondary/Rock/rock.tscn")
const Rifle = preload("res://equipment/Primary/Rifle/space_rifle_test.tscn")
const Shield = preload("res://equipment/gear/Shield/shield.tscn")
const Cover = preload("res://equipment/gear/Cover/cover.tscn")


@onready var connect_btn = $Lobby/ConnectBtn
@onready var disconnect_btn = $Lobby/DisconnectBtn
@onready var lobby = $Lobby
@onready var weapon1_button = $Lobby/MainMenu/MarginContainer/VBoxContainer/weapon1
@onready var weapon2_button = $Lobby/MainMenu/MarginContainer/VBoxContainer/weapon2
@onready var gear_button = $Lobby/MainMenu/MarginContainer/VBoxContainer/gear
@onready var spawner = $MultiplayerSpawner

var weapon1
var weapon2
var gear

var Team1count = 0
var Team2count = 0

var multiplayer_peer = ENetMultiplayerPeer.new()
var url : String = "your-prod.url"
const PORT = 9009

var connected_peer_ids = []


func _ready():
	if DEV == true:
		url = "127.0.0.1"
	update_connection_buttons()
	multiplayer.server_disconnected.connect(_on_server_disconnected)

func _unhandled_input(_event):
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()


func _on_connect_btn_pressed() -> void:
	print("Connecting ...")
	match weapon1_button.get_selected_id():
		0:
			weapon1 = Rifle
		1:
			weapon1 = Rock
	match weapon2_button.get_selected_id():
		#0:
			#weapon2 = 
		1:
			weapon2 = Rock
	match gear_button.get_selected_id():
		0:
			gear = Shield
		1:
			gear = Cover
	
	multiplayer_peer.create_client(url, PORT)
	multiplayer.multiplayer_peer = multiplayer_peer
	update_connection_buttons()



func _on_disconnect_btn_pressed():
	multiplayer_peer.close()
	update_connection_buttons()
	print("Disconnected.")


func _on_server_disconnected():
	
	multiplayer_peer.close()
	update_connection_buttons()
	print("Connection to server lost.")



func update_connection_buttons() -> void:
	if multiplayer_peer.get_connection_status() == multiplayer_peer.CONNECTION_DISCONNECTED:
		connect_btn.disabled = false
		disconnect_btn.disabled = true
	if multiplayer_peer.get_connection_status() == multiplayer_peer.CONNECTION_CONNECTING:
		connect_btn.disabled = true
		disconnect_btn.disabled = true
	if multiplayer_peer.get_connection_status() == multiplayer_peer.CONNECTION_CONNECTED:
		connect_btn.disabled = true
		disconnect_btn.disabled = false
		lobby.hide()
		
		

func add_player(peer_id):
	var player = Player.instantiate()
	player.name = str(peer_id) 
	player.set_multiplayer_authority(peer_id) 
	player.equip_weapons.rpc_id(player.get_multiplayer_authority())
	randomize()
	add_child(player)
	print("hi")
	



func remove_player(peer_id):
	var player = get_node_or_null(str(peer_id))
	if player:
		player.queue_free()


@rpc
func sync_player_list(updated_connected_peer_ids):
	connected_peer_ids = updated_connected_peer_ids
	multiplayer_peer.get_unique_id()
	update_connection_buttons()
	#for peer_id in connected_peer_ids:
	#	add_player(peer_id)
	print("Currently connected Players: " + str(connected_peer_ids))


#@rpc("any_peer", "call_local", "reliable")
#func spawn(Name, pos, rot, vel, player):
	#var unit = load(Name).instantiate()
	#unit.position = pos
	#unit.rotation = rot
	#if vel != Vector3.ZERO:
		#unit.linear_velocity = vel
	#unit.player = player
	##unit.team = team
	##print(str(unit.player))
	##var world = get_tree().root.get_node("Networking")
	#
	#spawner.spawn(unit)
	#

@rpc("any_peer", "call_local", "reliable")
func spawnTest(_nme, _pos, _rot, _scl):
	return



func _on_multiplayer_spawner_spawned(node):
	print("spawned " + str(node))
