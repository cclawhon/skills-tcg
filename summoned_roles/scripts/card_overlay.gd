#REMOVED ANIMPLAYER STUFF @onready var animplayer = $AnimationPlayer
	#ready -> animplayer.play("card_flip_1")
	#on button press -> 	animplayer.play_backwards("card_flip_1")
	
# ===================================================================
# File: res://ui/card_overlay.gd
# Node tree (CardOverlay.tscn suggestion):
#   Control (name: CardOverlay, anchors full rect)
#     Panel (name: Shadow)   # backdrop dim; modulate.a animates in/out
#     Control (name: Card3D) # container for the flipping card
#       TextureRect (name: Back)  # z_index 0
#       TextureRect (name: Front) # z_index 1
#     Button (name: BlockerButton) # full rect, transparent, catches clicks
# Changelog: updated convert global local helpers / xform to basis_xform
# update for animplayer not tween
#===================================================================
# res://scripts/card_overlay.gd
extends Control
class_name CardOverlay

@onready var card3d: Control = $Card3D
@onready var back_tex: TextureRect = $Card3D/Back
@onready var front_tex: TextureRect = $Card3D/Front
@onready var blocker_button: Button = $BlockerButton
@onready var animplayer: AnimationPlayer = $AnimationPlayer

# state
var _start_global_rect: Rect2
var _current_anim: StringName = &""
var _source_back: Control = null  # BackX from SceneX (to hide while overlay is up)

# timing / sizes (your values are fine; AnimationPlayer will mostly handle)
@export var center_size: Vector2 = Vector2(540, 780)

func _ready() -> void:
	# Avoid duplicate connect if you also wired in the Inspector
	if not blocker_button.pressed.is_connected(_on_blocker_button_pressed):
		blocker_button.pressed.connect(_on_blocker_button_pressed)
	# TextureRects fill their parent already bc that's what controls are set to do in inspector

# NOTE: added optional 4th arg = source_back (may be null)
func show_from(start_global_rect: Rect2, set_id: int, card_id: int, source_back: Control = null) -> void:
	_source_back = source_back
	if _source_back:
		_source_back.visible = false  # hide the original card while overlay is active

	# textures from autoload atlas
	back_tex.texture  = CardAtlas.load_back(set_id)
	front_tex.texture = CardAtlas.load_front(set_id, card_id)

	_start_global_rect = start_global_rect
	# Place card at the start rect AFTER the node is fully ready (avoid anchor override)
	call_deferred("_place_and_play", card_id)

func _place_and_play(card_id: int) -> void:
	# Choose animation by card index (your existing names)
	_current_anim = StringName("card_flip_%d" % card_id)
	if _current_anim in animplayer.get_animation_list():
		animplayer.play(_current_anim)
	else:
		# Fallback: if you only have one generic anim name, use it
		_current_anim = &"card_flip"
		if _current_anim in animplayer.get_animation_list():
			animplayer.play(_current_anim)
	
func _on_blocker_button_pressed() -> void:
	# Reverse the current animation; when done, restore source and free
	if _current_anim == &"":
		queue_free()
		return
	if _current_anim in animplayer.get_animation_list():
		animplayer.play_backwards(_current_anim)
		await animplayer.animation_finished
	if _source_back:
		_source_back.visible = true
	queue_free()
	
