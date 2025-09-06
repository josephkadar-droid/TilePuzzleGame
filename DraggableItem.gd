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
	
	original_position = position
	original_parent = get_parent()
	print("=== DraggableItem setup complete ===")

func create_item_texture() -> ImageTexture:
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
	
	var placement_successful = false
	var overlapping_areas = get_overlapping_areas()
	
	for area in overlapping_areas:
		if area is PlacementSpot:
			var spot = area as PlacementSpot
			if spot.place_item(self):
				placement_successful = true
				break
	
	if not placement_successful and return_to_inventory:
		return_to_original_position()

func _process(_delta):
	if is_being_dragged:
		global_position = get_global_mouse_position()

func place_at_spot(spot: PlacementSpot):
	current_placement_spot = spot
	position = spot.position
	return_to_inventory = false

func return_to_original_position():
	var tween = create_tween()
	tween.tween_property(self, "position", original_position, 0.3)
	tween.tween_callback(func(): return_to_inventory = true)
