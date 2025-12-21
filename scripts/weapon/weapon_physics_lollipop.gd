extends WeaponPhysicsBase


func _init_physics():
	is_ready = true


func _physics_process(delta):
	var is_attacking := false

	if weapon and weapon.state == weapon.State.ATTACKING:
		is_attacking = true

	if is_attacking:
		if weapon_collision.is_active:
			process_attack()
		else:
			calculate_if_swing(body,delta)


func process_attack():
	if active_swing_frames_left > 0:
		active_swing_frames_left -= 1
	else:
		weapon_collision.is_active = false
