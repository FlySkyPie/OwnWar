extends Unit


export var max_material := 10000
export var material := 0 setget set_material


func _ready():
	set_material(material)


func get_info():
	var info = .get_info()
	info["Material"] = str(material) + " / " + str(max_material)
	return info


func put_material(p_material):
	var max_put = max_material - material
	if max_put > p_material:
		self.material += p_material
		return 0
	else:
		self.material = max_material
		return p_material - max_put


func take_material(p_material, exact = false):
	if material > p_material:
		self.material -= p_material
		return p_material
	elif exact:
		return 0
	else:
		var remainder = material
		self.material = 0
		return remainder


func set_material(p_material):
	assert(0 <= p_material and p_material <= max_material)
	material = p_material
	$Indicator.scale.y = float(material) / max_material
