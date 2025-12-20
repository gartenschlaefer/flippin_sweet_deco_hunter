extends WeaponCollisionBase
class_name WeaponCollisionWhip

signal whip_crack

func emit_whip_crack_signal():
	whip_crack.emit()
