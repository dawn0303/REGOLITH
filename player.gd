extends CharacterBody3D

signal health_changed(health_value)
signal suit_changed(suit_value)
signal patches_changed(patches_value)
signal boost_changed(boost_value)
signal weapon_1(weapon_1_scene)
signal weapon_2(weapon_2_scene)
signal gear_1(gear_scene)

@onready var camera = $CameraParent/Camera3D
@onready var anim_player = $AnimationPlayer
@onready var weapon_parent = $"CameraParent/Camera3D/weapon parent"
@onready var holster1 = $MeshInstance3D/MeshInstance3D2/holster1
@onready var holster2 = $MeshInstance3D/MeshInstance3D2/holster2
@onready var holstergear = $MeshInstance3D/MeshInstance3D2/holstergear
@onready var aim_point = $CameraParent/Camera3D/aimPoint
@onready var raycast = $CameraParent/Camera3D/RayCast3D
@onready var cam_parent = $CameraParent
@onready var team_1_indicator = $Team1Ind
@onready var team_2_indicator = $Team2Ind

@onready var AnimTree = $z2anim/AnimationTree
@onready var animBody = $z2anim

@onready var audioPlayer = $AudioStreamPlayer

const Rock = preload("res://rock.tscn")
const Rifle = preload("res://space_rifle_test.tscn")
const shield = preload("res://shield.tscn")

var ammo1 = 0
var ammo2 = 0
var mag1 = 0
var mag2 = 0
var throwables = 3
var weapon1# = Rifle
var weapon2# = Rock
var gear
var gadget
var melee

var health = float(100)
var suit = float(100)
var patches = 3
var timer = 0
var equipped = 0

var localVel3 = Vector3(0,0,0)

var team

var control = false
var landing = true

var def_weapon_parent_pos
var mouse_input : Vector2
const sway_amount = 0.004
const tilt_amount = 0.05
const SPEED = 3
const THRUST = 1.0
const JUMP_VELOCITY = 2
const maxboost = 1000
var boost = 1000

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _enter_tree():
	set_multiplayer_authority(str(name).to_int())

func _ready():
	
	randomize()
	add_to_group("Players")
	
	if get_parent().Team1count > get_parent().Team2count:
		team = "Team2"
		get_parent().Team2count += 1
		print(str("Team2"))
		team_2_indicator.show()
		team_1_indicator.hide()
	elif get_parent().Team2count > get_parent().Team1count:
		team = "Team1"
		get_parent().Team1count += 1
		print(str("Team1"))
		team_1_indicator.show()
		team_2_indicator.hide()
	elif randf() < 0.5:
		team = "Team1"
		get_parent().Team1count += 1
		print(str("Team1"))
		team_1_indicator.show()
		team_2_indicator.hide()
	else:
		team = "Team2"
		get_parent().Team2count += 1
		print(str("Team2"))
		team_2_indicator.show()
		team_1_indicator.hide()
	
	#equip_weapons.rpc()
	weapon1 = get_parent().weapon1
	weapon2 = get_parent().weapon2
	gear = get_parent().gear
	if not is_multiplayer_authority(): 
		animBody.show()
		if equipped == 1:
			holster1.get_child(0,false).reparent(weapon_parent, false)
			weapon_parent.get_child(0,false).equipped = true
			equipped = 1
		if equipped == 2:
			holster2.get_child(0,false).reparent(weapon_parent, false)
			weapon_parent.get_child(0,false).equipped = true
			equipped = 2
		return
	audioPlayer.playing = true
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	camera.current = true
	equip_weapons.rpc()
	anim_player.play("spawn")
	def_weapon_parent_pos = weapon_parent.position

func _unhandled_input(event):
	if not is_multiplayer_authority(): return
	if event is InputEventMouseMotion:
		mouse_input = event.relative
		if control:
			rotate_y(-event.relative.x * .005)
			cam_parent.rotate_x(-event.relative.y * .005)
			cam_parent.rotation.x = clamp(cam_parent.rotation.x, (-PI/2 +0.42), (PI/2 - 0.4))
		if not control:
			#rotate_y(-event.relative.x * .005)
			#rotation.x = clamp(rotation.x, -PI/4, PI/4)
			cam_parent.rotate_x(-event.relative.y * .005)
			cam_parent.rotation.x = clamp(cam_parent.rotation.x, -PI/2, PI/4)


