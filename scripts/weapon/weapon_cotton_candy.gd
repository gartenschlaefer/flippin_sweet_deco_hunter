# --
# weapon cotton candy

class_name WeaponCottonCandy extends WeaponBase

@export var sticker_collected_sound: AudioStream

func _on_sticker_collected():
	weapon_audio_player.stream = sticker_collected_sound
	weapon_audio_player.play()
