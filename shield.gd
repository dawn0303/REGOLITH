extends StaticBody3D

var equipped = false
var team
var player
# Called when the node enters the scene tree for the first time.
func _ready():
		if player == null:
			player = $"../../../.."
		team = player.team


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
