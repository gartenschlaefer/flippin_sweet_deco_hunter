extends Node3D

@export var whip_scene: PackedScene

var whip_instance: Node3D
var skeleton: Skeleton3D
var mesh: MeshInstance3D
var segs: Array[RigidBody3D] = []

var offsets := []

func _ready():
	whip_instance = whip_scene.instantiate()
	add_child(whip_instance)

	skeleton = _find_skeleton(whip_instance)
	if skeleton == null:
		push_error("Skeleton3D not found in whip_scene")
		return

	mesh = _find_mesh(whip_instance)
	if mesh == null:
		push_error("Skinned MeshInstance3D not found in whip_scene")
		return

	segs = []
	for c in get_children():
		if c is RigidBody3D:
			segs.append(c)

	if segs.size() == 0:
		push_error("No physics segments found")
		return

	offsets.resize(segs.size())

	for i in segs.size():
		_create_joint(segs[i], segs[i - 1])
		var bone := i + 1
		var bone_pose: Transform3D = skeleton.get_bone_global_pose(bone)
		var seg_pose: Transform3D = segs[i].global_transform
		offsets[i] = seg_pose.affine_inverse() * bone_pose


func _physics_process(delta):
	skeleton.clear_bones_global_pose_override()
	for i in segs.size():
		var bone := i + 1
		var t: Transform3D = segs[i].global_transform * offsets[i]
		skeleton.set_bone_global_pose_override(bone, t, 1.0, true)

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

	j.set_param_x(Generic6DOFJoint3D.PARAM_ANGULAR_LOWER_LIMIT, deg_to_rad(-30.0))
	j.set_param_x(Generic6DOFJoint3D.PARAM_ANGULAR_UPPER_LIMIT, deg_to_rad(30.0))
	j.set_flag_x(Generic6DOFJoint3D.FLAG_ENABLE_ANGULAR_LIMIT, true)

	j.set_param_y(Generic6DOFJoint3D.PARAM_ANGULAR_LOWER_LIMIT, deg_to_rad(-10.0))
	j.set_param_y(Generic6DOFJoint3D.PARAM_ANGULAR_UPPER_LIMIT, deg_to_rad(10.0))
	j.set_flag_y(Generic6DOFJoint3D.FLAG_ENABLE_ANGULAR_LIMIT, true)

	j.set_param_z(Generic6DOFJoint3D.PARAM_ANGULAR_LOWER_LIMIT, deg_to_rad(-30.0))
	j.set_param_z(Generic6DOFJoint3D.PARAM_ANGULAR_UPPER_LIMIT, deg_to_rad(30.0))
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
