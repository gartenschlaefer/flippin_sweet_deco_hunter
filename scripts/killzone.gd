extends Area3D

func _on_body_entered(body):
	if body is CharacterBody3D:
		#get_tree().reload_current_scene()
		call_deferred("reload")
		

func reload():
	get_tree().reload_current_scene()
