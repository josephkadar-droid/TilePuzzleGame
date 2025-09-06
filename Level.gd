extends Node2D
class_name Level

signal level_completed

@export var tile_size: int = 64
@export var grid_width: int = 30
@export var grid_height: int = 17
@export var show_debug_grid: bool = false

var grid_data: Array = []
var placeable_objects: Array[PlaceableObject] = []
var placement_spots: Array[PlacementSpot] = []

func _ready():
	initialize_grid()
	if show_debug_grid:
		draw_debug_grid()
	
	# Find all placeable objects and placement spots
	find_objects_recursive(self)
	
	# Connect placement spot signals
	for spot in placement_spots:
		spot.item_placed.connect(_on_item_placed)

func initialize_grid():
	grid_data.clear()
	for x in range(grid_width):
		grid_data.append([])
		for y in range(grid_height):
			grid_data[x].append(null)

func draw_debug_grid():
	var grid_node = Node2D.new()
	grid_node.name = "DebugGrid"
	add_child(grid_node)
	
	for x in range(grid_width + 1):
		var line = Line2D.new()
		line.add_point(Vector2(x * tile_size, 0))
		line.add_point(Vector2(x * tile_size, grid_height * tile_size))
		line.width = 1.0
		line.default_color = Color(1, 1, 1, 0.3)
		grid_node.add_child(line)
	
	for y in range(grid_height + 1):
		var line = Line2D.new()
		line.add_point(Vector2(0, y * tile_size))
		line.add_point(Vector2(grid_width * tile_size, y * tile_size))
		line.width = 1.0
		line.default_color = Color(1, 1, 1, 0.3)
		grid_node.add_child(line)

func find_objects_recursive(node: Node):
	if node is PlaceableObject:
		placeable_objects.append(node)
	elif node is PlacementSpot:
		placement_spots.append(node)
	
	for child in node.get_children():
		find_objects_recursive(child)

func world_to_grid(world_pos: Vector2) -> Vector2i:
	return Vector2i(int(world_pos.x / tile_size), int(world_pos.y / tile_size))

func grid_to_world(grid_pos: Vector2i) -> Vector2:
	return Vector2(grid_pos.x * tile_size + tile_size/2, grid_pos.y * tile_size + tile_size/2)

func _on_item_placed():
	check_completion()

func check_completion():
	# Check if all objects are satisfied
	for obj in placeable_objects:
		if not obj.is_satisfied():
			return
	
	# All objects satisfied - trigger effects and complete level
	for obj in placeable_objects:
		obj.trigger_completion_effect()
	
	await get_tree().create_timer(1.5).timeout  # Wait for animations
	level_completed.emit()

func get_required_items() -> Dictionary:
	# Override in specific levels
	return {}
