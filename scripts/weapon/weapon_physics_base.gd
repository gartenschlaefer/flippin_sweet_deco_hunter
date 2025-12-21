extends Node3D
class_name WeaponPhysicsBase

@onready var cam : Camera3D = get_viewport().get_camera_3d()
@export var speed_threshold := 1.0
@export var velocity_smooth := 10.0
@export var body : RigidBody3D
@export var weapon_collision : WeaponCollisionBase
@export var active_swing_frames := 30
@export var weapon: WeaponBase

var active_swing_frames_left := 0
var skeleton: Skeleton3D
var mesh: MeshInstance3D
var segs: Array[RigidBody3D] = []
var offsets: Array = []
var _initialized := false
var is_ready : bool
var last_body_pos : Vector3
var last_cam_pos : Vector3
var cam_to_body_dir := Vector3.ZERO
var filtered_velocity := Vector3.ZERO
var is_swinging:bool

func _physics_process(_delta: float) -> void:
	pass

func setup(_skeleton: Skeleton3D, _mesh: MeshInstance3D):
	if _initialized:
		return

	skeleton = _skeleton
	mesh = _mesh
	_init_physics()
	skeleton.reset_bone_poses()
	last_body_pos = body.global_position
	_initialized = true


func _init_physics():
	pass


func calculate_if_swing(active_body: RigidBody3D,delta : float):
	var curr_body_pos := active_body.global_position
	var curr_cam_pos := cam.global_position

	var body_vel := (curr_body_pos - last_body_pos) / delta
	var cam_vel := (curr_cam_pos - last_cam_pos) / delta

	last_body_pos = curr_body_pos
	last_cam_pos = curr_cam_pos

	var velocity := body_vel - cam_vel

	filtered_velocity = filtered_velocity.lerp(
		velocity,
		clamp(delta * velocity_smooth, 0.0, 1.0)
	)

	#cam_to_body_dir = (active_body.global_position - curr_cam_pos).normalized()
	var weapon_speed : float = max(0.0,velocity.length())

	if weapon_speed >= speed_threshold and not is_swinging:
		active_swing_frames_left = active_swing_frames
		weapon_collision.is_active = true
		weapon_collision.emit_start_swing_signal()
		is_swinging = true
	else: 
		is_swinging = false
	return velocity
