extends WeaponPhysicsBase
class_name WeaponPhysicsWhip

@export var weapon: WeaponBase
@export var segment_root_path: NodePath
@onready var segment_root: Node = get_node_or_null(segment_root_path)
@export var physics_allow_segment_x: float = 15.0
@export var physics_allow_segment_y: float = 15.0
@export var physics_allow_segment_z: float = 15.0
@export var chain_stiffness := 1.0
@export var snap_duration := 0.55
@export var swing_duration := 0.90
@export var speed_threshold := 1.0
@export var force_min := 2.0
@export var force_max := 5.0
@export var force_gain := 1.2
@export var force_frames := 30

var force_frames_left := 0
var burst_armed := true
var rest_lengths: Array[float] = []
var rest_dirs_local: Array[Vector3] = []

var snap_time := 0.0
var is_swinging : bool
var is_snapping : bool
var last_root_pos : Vector3
var last_cam_pos : Vector3

var filtered_velocity := Vector3.ZERO
var last_velocity_dir := Vector3.ZERO
@export var velocity_smooth := 10.0


func _init_physics():
	segs.clear()
	for c in segment_root.get_children():
		if c is RigidBody3D:
			segs.append(c as RigidBody3D)

	segs.sort_custom(func(a, b): return a.global_position.y < b.global_position.y)

	if segs.size() == 0:
		push_error("No physics segments found under Physics")
		return

	offsets.resize(segs.size())

	for i in segs.size():
		var bone := i + 1
		var bone_pose: Transform3D = skeleton.global_transform * skeleton.get_bone_global_pose(bone)
		var seg_pose: Transform3D = segs[i].global_transform
		offsets[i] = seg_pose.affine_inverse() * bone_pose
	
	for i in range(1, segs.size()):
		_create_joint(segs[i], segs[i - 1])

	segs[0].freeze = true
	
	last_root_pos = segs[0].global_position
	last_cam_pos = get_viewport().get_camera_3d().global_position

	_cache_rest_data()


func _physics_process(delta):
	if is_swinging:
		apply_centrifugal_force(delta)
	elif is_snapping:
		apply_centrifugal_force(delta)

	if snap_time > 0.0:
		snap_time -= delta
	else:
		is_snapping = false
		is_swinging = false

	if weapon and weapon.state == weapon.State.ATTACKING:
		apply_centrifugal_force(delta)

	stabilize_chain_angles()
	apply_bone_pose()


func stabilize_chain_angles():
	var count := segs.size()
	if rest_lengths.size() != count - 1:
		return
	if rest_dirs_local.size() != count - 1:
		return

	var max_angle := deg_to_rad(physics_allow_segment_x)
	var cos_max := cos(max_angle)
	var stiffness : float = clamp(chain_stiffness, 0.0, 1.0)

	for i in range(1, count):
		var a := segs[i - 1]
		var b := segs[i]

		var a_pos := a.global_position
		var b_pos := b.global_position

		var dir := b_pos - a_pos
		var len_sq := dir.length_squared()
		if len_sq <= 1e-12:
			continue

		var inv_len := 1.0 / sqrt(len_sq)
		var n := dir * inv_len
		var target := rest_lengths[i - 1]

		var forward := a.global_transform.basis * rest_dirs_local[i - 1]
		var dotv : float = clamp(forward.dot(n), -1.0, 1.0)

		if dotv >= cos_max:
			var seg_len := len_sq * inv_len
			if abs(seg_len - target) > 0.0001:
				b.global_position = a_pos + n * target
			continue

		var axis := forward.cross(n)
		var axis_len_sq := axis.length_squared()
		if axis_len_sq <= 1e-12:
			b.global_position = a_pos + forward * target
			continue

		axis *= 1.0 / sqrt(axis_len_sq)

		var angle := acos(dotv)
		var corr := (angle - max_angle) * stiffness

		var q := Quaternion(axis, -corr)
		var new_dir := q * n

		b.global_position = a_pos + new_dir * target

		var v := b.linear_velocity
		b.linear_velocity = v - new_dir * v.dot(new_dir)


func apply_bone_pose():
	var skel_inv := skeleton.global_transform.affine_inverse()
	var count := segs.size()

	for i in range(count):
		var bone := i + 1
		var seg_pose: Transform3D = segs[i].global_transform
		var world_t: Transform3D = seg_pose * offsets[i]
		var bone_t: Transform3D = skel_inv * world_t
		skeleton.set_bone_global_pose(bone, bone_t)


func get_segment_stiffness(i: int) -> float:
	var t := float(i - 1) / float(segs.size() - 3)
	return clamp(1.0 - t * t, 0.15, 1.0)



