extends Node3D
class_name WeaponPhysicsBase

var skeleton: Skeleton3D
var mesh: MeshInstance3D

var segs: Array[RigidBody3D] = []
var offsets: Array = []

var _initialized := false

func setup(_skeleton: Skeleton3D, _mesh: MeshInstance3D):
	if _initialized:
		return

	skeleton = _skeleton
	mesh = _mesh

	_collect_segments()
	_cache_offsets()
	_init_physics_chain()
	skeleton.reset_bone_poses()
	_initialized = true


func _collect_segments():
	segs.clear()
	for c in get_children():
		if c is RigidBody3D:
			segs.append(c)

	segs.sort_custom(func(a, b): return a.global_position.y < b.global_position.y)

	if segs.is_empty():
		push_error("WeaponPhysicsBase: no RigidBody3D segments found")


func _cache_offsets():
	offsets.resize(segs.size())

	for i in segs.size():
		var bone := i + 1
		var bone_pose := (
			skeleton.global_transform
			* skeleton.get_bone_global_pose(bone)
		)
		var seg_pose := segs[i].global_transform
		offsets[i] = seg_pose.affine_inverse() * bone_pose

	segs[0].freeze = true

func _init_physics_chain():
	pass
