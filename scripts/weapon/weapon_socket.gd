extends Node3D
class_name WeaponSocket

@export var inventory: WeaponInventory
@export var input_weapon_1 := "weapon_1"
@export var input_weapon_2 := "weapon_2"
@export var input_weapon_3 := "weapon_3"
@export var input_previous := "weapon_previous"

var current_weapon: WeaponBase

var current_index := -1


func _ready():
	if inventory:
		inventory.weapon_added.connect(try_auto_equip)

func _unhandled_input(event):
	if event.is_action_pressed(input_weapon_1):
		if current_index != 0:
			equip_index(0)
	elif event.is_action_pressed(input_weapon_2):
		if current_index != 1:
			equip_index(1)
	elif event.is_action_pressed(input_weapon_3):
		if current_index != 2:
			equip_index(2)
	elif event.is_action_pressed(input_previous):
		equip_previous()

func equip_index(index: int):
	if not inventory:
		return

	var scene := inventory.get_weapon(index)
	if not scene:
		return
	_equip_scene(scene, index)

func _equip_scene(scene: PackedScene, index: int):
	if current_weapon:
		current_weapon.on_unequip()
		current_weapon.queue_free()

	var inst := scene.instantiate()
	add_child(inst)
	current_weapon = inst
	current_index = index

	current_weapon.on_equip(get_parent())
	inventory.set_current(index)


func try_auto_equip():
	if current_weapon:
		return
	if inventory.weapons.size() == 0:
		return
	equip_index(0)


func equip_previous():
	if not inventory:
		return
	var scene := inventory.get_previous()
	if not scene:
		return
	_equip_scene(scene, inventory.previous_index)

func attack_pressed():
	if current_weapon:
		current_weapon.attack_pressed()

func attack_released():
	if current_weapon:
		current_weapon.attack_released()

func handle_mouse_motion(delta: Vector2):
	if current_weapon:
		current_weapon.handle_mouse_motion(delta)
