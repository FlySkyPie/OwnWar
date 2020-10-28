extends Resource


const _ID_TO_MUNITION := {}


export var human_name := ""
# warning-ignore:unused_class_variable
export var shell: PackedScene
# warning-ignore:unused_class_variable
export var mesh: Mesh
# warning-ignore:unused_class_variable
export var cost := 1
# warning-ignore:unused_class_variable
export var shells_per_batch := 1
# warning-ignore:unused_class_variable
export var gauge := -1


func _to_string():
	return human_name


static func is_munition(id: int) -> bool:
	return id in _ID_TO_MUNITION


static func get_munition_ids() -> PoolIntArray:
	return PoolIntArray(_ID_TO_MUNITION.keys())


static func get_munition(id: int) -> Resource:
	return _ID_TO_MUNITION[id]


static func add_munition(m) -> int:
	# Ammo containers generally pack munition in a square pattern
	# Pretend that length = gauge * 3
	var volume: int = m.gauge * m.gauge * (m.gauge * 3)
	var id := Matter.add_matter(m.human_name, volume)
	_ID_TO_MUNITION[id] = m
	return id
