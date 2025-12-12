extends Camera3D

var speed := 5.0
var mouse_sens := 0.003
var rot_x := 0.0
var rot_y := 0.0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rot_y -= event.relative.x * mouse_sens
		rot_x -= event.relative.y * mouse_sens
		rot_x = clamp(rot_x, -1.55, 1.55)
		rotation = Vector3(rot_x, rot_y, 0)

	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _process(delta):
	var dir := Vector3.ZERO
	if Input.is_key_pressed(KEY_W):
		dir -= transform.basis.z
	if Input.is_key_pressed(KEY_S):
		dir += transform.basis.z
	if Input.is_key_pressed(KEY_A):
		dir -= transform.basis.x
	if Input.is_key_pressed(KEY_D):
		dir += transform.basis.x
	if Input.is_key_pressed(KEY_Q):
		dir.y -= 1
	if Input.is_key_pressed(KEY_E):
		dir.y += 1

	if dir != Vector3.ZERO:
		global_transform.origin += dir.normalized() * speed * delta
