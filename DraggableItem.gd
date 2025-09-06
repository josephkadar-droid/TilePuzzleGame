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
var snap_distance: float = 80.0

func _ready():
	print("=== DraggableItem _ready() called ===")
	print("Item type: ", item_type)
	
	# Create sprite
	sprite = Sprite2D.new()
	sprite.texture = create_item_texture()
	add_child(sprite)
	
	# Set up collision
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(60, 60)
	collision.shape = shape
	add_child(collision)
	
	# Enable input
	input_pickable = true
	
	original_parent = get_parent()
	original_position = original_parent.position
	print("og pos: ", original_position)
	print("=== DraggableItem setup complete ===")

func create_item_texture() -> ImageTexture:
	print("create txtre")
	if item_type == "angry_flower":
		return create_angry_flower_texture()
	else:
		# Default colored square
		var image = Image.create(60, 60, false, Image.FORMAT_RGB8)
		image.fill(item_color)
		# Add border
		for x in range(60):
			for y in range(60):
				if x < 3 or x >= 57 or y < 3 or y >= 57:
					image.set_pixel(x, y, Color.BLACK)
		
		var texture = ImageTexture.new()
		texture.set_image(image)
		return texture

func create_angry_flower_texture() -> ImageTexture:
	var image = Image.create(60, 60, false, Image.FORMAT_RGB8)
	image.fill(Color.TRANSPARENT)
	
	# Pot (brown/terracotta)
	var pot_color = Color(0.6, 0.3, 0.1)
	for y in range(35, 55):
		for x in range(15, 45):
			var pot_width = 30 - (y - 35) * 0.3
			var start_x = 30 - pot_width / 2
			var end_x = 30 + pot_width / 2
			if x >= start_x and x <= end_x:
				image.set_pixel(x, y, pot_color)
	
	# Pot rim (darker brown)
	var rim_color = Color(0.4, 0.2, 0.05)
	for x in range(15, 45):
		image.set_pixel(x, 35, rim_color)
		image.set_pixel(x, 36, rim_color)
	
	# Stem (green)
	var stem_color = Color(0.2, 0.6, 0.2)
	for y in range(20, 35):
		image.set_pixel(29, y, stem_color)
		image.set_pixel(30, y, stem_color)
		image.set_pixel(31, y, stem_color)
	
	# Flower petals (red/angry)
	var petal_color = Color(0.8, 0.1, 0.1)
	var center_x = 30
	var center_y = 15
	
	# 5 petals around center
	var petal_positions = [
		Vector2(0, -5),   # Top
		Vector2(-4, -2),  # Top left
		Vector2(-3, 3),   # Bottom left
		Vector2(3, 3),    # Bottom right
		Vector2(4, -2)    # Top right
	]
	
	for petal_pos in petal_positions:
		var petal_x = center_x + petal_pos.x
		var petal_y = center_y + petal_pos.y
		
		# Draw petal (small oval)
		for dy in range(-2, 3):
			for dx in range(-2, 3):
				if dx*dx + dy*dy <= 4:
					var px = petal_x + dx
					var py = petal_y + dy
					if px >= 0 and px < 60 and py >= 0 and py < 60:
						image.set_pixel(px, py, petal_color)
	
	# Flower center (dark red/black for angry look)
	var center_color = Color(0.3, 0.05, 0.05)
	for dy in range(-1, 2):
		for dx in range(-1, 2):
			image.set_pixel(center_x + dx, center_y + dy, center_color)
	
	# Angry eyes (black dots)
	image.set_pixel(27, 13, Color.BLACK)
	image.set_pixel(28, 13, Color.BLACK)
	image.set_pixel(32, 13, Color.BLACK)
	image.set_pixel(33, 13, Color.BLACK)
	
	# Angry mouth (downward curve)
	image.set_pixel(28, 17, Color.BLACK)
	image.set_pixel(29, 18, Color.BLACK)
	image.set_pixel(30, 18, Color.BLACK)
	image.set_pixel(31, 18, Color.BLACK)
	image.set_pixel(32, 17, Color.BLACK)
	
	# Angry eyebrows (angled lines)
	image.set_pixel(26, 11, Color.BLACK)
	image.set_pixel(27, 12, Color.BLACK)
	image.set_pixel(33, 12, Color.BLACK)
	image.set_pixel(34, 11, Color.BLACK)
	
	var texture = ImageTexture.new()
	texture.set_image(image)
	return texture

func _input(event):
	if Input.is_action_just_pressed("click"):
		var mouse_pos = get_global_mouse_position()
		var bounds = Rect2(global_position - Vector2(30, 30), Vector2(60, 60))
		
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

func return_to_original_position():
	var tween = create_tween()
	tween.tween_property(self, "position", original_position, 0.3)
	tween.tween_callback(func(): return_to_inventory = true)
