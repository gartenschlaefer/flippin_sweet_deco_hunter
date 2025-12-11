# --
# first person player

extends CharacterBody3D

# refs
@onready var head = $head

# const
const speed = 5.0
const jump_velocity = 4.5
const mouse_sensitivity = 0.01


func _ready():

	# hide mouse and lock at center
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _input(event):

	# only mouse input
	if not event is InputEventMouseMotion: return

	# rotate by mouse
	rotate_y(-event.relative.x * mouse_sensitivity)


func _physics_process(delta: float) -> void:

	# add the gravity
	if not is_on_floor(): velocity += get_gravity() * delta

	# jump
	if Input.is_action_just_pressed("jump") and is_on_floor(): velocity.y = jump_velocity

	# input vector
	var input_dir := Input.get_vector("left", "right", "forward", "backward")

	# direction
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	# speed
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	# move and slide
	move_and_slide()
