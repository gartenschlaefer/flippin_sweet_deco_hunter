# --
# sticker

class_name Sticker extends Node3D

# refs
@export var sticker_resource: StickerResource = null
@onready var sprite: Sprite3D = $sprite

# var
var use_rotation = true 

# const
const rotation_speed = 1.5

func _ready():
		
	# sticker resource skip
	if sticker_resource == null: return

	# set texture
	sprite.set_texture(sticker_resource.get_texture())


func _process(delta):

	# skip
	if not use_rotation: return

	# rotate
	self.rotate_y(rotation_speed * delta)


func hang_on_tree():

	# stop rotating
	use_rotation = false


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
