extends Node3D


signal mag_value(patches_value)
signal ammo_pool(patches_value)

@onready var raycast = $RayCast3D
@onready var anim_rifle = $AnimationRifle
@onready var muzzle_flash = $MuzzleFlash
@onready var mag_counter = $magCount
@onready var ammo_counter = $ammoCount
@onready var anim_player
@onready var player
@onready var camera
@onready var cam_parent

@export var recoil_rotation_x : Curve
@export var recoil_rotation_y : Curve
@export var recoil_position_z : Curve
@export var recoil_amplitude := Vector3(1,1,1)
@export var lerp_speed : float = 0.2

@onready var audioPlayer = $AudioStreamPlayer3D

#var Impact

var target_rot : Vector3
var target_pos : Vector3
var current_time : float

var equipped
var r

const damage = 5
const suit_damage = 10
var shooting = false
const shotDelay = 5
var shotCooldown
const magmax = 20
var mag
var poolmax = 210
var pool = 210
var kick = 0.01

var reset_rotation

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	current_time = 1
	shotCooldown = 0
	if player == null:
		#anim_player = $"../../../AnimationPlayer"
		player = $"../../../.."
		anim_player = player.anim_player
		cam_parent = $"../../.."
		camera = $"../.."
		mag = player.mag1
		target_rot.y = camera.rotation.y
	
	mag_counter.text = str(mag)
	ammo_counter.text = str(player.ammo1)

func _unhandled_input(_event):
	if not equipped: return
	if not player.is_multiplayer_authority(): return
	if Input.is_action_pressed("shoot") and player.mag1 > 0 and anim_player.current_animation != "heal" and anim_rifle.current_animation != "Reload" and anim_player.current_animation !=  "spawn":
		#reset_rotation = camera.rotation.x
		shooting = true
	else:
		shooting = false
	if Input.is_action_just_pressed("reload") and anim_player.current_animation != "shoot" and anim_player.current_animation != "heal" and anim_player.current_animation != "spawn":
		if(player.ammo1 > 0 and player.mag1 < magmax):
			reload.rpc()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if not equipped: return
	if player == null:
		player = $"../../../.."
		anim_player = player.anim_player
		cam_parent = $"../../.."
		camera = $"../.."
	
	if not player.is_multiplayer_authority(): return
	if shooting and shotCooldown == 0 and player.mag1 > 0:
		player.mag1 -= 1
		mag_counter.text = str(player.mag1)
		shotCooldown = shotDelay
		play_shoot_effects.rpc()
		if raycast.is_colliding():
			var hit_player = raycast.get_collider()
			if hit_player.team != player.team:
				hit_player.recieve_suit_damage.rpc_id(hit_player.get_multiplayer_authority(), suit_damage)
				hit_player.recieve_damage.rpc_id(hit_player.get_multiplayer_authority(), damage)
	elif shooting:
		shotCooldown -= 1
	
	if current_time < 1:
		r = randi_range(-1, 1)
		current_time += delta
		position.x = lerp(position.z, target_pos.z, lerp_speed * delta)
		camera.rotation.x = lerp(camera.rotation.x, target_rot.x, lerp_speed * delta)
		camera.rotation.y = lerp(camera.rotation.y, target_rot.y*r*0.5, lerp_speed * delta )
		target_rot.y = recoil_rotation_y.sample(current_time) * recoil_amplitude.y
		target_rot.x = recoil_rotation_x.sample(current_time) * recoil_amplitude.x
		target_pos.z = recoil_position_z.sample(current_time) * -recoil_amplitude.z



@rpc("call_local", "any_peer", "reliable")
func play_shoot_effects():
	#if not equipped: return
	r = randi_range(-1, 1)
	target_rot.y = recoil_rotation_y.sample(0)
	target_rot.x = recoil_rotation_x.sample(0)
	target_pos.z = recoil_position_z.sample(0)
	current_time = 0
	shotSound()
	muzzle_flash.restart()
	muzzle_flash.emitting = true
	
func shotSound():
	if not player.is_multiplayer_authority(): return
	audioPlayer.play()

@rpc("call_local", "any_peer")
func reload():
	#if not equipped: return
	anim_rifle.stop()
	anim_rifle.play("Reload")
	if player.ammo1 > magmax:
		player.ammo1 -= (magmax-player.mag1)
		player.mag1 = magmax
	elif player.ammo1>0:
		player.mag1 += player.ammo1
		player.ammo1 = 0
	mag_counter.text = str(player.mag1)
	ammo_counter.text = str(player.ammo1)
	shotCooldown = 0
	


