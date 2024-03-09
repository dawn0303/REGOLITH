extends RigidBody3D
@onready var col = $CollisionShape3D
@onready var col2 =$RigidBody3D/CollisionShape3D

var equipped = false
var team
var player
var amount = 10
var tag = "gear"
# Called when the node enters the scene tree for the first time.
func _ready():
		if player == null:
			player = $"../../../.."
		team = player.team
		if  get_parent().get_name() == "weapon parent" and col.disabled:# and !player.is_multiplayer_authority():
			col.disabled = false
			col2.disabled = false


func equip():
	equipped = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	if player.equipped == 3 and col.disabled:
	#	col.disabled = false

