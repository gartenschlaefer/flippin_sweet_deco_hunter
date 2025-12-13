# --
# camera slide

extends Path3D

# refs
@export var target_object: Node
@onready var path_follow = $path_follow
@onready var camera_stand = $path_follow/camera_stand


func _ready():

	# tween, obj, prop, final, time
	create_tween().tween_property(path_follow, "progress_ratio", 1.0, 5)


func _process(_delta):

	# skips
	if path_follow.get_progress_ratio() >= 1.0: return

	# look at target
	self._look_at_target()


func _look_at_target():

	# skips
	if target_object == null: return

	# look at target computation
	var target_direction: Vector3 = (camera_stand.global_transform.origin - target_object.get_global_transform().origin).normalized()

	# look at target direction
	var new_basis = Basis.looking_at(target_direction, Vector3.UP, true)

	# change transform
	camera_stand.global_transform = Transform3D(new_basis, camera_stand.global_transform.origin)
