# --
# bubaba

class_name Bubaba extends CharacterBody3D

# refs
@onready var nav_agent = $NavigationAgent3D
@onready var anim: AnimatedSprite3D = $anim

# vars
var player_in_reach = false
var hit_cooldown_timer: Timer = null

# const
const speed = 2.0
const evil_to_normal_distance = 3.0
const anim_normal_idle = &"normal_idle"
const anim_evil_idle = &"evil_idle"
const hit_cooldown_time = 2.0


func _ready():

	# settup
	player_in_reach = false


func _physics_process(_delta):
	
	# to new location
	nav_agent.set_velocity((nav_agent.get_next_path_position() - self.global_transform.origin).normalized() * speed)

	# player interaction
	_player_interaction()

	# weapon interactions
	for i in range(get_slide_collision_count()):

		# get collision
		var collision = get_slide_collision(i)

		# skips
		if collision.get_collider() == null: continue
		if not collision.get_collider().is_in_group('weapon_part'): continue

		# take damage
		self.take_damage(collision)


func take_damage(collision: KinematicCollision3D):

	# got hit -> hit cooldown timer
	if not hit_cooldown_timer == null: return

	# create timer
	hit_cooldown_timer = Timer.new()
	add_child(hit_cooldown_timer)
	hit_cooldown_timer.timeout.connect(self._on_hit_cooldown_timer_timeout)
	hit_cooldown_timer.wait_time = hit_cooldown_time
	hit_cooldown_timer.start()

	#var hit_vector = (collision.get_position() - self.global_transform.origin)
	var hit_vector = (self.global_transform.origin - collision.get_position())
	hit_vector.y = 0.0
	hit_vector = hit_vector.normalized()
	#nav_agent.set_velocity(hit_vector * 50.0)
	#velocity = velocity + hit_vector * 10.0
	velocity = velocity + hit_vector * 20.0


func _player_interaction():

	# player in reach case -> is evil
	if not player_in_reach: return

	# skip
	if nav_agent.distance_to_target() < evil_to_normal_distance: return

	# to normal
	anim.set_animation(anim_normal_idle)
	player_in_reach = false


func update_target_position(target_position):

	# target position
	nav_agent.set_target_position(target_position)


func _on_navigation_agent_3d_target_reached() -> void:

	# skip
	if player_in_reach: return
	player_in_reach = true
	anim.set_animation(anim_evil_idle)
	print("player in reach!!!")


func _on_navigation_agent_3d_velocity_computed(safe_velocity: Vector3) -> void:
	
	# move
	velocity = velocity.move_toward(safe_velocity, 0.25)
	
	# move
	move_and_slide()


func _on_hit_cooldown_timer_timeout():

	# stop and destroy timer
	hit_cooldown_timer.stop()
	hit_cooldown_timer.queue_free()
