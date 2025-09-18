# ===================================================================
# File: res://cards/CardSlot.gd
# Attach this to each card's CHILD Button (1..4) inside your GCardHandLayout item.
# Exports: card_id (1..4). On pressed, signal parent (scene controller).
# ===================================================================
# res://cards/card_slot.gd  (add one debug print)
extends Button
class_name CardSlot

signal card_pressed(card_id: int, card_global_rect: Rect2)
@export_range(1, 4, 1) var card_id: int = 1

func _ready() -> void:
	if not pressed.is_connected(_on_pressed):
		pressed.connect(_on_pressed)

func _on_pressed() -> void:
	var card_control := get_parent() as Control  # BackX (correct)
	var global_rect := Rect2(card_control.global_position, card_control.size)
	print("[CardSlot]", name, " emit -> id=", card_id, " rect=", global_rect)
	card_pressed.emit(card_id, global_rect)
