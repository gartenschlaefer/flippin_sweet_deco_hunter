extends Node3D
class_name WeaponBase

enum State { IDLE, ATTACKING, RETURNING }
enum AttackMode { DRAG }

var attack_mode : AttackMode = AttackMode.DRAG
var drag_active := false
var drag_pos := Vector3.ZERO
var drag_rot := Vector3.ZERO

@export var weapon_model: Node3D
@export var weapon_physics : WeaponPhysicsBase

@onready var weapon_mesh: MeshInstance3D
@onready var weapon_skeleton: Skeleton3D

@export var weapon_collision : WeaponCollisionBase
@export var weapon_audio_player: AudioStreamPlayer3D
@export var drag_pos_sensitivity := 0.1
@export var drag_rot_sensitivity := 0.003
@export var cam_speed_while_attacking := 0.1
const DRAG_ROT_MAX_Z := deg_to_rad(90.0)
const DRAG_ROT_MAX_X := deg_to_rad(45.0)

var state: State = State.IDLE
var weapon_default_audio_stream : AudioStream

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

var current_pos := Vector3.ZERO
var current_rot := Vector3.ZERO

func _ready():
	weapon_mesh = _find_mesh(weapon_model)
	weapon_skeleton= _find_skeleton(weapon_model)
	weapon_physics.setup(weapon_skeleton,weapon_mesh)
	init_weapon()
	weapon_default_audio_stream = weapon_audio_player.stream
	weapon_collision.enemy_hit.connect(_on_enemy_hit)
	weapon_collision.swing_start.connect(_on_swing_start)


func handle_mouse_motion(delta: Vector2):
	if state != State.ATTACKING:
		return

	if attack_mode == AttackMode.DRAG:
		_apply_drag(delta)


func _physics_process(delta): 
	if weapon_physics and weapon_physics.is_ready:
		weapon_physics._physics_process(delta)


func attack_pressed():
	match attack_mode:
		AttackMode.DRAG:
			_start_drag()


func attack_released():
	if attack_mode == AttackMode.DRAG:
		_end_drag()


func _start_attack(pose):
	start_pos = position
	start_rot = rotation
	attack_time = 0.0
	end_pos = pose.pos
	end_rot = pose.rot
	state = State.ATTACKING


func _start_drag():
	drag_active = true
	drag_pos = current_pos
	drag_rot = current_rot
	state = State.ATTACKING

func _end_drag():
	drag_active = false
	state = State.RETURNING
	attack_time = 0.0


func _apply_drag(mouse_delta: Vector2):
	var raw_z := drag_rot.z - mouse_delta.x * drag_rot_sensitivity
	var clamped_z = clamp(raw_z, -DRAG_ROT_MAX_Z, DRAG_ROT_MAX_Z)

	if raw_z == clamped_z:
		drag_pos.x += mouse_delta.x * drag_pos_sensitivity
	drag_rot.z = clamped_z

	var raw_x := drag_rot.x - mouse_delta.y * drag_rot_sensitivity
	var clamped_x = clamp(raw_x, -DRAG_ROT_MAX_X, DRAG_ROT_MAX_X)

	if raw_x == clamped_x:
		drag_pos.y += mouse_delta.y * drag_pos_sensitivity
	drag_rot.x = clamped_x

	set_weapon_pose(drag_pos, drag_rot)


func _start_return():
	start_pos = current_pos
	start_rot = current_rot
	end_pos = idle_pos
	end_rot = idle_rot
	attack_time  = 0.0
	state = State.RETURNING


func set_weapon_pose(pos: Vector3, rot: Vector3):
	transform.origin = pos * POS_SCALE

	var qx := Quaternion(Vector3.RIGHT, rot.x)
	var qy := Quaternion(Vector3.UP, rot.y)
	var qz := Quaternion(Vector3.BACK, rot.z)

	transform.basis = Basis(qz * qy * qx)


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

func _on_enemy_hit():
	pass

func _on_swing_start():
	if weapon_audio_player:
		weapon_audio_player.stream = weapon_default_audio_stream
		weapon_audio_player.play()

func on_equip(_player):
	pass

func on_unequip():
	pass
