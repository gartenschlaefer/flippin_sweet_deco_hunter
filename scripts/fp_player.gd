# --
# first person player

extends CharacterBody3D
class_name  Player

# refs
@onready var head = $head

# vars
var direction: Vector3
var collected_sticker: Array[StickerResource] = []

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
	weapon = preload("res://prefabs/weapon_whip.tscn").instantiate()
	# hide mouse and lock at center
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _input(event):
	
	if _weapon:
		if Input.is_action_just_pressed("attack"):
			_weapon.attack_pressed()
		elif Input.is_action_just_released("attack"):
			_weapon.attack_released()

	# only mouse input
	if not event is InputEventMouseMotion: return

	# rotate by mouse	
	if _weapon and _weapon.state == _weapon.State.ATTACKING:
		_weapon.handle_mouse_motion(event.relative)
		handle_mouse_motion(event.relative * _weapon.cam_speed_while_attacking)
	else:
		handle_mouse_motion(event.relative)


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


func handle_mouse_motion(delta: Vector2):
	rotate_y(-delta.x * mouse_sensitivity)
	head.rotate_x(-delta.y * mouse_sensitivity)
	head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))


func add_sticker(sticker: StickerResource):

	# add sticker
	collected_sticker.append(sticker)
	print("sticker collected!")


# --
# setter and getter

func get_player_has_bubaba_sticker():

	# quick has bubaba sticker evaluation
	for sticker in collected_sticker:
		if sticker.get_sticker_type_is_bubaba(): return true

	return false
