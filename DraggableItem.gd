extends Area2D
class_name DraggableItem

@export var item_type: String = "generic"
@export var item_color: Color = Color.YELLOW
@export var return_to_inventory: bool = true

var is_being_dragged: bool = false
var original_position: Vector2
var original_parent: Node
var current_placement_spot: PlacementSpot = null
var sprite: Sprite2D
var snap_distance: float = 100.0

var effect_sprite: Sprite2D

func _ready():
	print("=== DraggableItem _ready() called ===")
	print("Item type: ", item_type)
	
	# Enable input
	input_pickable = true
	
	# Connect the input event signal
	#input_event.connect(_on_input_event)
	
	original_parent = get_parent()
	original_position = position
	print("=== DraggableItem setup complete ===")

func _input(event):	
	if Input.is_action_just_pressed("click") and not is_being_dragged:
		var mouse_pos = get_global_mouse_position()
		
		for child in get_children():
			if child is CollisionShape2D:
				var shape_extents = Vector2.ZERO
				if child.shape is RectangleShape2D:
					shape_extents = child.shape.extents
				
				var shape_pos = global_position + child.position
				var bounds = Rect2(shape_pos - shape_extents, shape_extents * 2)
		
				if bounds.has_point(mouse_pos):
					print("=== CLICKED ON ITEM ===")
					start_drag()
	
	elif Input.is_action_just_released("click") and is_being_dragged:
		print("=== RELEASED CLICK ===")
		end_drag()

func start_drag():
	print("=== START_DRAG CALLED ===")
	
	# Remove from current spot if placed
	if current_placement_spot:
		current_placement_spot.remove_item()
		current_placement_spot = null
		return_to_inventory = true
	
	is_being_dragged = true
	z_index = 100
	var tween = create_tween()
	tween.tween_property(sprite, "scale", Vector2(1.1, 1.1), 0.1)

func end_drag():
	print("=== END_DRAG CALLED ===")
	is_being_dragged = false
	z_index = 0
	var tween = create_tween()
	tween.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.1)
	
	print("Item position when dropped: ", global_position)
	
	# Find the closest available placement spot
	var closest_spot: PlacementSpot = null
	var closest_distance: float = snap_distance + 1
	
	var overlapping_areas = get_overlapping_areas()
	print("Overlapping areas: ", overlapping_areas.size())
	
	# Check all overlapping areas for placement spots
	for area in overlapping_areas:
		if area is PlacementSpot:
			var spot = area as PlacementSpot
			var distance = global_position.distance_to(spot.global_position)
			
			print("Found PlacementSpot ", spot.name, " at distance: ", distance)
			
			if spot.can_accept_item(self) and distance < closest_distance:
				closest_spot = spot
				closest_distance = distance
				print("This is now the closest valid spot")
	
	# Try to place in the closest valid spot if within snap distance
	var placement_successful = false
	if closest_spot and closest_distance <= snap_distance:
		print("Attempting to place in closest spot: ", closest_spot.name)
		if closest_spot.place_item(self):
			print("Item placed successfully!")
			placement_successful = true
	else:
		print("No valid spot within snap distance (", snap_distance, ")")
	
	# If no placement, return to inventory or stay where dropped
	if not placement_successful:
		if return_to_inventory:
			print("No valid placement - returning to inventory")
			return_to_original_position()
		else:
			print("Item stays where dropped")

func _process(_delta):
	if is_being_dragged:
		global_position = get_global_mouse_position()

func place_at_spot(spot: PlacementSpot):
	print("=== PLACE_AT_SPOT CALLED ===")
	current_placement_spot = spot
	
	# Snap to the spot's position with animation
	var snap_tween = create_tween()
	snap_tween.tween_property(self, "global_position", spot.global_position, 0.2)
	
	return_to_inventory = false
	
func grow_plant():
	sprite = get_child(0)
	effect_sprite = get_child(1)
	
	var tween = create_tween()
	tween.tween_property(sprite, "scale:y", 0.3, 0.7)
	
	await get_tree().create_timer(0.7).timeout
	
	sprite.visible = false
	effect_sprite.visible = true

func return_to_original_position():
	var tween = create_tween()
	tween.tween_property(self, "position", original_position, 0.3)
	tween.tween_callback(func(): return_to_inventory = true)
