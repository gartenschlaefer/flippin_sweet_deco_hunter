extends Node3D

# refs
@export var demo_sticker_resource: StickerResource
@onready var christmas_tree = $christmas_tree
@onready var player = $fp_player


func _ready():
	pass


func _input(event):

	# end game
	if event.is_action_pressed("escape"): get_tree().quit()
	if event.is_action_pressed("interact"):
		hang_a_bubaba_on_tree()


func hang_a_bubaba_on_tree():

	# hang something on christmas tree
	christmas_tree.hang_deco_on_tree(demo_sticker_resource, player)
