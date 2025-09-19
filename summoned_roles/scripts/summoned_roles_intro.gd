extends Control

@onready var audioplayer = $AudioStreamPlayer
@onready var animplayer = $AnimationPlayer
@onready var hover_helptext = $Buttons/VBoxContainer/HoverHelpText
@onready var card_info = $CardInfoOverlay
@onready var hover_ch1 = $Buttons/HoverOA
@onready var hover_ch2 = $Buttons/HoverLI
@onready var hover_ch3 = $Buttons/HoverFD
@onready var hover_ch4 = $Buttons/HoverSL
@onready var hover_ch5 = $Buttons/HoverFF
@onready var buttons = $Buttons

@export var scene_x: PackedScene


func _ready():
	if scene_x == null:
		push_error("SceneX PackedScene is not assigned in Home.gd")
	card_info.visible = false
	hover_helptext.self_modulate = Color(1, 1, 1, 0)
	buttons.visible = false

#---scene set and go----
func go_to_scene(idx: int) -> void:
	if scene_x == null:
		return
	var inst = scene_x.instantiate()
	inst.set("set_id", idx)
	get_tree().root.add_child(inst)

	var old_scene = get_tree().current_scene
	get_tree().current_scene = inst
	if old_scene:
		old_scene.queue_free()

#---OrdAura-X
func _on_button_oa_mouse_entered() -> void:
	hover_ch1.visible = true
func _on_button_oa_mouse_exited() -> void:
	hover_ch1.visible = false

#---Liaseillume
func _on_button_li_mouse_entered() -> void:
	hover_ch2.visible = true
func _on_button_li_mouse_exited() -> void:
	hover_ch2.visible = false

#---Fathomdepth
func _on_button_fd_mouse_entered() -> void:
	hover_ch3.visible = true
func _on_button_fd_mouse_exited() -> void:
	hover_ch3.visible = false

#---Searchlight
func _on_button_sl_mouse_entered() -> void:
	hover_ch4.visible = true
func _on_button_sl_mouse_exited() -> void:
	hover_ch4.visible = false

#---Fyreforge
func _on_button_ff_mouse_entered() -> void:
	hover_ch5.visible = true
func _on_button_ff_mouse_exited() -> void:
	hover_ch5.visible = false

#---Help Button Stuff
func _on_card_info_mouse_entered() -> void:
	hover_helptext.self_modulate = Color(1, 1, 1, 1)
func _on_card_info_mouse_exited() -> void:
	hover_helptext.self_modulate = Color(1,1,1,0)

func _on_card_info_pressed() -> void:
	card_info.visible = true
func _on_button_exit_pressed() -> void:
	card_info.visible = false

#-----BUTTONS TO CARDS SCENES-----#

func _on_button_oa_pressed() -> void:
	go_to_scene(0)

func _on_button_li_pressed() -> void:
	go_to_scene(1)

func _on_button_fd_pressed() -> void:
	go_to_scene(2)

func _on_button_sl_pressed() -> void:
	go_to_scene(3)

func _on_button_ff_pressed() -> void:
	go_to_scene(4)

func _on_button_05_pressed() -> void:
	pass 
	#go_to_scene(5)


func _on_start_pressed() -> void:
	$Start.visible = false
	$Start.disabled = true
	AudioServer.unlock()               # required by browsers on first user gesture
	animplayer.play("anim_intro")
	audioplayer.play(0)
	await animplayer.animation_finished
	_on_animation_player_animation_finished("anim_intro")

#anim stuff
func _on_animation_player_animation_finished(anim_name) -> void:
	if anim_name == "anim_intro":
		$Buttons/ButtonOA.disabled = false
		$Buttons/ButtonLI.disabled = false
		$Buttons/ButtonFD.disabled = false
		$Buttons/ButtonSL.disabled = false
		$Buttons/ButtonFF.disabled = false
		$BG/ImageCards2/Button05.disabled = false
		buttons.visible = true
