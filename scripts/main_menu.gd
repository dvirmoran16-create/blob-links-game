extends Control

var is_god_mode = false

func _ready():
	$VBoxContainer/PlayButton.pressed.connect(_on_play_pressed)
	$VBoxContainer/TutorialButton.pressed.connect(_on_tutorial_pressed)
	$VBoxContainer/SandboxButton.pressed.connect(_on_sandbox_pressed)
	$VBoxContainer/ExitButton.pressed.connect(_on_exit_pressed)
	$VBoxContainer/PlayButton/GodModeToggle.toggled.connect(_on_god_mode_toggled)

func _on_play_pressed():
	Player.god_mode = is_god_mode
	get_tree().change_scene_to_file("res://scenes/main_scenes/game.tscn")

func _on_tutorial_pressed():
	print("Tutorial clicked - implement later!")
	
func _on_sandbox_pressed():
	print("Sandbox clicked - implement later!")
	
func _on_exit_pressed():
	get_tree().quit()
	
func _on_god_mode_toggled(is_on):
	is_god_mode = is_on
