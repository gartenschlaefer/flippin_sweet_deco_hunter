# --
# bubaba

class_name Bubaba extends CharacterBody3D

# refs
@onready var nav_agent = $NavigationAgent3D
@onready var anim: AnimatedSprite3D = $anim

# vars
var player_in_reach = false

# const
const speed = 2.0
const evil_to_normal_distance = 3.0
const anim_normal_idle = &"normal_idle"
const anim_evil_idle = &"evil_idle"


func _ready():

	# settup
	player_in_reach = false


func _physics_process(_delta):
	
	# to new location
	nav_agent.set_velocity((nav_agent.get_next_path_position() - self.global_transform.origin).normalized() * speed)

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