func _physics_process(delta):
	if not is_multiplayer_authority(): return
	if is_on_floor():
		body_animate.rpc()
	#if landing and velocity.x > 0:
		#velocity.z -= 1000/60
		#velocity.x -= 100/60
		
	
	
	aim_point.global_position.x = lerp(aim_point.global_position.x, raycast.get_collision_point().x, 15*delta )#.normalized()
	aim_point.global_position.y = lerp(aim_point.global_position.y, raycast.get_collision_point().y, 15*delta )
	aim_point.global_position.z = lerp(aim_point.global_position.z, raycast.get_collision_point().z, 15*delta )
	#weapon_parent.rotation.y += PI/2
	
	weapon_parent.look_at(aim_point.global_position, Vector3(0, 1, 0))#Vector3(PI/2, 0, 0))
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	if not control: return
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	if Input.is_action_just_pressed("heal") and suit < 100 and patches > 0 and anim_player.current_animation != "shoot" and anim_player.current_animation != "reload" :
		play_heal_effects.rpc()
		suit += 25
		suit = clamp(suit, 0, 100)
		patches -= 1
		suit_changed.emit(suit)
		patches_changed.emit(patches)
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction and is_on_floor():
		velocity.x = move_toward(velocity.x, (direction.x * SPEED) , 0.2)
		velocity.z =  move_toward(velocity.z, (direction.z * SPEED) , 0.2)
	elif boost > 0 and Input.is_action_pressed("boost") and direction and not is_on_floor():
		velocity.x = move_toward(velocity.x, (direction.x * 2 * SPEED) , THRUST/30)
		velocity.z =  move_toward(velocity.z, (direction.z * 2 * SPEED) , THRUST/30)
		boost -= 2
		boost_changed.emit(boost)
	elif is_on_floor():
		velocity.x = move_toward(velocity.x, 0, 0.5)
		velocity.z = move_toward(velocity.z, 0, 0.5)
	if boost > 0 and Input.is_action_pressed("boost") and not is_on_floor():
		velocity.y += THRUST/60
		boost -=1
		boost_changed.emit(boost)
	if not Input.is_action_pressed("boost") and boost < 1000:
		boost += 0.2
		boost_changed.emit(boost)
	#localVel3 =  Vector3(input_dir.x, 0, input_dir.y)
	localVel3.x = move_toward(localVel3.x, input_dir.x, 0.2/SPEED)
	localVel3.z = move_toward(localVel3.z, input_dir.y, 0.2/SPEED)
	
	cam_tilt(input_dir.x, delta)
	weapon_tilt(input_dir.x, delta)
	#weapon_sway(delta)
	
	weapon_bob(velocity.length(), delta)
	
	#if anim_player.current_animation == "shoot" or anim_player.current_animation == "heal"or anim_player.current_animation == "reload":
		#pass
	#elif input_dir != Vector2.ZERO and is_on_floor():
		#anim_player.play("move")
	#else:
		#anim_player.play("idle")
	

	
	
	if Input.is_action_just_pressed("1")  and anim_player.current_animation != "shoot" and anim_player.current_animation != "reload" :
		switch_weapon_1.rpc()

	if Input.is_action_just_pressed("2")  and anim_player.current_animation != "shoot" and anim_player.current_animation != "reload" :
		switch_weapon_2.rpc()

	if Input.is_action_just_pressed("3")  and anim_player.current_animation != "shoot" and anim_player.current_animation != "reload" :
		switch_gear.rpc()
		
	move_and_slide()
	
	if suit < 100:
		suitLeak()
	
	#AnimTree.set("parameters/BlendSpace2D/blend_position", Vector2(velocity.z/SPEED, velocity.x/SPEED) )
	



@rpc("call_local")
func play_heal_effects():
	anim_player.stop()
	anim_player.play("heal")

@rpc("call_local", "reliable")
func body_animate():
	#print(str(localVel3))
	#print(str(velocity))
	AnimTree.set("parameters/BlendSpace2D/blend_position", Vector2(localVel3.z*SPEED, -localVel3.x*SPEED) )
	#if is_on_floor():
		#AnimTree.set("parameters/BlendSpace2D/blend_position", Vector2(velocity.z/SPEED, velocity.x/SPEED) )
	#else:
		#AnimTree.set("parameters/BlendSpace2D/blend_position", Vector2(0,0) )
	#

@rpc("call_local", "reliable")
func equip_weapons():
	if not is_multiplayer_authority(): return
	
	holster1.add_child(weapon1.instantiate())
	mag1 = holster1.get_child(1,true).magmax
	ammo1 = holster1.get_child(1,true).poolmax
	weapon_1.emit(weapon1)
	
	holster2.add_child(weapon2.instantiate())
	mag2 = holster2.get_child(1,true).magmax
	ammo2 = holster2.get_child(1,true).poolmax
	weapon_2.emit(weapon2)
	
	holstergear.add_child(gear.instantiate())
	gear_1.emit(gear)
	
	equipped = 0

@rpc("call_local", "reliable")
func switch_weapon_1():
	if not is_multiplayer_authority(): return
	
	if equipped == 1: return
	if holster2.get_child_count() == 1:
		weapon_parent.get_child(1,true).free()
		holster2.add_child(weapon2.instantiate(), true)
		holster2.get_child(1,false).equipped = false
	
	if holstergear.get_child_count() == 1:
		weapon_parent.get_child(1,true).free()
		holstergear.add_child(gear.instantiate(), true)
		holstergear.get_child(1,false).equipped = false
	
	if holster1.get_child_count() == 2:
		holster1.get_child(1,true).free()
	weapon_parent.add_child(weapon1.instantiate(), true)
	weapon_parent.get_child(1,false).equipped = true
	equipped = 1

