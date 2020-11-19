const PLUGIN_ID = "campaign_abcd"
const PLUGIN_VERSION = Vector3(0, 0, 1)
const MIN_VERSION = Vector3(0, 12, 0)
const PLUGIN_DEPENDENCIES := {
		"chassis_blocks": Vector3(0, 0, 1),
		"basic_manufacturing": Vector3(0, 0, 1),
		"worker_drone": Vector3(0, 0, 1),
		"cannon": Vector3(0, 0, 1),
		"mainframe": Vector3(0, 0, 1),
		"wheel": Vector3(0, 0, 1),
		"engine": Vector3(0, 0, 1),
		"turret": Vector3(0, 0, 1),
	}


static func pre_init(_plugin_path: String):
	Maps.add_map("campaign_abcd", _plugin_path.plus_file("map.tscn"))


static func init(_plugin_path: String):
	pass


static func post_init(_plugin_path: String):
	pass


static func save_game(_game_master: GameMaster) -> Dictionary:
	return {}


static func load_game(_game_master: GameMaster, _data: Dictionary) -> void:
	pass
