# --
# christmas tree

class_name ChristmasTree extends Node3D

# resources
@export var hang_button_textures: Array[Texture2D]

# refs
@export var hang_button: Sprite3D
@export var debug_cube: MeshInstance3D = null
@onready var turnable_hanging_space = $turnable_hanging_space

# vars
var collected_deco: Array[StickerResource] = []
var actual_frame = 0

# const frame update
const frame_update_dir = 1


func _ready():

	# change color
	self.debug_cube_set_inactive()

	# actual frame
	actual_frame = 0

	# hide
	hang_button.hide()


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


func hang_deco_on_tree(deco: StickerResource, player: Player):

	print("add deco: ", deco)
	self.hang_button_update(player)

	# add deco
	collected_deco.append(deco)

	# todo:
	# create sticker on resource and hang on tree


func hang_button_update(player: Player):

	# hang button
	hang_button.set_texture(hang_button_textures[int(player.get_player_has_sticker())])

	# visible
	if player.get_is_in_tree_hanging_range(): hang_button.show()
	else: hang_button.hide()


func debug_cube_set_active(): debug_cube.get_active_material(0).set_albedo(Color(1.0, 1.0, 0.0))
func debug_cube_set_inactive(): debug_cube.get_active_material(0).set_albedo(Color(0.5, 0.5, 0.5))


# --
# private functions

func _on_hang_deco_area_area_entered(area: Area3D) -> void:

	# safety
	if not area.get_parent() is Player: return

	# player
	var player = area.get_parent()

	# player notification
	player.set_is_in_tree_hanging_range(true, self)

	# updates
	self.hang_button_update(player)

	# no bubaba sticker skip
	if player.get_player_has_bubaba_sticker(): self.debug_cube_set_active()



func _on_hang_deco_area_area_exited(area: Area3D) -> void:

	# safety
	if not area.get_parent() is Player: return

	# get player
	var player: Player = area.get_parent()

	# set in range
	player.set_is_in_tree_hanging_range(false, null)

	# updates
	self.hang_button_update(player)
	self.debug_cube_set_inactive()
