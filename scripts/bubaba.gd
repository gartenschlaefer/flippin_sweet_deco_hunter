# --
# bubaba

class_name Bubaba extends EnemyBase


# func _ready():
# 	pass


# --
# private functions

func _player_interaction():

	# todo:
	# only if player is in sight -> otherwise exploration
	if not player_in_sight: return

	# player is in reach
	if target_in_reach:

		# skip
		if nav_agent.distance_to_target() < target_reach_distance: return
		target_in_reach = false
		anim.set_animation(anim_normal_idle)
		return

	# target in reach
	if nav_agent.distance_to_target() >= target_reach_distance: return

	# to evil
	anim.set_animation(anim_evil_idle)
	target_in_reach = true


func _weapon_interaction():

	# weapon interactions
	for i in range(get_slide_collision_count()):

		# get collision
		var collision = get_slide_collision(i)

		# skips
		if collision.get_collider() == null: continue
		if not collision.get_collider().is_in_group('weapon_part'): continue

		# take damage
		self.take_damage(collision)
