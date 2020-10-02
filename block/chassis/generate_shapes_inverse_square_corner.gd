extends "res://block/chassis/generate_shapes.gd"


func _init():
	name = "inverse_corner"
	._set_indices_count(9)


func start(segments: int, scale: Vector3, offset: Vector3):
	.start(segments, scale, offset)
	step()


func step():
	.step()
	var fractions = PoolRealArray()
	for index in indices:
		fractions.append(float(index) / float(segments))
		
	var x = Vector3(fractions[0], 0, 0)
	var y = Vector3(0, fractions[1], 0)
	var z = Vector3(0, 0, fractions[2])
	var u = Vector3(0, fractions[3], fractions[4])
	var v = Vector3(fractions[5], 0, fractions[6])
	var w = Vector3(fractions[7], fractions[8], 0)
	
	var vertices = PoolVector3Array()
	var normals = PoolVector3Array()
	
	var normal_x = (v - x).cross(x - w).normalized()
	var normal_z = (u - z).cross(z - v).normalized()
	var normal_ex = (y - w).cross(v - y).normalized()
	var normal_ez = (y - u).cross(y - v).normalized()
	
	for vertex in [Vector3.ZERO, y, u, Vector3.ZERO, u, z]: # -X
		vertices.append(vertex)
		normals.append(Vector3.LEFT)
	for vertex in [Vector3.ZERO, v, x, Vector3.ZERO, z, v]: # -Y
		vertices.append(vertex)
		normals.append(Vector3.DOWN)
	for vertex in [Vector3.ZERO, x, w, Vector3.ZERO, w, y]: # -Z
		vertices.append(vertex)
		normals.append(Vector3.FORWARD)
	for vertex in [x, v, w]: # +X 
		vertices.append(vertex)
		normals.append(normal_x)
	for vertex in [z, u, v]: # +Z
		vertices.append(vertex)
		normals.append(normal_z)
	for vertex in [y, w, v]: # E (X)
		vertices.append(vertex)
		normals.append(normal_ex)
	for vertex in [y, v, u]: # E (Z)
		vertices.append(vertex)
		normals.append(normal_ez)
	
	var array = []
	array.resize(Mesh.ARRAY_MAX)
	array[Mesh.ARRAY_VERTEX] = vertices
	array[Mesh.ARRAY_NORMAL] = normals
	result = ArrayMesh.new()
	result.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, array)
