extends Node
class_name WeaponInventory

var weapons: Array[PackedScene] = []

var current_index := -1
var previous_index := -1
var last_index

signal weapon_added

func add_weapon(scene: PackedScene):
	if weapons.has(scene):
		return
	weapons.append(scene)
	emit_signal("weapon_added")

func get_weapon(index: int) -> PackedScene:
	if index < 0 or index >= weapons.size():
		return null
	return weapons[index]

func set_current(index: int):
	if index == current_index:
		return

	previous_index = current_index
	current_index = index

func weapon_count() -> int:
	return weapons.size()

func get_previous() -> PackedScene:
	if previous_index < 0:
		return null
	return get_weapon(previous_index)
