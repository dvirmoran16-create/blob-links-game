extends Line2D

@export var fade_duration = 0.2

var point_ages = []
var is_active = false

func _process(delta):
	if not is_active:
		# Fade out existing trail
		if get_point_count() > 0:
			age_and_remove_points(delta)
		return
		
	var pos = get_parent().global_position
	add_point(pos, 0)
	point_ages.insert(0, 0.0)
	
	# Age and remove old points
	age_and_remove_points(delta)

func age_and_remove_points(delta):
	for i in range(point_ages.size() - 1, -1, -1):
		point_ages[i] += delta
		if point_ages[i] > fade_duration:
			remove_point(i)
			point_ages.remove_at(i)

func activate():
	is_active = true

func deactivate():
	is_active = false
