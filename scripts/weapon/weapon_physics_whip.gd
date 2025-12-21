extends WeaponPhysicsBase
class_name WeaponPhysicsWhip

@onready var segment_root: Node = get_node_or_null(segment_root_path)
@export var segment_root_path: NodePath
@export var whip_tip : RigidBody3D
@export var physics_allow_segment_x: float = 15.0
@export var physics_allow_segment_y: float = 15.0
@export var physics_allow_segment_z: float = 15.0
@export var chain_stiffness := 1.0
@export var force_min := 2.0
@export var force_max := 5.0
@export var force_gain := 1.2

var rest_lengths: Array[float] = []
var rest_dirs_local: Array[Vector3] = []
var force_value := 0.0


func _init_physics():
	segs.clear()
	for c in segment_root.get_children():
		if c is RigidBody3D:
			segs.append(c as RigidBody3D)

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
	
	last_body_pos = body.global_position
	last_cam_pos = get_viewport().get_camera_3d().global_position

	_cache_rest_data()
	is_ready = true


func _physics_process(delta):
	var is_attacking := false

	if weapon and weapon.state == weapon.State.ATTACKING:
		is_attacking = true

	if Engine.get_physics_frames() & 1 == 0:
		if weapon_collision.is_active:
			cam_to_body_dir = (body.global_position - cam.global_position).normalized()
			process_attack(cam_to_body_dir)
		elif is_attacking:
			calculate_if_swing(body,delta)
			if weapon_collision.is_active:
				cam_to_body_dir = (body.global_position - cam.global_position).normalized()
	else:
		stabilize_chain_angles()
		apply_bone_pose()


func stabilize_chain_angles():
	var count := segs.size()
	if count < 2:
		return
	if rest_lengths.size() != count - 1:
		return
	if rest_dirs_local.size() != count - 1:
		return

	var max_angle := deg_to_rad(physics_allow_segment_x)
	var cos_max := cos(max_angle)
	var stiffness :float= clamp(chain_stiffness, 0.0, 1.0)

	for i in range(1, count):
		var a := segs[i - 1]
		var b := segs[i]

		var a_pos := a.global_position
		var b_pos := b.global_position

		var d := b_pos - a_pos
		var len_sq := d.length_squared()
		if len_sq <= 1e-12:
			continue

		var inv_len := 1.0 / sqrt(len_sq)
		var n := d * inv_len
		var target_len := rest_lengths[i - 1]

		var forward := (a.global_transform.basis * rest_dirs_local[i - 1]).normalized()
		var dotv :float= clamp(forward.dot(n), -1.0, 1.0)

		var desired_dir := n

		if dotv < cos_max:
			var lateral := n - forward * dotv
			var lat_len_sq := lateral.length_squared()
			if lat_len_sq <= 1e-12:
				desired_dir = forward
			else:
				var lateral_n := lateral * (1.0 / sqrt(lat_len_sq))
				var sin_max := sqrt(max(0.0, 1.0 - cos_max * cos_max))
				desired_dir = (forward * cos_max + lateral_n * sin_max).normalized()

		var desired_pos := a_pos + desired_dir * target_len
		var corr := desired_pos - b_pos

		var max_corr := target_len * 0.25
		var corr_len := corr.length()
		if corr_len > max_corr:
			corr *= max_corr / corr_len

		b.global_position = b_pos + corr * stiffness

		var v := b.linear_velocity
		var vc := v.dot(desired_dir)
		if vc < 0.0:
			b.linear_velocity = v - desired_dir * vc



func apply_bone_pose():
	var skel_inv := skeleton.global_transform.affine_inverse()
	var count := segs.size()

	for i in range(count):
		var bone := i + 1
		var seg_pose: Transform3D = segs[i].global_transform
		var world_t: Transform3D = seg_pose * offsets[i]
		var bone_t: Transform3D = skel_inv * world_t
		skeleton.set_bone_global_pose(bone, bone_t)


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


func process_attack(direction):
	if active_swing_frames_left > 0:
		force_value = force_min
		active_swing_frames_left -= 1
	else:
		weapon_collision.is_active = false
		weapon_collision.emit_whip_crack_signal()
		return
	whip_tip.apply_force(direction * force_value*segs.size())
