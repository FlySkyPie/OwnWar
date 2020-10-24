extends Unit


#export(Array, Munition) var munition_types := []
export(Array, Resource) var munition_types := []
const _MAX_MATERIAL := 30
const _MAX_MUNITION_VOLUME := 125_000_000
var _material := 0
var _munition := {}
var _munition_volume := 0
var _current_munition_type: Munition
var _producing_munition := false
var _time_between_munitions := 1.0
var _time_until_munition_produced := 0.0
onready var _material_id = Matter.name_to_id["material"]


func _ready():
	_current_munition_type = munition_types[0]


func _physics_process(delta):
	if _producing_munition:
		if _time_until_munition_produced >= _time_between_munitions:
			var id = Matter.name_to_id[_current_munition_type.human_name]
			var volume = Matter.matter_volume[id]
			if _munition_volume + volume < _MAX_MUNITION_VOLUME:
				_munition[id] = _munition.get(id, 0) + 1
				_munition_volume += volume
				_visualize_munitions()
				_producing_munition = false
				_time_until_munition_produced -= _time_between_munitions
				emit_signal("dump_matter", id, _munition[id])
				emit_signal("provide_matter", id, _munition[id])
		else:
			_time_until_munition_produced += delta
	else:
		if _current_munition_type.cost <= _material:
			_material -= _current_munition_type.cost
			emit_signal("need_matter", _material_id, _MAX_MATERIAL - _material)
			_producing_munition = true


func get_actions():
	var actions = []
	for munition_type in munition_types:
		actions.append([
				"Produce %s" % str(munition_type),
				Action.INPUT_NONE,
				"set_munition_type",
				[munition_type],
			])
	return actions


func get_info():
	var info = .get_info()
	info["Material"] = "%d / %d" % [_material, _MAX_MATERIAL]
	info["Producing"] = str(_current_munition_type)
	info["Volume"] = "%d / %d" % [_munition_volume / 1_000_000, _MAX_MUNITION_VOLUME / 1_000_000]
	for m in _munition:
		info[Matter.matter_name[m]] = _munition[m]
	return info


func needs_matter(id: int) -> int:
	return _MAX_MATERIAL - _material if _material_id == id else 0


func dumps_matter(id: int) -> int:
	return _munition.get(id, 0)


func provides_matter(id: int) -> int:
	return _munition.get(id, 0)


func get_matter_count(id: int) -> int:
	if id == _material_id:
		return _material
	return _munition.get(id, 0)


func get_matter_space(id: int) -> int:
	if id == _material_id:
		return _MAX_MATERIAL - _material
	elif Munition.is_munition(id):
		var v := Matter.matter_volume[id]
# warning-ignore:integer_division
		return (_MAX_MUNITION_VOLUME - _munition_volume) / v
	return 0


func get_put_matter_list() -> PoolIntArray:
	return PoolIntArray([_material])


func get_take_matter_list() -> PoolIntArray:
	return PoolIntArray(RegisterMunition.id_to_munitions.keys())


func put_matter(id: int, amount: int) -> int:
	if id == _material_id:
		var remainder = 0
		_material += amount
		if _material > _MAX_MATERIAL:
			remainder = _material - _MAX_MATERIAL
			_material = _MAX_MATERIAL
			emit_signal("need_matter", _material_id, _MAX_MATERIAL - _material)
		return remainder
	return amount


func take_matter(id: int, amount: int) -> int:
	if id in _munition:
		if _munition[id] >= amount:
			_munition[id] -= amount
		else:
			amount = _munition[id]
# warning-ignore:return_value_discarded
			_munition.erase(id)
		_munition_volume -= amount * Matter.matter_volume[id]
		_visualize_munitions()
		emit_signal("dump_matter", id, _munition.get(id, 0))
		emit_signal("provide_matter", id, _munition.get(id, 0))
		return amount
	return 0


func set_munition_type(_flags, munition_type):
	_current_munition_type = munition_type


func _visualize_munitions():
	var id = Matter.name_to_id[_current_munition_type.human_name]
	$MultiMeshInstance.multimesh.mesh = _current_munition_type.mesh
	$MultiMeshInstance.multimesh.instance_count = _munition.get(id, 0)
	for i in range(_munition.get(id, 0)):
		var munition_transform := Transform2D(Vector2.UP, Vector2.RIGHT,
			Vector2(i % 5, i / 5.0) / 3.0)
		$MultiMeshInstance.multimesh.set_instance_transform_2d(i, munition_transform)
