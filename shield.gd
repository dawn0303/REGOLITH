extends StaticBody3D
@onready var col = $CollisionShape3D
@onready var col2 =$StaticBody3D/CollisionShape3D

var equipped = false
var team
var player
# Called when the node enters the scene tree for the first time.
func _ready():
		if player == null:
			player = $"../../../.."
		team = player.team
		if  get_parent().get_name() == "weapon parent" and col.disabled:# and !player.is_multiplayer_authority():
			col.disabled = false
			col2.disabled = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	if player.equipped == 3 and col.disabled:
	#	col.disabled = false
