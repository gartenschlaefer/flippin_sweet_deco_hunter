extends Node3D

# refs
@export var target_object: Node3D


func _input(event):

	# end game
	if event.is_action_pressed("escape"): get_tree().quit()
