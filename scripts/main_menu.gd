extends Control

func _ready():
	# Connect button signals
	$VBoxContainer/PlayButton.pressed.connect(_on_play_pressed)
	$VBoxContainer/TutorialButton.pressed.connect(_on_tutorial_pressed)
	$VBoxContainer/SandboxButton.pressed.connect(_on_sandbox_pressed)
	$VBoxContainer/ExitButton.pressed.connect(_on_exit_pressed)

func _on_play_pressed():
	# Load the game scene
	get_tree().change_scene_to_file("res://scenes/main_scenes/game.tscn")

func _on_tutorial_pressed():
	print("Tutorial clicked - implement later!")
	
func _on_sandbox_pressed():
	print("Sandbox clicked - implement later!")
	
func _on_exit_pressed():
	get_tree().quit()
