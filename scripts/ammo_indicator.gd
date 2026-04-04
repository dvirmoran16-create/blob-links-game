class_name AmmoIndicator
extends Node2D

@export var radius = 40.0  # Distance from player center
@export var max_ammo = 5  # Number of dots to create
@export var rotation_speed = PI / 2

var dots = []
var ammo_sprite = preload("res://scenes/sprite_scenes/ammo_sprite.tscn")

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

func _physics_process(delta):
	rotate(rotation_speed * delta)
	for d in dots:
		d.rotation -= rotation_speed * delta * 2
	
func create_dots(num_of_dots):
	dots.clear()
	for i in range(num_of_dots):
		var dot := ammo_sprite.instantiate() as ColorRect
		dot.color.a = 0.5
		add_child(dot)
		dots.append(dot)

func place_dots(num_of_dots: int):
	# Position visible dots in a circle
	for i in range(num_of_dots):
		var angle = (float(i) / dots.size()) * TAU  # TAU = 2 * PI
		var x = cos(angle) * radius
		var y = sin(angle) * radius
		var dot_center_vector = Vector2(-dots[0].size.x / 2, -dots[0].size.y / 2)
		dots[i].position = Vector2(x, y) + dot_center_vector
		
func _on_player_ammo_changed(current, max, delta):
	if max != dots.size():
		create_dots(max)
		place_dots(current)
		
	for i in range(dots.size()):
		dots[i].visible = (i < current)
