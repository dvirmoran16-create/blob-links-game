extends Control

var is_god_mode = false

@onready var tutorial_popup: Popup = $TutorialPopup

func _ready():
	$VBoxContainer/PlayButton.pressed.connect(_on_play_pressed)
	$VBoxContainer/TutorialButton.pressed.connect(_on_tutorial_pressed)
	$VBoxContainer/ExitButton.pressed.connect(_on_exit_pressed)
	$VBoxContainer/PlayButton/GodModeToggle.toggled.connect(_on_god_mode_toggled)
	tutorial_popup.hide()

func _on_play_pressed():
	Player.god_mode = is_god_mode
	get_tree().change_scene_to_file("res://scenes/main_scenes/game.tscn")

func _on_tutorial_pressed():
	print("Tutorial clicked - implement later!")
	tutorial_popup.popup_centered()
	
func _on_exit_pressed():
	get_tree().quit()
	
func _on_god_mode_toggled(toggle_value: bool):
	is_god_mode = toggle_value