@rpc("call_local", "reliable")
func switch_weapon_2():
	if not is_multiplayer_authority(): return
	
	if equipped == 2: return
	if holster1.get_child_count() == 1:
		weapon_parent.get_child(1,true).free()
		holster1.add_child(weapon1.instantiate(), true)
		holster1.get_child(1,false).equipped = false
	if holster2.get_child_count() == 2:
		holster2.get_child(1,true).free()
	weapon_parent.add_child(weapon2.instantiate(), true)
	weapon_parent.get_child(1,false).equipped = true
	equipped = 2

@rpc("call_local", "reliable")
func switch_gear():
	if not is_multiplayer_authority(): return
	
	if equipped == 3: return
	if holster2.get_child_count() == 1:
		weapon_parent.get_child(1,true).free()
		holster2.add_child(weapon2.instantiate(), true)
		holster2.get_child(1,false).equipped = false
	if holster1.get_child_count() == 1:
		weapon_parent.get_child(1,true).free()
		holster1.add_child(weapon1.instantiate(), true)
		holster1.get_child(1,false).equipped = false
	if holstergear.get_child_count() == 2:
		holstergear.get_child(1,true).free()
	weapon_parent.add_child(gear.instantiate(), true)
	weapon_parent.get_child(1,false).equipped = true
	equipped = 3
	
@rpc("call_local", "any_peer")
func recieve_damage(dmg):
	if not control: return
	health -= dmg
	if health <=0:
		health = 100
		suit = 100
		patches = 3
		position.x = randf_range(-200.0, 200.0)
		position.z = randf_range(-200.0, 200.0)
		randomize()
		control = false
		if weapon_parent.get_child_count() == 2:
			weapon_parent.get_child(1,true).free()
		if holster2.get_child_count() == 2:
			holster2.get_child(1,true).free()
		if holster1.get_child_count() == 2:
			holster1.get_child(1,true).free()
		equip_weapons.rpc()
		anim_player.play("spawn")
	health_changed.emit(health)
	suit_changed.emit(suit)
	patches_changed.emit(patches)

@rpc("call_local", "any_peer")
func recieve_suit_damage(dmg):
	if not control: return
	if suit > 0:
		suit -= dmg
		suit_changed.emit(suit)
	elif dmg > suit:
		suit = 0
		suit_changed.emit(suit)

func suitLeak():
	timer += 1
	if timer > suit:
		recieve_damage(1)
		timer = 0

func _on_animation_player_animation_finished(anim_name):
	#if anim_name == "shoot" or anim_name == "heal" or anim_name == "reload":
		#anim_player.play("idle")
	if anim_name == "spawn":
		control = true
		#anim_player.play("idle")
		switch_weapon_1.rpc()

@rpc("call_local", "reliable")
func spawn():
		landing = true
		control = false
		health = 100
		suit = 100
		patches = 3
		position = Vector3(0, 100, 10)
		velocity += Vector3(0, 0, 1000)
	


func cam_tilt(x, delta):
	if cam_parent:
		cam_parent.rotation.z = lerp(cam_parent.rotation.z, -x * tilt_amount, 1 * delta)

func weapon_tilt(x, delta):
	if weapon_parent:
		weapon_parent.rotation.x = lerp(weapon_parent.rotation.x, x * tilt_amount*2, 1 * delta)

func weapon_sway(delta):
	mouse_input = lerp(mouse_input,Vector2.ZERO,10*delta)
	weapon_parent.rotation.z = lerp(weapon_parent.rotation.z, mouse_input.y * sway_amount, 10*delta)
	weapon_parent.rotation.y = lerp(weapon_parent.rotation.y, (mouse_input.x * sway_amount)+PI/2, 10*delta)

func weapon_bob(vel : float, delta):
	if vel > 0 and is_on_floor():
		var bob_amount = 0.05
		var bob_freq = 0.005
		weapon_parent.position.y = lerp(weapon_parent.position.y, def_weapon_parent_pos.y + sin(Time.get_ticks_msec() * bob_freq) * bob_amount, SPEED*delta)
		weapon_parent.position.x = lerp(weapon_parent.position.x, def_weapon_parent_pos.x + sin(Time.get_ticks_msec() * bob_freq*0.5) * bob_amount, SPEED*delta)
	else:
		var bob_amount = 0.01
		var bob_freq = 0.001
		weapon_parent.position.y = lerp(weapon_parent.position.y, def_weapon_parent_pos.y + sin(Time.get_ticks_msec() * bob_freq) * bob_amount, SPEED*delta)
		weapon_parent.position.x = lerp(weapon_parent.position.x, def_weapon_parent_pos.x + sin(Time.get_ticks_msec() * bob_freq*0.5) * bob_amount, SPEED*delta)
