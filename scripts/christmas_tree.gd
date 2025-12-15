# --
# christmas tree

extends Node3D

var collected_deco = []
@export var debug_cube: MeshInstance3D = null

func _ready():

	# change color
	self.debug_cube_set_inactive()


func add_deco_to_tree(deco_index: int):

	print("add deco i: ", deco_index)
	pass


func debug_cube_set_active(): debug_cube.get_active_material(0).set_albedo(Color(1.0, 1.0, 0.0))
func debug_cube_set_inactive(): debug_cube.get_active_material(0).set_albedo(Color(0.5, 0.5, 0.5))


# --
# private functions

func _on_hang_deco_area_area_entered(_area: Area3D) -> void:
	self.debug_cube_set_active()


func _on_hang_deco_area_area_exited(_area: Area3D) -> void:
	self.debug_cube_set_inactive()
