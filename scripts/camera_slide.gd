extends Path3D

# refs
@export var target_object: Node
@onready var path_follow = $path_follow
@onready var camera = $path_follow/camera


func _ready():

	# tween, obj, prop, final, time
	create_tween().tween_property(path_follow, "progress_ratio", 1.0, 5)


func _process(_delta):

	# transforms
	var target_transform = target_object.get_global_transform()

	# billboarding computations
	var basis_y = target_transform.basis.y
	var basis_z = (camera.global_transform.origin - target_transform.origin).normalized()
	var basis_x = basis_y.cross(basis_z).normalized()

	# change transform
	camera.global_transform = Transform3D(basis_x, basis_y, basis_z, camera.global_transform.origin)
