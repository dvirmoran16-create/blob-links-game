class_name AmmoPickup
extends Area2D

@export var rotation_speed = PI / 2
@export var ttl = 12.0

var look_for_player : bool = false
var age = 0.0
@onready var progress_circle = $TextureProgressBar

func _ready():
	body_entered.connect(_on_detect_player)
	body_exited.connect(_on_stop_detect_player)
	progress_circle.max_value = ttl
	progress_circle.step = 0.25
	
func _physics_process(delta):
	rotate(rotation_speed * delta)
	age += delta
	progress_circle.value = ttl - age
	
	if age >= ttl:
		queue_free()
		return
	
	if look_for_player:
		var bodies = get_overlapping_bodies()
		for body in bodies:
			_on_detect_player(body)
		
func _on_detect_player(body):
	if body.is_in_group("player"):
		var player = body as Player
		if player.current_ammo >= player.max_ammo:
			look_for_player = true
		else:
			player.update_ammo_status(1, false)
			queue_free()
			
func _on_stop_detect_player(body):
	if body.is_in_group("player"):
		look_for_player = false
