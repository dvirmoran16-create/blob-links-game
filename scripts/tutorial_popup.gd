extends Popup

func _ready():
	$VBoxContainer/CloseButton.pressed.connect(_on_close_button_pressed)

func _on_close_button_pressed():
	hide()
