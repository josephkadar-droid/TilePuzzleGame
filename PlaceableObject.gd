extends Node2D
class_name PlaceableObject

@export var object_name: String = "Object"
@export var completion_effect: String = "fall"  # "fall", "disappear", etc.

var placement_spots: Array[PlacementSpot] = []

func _ready():
	# Find all placement spots that belong to this object
	find_placement_spots_recursive(self)

func find_placement_spots_recursive(node: Node):
	if node is PlacementSpot:
		placement_spots.append(node)
		node.parent_object = self
	
	for child in node.get_children():
		find_placement_spots_recursive(child)

func is_satisfied() -> bool:
	# Check if all placement spots are filled
	for spot in placement_spots:
		if not spot.is_filled():
			return false
	return true

func trigger_completion_effect():
	match completion_effect:
		"fall":
			fall_animation()
		"disappear":
			disappear_animation()

func fall_animation():
	var tween = create_tween()
	tween.tween_property(self, "position", position + Vector2(0, 1000), 1.0)
	tween.tween_callback(queue_free)

func disappear_animation():
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	tween.tween_callback(queue_free)
