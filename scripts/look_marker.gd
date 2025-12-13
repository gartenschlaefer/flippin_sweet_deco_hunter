# --
# look marker

@tool
extends Node3D

# refs
@export var target_object: Node


func _process(_delta: float) -> void:

	# skip
	if target_object == null: return

	# look at target computation
	var target_direction: Vector3 = (self.global_transform.origin - target_object.get_global_transform().origin).normalized()

	# look at target direction
	var new_basis = Basis.looking_at(target_direction)
	#var new_basis = self.my_look_function_basis(target_direction)

	# change transform
	self.global_transform = Transform3D(new_basis, self.global_transform.origin)


func my_look_function_basis(target_dir: Vector3) -> Basis:

	var basis_z: Vector3 = target_dir
	#var basis_y: Vector3 = target_transform.basis.y
	var basis_y: Vector3 = Vector3(0, basis_z.y, -basis_z.z).normalized()
	var basis_x: Vector3 = basis_y.cross(basis_z).normalized()

	return Basis(basis_x, basis_y, basis_z)
