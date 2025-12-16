# --
# sticker

class_name StickerResource extends Resource

@export var sticker_type: Enums.StickerType
@export var uid: int
@export var texture: Texture2D


# --
# getter

func get_uid(): return uid
func get_sticker_type(): return sticker_type
