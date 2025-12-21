extends WeaponPhysicsBase

@export var base_wave_speed := 0.0
@export var max_wave_speed := 5.0
#@export var physics_root_path: NodePath
#@onready var physics_root: Node = get_node_or_null(physics_root_path)

var mat: ShaderMaterial
var curr_root_pos : Vector3
var last_root_pos : Vector3
var curr_wave_speed : float
var cached_velocity
var smooth_dir: Vector3 = Vector3.ZERO

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

	is_ready = true


func _physics_process(delta):
	if active_swing_frames_left < 1:
		calculate_if_swing(body,delta)
	calculate_wave_effect(delta)


func calculate_wave_effect(delta):
	curr_root_pos = body.global_position
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
		active_swing_frames_left = active_swing_frames

	var movement := Vector3.ZERO
	var wave_speed := base_wave_speed

	if active_swing_frames_left > 0:
		active_swing_frames_left -= 1
		movement = velocity
		wave_speed = base_wave_speed
	else:
		weapon_collision.is_active = false
		return
		
	var dir := movement
	if dir.length() > 0.0001:
		dir = dir.normalized()
		smooth_dir = smooth_dir.lerp(dir, 0.15)
	else:
		smooth_dir = smooth_dir.lerp(Vector3.ZERO, 0.1)

	mat.set_shader_parameter("movement_dir", smooth_dir)
	mat.set_shader_parameter("wave_speed", wave_speed)
