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
const scale_sticker_on_tree = 0.4
const scale_sticker_on_ground = 0.6


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

	# scaling
	_scale_to_defined_size()


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


func _scale_to_defined_size():

	# set correct scale
	if is_hanging_on_tree: set_scale(Vector3(scale_sticker_on_tree, scale_sticker_on_tree, scale_sticker_on_tree))
	else: set_scale(Vector3(scale_sticker_on_ground, scale_sticker_on_ground, scale_sticker_on_ground))


func _on_area_3d_area_entered(area: Area3D) -> void:
		
	# skip
	if is_hanging_on_tree: return

	# only cotton candy can pick it up
	var cotton_candy = area.get_parent()
	if cotton_candy is WeaponCottonCandy: 
		cotton_candy._on_sticker_collected()
	else: return
	
	# do not add sticker
	if sticker_resource == null: return

	# add sticker
	area.get_parent().get_parent().get_player().add_sticker(sticker_resource)

	# delete
	self.queue_free()


# --
# getter and setter

func set_is_hanging_on_tree(is_hanging: bool): 
	
	# flag
	is_hanging_on_tree = is_hanging

	# hanging condition
	if is_hanging: 

		# disable collision
		$interaction_area/collision_shape.set_disabled(true)

		# sorting if hanging on tree
		$sprite.set_sorting_offset(3)


func set_sticker_resource(sr: StickerResource): sticker_resource = sr
