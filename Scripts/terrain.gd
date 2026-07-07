extends Node3D

@export var terrain_size: int = 128
@export var terrain_height: float = 20.0
@export var base_seed: int = 12345
@export var regenerate: bool = false
@export var threshold: float

@onready var mesh_instance: MeshInstance3D = $"MeshInstance3D"
@onready var collision_shape: CollisionShape3D = $"StaticBody3D/CollisionShape3D"

func _ready():
	regenerate_terrain(base_seed)
	
func _process(delta: float):
	if (regenerate):
		regenerate_terrain(base_seed)
		regenerate = false

func regenerate_terrain(seed: float = 0):
	var noise := FastNoiseLite.new()
	noise.seed = seed
	noise.frequency = 0.05

	var vertices := PackedVector3Array()
	var uvs := PackedVector2Array()
	var indices := PackedInt32Array()
	var heights := PackedFloat32Array()

	for z in range(terrain_size):
		for x in range(terrain_size):
			var h = noise.get_noise_2d(x, z) * terrain_height
			h = max(h, threshold)
			vertices.append(Vector3(x, h, z))
			uvs.append(Vector2(float(x) / float(terrain_size - 1), float(z) / float(terrain_size - 1)))
			heights.append(h)

	for z in range(terrain_size - 1):
		for x in range(terrain_size - 1):
			var i = z * terrain_size + x
			indices.append_array([i, i + terrain_size, i + 1, i + 1, i + terrain_size, i + terrain_size + 1])

	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)

	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_INDEX] = indices

	var st = SurfaceTool.new()
	st.create_from_arrays(arrays)
	st.generate_normals()

	var terrain_mesh = st.commit()
	mesh_instance.mesh = terrain_mesh
	#mesh_instance.mesh.surface_set_material(0, shader)

	var heightmap := HeightMapShape3D.new()
	heightmap.map_width = terrain_size
	heightmap.map_depth = terrain_size
	heightmap.map_data = heights
	collision_shape.shape = heightmap
