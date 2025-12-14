extends Node3D
class_name WeaponBase

enum State { IDLE, ATTACKING, COMBO_WAIT, RETURNING }

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
var attack_duration := 0.9
var attack_time := 0.0
var attack_alpha := 0.0

var weapon_physics : Node3D

func _ready():
	for child in get_children():
		if child.name == "Physics":
			weapon_physics = child

func attack():
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
	


func _physics_process(delta): 
	if weapon_physics:
		weapon_physics.physics_process(delta)
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
				"pos": Vector3(10, 0, -5),
				"rot": Vector3(0,0,deg_to_rad(-35))
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


func notify_hit(_enemy):
	pass

func on_equip(_player):
	pass

func on_unequip():
	pass
