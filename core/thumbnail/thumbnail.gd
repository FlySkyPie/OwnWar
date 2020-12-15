extends Node


const THUMBNAIL_DIRECTORY := "user://cache/thumbnails"


static func get_thumbnail_async(name: String, callback: FuncRef, arguments := []
	) -> bool:
	var path := _get_path(name)
	if File.new().file_exists(path):
		var img := Image.new()
		var e := img.load(path)
		assert(e == OK)
		callback.call_funcv([img] + arguments)
		return true
	else:
		OwnWar_Thumbnail._create_thumbnail(name, callback, arguments)
		return false


static func _get_path(name: String) -> String:
	return THUMBNAIL_DIRECTORY.plus_file(name + ".png")


func _create_thumbnail(name: String, callback: FuncRef, arguments: Array
	) -> Image:
	while get_child_count() > 16:
		# Cap to 16 to prevent lag when loading a large amount of thumbnails
		yield(get_tree(), "idle_frame")
	var tn: Viewport = preload("thumbnail.tscn").instance()
	add_child(tn)
	var mi: MeshInstance = tn.get_node("MeshInstance")
	var block: OwnWar.Block = OwnWar.Block.get_block(name)
	var path := _get_path(block.name)
	print("Generating thumbnail for ", block.name)
	mi.scale = Vector3.ONE / max(block.size.x, max(block.size.y, block.size.z))
	mi.mesh = block.mesh
	var scene: Spatial
	if block.scene != null:
		scene = block.scene.instance()
		scene.propagate_call("set_script", [null], true)
		scene.transform = mi.transform
		tn.add_child(scene)
	yield(VisualServer, "frame_post_draw")
	yield(VisualServer, "frame_post_draw")
	var img := tn.get_texture().get_data()
	img.convert(Image.FORMAT_RGBA8)
	var e := Util.create_dirs(THUMBNAIL_DIRECTORY)
	assert(e == OK)
	e = img.save_png(path)
	assert(e == OK)
	tn.queue_free()
	callback.call_funcv([img] + arguments)
	return img
