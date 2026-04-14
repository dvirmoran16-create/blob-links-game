class_name BlobLine
extends Line2D

@export var fade_duration = 0.5
@export var max_width = 40.0
@export var start_color = Color(0.3, 0.5, 1.0, 1.0)  # Semi-opaque blue
@export var end_color = Color(0.0, 0.0, 1.0, 1.0)  # Semi-opaque blue

var age = 0.0
var damaged_enemies = []
var start_pos: Vector2
var end_pos: Vector2

@onready var hit_area = $HitArea
@onready var player: Player = get_tree().get_first_node_in_group("player")

func _ready():
	age = 0.0
	width = max_width
	collision_shape_setup()
	hit_area.monitoring = true
	hit_area.body_entered.connect(_on_body_entered)
	await get_tree().physics_frame
	call_deferred("collect_pickups")
	await get_tree().create_timer(0.2).timeout
	hit_area.monitoring = false

func _physics_process(delta):	
	age += delta
	var progress = age / fade_duration  # 0 to 1
	
	if progress >= 1.0:
		queue_free()
		return
	
	default_color = start_color.lerp(end_color, progress)
	default_color.a = 1.0 - progress
	width = max_width * (1.0 - progress)

func collision_shape_setup():
	clear_points()
	add_point(start_pos)
	add_point(end_pos)
	
	if hit_area:
		var collision_shape = hit_area.get_node("CollisionShape2D")
		if collision_shape and collision_shape.shape is CapsuleShape2D:
			var capsule = collision_shape.shape as CapsuleShape2D
			
			# Calculate line properties
			var line_vec = end_pos - start_pos
			var line_length = line_vec.length()
			var line_center = (start_pos + end_pos) / 2
			var line_angle = line_vec.angle() + PI / 2
			
			# Set capsule dimensions
			capsule.radius = max_width / 2  # Thickness
			capsule.height = line_length  # Length
			
			# Position and rotate capsule
			collision_shape.position = line_center
			collision_shape.rotation = line_angle

func _on_body_entered(body):
	if body.is_in_group("enemies") and body not in damaged_enemies:
		if body.has_method("blobify"):
			body.blobify()
		damaged_enemies.append(body)
		
func collect_pickups():
	var bodies = hit_area.get_overlapping_areas()
	for b in bodies:
		if b.is_in_group("pickups"):
			b._on_detect_player(player)
		elif b.is_in_group("enemies"):
			damaged_enemies.append(b)
			b.blobify()
