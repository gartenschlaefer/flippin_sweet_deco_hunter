extends Node3D
class_name WeaponBase

enum State { IDLE, ATTACKING, COMBO_WAIT, RETURNING }
enum AttackMode { COMBO, DRAG }

var attack_mode : AttackMode = AttackMode.DRAG
var drag_active := false
var drag_pos := Vector3.ZERO
var drag_rot := Vector3.ZERO

@export var weapon_model: Node3D
@export var weapon_physics : WeaponPhysicsBase

@onready var weapon_mesh: MeshInstance3D
@onready var weapon_skeleton: Skeleton3D

@export var drag_pos_sensitivity := 0.1
@export var drag_rot_sensitivity := 0.003
@export var cam_speed_while_attacking := 1.0
const DRAG_ROT_MAX_Z := deg_to_rad(45.0)
const DRAG_ROT_MAX_X := deg_to_rad(90.0)

var state: State = State.IDLE

var idle_pos := Vector3.ZERO
var idle_rot := Vector3.ZERO

var start_pos := Vector3.ZERO
var start_rot := Vector3.ZERO
var end_pos := Vector3.ZERO
var end_rot := Vector3.ZERO
var start_transform: Transform3D
var end_transform: Transform3D

var combo_index := 0
var combo_timer := 0.0
var combo_timeout := 0.5

const DEPTH := 0.0
const POS_SCALE := 0.01
var attack_duration := 1.9
var attack_time := 0.0
var attack_alpha := 0.0

func _ready():
	weapon_mesh = _find_mesh(weapon_model)
	weapon_skeleton= _find_skeleton(weapon_model)
	weapon_physics.setup(weapon_skeleton,weapon_mesh)
	init_weapon()


func handle_mouse_motion(delta: Vector2):
	if state != State.ATTACKING:
		return

	if attack_mode == AttackMode.DRAG:
		_apply_drag(delta)


func _physics_process(delta): 
	if weapon_physics and weapon_physics.is_ready:
		weapon_physics._physics_process(delta)
	if attack_mode == AttackMode.COMBO:
		match state: 
			State.ATTACKING: 
				attack_time += delta / attack_duration 
				_apply_step(clamp(attack_time , 0.0, 1.0)) 
				if attack_time  >= 1.0: 
					state = State.COMBO_WAIT 
					combo_timer = combo_timeout 
			State.COMBO_WAIT: 
				combo_timer -= delta 
				if combo_timer <= 0.0: 
					_start_return() 
			State.RETURNING: 
				attack_time  += delta / attack_duration 
				_apply_step(clamp(attack_time , 0.0, 1.0)) 
				if attack_time  >= 1.0: 
					state = State.IDLE 
					combo_index = 0


func attack_pressed():
	match attack_mode:
		AttackMode.COMBO:
			attack()
		AttackMode.DRAG:
			_start_drag()
			attack()


func attack_released():
	if attack_mode == AttackMode.DRAG:
		_end_drag()


func attack():
	if attack_mode == AttackMode.COMBO:
		if state == State.IDLE:
			_start_attack(get_attack_pose(0))
		elif state == State.COMBO_WAIT:
			combo_index += 1
			_start_attack(get_attack_pose(combo_index))


func _start_attack(pose):
	start_pos = position
	start_rot = rotation
	attack_time = 0.0
	end_pos = pose.pos
	end_rot = pose.rot
	state = State.ATTACKING


func _start_drag():
	drag_active = true
	drag_pos = get_current_pos()
	drag_rot = rotation
	state = State.ATTACKING

func _end_drag():
	drag_active = false
	state = State.RETURNING
	attack_time = 0.0


func _apply_drag(mouse_delta: Vector2):
	drag_rot.z -= mouse_delta.x * drag_rot_sensitivity
	if (drag_rot.z > DRAG_ROT_MAX_X):
		drag_rot.z = DRAG_ROT_MAX_X
	elif (drag_rot.z < -DRAG_ROT_MAX_X):
		drag_rot.z = -DRAG_ROT_MAX_X
	else:
		drag_pos.x += mouse_delta.x * drag_pos_sensitivity
	
	drag_rot.x -= mouse_delta.y * drag_rot_sensitivity	
	if (drag_rot.x > DRAG_ROT_MAX_Z):
		drag_rot.x = DRAG_ROT_MAX_Z
	elif (drag_rot.x < -DRAG_ROT_MAX_Z):
		drag_rot.x = -DRAG_ROT_MAX_Z
	else:
		drag_pos.y -= mouse_delta.y * drag_pos_sensitivity

	set_weapon_pose(drag_pos, drag_rot)


func _start_return():
	start_pos = get_current_pos()
	start_rot = rotation
	end_pos = idle_pos
	end_rot = idle_rot
	attack_time  = 0.0
	state = State.RETURNING

func _apply_step(delta):
	var speed := 1.0 / attack_duration
	var step : float = speed * delta

	var curr_pos := get_current_pos()
	var curr_rot := rotation

	var target_pos := curr_pos.move_toward(end_pos, step * curr_pos.distance_to(end_pos))
	var target_rot := Vector3(
		rotate_toward(curr_rot.x, end_rot.x, delta),
		rotate_toward(curr_rot.y, end_rot.y, delta),
		rotate_toward(curr_rot.z, end_rot.z, delta)
	)

	set_weapon_pose(target_pos, target_rot)


func set_weapon_pose(pos: Vector3, rot: Vector3):
	var local_pos := Vector3(
		pos.x * POS_SCALE,
		pos.y * POS_SCALE,
		pos.z * POS_SCALE
	)

	transform.origin = local_pos
	rotation = rot

func get_current_pos() -> Vector3:
	return Vector3(
		transform.origin.x / POS_SCALE,
		transform.origin.y / POS_SCALE,
		transform.origin.z / POS_SCALE
	)

func get_attack_pose(index: int):
	match index:
		0:
			return {
				"pos": Vector3(-40, 0, -15),
				"rot": Vector3(deg_to_rad(-10),deg_to_rad(15),deg_to_rad(45))
				}
		1:
			return {
				"pos": Vector3(-10, 0, 5),
				"rot": Vector3(deg_to_rad(-45),deg_to_rad(-15),deg_to_rad(-35))
			}
		2:
			return {
				"pos": Vector3(-20, 0, 30),
				"rot": Vector3(deg_to_rad(35),deg_to_rad(15),deg_to_rad(15))
			}
		3:
			return {
				"pos": Vector3(-20, 0, 0),
				"rot": Vector3(deg_to_rad(-30),0,deg_to_rad(15))
			}
		_:
			return {
				"pos": idle_pos,
				"rot": idle_rot
			}


func rotate_toward(curr: float, target: float, max_delta: float) -> float:
	var diff := wrapf(target - curr, -PI, PI)
	diff = clamp(diff, -max_delta, max_delta)
	return curr + diff


func _find_mesh(n: Node3D) -> MeshInstance3D:
	if n is MeshInstance3D:
		return n
	for c in n.get_children():
		var m = _find_mesh(c)
		if m:
			return m
	return null


func _find_skeleton(n: Node) -> Skeleton3D:
	if n is Skeleton3D:
		return n
	for c in n.get_children():
		var s = _find_skeleton(c)
		if s:
			return s
	return null

func get_camera_speed_multiplier() -> float:
	if state == State.ATTACKING:
		return cam_speed_while_attacking
	return 1.0

func init_weapon():
	pass

func notify_hit(_enemy):
	pass

func on_equip(_player):
	pass

func on_unequip():
	pass
