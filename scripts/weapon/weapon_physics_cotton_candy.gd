extends WeaponPhysicsBase

@export var wave_frames := 30
@export var base_wave_speed := 0.0
@export var max_wave_speed := 5.0
@export var speed_threshold := 1.0
@export var physics_root_path: NodePath
@onready var physics_root: Node = get_node_or_null(physics_root_path)

var physics_body : RigidBody3D 
var mat: ShaderMaterial
var curr_root_pos : Vector3
var last_root_pos : Vector3
var curr_wave_speed : float
var cached_velocity
var smooth_dir: Vector3 = Vector3.ZERO
var wave_frames_left := 0

func _init_physics():
	for i in range(mesh.mesh.get_surface_count()):
		var m := mesh.get_active_material(i)
		if m is ShaderMaterial:
			var sm := m.duplicate()
			mesh.set_surface_override_material(i, sm)
			mat = sm
			break

	if mat == null:
		push_error("No ShaderMaterial found on mesh surfaces")

	for c in physics_root.get_children():
		if c is RigidBody3D:
			physics_body = c

	last_root_pos = physics_body.global_position


func _physics_process(delta):
	calculate_wave_effect(delta)


func calculate_wave_effect(delta):
	curr_root_pos = physics_body.global_position
	var velocity: Vector3 = (curr_root_pos - last_root_pos) / delta
	last_root_pos = curr_root_pos

	var speed := velocity.length()

	if speed >= speed_threshold:
		cached_velocity = velocity
		curr_wave_speed = clamp(
			(speed - speed_threshold) * 1.2,
			base_wave_speed,
			max_wave_speed
		)/10
		wave_frames_left = wave_frames

	elif wave_frames_left > 0:
		wave_frames_left -= 1

	var movement := Vector3.ZERO
	var wave_speed := base_wave_speed

	if wave_frames_left > 0:
		movement = cached_velocity
		wave_speed = curr_wave_speed
	else:
		return
		
	var dir := movement
	if dir.length() > 0.0001:
		dir = dir.normalized()
		smooth_dir = smooth_dir.lerp(dir, 0.15)
	else:
		smooth_dir = smooth_dir.lerp(Vector3.ZERO, 0.1)

	mat.set_shader_parameter("movement_dir", smooth_dir)
	mat.set_shader_parameter("wave_speed", wave_speed)
