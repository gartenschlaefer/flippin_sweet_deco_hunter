# --
# sticker

class_name Sticker extends Node3D

# refs
@export var sticker_resource: StickerResource = null
@onready var sprite: Sprite3D = $sprite

# var
var is_hanging_on_tree = true
var tree_rotation_dir = 1

# const
const rotation_speed_on_ground = 1.5
const rotation_speed_on_tree = 0.3
const rotation_deco_on_tree_max = 0.5

func _ready():
		
	# sticker resource skip
	if sticker_resource == null: return

	# set texture
	sprite.set_texture(sticker_resource.get_texture())


func _process(delta):

	# hanging on tree rotation
	if is_hanging_on_tree:

		# calculate new rotation
		var new_rotation_y = self.get_rotation().y + rotation_speed_on_tree * delta  * tree_rotation_dir

		# direction shift
		if abs(new_rotation_y) >= rotation_deco_on_tree_max: tree_rotation_dir *= -1

		# set new rotation
		self.set_rotation(Vector3(0, new_rotation_y, 0))
		return

	# ground rotation
	self.rotate_y(rotation_speed_on_ground * delta)


func hang_on_tree():

	# stop rotating
	is_hanging_on_tree = false


func _on_area_3d_area_entered(area: Area3D) -> void:
	
	# todo: use cotton candy area!!! (activate collider when hit)
	# must be player to interact
	if not area.get_parent() is Player: return
	
	# player
	var player = area.get_parent()

	# do not add sticker
	if sticker_resource == null: return

	# add sticker
	player.add_sticker(sticker_resource)

	# delete
	self.queue_free()
