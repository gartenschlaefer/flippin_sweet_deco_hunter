extends CollisionShape3D
class_name WeaponCollisionWhip

var is_active : bool = false

signal enemy_hit

func emit_enemy_hit_signal():
	enemy_hit.emit()
