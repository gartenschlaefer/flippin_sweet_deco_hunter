# --
# first person player

extends CharacterBody3D
class_name  Player

# refs
@onready var head = $head

# vars
var direction: Vector3

# const
const speed = 5.0
const jump_velocity = 4.5
const mouse_sensitivity = 0.005
const lerp_speed = 7.0

@onready var weapon_socket: Node3D = $head/Camera3D/WeaponSocket

var _weapon: WeaponBase = null

var weapon: WeaponBase:
	set(value):
		if _weapon:
			_weapon.on_unequip()
			_weapon.queue_free()

		_weapon = value

		if _weapon:
			weapon_socket.add_child(_weapon)
			_weapon.transform = Transform3D.IDENTITY
			_weapon.on_equip(self)


func _ready():
	weapon = preload("res://prefabs/licorice_whip.tscn").instantiate()
	# hide mouse and lock at center
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _input(event):
	
	if _weapon and Input.is_action_just_pressed("attack"):
		_weapon.attack()

	# only mouse input
	if not event is InputEventMouseMotion: return

	# rotate by mouse
	rotate_y(-event.relative.x * mouse_sensitivity)
	head.rotate_x(-event.relative.y * mouse_sensitivity)
	head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))


func _physics_process(delta: float) -> void:

	# add the gravity
	if not is_on_floor(): velocity += get_gravity() * delta

	# jump
	if Input.is_action_just_pressed("jump") and is_on_floor(): velocity.y = jump_velocity

	# input vector
	var input_dir := Input.get_vector("left", "right", "forward", "backward")

	# direction
	direction = lerp(direction, (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta * lerp_speed)
	
	# speed
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	# move and slide
	move_and_slide()
