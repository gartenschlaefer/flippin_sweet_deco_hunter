# --
# sticker

class_name Sticker extends Node3D

@export var sticker_resource: StickerResource = null


func _ready():
	pass


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
