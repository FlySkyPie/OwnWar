extends Unit


signal spawned(unit)
# Thank cyclic PackedScene errors for this
export(PackedScene) var worker = load("res://unit/worker/drone.tscn")
var material = 0 setget set_material
var queued_vehicle = null
var queued_vehicle_name
onready var _material_id = Matter.name_to_id["material"]


func _ready():
	unit_name = "spawn_platform"
	set_material(material)
	$IndicatorVehicle.material_override = $IndicatorVehicle.material_override.duplicate()
	$IndicatorVehicle.material_override.albedo_color = Color.green
	add_user_signal("dump_matter", [{"name": "amounts", "type": TYPE_DICTIONARY}])


func _notification(notification):
	match notification:
		NOTIFICATION_PREDELETE:
			if queued_vehicle != null:
				queued_vehicle.free()


func get_info():
	var info = .get_info()
	info["Material"] = "%d / %d" % [material, _get_needed_material()]
	if queued_vehicle != null:
		info["Queued"] = queued_vehicle_name
	return info


func get_actions():
	var actions = [["Spawn Drone", Action.INPUT_NONE, "spawn_worker", []]]
	var directory = Directory.new()
	var err = directory.open(Global.DIRECTORY_USER_VEHICLES)
	if err == OK:
		directory.list_dir_begin(true)
		var file_name = directory.get_next()
		while file_name != "":
			if not directory.current_is_dir() and \
					file_name.ends_with(Global.FILE_EXTENSION):
				var action_name = "Spawn " + Vehicle.path_to_name(file_name)
				var path = directory.get_current_dir() + '/' + file_name
				actions.append([action_name, 0, "spawn_vehicle", [path]])
			file_name = directory.get_next()
	else:
		Global.error(err)
	return actions


func request_info(info: String):
	if info == "need":
		return {_material_id: queued_vehicle.get_cost() - material}
	return .request_info(info)


func get_interaction_port() -> Vector3:
	return $InteractionPort.global_transform.origin


func spawn_worker(_flags):
	if queued_vehicle != null:
		queued_vehicle.free()
	queued_vehicle = worker.instance()
	$IndicatorVehicle.material_override.albedo_color = Color.orange
	queued_vehicle.global_transform = global_transform
	queued_vehicle.translate(Vector3.UP * 5)
	queued_vehicle.rotate_y(PI)
	queued_vehicle_name = "Worker Drone"
	emit_signal("need", {_material_id: _get_needed_material()})
	return queued_vehicle


func spawn_vehicle(_flags, path):
	if queued_vehicle != null:
		queued_vehicle.free()
	queued_vehicle = load(Global.SCENE_VEHICLE).instance()
	var err = queued_vehicle.load_from_file(path)
	if err != OK:
		Global.error("Failed to spawn vehicle from '%s'" % path, err)
		queued_vehicle.free()
		queued_vehicle = null
		$IndicatorVehicle.material_override.albedo_color = Color.red
	else:
		queued_vehicle.global_transform = global_transform
		queued_vehicle.translate(Vector3.UP * 5)
		queued_vehicle.rotate_y(PI)
		$IndicatorVehicle.material_override.albedo_color = Color.orange
		queued_vehicle_name = Vehicle.path_to_name(path.get_file())
	emit_signal("need", {_material_id: _get_needed_material()})
	return queued_vehicle


func set_material(p_material):
	assert(0 <= p_material)
	material = p_material
	emit_signal("need", {_material_id: _get_needed_material()})
	if queued_vehicle == null:
		$IndicatorMaterial.scale.z = 0 if material == 0 else 1
	else:
		$IndicatorMaterial.scale.z = clamp(float(material) / queued_vehicle.get_cost(), 0, 1)


func get_matter_count(id: int) -> int:
	if id == _material_id and queued_vehicle != null:
		return queued_vehicle.get_cost()
	return 0


func get_matter_space(id: int) -> int:
	if id == _material_id and queued_vehicle != null:
		return queued_vehicle.get_cost() - material
	return 0


func get_put_matter_list() -> PoolIntArray:
	return PoolIntArray([_material_id])


func get_take_matter_list() -> PoolIntArray:
	return PoolIntArray([_material_id])


func put_matter(id: int, amount: int) -> int:
	if id == _material_id:
		if queued_vehicle == null:
			return amount
		self.material += amount
		if material >= queued_vehicle.get_cost():
			game_master.add_unit(team, queued_vehicle)
			emit_signal("spawned", queued_vehicle)
			var remainder = material - queued_vehicle.get_cost()
			queued_vehicle = null
			self.material = 0
			$IndicatorVehicle.material_override.albedo_color = Color.green
			return remainder
		return 0
	return amount


func _get_needed_material():
	return 0 if queued_vehicle == null else queued_vehicle.get_cost() - material
