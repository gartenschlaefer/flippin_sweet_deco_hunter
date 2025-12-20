extends CollisionShape3D
class_name WeaponCollisionBase

var is_active: bool = false

signal enemy_hit
signal swing_start

func emit_enemy_hit_signal():
	enemy_hit.emit()

func emit_start_swing_signal():
	swing_start.emit()
