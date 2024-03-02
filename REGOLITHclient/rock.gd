extends RigidBody3D


@onready var anim_player
@onready var col = $CollisionShape3D
@onready var area = $Area3D
@onready var body = $Sphere

@onready var player

const suit_damage = 5
const damage = 20
var mag = 0
var poolmax = 3
var pool = 3
var magmax = 0
var count = 3
var shooting = false
var timer = 10

var equipped = false

# Called when the node enters the scene tree for the first time.
func _ready():
	
	if get_parent().get_name() == "weapon parent" or get_parent().get_name() == "holster2":
		sleeping = true
		freeze = true
		col.disabled = true
		#anim_player = $"../../../AnimationPlayer"
		player = $"../../../.."
		anim_player = player.anim_player
		if player.throwables == 0:
			visible = false
	else :
		sleeping = false
		freeze = false
		col.disabled = false
	area.monitorable = false
	

func _physics_process(_delta):
	if equipped and (anim_player == null):
		anim_player = $"../../../../AnimationPlayer"
		player = $"../../../.."
	if equipped and get_parent().get_name() == "weapon parent" :
		if Input.is_action_just_pressed("shoot") and anim_player.current_animation != "heal" and anim_player.current_animation != "reload" and anim_player.current_animation != "spawn":
			if not player.is_multiplayer_authority(): return
			throw.rpc()
	
	if get_parent().get_name() != "weapon parent" and get_parent().get_name() != "holster1" and get_parent().get_name() != "holster 2":
			if timer > 0:
				timer -= 1


# Called every frame. 'delta' is the elapsed time since the previous frame.

@rpc("call_local")
func throw():
	if player.throwables == 0: return
	if equipped:# and get_tree().root.get_child(0):
		var world = get_tree().root.get_child(0)
		var pos = global_position
		var rot = global_rotation
		
		var a = player.get_transform().basis
		var b = get_parent().get_parent().get_parent().get_transform().basis
		var vel = (Vector3(a.x.z, b.y.z, -a.z.z) * 20)
		
		world.spawn.rpc("res://rock.tscn", pos, rot, vel, player)
		player.throwables -= 1
		
		if player.throwables == 0:
			queue_free()






func _on_area_3d_area_entered(Area):
	if timer == 0 and Area.get_parent().is_in_group("Players") and get_parent().get_name() != "weapon parent" and get_parent().get_name() != "holster1" and get_parent().get_name() != "holster2":
		linear_velocity = Vector3.ZERO
		print(str(Area.get_parent().name))
		var hit_player = Area.get_parent()
		hit_player.recieve_suit_damage.rpc_id(hit_player.get_multiplayer_authority(), suit_damage)
		hit_player.recieve_damage.rpc_id(hit_player.get_multiplayer_authority(), damage)
		area.set_deferred("monitoring", false)

