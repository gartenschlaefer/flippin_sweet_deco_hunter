# --
# enemy base class

class_name EnemyBase extends CharacterBody3D

# settings
@export var speed = 2.0
@export var target_reach_distance = 5.0
@export var hit_cooldown_time = 2.0
@export var full_health = 100
@export var whip_damage_to_be_taken = 25
@export var lollipop_damage_to_be_taken = 10
@export var cotton_candy_damage_to_be_taken = 2

@export var weapon_force = 10.0
@export var exploration_range_meters = 100.0

# resources
@export var sticker_resource: StickerResource

# refs
@export var health_bar: ProgressBar
@onready var nav_agent = $NavigationAgent3D
@onready var anim: AnimatedSprite3D = $anim
@onready var anim_player: AnimationPlayer = $anim_player
@onready var audio_player: AudioStreamPlayer3D = $audio_player
@onready var call_timer: Timer = $call_timer

@export var casual_calls: AudioStreamRandomizer
@export var angry_calls: AudioStreamRandomizer
@export var hurt_calls: AudioStreamRandomizer
@export var death_screams: AudioStreamRandomizer

# vars
var player_in_sight = false
var target_in_reach = false
var hit_cooldown_timer: Timer = null
var is_ko = false
var home_location: Vector3
var is_angry := false

# animations
const anim_normal_idle = &"normal_idle"
const anim_evil_idle = &"evil_idle"
const anim_player_death = &"death"


func _ready():

	# setup
	target_in_reach = false
	player_in_sight = false
	is_ko = false

	# set init value
	health_bar.set_max(full_health)
	health_bar.set_value(100)

	# set home location
	home_location = self.global_transform.origin

	# go exploring
	self.go_on_another_expedition()

	# connect signals
	nav_agent.velocity_computed.connect(self._on_navigation_agent_3d_velocity_computed)
	nav_agent.navigation_finished.connect(self._on_navigation_agent_3d_navigation_finished)
	
	if call_timer:
		call_timer.timeout.connect(_on_call_timer_timeout)
		_schedule_casual_call()


func _physics_process(_delta):
	
	# k.o.
	if is_ko:

		# check if stopped moving
		if (velocity.x + velocity.y + velocity.z) < 0.1: self.bubaba_dies()
		move_and_slide()
		return

	# to new location
	nav_agent.set_velocity((nav_agent.get_next_path_position() - self.global_transform.origin).normalized() * speed)

	# player interaction
	self._player_interaction()

	# weapon interaction
	self._weapon_interaction()


func take_damage(collision: KinematicCollision3D):

	var weapon = collision.get_collider().get_weapon()

	var damage = 0
	if weapon is WeaponWhip: damage = whip_damage_to_be_taken
	elif weapon is WeaponCottonCandy: damage = cotton_candy_damage_to_be_taken
	elif weapon is WeaponLollipop: damage = lollipop_damage_to_be_taken

	print(weapon)
	# got hit -> hit cooldown timer
	if not hit_cooldown_timer == null: return

	# create timer
	hit_cooldown_timer = Timer.new()
	add_child(hit_cooldown_timer)
	hit_cooldown_timer.timeout.connect(self._on_hit_cooldown_timer_timeout)
	hit_cooldown_timer.wait_time = hit_cooldown_time
	hit_cooldown_timer.start()

	# hit vector + velocity
	var hit_vector = (self.global_transform.origin - collision.get_position())
	hit_vector.y = 0.0
	velocity = velocity + hit_vector.normalized() * weapon_force

	# decrease health
	health_bar.set_value(health_bar.get_value() - damage)

	# not dead yet
	if health_bar.get_value(): 
		_play_call(hurt_calls)
		return
	self.bubaba_set_to_ko()


func bubaba_set_to_ko():

	# k.o. mode
	is_ko = true

	# end velocity
	nav_agent.set_velocity(Vector3.ZERO)
	_play_call(death_screams)


	# todo:
	# set ko anim


func bubaba_dies():

	# play anim, everything else is handled by it
	anim_player.play(anim_player_death)


func bubaba_is_dead():

	# add a sticker if it has any
	if sticker_resource != null:

		# parent
		var world = self.get_parent()

		# create sticker on resource and hang on tree
		var sticker = Sticker.new_sticker(sticker_resource, false)

		# set position
		sticker.set_position(self.get_global_transform().origin)

		# spawn a bubaba sticker
		world.add_child(sticker)

	# remove bubaba from this world forever, sob***
	self.queue_free()


func update_target_position(target_position):

	# target position
	nav_agent.set_target_position(target_position)


func go_on_another_expedition():
	
	# new expedition position
	var target_position = home_location + Vector3(randf_range(-exploration_range_meters, exploration_range_meters), 0, randf_range(-exploration_range_meters, exploration_range_meters))
	
	# set new target
	self.update_target_position(target_position)


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

	# to normal
	anim.set_animation(anim_evil_idle)
	is_angry = true
	_play_call(angry_calls) 
	target_in_reach = true


func _weapon_interaction():

	# weapon interactions
	for i in range(get_slide_collision_count()):

		# get collision
		var collision = get_slide_collision(i)

		# get collider
		var weapon_collider = collision.get_collider()

		# skips
		if weapon_collider == null: continue
		if not collision.get_collider().is_in_group('weapon_part'): continue

		# is weapon active
		if not weapon_collider.get_is_active(): continue

		# emit hit signal
		weapon_collider.emit_enemy_hit_signal()

		# take damage
		self.take_damage(collision)


func _on_navigation_agent_3d_velocity_computed(safe_velocity: Vector3) -> void:
	
	# move
	velocity = velocity.move_toward(safe_velocity, 0.25)
	
	# move
	move_and_slide()


func _on_hit_cooldown_timer_timeout():

	# stop and destroy timer
	hit_cooldown_timer.stop()
	hit_cooldown_timer.queue_free()


func _on_navigation_agent_3d_navigation_finished() -> void:

	# this was just some exploration -> set new goal
	if not player_in_sight: 
		self.go_on_another_expedition()
		return


func _play_call(stream: AudioStreamRandomizer):
	if audio_player and stream:
		#audio_player.stop()
		audio_player.stream = stream
		audio_player.play()


func _schedule_casual_call():
	if is_ko:
		return
	call_timer.start(randf_range(5.0, 15.0))


func _schedule_angry_call():
	if is_ko:
		return
	call_timer.start(randf_range(5.0, 10.0))


func _on_call_timer_timeout():
	if is_angry:
		_play_call(angry_calls)
		_schedule_angry_call()
	else:
		_play_call(casual_calls)
		_schedule_casual_call()
