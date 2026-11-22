@tool
extends Node3D

@export var offset_target: Node3D
@export var radius: int = 16
@export_tool_button("Generate Meshes") var __setup_mmi = _refresh_chunks
@export_tool_button("Clear Meshes") var __clear_mmi = _clear_mmi
@export_tool_button("Refresh Texture") var __refresh_vp_texture = _refresh_vp_texture

@export var ocean_wave_velocity := Vector2.ZERO
@export var ocean_wave_height := 0.2
@export var ocean_wave_frequency := 0.2
@export var ocean_random_noise: NoiseTexture3D

@onready var template_mesh: MeshInstance3D = $TemplateMesh
@onready var chunks: Node3D = $Chunks

var chunk_size: int = -1

func _ready() -> void:
	# print("VP")
	#_refresh_vp_texture()
	if not Engine.is_editor_hint():
		assert(offset_target)
		_refresh_vp_texture()
		_refresh_chunks()

var _target_chunk_pos: Vector2i = Vector2i.ZERO
func _physics_process(_delta: float) -> void:
	chunk_size = template_mesh.mesh.size.x
	var _new_target_chunk_pos = Vector2i(offset_target.global_position.x, offset_target.global_position.z)
	_new_target_chunk_pos /= chunk_size
	if _target_chunk_pos != _new_target_chunk_pos:
		_target_chunk_pos = _new_target_chunk_pos
		_refresh_chunks()

	template_mesh.mesh.material.set_shader_parameter("time", Time.get_ticks_msec())
	template_mesh.mesh.material.set_shader_parameter("ocean_wave_velocity", ocean_wave_velocity)
	template_mesh.mesh.material.set_shader_parameter("ocean_wave_height", ocean_wave_height)
	template_mesh.mesh.material.set_shader_parameter("ocean_wave_frequency", ocean_wave_frequency)
	template_mesh.mesh.material.set_shader_parameter("noise_texture", ocean_random_noise)

	var points = [offset_target.global_position, offset_target.global_position+Vector3.FORWARD, offset_target.global_position+Vector3.RIGHT]
	for i in range(3):
		points[i].y = sample_sea_level(Vector2(points[i].x, points[i].z))
	var plane = Plane(points[0], points[1], points[2])
	var n = plane.normal if plane.normal.y > 0 else -(plane.normal)

	var q := offset_target.global_basis.get_rotation_quaternion()
	var twist := Quaternion(0, q.y, 0, q.w).normalized()
	var tilt := Quaternion(Vector3.UP, n.normalized())
	offset_target.global_basis = Basis(tilt) * Basis(twist)

	offset_target.global_position.y = points[0].y

func _refresh_vp_texture():
	print("refreshing texture")
	template_mesh.mesh.material.set_shader_parameter("albedo_texture", $SubViewport.get_texture())

var _chunks_dict: Dictionary[Vector2i, MeshInstance3D]
func _refresh_chunks():
	chunk_size = template_mesh.mesh.size.x
	var del_array = []
	for mi in _chunks_dict.values():
		var chunk_pos: Vector2i = _chunks_dict.find_key(mi)
		if chunk_pos.distance_to(_target_chunk_pos) > radius:
			del_array.push_back(mi)
	for n in del_array:
		_chunks_dict.erase(_chunks_dict.find_key(n))
		n.queue_free()

	for y in range(_target_chunk_pos.y-radius, _target_chunk_pos.y+radius):
		for x in range(_target_chunk_pos.x-radius, _target_chunk_pos.x+radius):
			var chunk_pos := Vector2i(x,y)
			if _chunks_dict.has(chunk_pos):
				continue
			if chunk_pos.distance_to(_target_chunk_pos) > radius:
				continue
			var mi = MeshInstance3D.new()
			# var am = ArrayMesh.new()
			# am.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, template_mesh.mesh.get_mesh_arrays())
			# am.surface_set_material(0, template_mesh.mesh.material)
			# am.custom_aabb = template_mesh.mesh.custom_aabb
			# mi.mesh = am
			mi.mesh = template_mesh.mesh
			mi.extra_cull_margin = 16.0
			mi.transform = Transform3D(Basis(), Vector3((x+0.5)*chunk_size, 0, (y+0.5)*chunk_size))
			chunks.add_child(mi)
			mi.owner = self
			_chunks_dict[chunk_pos] = mi	

func _clear_mmi():
	for n in chunks.get_children():
		n.queue_free()
	_chunks_dict.clear()

func sample_sea_level(pos: Vector2):
	var _v: Vector2 = ocean_wave_velocity.normalized() * pos * ocean_wave_frequency
	return sin(_v.x + _v.y + Time.get_ticks_msec()/1000.0 * ocean_wave_velocity.length()) * ocean_wave_height

	# var mm = MultiMesh.new()
	# mmi.multimesh = mm
	# mm.transform_format = MultiMesh.TRANSFORM_3D
	# mm.mesh = template_mesh.mesh
	# mm.visible_instance_count = -1
	# mm.instance_count = size ** 2

	# var chunk_size = template_mesh.mesh.size.x
	# var _range = range(-size/2, size/2)
	# var i=0
	# for z in _range:
	# 	for x in _range:
	# 		mm.set_instance_transform(i, Transform3D(Basis(), Vector3((x+0.5)*chunk_size, 0, (z+0.5)*chunk_size)))
	# 		i+=1