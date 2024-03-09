extends StaticBody3D


var equipped
var player
var amount = 2
var valid = true
var tag = "gear"
@onready var anim = $AnimationPlayer
@onready var raycast = $RayCast3D
@onready var col1 = $CollisionShape3D
@onready var col2 = $CollisionShape3D2
@onready var col3 = $CollisionShape3D3
@onready var area = $Area3D
@onready var ghost = $Area3D/Ghost

# Called when the node enters the scene tree for the first time.
func _ready():
	if get_parent() == get_tree().root.get_child(0):
		equipped = false
		col1.disabled = false
		col2.disabled = false
		col3.disabled = false
		anim.play("KeyAction")
		return
	if player == null and get_parent() != get_tree().root.get_child(0):
		player = $"../../../.."
	if not player.is_multiplayer_authority(): return
	if player.gearCount == 0:
		hide()


func _unhandled_input(_event):
	if not equipped: return
	if not player.is_multiplayer_authority(): return
	if Input.is_action_pressed("shoot") and raycast.is_colliding() and player.gearCount > 0 and !area.has_overlapping_bodies():
		place.rpc()
# Called every frame. 'delta' is the elapsed time since the previous frame.

func _process(delta):
	if not equipped: return
	if raycast.is_colliding() and !area.has_overlapping_bodies() and  player.gearCount > 0 :
		ghost.show()
		area.global_position = raycast.get_collision_point()
		area.global_rotation = raycast.get_collision_normal()
		area.global_rotation.y = player.global_rotation.y + PI
	else:
		ghost.hide()






@rpc('any_peer', "call_local")
func place():
	
	ghost.hide()
	var parent = get_parent()
	var world = get_tree().root.get_child(0)
	var pos = raycast.get_collision_point()
	var rot =raycast.get_collision_normal()
	var scl = Vector3(1.3, 1.3, 1.3)
	rot.y = player.rotation.y + PI
	
	world.spawnTest.rpc("res://equipment/gear/Cover/cover.tscn", pos, rot, scl)
	
	player.gearCount -= 1
	if player.gearCount == 0:
		hide()
		


func equip():
	equipped = true


func _on_area_3d_area_entered(area):
	valid = false


func _on_area_3d_area_exited(area):
	valid = true