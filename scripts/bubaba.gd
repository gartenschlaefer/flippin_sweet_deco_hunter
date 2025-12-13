# --
# bubaba

class_name Bubaba extends CharacterBody3D

# refs
@onready var nav_agent = $NavigationAgent3D

const speed = 2.0

func _ready():
	pass


func _physics_process(_delta):
	
	# vars
	var current_location = self.global_transform.origin
	var next_location = nav_agent.get_next_path_position()

	# to new location
	var new_velocity = (next_location - current_location).normalized() * speed
	velocity = new_velocity
	
	# move
	move_and_slide()


func update_target_location(target_location):

	# target location
	nav_agent.set_target_location(target_location)
