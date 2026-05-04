class_name PickupIndicator
extends Node2D

@export var arrow_distance_factor = 10
@export var min_distance = 300.0

var arrows = []
@onready var arrow_node : Polygon2D = $Arrow

func _process(_delta):
	var pickups = get_tree().get_nodes_in_group("pickups")
	while arrows.size() < pickups.size():
		var arrow = create_arrow()
		arrows.append(arrow)
	
	for i in range(pickups.size()):
		if is_instance_valid(pickups[i]):
			update_arrow(arrows[i], pickups[i])
	
	for i in range(pickups.size(), arrows.size()):
		arrows[i].visible = false

func create_arrow() -> Polygon2D:
	var arrow = arrow_node.duplicate()
	add_child(arrow)
	return arrow

func update_arrow(arrow: Polygon2D, pickup: Node2D):
	var player_pos = get_parent().global_position
	var distance = player_pos.distance_to(pickup.global_position)
	if distance < min_distance:
		arrow.visible = false
	else:
		var direction = (pickup.global_position - player_pos).normalized()
		arrow.position = direction * distance / arrow_distance_factor
		arrow.rotation = direction.angle()
		arrow.visible = true
