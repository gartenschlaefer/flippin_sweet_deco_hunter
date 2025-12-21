# --
# collision base

class_name WeaponCollisionBase extends RigidBody3D

# refs
@export var weapon: WeaponBase

# vars
var is_active := false:
	set(value):
		if is_active == value:
			return
		is_active = value
		_on_active_changed(value)
	get:
		return is_active

signal enemy_hit
signal swing_start

func emit_enemy_hit_signal():
	enemy_hit.emit()

func emit_start_swing_signal():
	swing_start.emit()

func get_is_active(): return is_active
func get_weapon(): return weapon

func _on_active_changed(_value: bool) -> void:
	pass
