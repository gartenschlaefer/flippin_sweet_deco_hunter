# --
# first person player

extends CharacterBody3D
class_name  Player

# refs
@onready var head = $head

# vars
var direction: Vector3
var collected_sticker: Array[StickerResource] = []
var is_in_tree_hanging_range = false
var christmas_tree_object = null

# const
const speed = 5.0
const jump_velocity = 4.5
const mouse_sensitivity = 0.005
const lerp_speed = 7.0

@onready var weapon_socket: WeaponSocket = $head/Camera3D/WeaponSocket
@export var weapon_inventory: WeaponInventory

func _ready():
	weapon_inventory.add_weapon(preload("res://prefabs/weapon/weapon_cotton_candy.tscn"))
	weapon_inventory.add_weapon(preload("res://prefabs/weapon/weapon_lollipop.tscn"))
	weapon_inventory.add_weapon(preload("res://prefabs/weapon/weapon_whip.tscn"))
	
	weapon_socket.inventory = weapon_inventory
	weapon_socket.try_auto_equip()
	# hide mouse and lock at center
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	is_in_tree_hanging_range = false
	christmas_tree_object = null


func _input(event):
	if Input.is_action_just_pressed("attack"):
		weapon_socket.attack_pressed()
	elif Input.is_action_just_released("attack"):
		weapon_socket.attack_released()
	elif Input.is_action_just_pressed("weapon_previous"):
		weapon_socket.equip_previous()

	if event is InputEventMouseMotion:
		var delta : Vector2 = event.relative

		weapon_socket.handle_mouse_motion(delta)

		var cam_mul := 1.0
		if weapon_socket.current_weapon:
			cam_mul = weapon_socket.current_weapon.get_camera_speed_multiplier()

		handle_mouse_motion(delta * cam_mul)

	# tree hanging
	if not is_in_tree_hanging_range: return

	# interact with christmas tree
	if Input.is_action_just_pressed("interact"): 
		if not event.is_echo(): self.hang_deco_on_christmas_tree()



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


func hang_deco_on_christmas_tree():

	# skips if no christmas tree object or sticker
	if christmas_tree_object == null: return
	if not len(collected_sticker): return

	# add deco
	christmas_tree_object.hang_deco_on_tree(collected_sticker.pop_back(), self)


# --
# setter and getter

func get_player_has_sticker() -> bool: return bool(len(collected_sticker))

func get_player_has_bubaba_sticker() -> bool:

	# quick has bubaba sticker evaluation
	for sticker in collected_sticker:
		if sticker.get_sticker_type_is_bubaba(): return true

	return false


func set_is_in_tree_hanging_range(is_in_range: bool, christmas_tree: ChristmasTree): 

	# settings
	is_in_tree_hanging_range = is_in_range
	christmas_tree_object = christmas_tree if is_in_range else null


func get_is_in_tree_hanging_range() -> bool: return is_in_tree_hanging_range
