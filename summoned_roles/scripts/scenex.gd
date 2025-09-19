# ===================================================================
# File: res://scenes/SceneX.gd
# Controller for each of your scenes (0..5). Reuse the same script.
# Hook up the 4 CardSlot signals to _on_card_pressed via export inspector
# ===================================================================
# res://scripts/scenex.gd
extends Control
class_name CardSceneController

var set_id: int = 0
@export var overlay_packed: PackedScene

@onready var hover_helptext = $BG/VBoxContainer/HoverHelpText
@onready var card_info = $CardInfoOverlay
@onready var set_title_label: Label = $"BG/SetTitle"
@onready var set_def_label:   Label = $"BG/SetDef"
@onready var music_player: AudioStreamPlayer = $"MusicPlayer"

const SETS := [
	{"name": "OrdAura-X",   "desc": "Problem Solving & Strategy", "song": preload("res://summoned_roles/themes_fx/audio/music_ox.mp3")},
	{"name": "LiaseIllume", "desc": "Communication & Connection", "song": preload("res://summoned_roles/themes_fx/audio/music_li.mp3")},
	{"name": "FathomDepth", "desc": "Core of Conviction", "song": preload("res://summoned_roles/themes_fx/audio/music_fd.mp3")},
	{"name": "SearchLight", "desc": "Data & Research", "song": preload("res://summoned_roles/themes_fx/audio/music_sl.mp3")},
	{"name": "FyreForge",   "desc": "Creativity & Innovation", "song": preload("res://summoned_roles/themes_fx/audio/music_ff.mp3")},
	{"name": "StellarLume",   "desc": "Epic Cards & Eccentricity", "song": preload("res://summoned_roles/themes_fx/audio/SummonedRoles-IntroRevB_mixdown.mp3")},
]

func _ready() -> void:
	_update_set_labels()
	_apply_back_textures()
	_play_set_music()
	card_info.visible = false
	hover_helptext.self_modulate = Color(1, 1, 1, 0)
	# Defer: let GCardHandLayout finish positioning/rebuilding children
	call_deferred("_connect_card_slots_deferred")

func _update_set_labels() -> void:
	var data = SETS[set_id] if set_id >= 0 and set_id < SETS.size() else null
	if data == null:
		set_title_label.text = "Unknown Set"
		set_def_label.text = ""
	else:
		set_title_label.text = data["name"]
		set_def_label.text = data["desc"]

func _apply_back_textures() -> void:
	var tex: Texture2D = CardAtlas.load_back(set_id)
	for i in range(1, 5):
		var back := get_node_or_null("GCardHandLayout/Back%d" % i) as TextureRect
		if back:
			back.texture = tex

func _play_set_music() -> void:
	var data = SETS[set_id] if set_id >= 0 and set_id < SETS.size() else null
	if data == null:
		return
	music_player.stream = data["song"]  # already an AudioStream
	music_player.play()

func _connect_card_slots_deferred() -> void:
	await get_tree().process_frame
	for i in range(1, 5):
		var path := "GCardHandLayout/Back%d/Button_%d" % [i, i]
		var btn := get_node_or_null(path)
		if btn == null:
			continue
		# Prefer your CardSlot custom signal
		if btn.has_signal("card_pressed"):
			# String-name connect avoids cast issues
			if not btn.is_connected(&"card_pressed", Callable(self, "_on_card_pressed")):
				btn.connect(&"card_pressed", Callable(self, "_on_card_pressed"))
		# Fallback if CardSlot not attached
		elif btn is Button:
			var idx := i
			(btn as Button).pressed.connect(func():
				var back := get_node("GCardHandLayout/Back%d" % idx) as Control
				_on_card_pressed(idx, Rect2(back.global_position, back.size))
			)

func _on_card_pressed(card_id: int, card_global_rect: Rect2) -> void:
	if overlay_packed == null:
		push_error("Overlay Packed not set on SceneX")
		return
	var overlay := overlay_packed.instantiate()
	add_child(overlay)
	if overlay is Control:
		(overlay as Control).set_anchors_preset(Control.PRESET_FULL_RECT)
	# Pass the source BackX so overlay can hide/show it cleanly
	var source_back := get_node_or_null("GCardHandLayout/Back%d" % card_id) as Control
	overlay.call("show_from", card_global_rect, set_id, card_id, source_back)

#---Help Button Stuff
func _on_card_info_mouse_entered() -> void:
	hover_helptext.self_modulate = Color(1, 1, 1, 1)
func _on_card_info_mouse_exited() -> void:
	hover_helptext.self_modulate = Color(1,1,1,0)

func _on_card_info_pressed() -> void:
	card_info.visible = true
func _on_button_exit_pressed() -> void:
	card_info.visible = false


# SceneX.gd
func _on_button_home_pressed() -> void:
	var home_scene: PackedScene = load("res://summoned_roles/scenes/summoned_roles_home.tscn")
	if home_scene == null:
		push_error("Failed to load summoned_roles_home.tscn")
		return

	var inst = home_scene.instantiate()
	get_tree().root.add_child(inst)

	# swap current scene
	var old_scene = get_tree().current_scene
	get_tree().current_scene = inst
	if old_scene:
		old_scene.queue_free()



func _on_button_sound_toggled(toggled_on: bool) -> void:
	if toggled_on:
		$MusicPlayer.stream_paused = true
	else:
		$MusicPlayer.stream_paused = false
