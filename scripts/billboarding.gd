# --
# billboarding

extends Sprite3D

# vars
var original_scale


func _ready():

	# save scale
	original_scale = scale


func _process(_delta):

	# transforms
	var camera_transform = get_viewport().get_camera_3d().global_transform
	var sprite_transform = get_global_transform()

	# billboarding computations
	var basis_y = sprite_transform.basis.y
	var basis_z = (camera_transform.origin - sprite_transform.origin).normalized() * original_scale.z
	var basis_x = basis_y.cross(basis_z).normalized() * original_scale.x

	# change transform
	self.global_transform = Transform3D(basis_x, basis_y, basis_z, sprite_transform.origin)
