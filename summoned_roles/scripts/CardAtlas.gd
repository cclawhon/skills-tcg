# ===================================================================
# File: res://scripts/CardAtlas.gd
# Purpose: Centralized texture loading for card fronts/backs.
# ===================================================================
extends Node

# Why: Keep path logic DRY and allow swapping theme/folder easily.
var root_dir: String = "res://art/cards/sets/"

func front_path(set_id: int, card_id: int) -> String:
	return "%s/%d/front_%d.png" % [root_dir, set_id, card_id]

func back_path(set_id: int) -> String:
	return "%s/%d/back.png" % [root_dir, set_id]

func load_front(set_id: int, card_id: int) -> Texture2D:
	var p := front_path(set_id, card_id)
	var tex := load(p)
	if tex is Texture2D:
		return tex
	push_warning("Missing front texture: %s" % p)
	return ImageTexture.create_from_image(Image.create(4, 4, false, Image.FORMAT_RGBA8))

func load_back(set_id: int) -> Texture2D:
	var p := back_path(set_id)
	var tex := load(p)
	if tex is Texture2D:
		return tex
	push_warning("Missing back texture: %s" % p)
	return ImageTexture.create_from_image(Image.create(4, 4, false, Image.FORMAT_RGBA8))
