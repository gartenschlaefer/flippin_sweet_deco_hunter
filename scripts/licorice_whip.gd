extends Node3D

@onready var skeleton: Skeleton3D = $Licorice_Whip/Armature/Skeleton3D
@onready var mesh: MeshInstance3D = _find_mesh($Licorice_Whip)
@onready var physics: Node3D = $Physics
@export var physics_allow_segment_x: float = 15.0
@export var physics_allow_segment_y: float = 50.0
@export var physics_allow_segment_z: float = 15.0
@export var chain_stiffness := 1.0


var whip_instance: Node3D
var segs: Array[RigidBody3D] = []
var rest_lengths: Array[float] = []

var offsets := []

func _ready():
	for c in physics.get_children():
		if c is RigidBody3D:
			segs.append(c)

	segs.sort_custom(func(a, b): return a.global_position.y < b.global_position.y)

	offsets.resize(segs.size())

	for i in segs.size():
		var bone := i + 1
		var bone_pose: Transform3D = skeleton.global_transform * skeleton.get_bone_global_pose(bone)
		var seg_pose: Transform3D = segs[i].global_transform
		offsets[i] = seg_pose.affine_inverse() * bone_pose

	segs[0].freeze = true

	for i in range(1, segs.size()):
		_create_joint(segs[i], segs[i - 1])
		var rest_lengths: Array[float] = []
	_cache_rest_lengths()


func _physics_process(delta):

	skeleton.clear_bones_global_pose_override()
	var skel_inv := skeleton.global_transform.affine_inverse()

	for i in segs.size():
		var bone := i + 1
		var seg_pose: Transform3D = segs[i].global_transform
		var world_t: Transform3D = seg_pose * offsets[i]
		var bone_t: Transform3D = skel_inv * world_t
		skeleton.set_bone_global_pose_override(bone, bone_t, 1.0, true)
	stabilize_chain()


func stabilize_chain():
	for i in range(1, segs.size()):
		var a := segs[i - 1]
		var b := segs[i]

		var dir := b.global_position - a.global_position
		var len := dir.length()
		if len == 0.0:
			continue

		var target := rest_lengths[i - 1]
		var error := len - target

		if abs(error) < 0.0001:
			continue

		var n := dir / len
		var correction := -n * error * chain_stiffness

		b.global_position += correction

		var v := b.linear_velocity
		var radial := n * v.dot(n)
		b.linear_velocity = v - radial


func _cache_rest_lengths():
	rest_lengths.clear()
	for i in range(1, segs.size()):
		rest_lengths.append(
			segs[i].global_position.distance_to(segs[i - 1].global_position)
		)


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


func _find_mesh(n: Node) -> MeshInstance3D:
	if n is MeshInstance3D and n.skin:
		return n
	for c in n.get_children():
		var m = _find_mesh(c)
		if m:
			return m
	return null
