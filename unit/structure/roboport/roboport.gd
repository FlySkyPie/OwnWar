extends Unit


export var drone_scene: PackedScene
export var drone_limit := 10
var _drones := []
var _radius2 := 100.0 * 100.0
var _immediate_geometry: ImmediateGeometry
var _units := []
var _needs_material := {}
var _provides_material := []


func _ready():
	_set_radius2(_radius2)


func _physics_process(_delta: float) -> void:
	if len(_provides_material) > 0:
		var provider := _provides_material[0] as Unit
		for unit in _needs_material:
			var drone := _needs_material[unit] as Unit
			if drone == null:
				drone = _get_idle_drone()
				if drone == null:
					break
				drone.task = 1
				drone.task_data = [provider, unit]
				drone.connect("task_completed", self, "_task_completed", [unit, drone])
				_needs_material[unit] = drone
	for drone in _drones:
		pass


func get_actions() -> Array:
	var actions := .get_actions()
	actions += [
			["Set Coverage", Action.INPUT_COORDINATE, "set_coverage_radius", []]
		]
	return actions

func get_info() -> Dictionary:
	var info = .get_info()
	info["Requesters"] = len(_needs_material)
	info["Providers"] = len(_provides_material)
	return info


func show_feedback():
	if _immediate_geometry == null:
		_immediate_geometry = ImmediateGeometry.new()
		_immediate_geometry.material_override = SpatialMaterial.new()
		_immediate_geometry.material_override.albedo_color = Color.orange
		_immediate_geometry.material_override.flags_unshaded = true
		add_child(_immediate_geometry)
	_draw_circle(sqrt(_radius2))


func hide_feedback():
	if _immediate_geometry != null:
		_immediate_geometry.queue_free()
		_immediate_geometry = null


func show_action_feedback(function: String, viewport: Viewport, arguments: Array) -> void:
	match function:
		"set_coverage_radius":
			var position := arguments[1] as Vector3
			var projected_position := Plane(transform.basis.y, 0).project(position)
			_draw_circle(translation.distance_to(projected_position))
		_:
			.show_action_feedback(function, viewport, arguments)


func set_coverage_radius(_flags: int, position: Vector3) -> void:
	_set_radius2(translation.distance_squared_to(position))


func _draw_circle(radius: float) -> void:
	var space_state := get_world().direct_space_state
	_immediate_geometry.clear()
	_immediate_geometry.begin(Mesh.PRIMITIVE_LINE_LOOP)
	for i in range(128):
		var r := i * 2.0 * PI / 128
		var v := to_global(Vector3(cos(r) * radius, 0.0, sin(r) * radius))
		# NOTE: raycast tests against large bodies are very inaccurate because
		# reasons (https://pybullet.org/Bullet/phpBB3/viewtopic.php?t=3524)
		var result := space_state.intersect_ray(v + Vector3.UP * 1000,
				v + Vector3.DOWN * 1000, [], Global.COLLISION_MASK_TERRAIN)
		if len(result) > 0:
			v = result.position + Vector3.UP * 0.025
		_immediate_geometry.add_vertex(to_local(v))
	_immediate_geometry.end()


func _set_radius2(radius2: float) -> void:
	_radius2 = radius2
	for unit in _units:
		unit.disconnect("message", self, "_get_message")
		unit.disconnect("destroyed", self, "_unit_destroyed")
	_needs_material = {}
	_provides_material = []
	for unit in game_master.get_units(team):
		if translation.distance_squared_to(unit.translation) < radius2:
			_units.append(unit)
			unit.connect("message", self, "_get_message", [unit])
			unit.connect("destroyed", self, "_unit_destroyed")
			var needs = unit.request_info("need_material")
			if needs != null and needs > 0:
				_needs_material[unit] = null
			var provides = unit.request_info("provide_material")
			if provides != null and provides > 0:
				_provides_material.append(unit)


func _get_message(message, data, unit):
	match message:
		"need_material":
			var amount = data as int
			if amount == 0:
				_needs_material.erase(unit)
			else:
				if not unit in _needs_material:
					_needs_material[unit] = null
		"provide_material":
			var amount = data as int
			if amount == 0:
				_provides_material.erase(unit)
			else:
				if not unit in _provides_material:
					_provides_material.append(unit)


func _unit_destroyed(unit):
	_units.erase(unit)


func _get_idle_drone() -> Unit:
	for drone in _drones:
		if drone.task == drone.Task.NONE:
			return drone
	if len(_drones) < drone_limit:
		var drone = drone_scene.instance()
		drone.transform = $SpawnPoint.global_transform
		_drones.append(drone)
		game_master.add_unit(team, drone)
		return drone
	return null


func _task_completed(unit: Unit, drone: Unit) -> void:
	_needs_material[unit] = null
	drone.disconnect("task_completed", self, "_task_completed")
