extends Node


func _ready():
	name = str(get_multiplayer_authority())


@rpc("call_local")
func play_heal_effects():pass

##Here
@rpc("call_local", "reliable")
func body_animate():pass

@rpc
func equip_weapons():pass

##Here
@rpc("call_local", "reliable")
func switch_weapon_1():pass

##Here
@rpc("call_local", "reliable")
func switch_weapon_2():pass


##Here
@rpc("call_local", "any_peer")
func recieve_damage(dmg):pass

##Here
@rpc("call_local", "any_peer")
func recieve_suit_damage(dmg):pass

##Here
@rpc("call_local", "reliable")
func spawn():pass
