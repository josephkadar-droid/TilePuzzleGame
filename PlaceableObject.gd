extends Node2D
class_name PlaceableObject

@export var object_name: String = "Object"
@export var completion_effect: String = "fall"

var placement_spots: Array[PlacementSpot] = []

func _ready():
	print("=== PLACEABLE OBJECT _ready() ===")
	print("Object name: ", object_name)
	
	# Find all placement spots that belong to this object
	find_placement_spots_recursive(self)
	
	print("Found ", placement_spots.size(), " placement spots")
	for i in range(placement_spots.size()):
		print("Spot ", i+1, ": ", placement_spots[i].name)

func find_placement_spots_recursive(node: Node):
	if node is PlacementSpot:
		print("Found PlacementSpot: ", node.name)
		placement_spots.append(node)
		node.parent_object = self
		node.item_placed.connect(_on_item_placed)
	
	for child in node.get_children():
		find_placement_spots_recursive(child)

func _on_item_placed():
	print("=== ITEM PLACED - CHECKING COMPLETION ===")
	print("Total spots: ", placement_spots.size())
	var filled_spots = 0
	
	for spot in placement_spots:
		if spot.is_filled():
			filled_spots += 1
			print("Spot ", spot.name, " is filled")
		else:
			print("Spot ", spot.name, " is empty")
	
	print("Filled spots: ", filled_spots, " / ", placement_spots.size())
	
	if is_satisfied():
		print("ALL SPOTS FILLED - TRIGGERING COMPLETION EFFECT")
		trigger_completion_effect()
	else:
		print("Not all spots filled yet - waiting for more items")

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
