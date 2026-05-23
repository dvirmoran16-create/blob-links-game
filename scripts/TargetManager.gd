extends Node2D

const TARGETING_RADIUS_SQUARED = 150.0 ** 2

var current_enemy: Node2D = null
var current_blob: Blob  = null

func _process(_delta):
	var mouse = get_global_mouse_position()
	var new_enemy = _find_closest(mouse, "enemies")
	var new_blob : Blob = _find_closest(mouse, "blobs")
	handle_blob_transitioning(new_blob)
		
func handle_blob_transitioning(new_blob: Blob):
	if new_blob == current_blob:
		return
	if is_instance_valid(current_blob):
		current_blob.undo_highlight()
	if is_instance_valid(new_blob):
		new_blob.highlight()
	current_blob = new_blob
	

func _find_closest(pos: Vector2, group: String) -> Node2D:
	var closest = null
	var closest_dist = TARGETING_RADIUS_SQUARED
	for node in get_tree().get_nodes_in_group(group):
		var d = pos.distance_squared_to(node.global_position)
		if d < closest_dist:
			closest_dist = d
			closest = node
	return closest

func _update_indicator(indicator: Node2D, target: Node2D):
	if target:
		indicator.global_position = target.global_position
		indicator.modulate.a = 0.4
		if target.has_method("highlight"):
			target.highlight
		indicator.show()
	else:
		indicator.hide()
