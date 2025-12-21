# --
# win canvas

extends CanvasLayer

# signals
signal end_win


func _process(_delta:float) -> void:
	
	# active check
	if not self.visible: return

	# escape and end game
	#if Input.is_action_just_pressed("escape") or Input.is_action_just_pressed("interact"): 
	if Input.is_action_just_pressed("escape"):
		end_win.emit()


func _on_end_button_button_up() -> void:
	end_win.emit()
