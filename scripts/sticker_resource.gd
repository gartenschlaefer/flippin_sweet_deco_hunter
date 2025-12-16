# --
# sticker

class_name StickerResource extends Resource

@export var sticker_type: Enums.StickerType
@export var uid: int
@export var texture: Texture2D


# --
# getter

func get_uid(): return uid
func get_sticker_type() -> Enums.StickerType: return sticker_type
func get_sticker_type_is_bubaba() -> bool: return self.get_sticker_type() == Enums.StickerType.bubaba
func get_texture() -> Texture2D: return texture
