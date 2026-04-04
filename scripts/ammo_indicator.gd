class_name AmmoIndicator
extends Node2D

@export var radius = 40.0  # Distance from player center
@export var max_ammo = 5  # Number of dots to create
@export var rotation_speed = PI / 2

var dots = []

var ammo_sprite = preload("res://scenes/sprite_scenes/ammo_sprite.tscn")

func _ready():
	create_dots()
	update_dots(max_ammo)  # Start with full ammo

func _physics_process(delta):
	rotate(rotation_speed * delta)
	for d in dots:
		d.rotation -= rotation_speed * delta * 2
	
func create_dots():
	# Create dots dynamically
	for i in range(max_ammo):
		var dot := ammo_sprite.instantiate() as ColorRect
		dot.position = Vector2(-dot.size.x / 2, -dot.size.y / 2)
		dot.color.a = 0.5
		add_child(dot)
		dots.append(dot)
	

func update_dots(ammo_count: int):
	# Show/hide dots based on ammo
	for i in range(dots.size()):
		dots[i].visible = (i < ammo_count)
	
	# Position visible dots in a circle
	for i in range(ammo_count):
		var angle = (float(i) / max_ammo) * TAU  # TAU = 2 * PI
		var x = cos(angle) * radius
		var y = sin(angle) * radius
		dots[i].position = Vector2(x, y) + Vector2(-dots[i].size.x / 2, -dots[i].size.y / 2)
