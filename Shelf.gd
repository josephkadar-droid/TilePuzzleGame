# PlaceableObject.gd - Base class for objects that can have items placed on them
# This is like a base GameObject class in C# that handles placement logic

extends Area2D  # Inherits from Node2D (like inheriting from MonoBehaviour in Unity)
class_name Shelf  # Defines this as a custom class type

# EXPORTED VARIABLES - appear in editor inspector (like [SerializeField] in Unity)
@export var object_name: String = "Object"  # Name identifier for this object
@export var completion_effect: String = "fall"  # Effect type: "fall", "disappear", etc.
@export var max_weight: int = 3

# PRIVATE VARIABLES - internal state management
var placement_spots: Array[ShelfSpot] = []  # List of spots where items can be placed
var current_weight: int = 0

var has_effects: bool = false

@export var position_effects: Dictionary = {}

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
		
	print("current weight: ", current_weight)

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
	var pos_count = 1
	for child in node.get_children():
		if child is ShelfSpot:
			print("Found ShelfSpot: ", child.name)
			placement_spots.append(child)  # Add to our array (like List.Add() in C#)
			child.parent_object = self  # Set back-reference so spot knows its parent
			# EVENT SUBSCRIPTION - listen for item placement events (like += in C#)
			child.item_placed.connect(_on_item_placed)
			child.spot_position = pos_count
			print("pos", pos_count)
			pos_count += 1
	
	# RECURSION - check all children of this node
	#for child in node.get_children():
		#find_placement_spots_recursive(child)

# EVENT HANDLER - called whenever an item is placed on any of our spots
func _on_item_placed():
	print("=== ITEM PLACED - CHECKING COMPLETION ===")
	print("Total spots: ", placement_spots.size())
	var filled_spots = 0  # Counter for filled spots
	var weight = 0  # Counter for filled spots
	
	# VALIDATION LOOP - check each spot to see if it's filled
	for spot in placement_spots:
		if spot.is_placed:
			if spot is PlacementSpot:
				spot.weight = 1
				has_effects = false
				apply_special_effect(spot)
			filled_spots += 1
			weight += spot.weight
	
	print("Filled spots: ", filled_spots, " / ", placement_spots.size())
	print("current weight: ", weight)
	current_weight = weight
	
	# COMPLETION CHECK - trigger effect if all spots are filled
	if is_satisfied():
		print("ALL SPOTS FILLED - TRIGGERING COMPLETION EFFECT")
		trigger_completion_effect()
	else:
		print("Not all spots filled yet - waiting for more items")

func apply_special_effect(spot: PlacementSpot):
	print("special effect")
	if position_effects.has(spot.spot_position):
		print("effect match")
		match position_effects[spot.spot_position]:
			"sun":
				print("sun effect: ", spot.spot_position)
				spot.filled_item.grow_plant()
				has_effects = true
				#await get_tree().create_timer(0.2).timeout
				spot.weight = 2
			"fire":
				if not spot.filled_item.heat_resistant:
					spot.filled_item.shrivel_plant()
					has_effects = true
					spot.weight = 0

# COMPLETION VALIDATOR - checks if all placement spots are filled
func is_satisfied() -> bool:
	# VALIDATION LOOP - return false if any spot is empty
	return current_weight >= max_weight

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
	
	var crash_player = AudioStreamPlayer2D.new()
	var sound = load("res://assets/crash.mp3")
	crash_player.stream = sound
	crash_player.volume_db = 5
	add_child(crash_player)
	crash_player.play()
	
	# TV INTERACTION - find and break the TV when shelf falls
	var level = get_parent()  # Get parent level node (like transform.parent in Unity)
	var tv_node = level.get_node_or_null("TV")  # Search for TV node by name
	
	var timeout: float = 0.4
	if has_effects:
		timeout = 2
	await get_tree().create_timer(timeout).timeout
	
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
