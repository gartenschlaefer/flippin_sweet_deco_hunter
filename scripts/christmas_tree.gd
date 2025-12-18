# --
# christmas tree

extends Node3D

# refs
@export var debug_cube: MeshInstance3D = null
@onready var turnable_hanging_space = $turnable_hanging_space

# vars
var collected_deco = []
var actual_frame = 0

# const frame update
const frame_update_dir = 1


func _ready():

	# change color
	self.debug_cube_set_inactive()

	# actual frame
	actual_frame = 0


func _process(_delta):

	# # skip
	# if actual_frame <= frame_update_dir: 
	# 	actual_frame += 1
	# 	return

	# do turning
	actual_frame = 0

	# positions
	var camera_pos = get_viewport().get_camera_3d().global_transform.origin
	var tree_pos = self.get_global_transform().origin

	# to player vector
	var player_vector = Vector2(camera_pos.z - tree_pos.z, camera_pos.x - tree_pos.x).normalized()

	# rotate turnable hanging space
	turnable_hanging_space.set_rotation(Vector3(0, player_vector.angle(), 0))


func add_deco_to_tree(deco_index: int):

	print("add deco i: ", deco_index)
	pass


func debug_cube_set_active(): debug_cube.get_active_material(0).set_albedo(Color(1.0, 1.0, 0.0))
func debug_cube_set_inactive(): debug_cube.get_active_material(0).set_albedo(Color(0.5, 0.5, 0.5))


# --
# private functions

func _on_hang_deco_area_area_entered(area: Area3D) -> void:

	# safety
	if not area.get_parent() is Player: return

	# player
	var player = area.get_parent()

	# no bubaba sticker skip
	if not player.get_player_has_bubaba_sticker(): return

	# debug
	self.debug_cube_set_active()


func _on_hang_deco_area_area_exited(area: Area3D) -> void:

	# safety
	if not area.get_parent() is Player: return
	self.debug_cube_set_inactive()
