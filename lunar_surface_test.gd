extends Node3D

@onready var main_menu = $CanvasLayer/MainMenu
@onready var address_entry = $CanvasLayer/MainMenu/MarginContainer/VBoxContainer/AddressEntry
@onready var hud = $CanvasLayer/HUD
@onready var health_bar = $CanvasLayer/HUD/HealthBar
@onready var suit_bar = $CanvasLayer/HUD/SuitBar
@onready var boost_bar = $CanvasLayer/HUD/BoostBar
@onready var patches = $CanvasLayer/HUD/Patches
@onready var weapon1_button = $CanvasLayer/MainMenu/MarginContainer/VBoxContainer/weapon1
@onready var weapon2_button = $CanvasLayer/MainMenu/MarginContainer/VBoxContainer/weapon2
@onready var gear_button = $CanvasLayer/MainMenu/MarginContainer/VBoxContainer/gear




const Player = preload("res://player.tscn")
const Rock = preload("res://rock.tscn")
const Rifle = preload("res://space_rifle_test.tscn")
const Shield = preload("res://shield.tscn")

var weapon1
var weapon2
var gear

const PORT = 9999
var enet_peer = ENetMultiplayerPeer.new()
var Team1count = 0
var Team2count = 0

func _ready():
	randomize()
	

func _unhandled_input(_event):
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()


func _on_host_button_pressed():
	main_menu.hide()
	hud.show()
	match weapon1_button.get_selected_id():
		0:
			weapon1 = Rifle
		1:
			weapon1 = Rock
	match weapon2_button.get_selected_id():
		0:
			weapon2 = Rifle
		1:
			weapon2 = Rock
	match gear_button.get_selected_id():
		0:
			gear = Shield
	
	
	enet_peer.create_server(PORT)
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(remove_player)
	
	add_player(multiplayer.get_unique_id())
	
	#upnp_setup()

func _on_join_button_pressed():
	main_menu.hide()
	hud.show()
	
	match weapon1_button.get_selected_id():
		0:
			weapon1 = Rifle
		1:
			weapon1 = Rock
	match weapon2_button.get_selected_id():
		0:
			weapon2 = Rifle
		1:
			weapon2 = Rock
	match gear_button.get_selected_id():
		0:
			gear = Shield
		
	enet_peer.create_client(address_entry.text, PORT)
	multiplayer.multiplayer_peer = enet_peer
	


func add_player(peer_id):
	var player = Player.instantiate()
	player.name = str(peer_id) 
	#if Team1count > Team2count:
		#player.team = "Team2"
		#Team2count += 1
		#print(str("Team2"))
	#elif Team2count > Team1count:
		#player.team = "Team1"
		#Team1count += 1
		#print(str("Team1"))
	#elif randf() < 0.5:
		#player.team = "Team1"
		#Team1count += 1
		#print(str("Team1"))
	#else:
		#player.team = "Team2"
		#Team2count += 1
		#print(str("Team2"))
	player.equip_weapons.rpc_id(player.get_multiplayer_authority())
	#player.position.x = randf_range(-200.0, 200.0)
	#player.position.z = randf_range(-200.0, 200.0)
	randomize()
	#player.weapon1 = weapon1
	#player.weapon2 = weapon2
	add_child(player)
	
	if player.is_multiplayer_authority():
		player.health_changed.connect(update_health_bar)
		player.suit_changed.connect(update_suit_bar)
		player.patches_changed.connect(update_patches)
		player.boost_changed.connect(update_boost)
		
	

func remove_player(peer_id):
	var player = get_node_or_null(str(peer_id))
	if player:
		player.queue_free()


func update_health_bar(health_value):
	health_bar.value = health_value
func update_suit_bar(suit_value):
	suit_bar.value = suit_value
func update_patches(patches_value):
	patches.text = "repair patches: " + str(patches_value)
func update_boost(boost_value):
	boost_bar.value = boost_value


func _on_multiplayer_spawner_spawned(node):
	if node.is_multiplayer_authority():
		node.health_changed.connect(update_health_bar)
		node.suit_changed.connect(update_suit_bar)
		node.patches_changed.connect(update_patches)
		node.boost_changed.connect(update_boost)


@rpc("any_peer", "call_local", "reliable")
func spawn(Name, pos, rot, vel, player):
	var unit = load(Name).instantiate()
	unit.position = pos
	unit.rotation = rot
	unit.linear_velocity = vel
	unit.player = player
	#unit.team = team
	#print(str(unit.player))
	var world = get_tree().root.get_node("world")
	
	world.add_child(unit, true)
	






#
#func upnp_setup():
	#var upnp = UPNP.new()
	#
	#var discover_result = upnp.discover()
	#assert(discover_result == UPNP.UPNP_RESULT_SUCCESS, "UPNP Discover Failed! error %s" % discover_result)
	#
	#assert(upnp.get_gateway() and upnp.get_gateway().is_valid_gateway(), "UPNP Invalid Gateway!")
	#
	#var map_result = upnp.add_port_mapping(PORT)
	#assert(map_result== UPNP.UPNP_RESULT_SUCCESS, "UPNP Port Mapping Failed! Erorr %s" % map_result)
	#
	#print("Success! Join Address: %s" % upnp.query_external_address())

