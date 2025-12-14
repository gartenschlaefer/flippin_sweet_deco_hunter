extends Node3D

# refs
@export var target_object: Node3D


func _input(event):

	# end game
	if event.is_action_pressed("escape"): get_tree().quit()


func _physics_process(_delta):

	# skip
	if target_object == null: return

	# let them walk
	get_tree().call_group('enemies', 'update_target_position', target_object.global_transform.origin)
