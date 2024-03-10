extends Node


func _ready():
	name = str(get_multiplayer_authority())
	$MultiplayerSynchronizer.set_multiplayer_authority(str(name).to_int())


@rpc("call_local")
func play_heal_effects():
	return

@rpc("call_local", "reliable")
func body_animate():
	return

@rpc("call_local", "reliable")
func equip_weapons():
	return


@rpc("call_local", "reliable")
func switch_weapon_1():
	return



@rpc("call_local", "reliable")
func switch_weapon_2():
	return


@rpc("call_local", "reliable")
func switch_gear():
	return

	
@rpc("call_local", "any_peer")
func recieve_damage(_dmg):
	return


@rpc("call_local", "any_peer")
func recieve_suit_damage(_dmg):
	return

@rpc("call_local", "reliable")
func spawn():
	return
