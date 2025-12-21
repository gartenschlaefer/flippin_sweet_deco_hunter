# --
# weapon collision whip

class_name WeaponCollisionWhip extends WeaponCollisionBase

signal whip_crack
@export var enemy_colission: CollisionShape3D

func emit_whip_crack_signal():
	whip_crack.emit()

func _on_active_changed(value: bool) -> void:
	enemy_colission.disabled = not value
