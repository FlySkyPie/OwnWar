const PLUGIN_ID := "weapon_manager"
const PLUGIN_VERSION := Vector3(0, 0, 1)
const MIN_VERSION := Vector3(0, 12, 0)


const Munition := preload("munition.gd")


func _init():
	Block.add_block(preload("ammo_rack.tres"))
	Vehicle.add_manager("weapon", preload("weapon_manager.gd"))
