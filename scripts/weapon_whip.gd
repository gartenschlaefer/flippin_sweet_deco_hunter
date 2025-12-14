extends WeaponBase
class_name WeaponWhip

enum SweetSource { NONE, INPUT, HIT }

var sweet_active := false
var sweet_timer := 0.0
var sweet_window := 0.15
var sweet_source := SweetSource.NONE
var hit_pending := false
@onready var whip_physics: WhipPhysics = $WhipPhysics

func attack():
	if state == State.ATTACKING and not sweet_active:
		_start_sweetspot(SweetSource.INPUT)
	else:
		super.attack()
		whip_physics.start_swing()

func _physics_process(delta):
	super._physics_process(delta)


func notify_hit(_enemy):
	if not sweet_active:
		_start_sweetspot(SweetSource.HIT)
		hit_pending = true
	else:
		hit_pending = true


func _start_sweetspot(source):
	sweet_active = true
	sweet_timer = sweet_window
	sweet_source = source
	hit_pending = false


func _resolve_sweetspot(input_received: bool):
	if sweet_source == SweetSource.INPUT:
		_whipcrack()
	elif sweet_source == SweetSource.HIT and input_received:
		_whipcrack()

	sweet_active = false
	sweet_source = SweetSource.NONE
	hit_pending = false


func _input(event):
	if event.is_action_pressed("attack") and sweet_active and sweet_source == SweetSource.HIT:
		_resolve_sweetspot(true)


func _whipcrack():
	_trigger_snapback()
	_play_whip_sound()


func _trigger_snapback():
	var snap := Vector3(0, 0,-15)
	set_weapon_pose(get_current_pos()+snap, rotation)
	whip_physics.trigger_snapback()


func _play_whip_sound():
	pass
