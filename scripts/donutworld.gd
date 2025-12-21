# --
# donut world

class_name DonutWorld extends Node3D

# signals
signal win_donutworld_collected_all_bubabas

# refs
@export var christmas_tree: ChristmasTree

# demo
@export var demo_sticker_resource: StickerResource


# func _input(_event):
	
# 	# demo
# 	if Input.is_action_just_pressed("interact"): christmas_tree.hang_deco_on_tree(demo_sticker_resource, null)


func _ready():
	
	# connections
	christmas_tree.win_hanged_all_bubaba_on_tree.connect(self.win_donutworld)


func win_donutworld():
	print("win donutworld!")
	win_donutworld_collected_all_bubabas.emit()
