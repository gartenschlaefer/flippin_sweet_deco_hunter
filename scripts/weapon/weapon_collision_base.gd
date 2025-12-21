# --
# collision base

class_name WeaponCollisionBase extends RigidBody3D

# refs
@export var weapon: WeaponBase

# vars
var is_active: bool = false

signal enemy_hit
signal swing_start

func emit_enemy_hit_signal():
	enemy_hit.emit()

func emit_start_swing_signal():
	swing_start.emit()

func get_is_active(): return is_active
func get_weapon(): return weapon
