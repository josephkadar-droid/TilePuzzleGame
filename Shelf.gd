# PlaceableObject.gd - Base class for objects that can have items placed on them
# This is like a base GameObject class in C# that handles placement logic

extends Area2D  # Inherits from Node2D (like inheriting from MonoBehaviour in Unity)
class_name Shelf  # Defines this as a custom class type

# EXPORTED VARIABLES - appear in editor inspector (like [SerializeField] in Unity)
@export var object_name: String = "Object"  # Name identifier for this object
@export var completion_effect: String = "fall"  # Effect type: "fall", "disappear", etc.

# PRIVATE VARIABLES - internal state management
var placement_spots: Array[PlacementSpot] = []  # List of spots where items can be placed

# INITIALIZATION - called when object enters scene (like Start() in Unity)
func _ready():
	print("=== PLACEABLE OBJECT _ready() ===")
	print("Object name: ", object_name)
	
	# RECURSIVE SEARCH - find all placement spots that belong to this object
	find_placement_spots_recursive(self)
	
	# DEBUG OUTPUT - show how many spots were found
	print("Found ", placement_spots.size(), " placement spots")
	for i in range(placement_spots.size()):
		print("Spot ", i+1, ": ", placement_spots[i].name)

func _process(delta: float) -> void:
	FuckTheItems()

func FuckTheItems():
	var overlapping_areas = get_overlapping_areas()
	
	for area in overlapping_areas:
		if area is FuckableItem:
			area.fuck_item()

# RECURSIVE FINDER - searches through all child nodes to find PlacementSpots
func find_placement_spots_recursive(node: Node):
	# TYPE CHECK - if this node is a PlacementSpot, add it to our list
	if node is PlacementSpot:
		print("Found PlacementSpot: ", node.name)
		placement_spots.append(node)  # Add to our array (like List.Add() in C#)
		node.parent_object = self  # Set back-reference so spot knows its parent
		# EVENT SUBSCRIPTION - listen for item placement events (like += in C#)
		node.item_placed.connect(_on_item_placed)
	
	# RECURSION - check all children of this node
	for child in node.get_children():
		find_placement_spots_recursive(child)

# EVENT HANDLER - called whenever an item is placed on any of our spots
func _on_item_placed():
	print("=== ITEM PLACED - CHECKING COMPLETION ===")
	print("Total spots: ", placement_spots.size())
	var filled_spots = 0  # Counter for filled spots
	
	# VALIDATION LOOP - check each spot to see if it's filled
	for spot in placement_spots:
		if spot.is_filled():
			filled_spots += 1
			print("Spot ", spot.name, " is filled")
		else:
			print("Spot ", spot.name, " is empty")
	
	print("Filled spots: ", filled_spots, " / ", placement_spots.size())
	
	# COMPLETION CHECK - trigger effect if all spots are filled
	if is_satisfied():
		print("ALL SPOTS FILLED - TRIGGERING COMPLETION EFFECT")
		trigger_completion_effect()
	else:
		print("Not all spots filled yet - waiting for more items")

# COMPLETION VALIDATOR - checks if all placement spots are filled
func is_satisfied() -> bool:
	# VALIDATION LOOP - return false if any spot is empty
	for spot in placement_spots:
		if not spot.is_filled():
			return false  # Early exit if any spot is empty
	return true  # All spots are filled

# EFFECT DISPATCHER - triggers the appropriate completion effect
func trigger_completion_effect():
	# SWITCH STATEMENT - choose effect based on completion_effect setting
	match completion_effect:
		"fall":
			fall_animation()  # Make object fall down
		"disappear":
			disappear_animation()  # Make object fade away

# FALL ANIMATION - makes object fall and breaks TV below
func fall_animation():
	print("=== SHELF STARTING TO FALL ===")
	
	# TV INTERACTION - find and break the TV when shelf falls
	var level = get_parent()  # Get parent level node (like transform.parent in Unity)
	var tv_node = level.get_node_or_null("TV")  # Search for TV node by name
	
	# ANIMATION SETUP - create falling motion (like DOTween in Unity)
	var tween = create_tween()  # Create animation controller
	# TWEEN ANIMATION - animate position downward over 1 second
	tween.tween_property(self, "position", position + Vector2(0, 1000), 1.0)
	
	# TV DESTRUCTION - break TV when she
	# DISAPPEAR ANIMATION - makes object fade out instead of falling
func disappear_animation():
	print("=== OBJECT DISAPPEARING ===")
	# FADE ANIMATION - animate alpha/transparency to 0 over 0.5 seconds
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)  # Fade to transparent
	tween.tween_callback(queue_free)  # Destroy after fade completes
