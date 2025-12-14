extends Node3D
class_name WhipPhysics

@onready var skeleton: Skeleton3D = $Licorice_Whip/Armature/Skeleton3D
@onready var mesh: MeshInstance3D = _find_mesh($Licorice_Whip)
@onready var physics: Node3D = self
@onready var cam : Camera3D = get_viewport().get_camera_3d() 
@export var physics_allow_segment_x: float = 15.0
@export var physics_allow_segment_y: float = 15.0
@export var physics_allow_segment_z: float = 15.0
@export var chain_stiffness := 1.0
@export var swing_force := 10.0
@export var snap_force := -100.0
@export var snap_duration := 0.55
@export var swing_duration := 0.90
@export var camera_direction_distance := 5.0

enum DrivePhase {
	NONE,
	SWING_OUT,
	TARGET   
}

var drive_phase : DrivePhase = DrivePhase.NONE
var drive_time : float = 0.0

var segs: Array[RigidBody3D] = []
var rest_lengths: Array[float] = []
var rest_dirs_local: Array[Vector3] = []
var offsets := []
var snap_time := 0.0
var is_swinging : bool
var is_snapping : bool

func _ready():
	segs.clear()
	for c in physics.get_children():
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

	segs[0].freeze = true

	for i in range(1, segs.size()):
		_create_joint(segs[i], segs[i - 1])

	_cache_rest_data()


func _physics_process(_delta):	
	if snap_time > 0.0:
		if is_snapping:
			apply_torque(snap_force)
		if is_swinging: 
			apply_torque(swing_force)
		snap_time -= _delta
	else:
		is_snapping = false
		is_swinging = false
	stabilize_chain_angles()

	skeleton.clear_bones_global_pose_override()
	var skel_inv: Transform3D = skeleton.global_transform.affine_inverse()

	for i in segs.size():
		var bone := i + 1
		var seg_pose: Transform3D = segs[i].global_transform
		var world_t: Transform3D = seg_pose * offsets[i]
		var bone_t: Transform3D = skel_inv * world_t
		skeleton.set_bone_global_pose_override(bone, bone_t, 1.0, true)


func stabilize_chain_angles():
	if rest_lengths.size() != segs.size() - 1:
		return
	if rest_dirs_local.size() != segs.size() - 1:
		return

	var max_x := deg_to_rad(physics_allow_segment_x)

	for i in range(1, segs.size()):
		var a := segs[i - 1]
		var b := segs[i]

		var dir := b.global_position - a.global_position
		var length := dir.length()
		if length == 0.0:
			continue

		var n := dir / length
		var target := rest_lengths[i - 1]

		var forward: Vector3 = a.global_transform.basis * rest_dirs_local[i - 1]
		forward = forward.normalized()

		var dotv : float = clamp(forward.dot(n), -1.0, 1.0)
		var angle := acos(dotv)

		if angle <= max_x:
			if abs(length - target) > 0.0001:
				b.global_position = a.global_position + n * target
			continue

		var axis := forward.cross(n)
		var axis_len := axis.length()
		if axis_len == 0.0:
			b.global_position = a.global_position + forward * target
			continue

		axis /= axis_len

		var excess := angle - max_x
		var corr: float = excess * clamp(chain_stiffness, 0.0, 1.0)

		var q := Quaternion(axis, -corr)
		var new_dir := (q * n).normalized()

		b.global_position = a.global_position + new_dir * target

		var v := b.linear_velocity
		var radial := new_dir * v.dot(new_dir)
		b.linear_velocity = v - radial


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
	add_child(j)

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


func _find_skeleton(n: Node) -> Skeleton3D:
	if n is Skeleton3D:
		return n
	for c in n.get_children():
		var s = _find_skeleton(c)
		if s:
			return s
	return null


func _find_mesh(n: Node3D) -> MeshInstance3D:
	for c in n.get_children():
		var m = _find_mesh(c)
		if m:
			return m
	return null

func start_swing():
	snap_time = swing_duration
	is_swinging = true
	is_snapping = false


func trigger_snapback():
	snap_time = snap_duration
	is_swinging = false
	is_snapping = true


func get_target_point() -> Vector3:
	return cam.global_position - cam.global_transform.basis.z * camera_direction_distance

func get_swing_out_point() -> Vector3:
	return (
		cam.global_position
		- cam.global_transform.basis.z * camera_direction_distance
		- cam.global_transform.basis.y * 2.0
	)

func apply_torque(force):
	if cam == null:
		return

	var target_point := cam.global_position - cam.global_transform.basis.z * camera_direction_distance

	var count := segs.size()
	for i in range(count):
		#if i < 1:
			#break
		var seg := segs[i]

		var tip_pos := seg.global_position
		var desired_dir := (target_point - tip_pos).normalized()

		# ACHTUNG: Achse prüfen (z/y/x je nach Modell)
		var current_dir := -seg.global_transform.basis.y

		var axis := current_dir.cross(desired_dir)
		var axis_len := axis.length()
		if axis_len < 0.0001:
			continue

		axis /= axis_len
		var angle := current_dir.angle_to(desired_dir)

		# Gewichtung: hintere Segmente stärker
		var t := float(i) / float(count - 1)
		var strength :float = -force * t * t

		seg.apply_torque(axis * angle * strength)
