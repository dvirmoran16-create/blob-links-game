extends Node

var is_paused = false

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(_delta):
	if Input.is_action_just_pressed("pause"):
		is_paused = not is_paused
		get_tree().paused = is_paused
