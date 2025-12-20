extends WeaponBase
class_name WeaponWhip

var sweet_active := false
var sweet_timer := 0.0
var sweet_window := 0.15
var hit_pending := false
@export var whip_collision: WeaponCollisionWhip
@export var whip_tip_audio_player: AudioStreamPlayer3D
@export var whip_mid_audio_player: AudioStreamPlayer3D
@export var whip_crack_light_energy := 10.0
@export var whip_crack_light_range := 1.0
@export var whip_crack_light_fade_frames := 10
@export var whip_crack_light_color : Color = Color(1.0, 0.15, 0.3)

func init_weapon():
	whip_collision.whip_crack.connect(_on_whip_crack)
	whip_collision.enemy_hit.connect(_on_whip_crack)
	whip_collision.swing_start.connect(_on_swing_start)


func _physics_process(delta):
	super._physics_process(delta)


func _play_whip_sound():
	whip_tip_audio_player.play()
	whip_mid_audio_player.stop()
	

func _on_whip_crack():
	_play_whip_sound()
	_spawn_whip_crack_light()
	whip_collision.is_active = false


func _on_swing_start():
	whip_mid_audio_player.play()


func _spawn_whip_crack_light():
	var light := OmniLight3D.new()
	light.light_energy = whip_crack_light_energy
	light.omni_range = whip_crack_light_range
	light.light_color = whip_crack_light_color

	whip_tip_audio_player.add_child(light)
	light.global_position = whip_tip_audio_player.global_position

	_fade_and_free_light(light)


func _fade_and_free_light(light: OmniLight3D):
	var frames := whip_crack_light_fade_frames
	var start_energy := light.light_energy

	for i in frames:
		await get_tree().physics_frame
		light.light_energy = start_energy * (1.0 - float(i + 1) / frames)

	light.queue_free()
