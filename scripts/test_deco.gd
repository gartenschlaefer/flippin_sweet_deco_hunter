extends Node3D

func _input(event):

  # end game
  if event.is_action_pressed("escape"): get_tree().quit()
