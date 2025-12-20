# --
# weapon collision whip

class_name WeaponCollisionWhip extends WeaponCollisionBase

signal whip_crack

func emit_whip_crack_signal():
	whip_crack.emit()