func _cache_rest_data():
	rest_lengths.clear()
	rest_dirs_local.clear()

	for i in range(1, segs.size()):
		var a := segs[i - 1]
		var b := segs[i]

		var d := b.global_position - a.global_position
		var length := d.length()
		rest_lengths.append(length)

		var n := Vector3.ZERO
		if length > 0.0:
			n = d / length

		var a_inv: Basis = a.global_transform.basis.inverse()
		rest_dirs_local.append(a_inv * n)


func _create_joint(a: RigidBody3D, b: RigidBody3D) -> Generic6DOFJoint3D:
	var j := Generic6DOFJoint3D.new()
	a.add_child(j)

	j.node_a = a.get_path()
	j.node_b = b.get_path()
	
	var pj := PinJoint3D.new()
	#a.add_child(pj)

	pj.node_a = a.get_path()
	pj.node_b = b.get_path()

	j.set_param_x(Generic6DOFJoint3D.PARAM_LINEAR_LOWER_LIMIT, 0.0)
	j.set_param_x(Generic6DOFJoint3D.PARAM_LINEAR_UPPER_LIMIT, 0.0)
	j.set_param_y(Generic6DOFJoint3D.PARAM_LINEAR_LOWER_LIMIT, 0.0)
	j.set_param_y(Generic6DOFJoint3D.PARAM_LINEAR_UPPER_LIMIT, 0.0)
	j.set_param_z(Generic6DOFJoint3D.PARAM_LINEAR_LOWER_LIMIT, 0.0)
	j.set_param_z(Generic6DOFJoint3D.PARAM_LINEAR_UPPER_LIMIT, 0.0)

	j.set_flag_x(Generic6DOFJoint3D.FLAG_ENABLE_LINEAR_LIMIT, true)
	j.set_flag_y(Generic6DOFJoint3D.FLAG_ENABLE_LINEAR_LIMIT, true)
	j.set_flag_z(Generic6DOFJoint3D.FLAG_ENABLE_LINEAR_LIMIT, true)

	j.set_param_x(Generic6DOFJoint3D.PARAM_ANGULAR_LOWER_LIMIT, deg_to_rad(-physics_allow_segment_x))
	j.set_param_x(Generic6DOFJoint3D.PARAM_ANGULAR_UPPER_LIMIT, deg_to_rad(physics_allow_segment_x))
	j.set_flag_x(Generic6DOFJoint3D.FLAG_ENABLE_ANGULAR_LIMIT, true)

	j.set_param_y(Generic6DOFJoint3D.PARAM_ANGULAR_LOWER_LIMIT, deg_to_rad(-physics_allow_segment_y))
	j.set_param_y(Generic6DOFJoint3D.PARAM_ANGULAR_UPPER_LIMIT, deg_to_rad(physics_allow_segment_y))
	j.set_flag_y(Generic6DOFJoint3D.FLAG_ENABLE_ANGULAR_LIMIT, true)

	j.set_param_z(Generic6DOFJoint3D.PARAM_ANGULAR_LOWER_LIMIT, deg_to_rad(-physics_allow_segment_z))
	j.set_param_z(Generic6DOFJoint3D.PARAM_ANGULAR_UPPER_LIMIT, deg_to_rad(physics_allow_segment_z))
	j.set_flag_z(Generic6DOFJoint3D.FLAG_ENABLE_ANGULAR_LIMIT, true)

	return j


func start_swing():
	snap_time = swing_duration
	is_swinging = true
	is_snapping = false


func trigger_snapback():
	snap_time = snap_duration
	is_swinging = false
	is_snapping = true


func apply_centrifugal_force(delta: float):
	if segs.size() < 2:
		return

	var root := segs[0]
	var cam := get_viewport().get_camera_3d()

	var curr_root_pos := root.global_position
	var curr_cam_pos := cam.global_position

	var root_vel := (curr_root_pos - last_root_pos) / delta
	var cam_vel := (curr_cam_pos - last_cam_pos) / delta

	last_root_pos = curr_root_pos
	last_cam_pos = curr_cam_pos

	var velocity := root_vel - cam_vel

	filtered_velocity = filtered_velocity.lerp(
		velocity,
		clamp(delta * velocity_smooth, 0.0, 1.0)
	)

	var cam_to_root_dir := (root.global_position - curr_cam_pos).normalized()
	var whip_root_speed : float = max(0.0, filtered_velocity.dot(cam_to_root_dir))

	var force_value := 0.0

	if whip_root_speed >= speed_threshold:
		force_value = clamp(whip_root_speed, force_min, force_max)
		force_frames_left = force_frames

	elif force_frames_left > 0:
		# speed dropped, but keep minimum force alive
		force_value = force_min
		force_frames_left -= 1

	else:
		return

	for seg in segs:
		var len_sq := cam_to_root_dir.length_squared()
		if len_sq < 1e-8:
			continue

		cam_to_root_dir *= 1.0 / sqrt(len_sq)
		seg.apply_force(cam_to_root_dir * force_value)
