# --
# sticker

class_name Sticker extends Node3D

# refs
@export var sticker_resource: StickerResource = null
@onready var sprite: Sprite3D = $sprite

# var
var is_hanging_on_tree = false
var tree_rotation_dir = 1

# const
const sticker_scene: PackedScene = preload("uid://qdfw3qsr5x8o")
const rotation_speed_on_ground = 1.5
const rotation_speed_on_tree = 0.3
const rotation_deco_on_tree_max = 0.5


static func new_sticker(target_sticker_resource: StickerResource, _is_hanging_on_tree: bool = false):

	# new instance
	var new_sticker_inst = sticker_scene.instantiate()
	
	# set card image
	new_sticker_inst.set_sticker_resource(target_sticker_resource)
	new_sticker_inst.set_is_hanging_on_tree(_is_hanging_on_tree)

	# set random start rotation
	new_sticker_inst.set_rotation(Vector3(0, randf_range(-rotation_deco_on_tree_max, rotation_deco_on_tree_max), 0))
	
	return new_sticker_inst


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


# --
# getter and setter

func set_is_hanging_on_tree(is_hanging: bool): is_hanging_on_tree = is_hanging
func set_sticker_resource(sr: StickerResource): sticker_resource = sr
