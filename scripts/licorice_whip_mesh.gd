@export_node_path("Skeleton3D") var skeleton_path: NodePath
@export var start_scene: PackedScene


var offsets := []

func _ready():
	offsets.resize(segs.size())
	for i in segs.size():
		var bone := i + 1
		var bone_pose := skeleton.get_bone_global_pose(bone)
		var seg_pose := segs[i].global_transform
		offsets[i] = seg_pose.affine_inverse() * bone_pose

func _physics_process(delta):
	skeleton.clear_bones_global_pose_override()
	for i in segs.size():
		var bone := i + 1
		var t := segs[i].global_transform * offsets[i]
		skeleton.set_bone_global_pose_override(bone, t, 1.0, true)
