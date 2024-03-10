extends Node3D

var amount = 1
var equipped = false
var health = 100


@rpc('any_peer', "call_local")
func place():
	return


@rpc("call_local", "any_peer")
func recieve_damage(dmg):
	health -= dmg
	if health == 0:
		queue_free()
