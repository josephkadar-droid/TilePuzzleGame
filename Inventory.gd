extends Control
class_name Inventory

var item_scenes: Dictionary = {}
var item_containers: Dictionary = {}

func _ready():
	print("=== INVENTORY _ready() called ===")
	setup_item_scenes()

func setup_item_scenes():
	pass

func setup_for_level(level_num: int, init_inventory: Array[InventoryItem]):
	print("=== SETTING UP INVENTORY FOR LEVEL ===")
	print("Initial inventory items: ", init_inventory)
	
	# Clear existing items
	for child in get_children():
		child.queue_free()
	
	item_containers.clear()
	
	# Create item containers
	var y_offset = 0
	for item in init_inventory:
		var quantity = item.quantity
		print("Creating ", quantity, " items of type: ", item.name)
		create_item_container(level_num, item.name, quantity, y_offset)
		y_offset += 70

func create_item_container(level_num: int, item_type: String, quantity: int, y_pos: int):
	print("=== CREATING ITEM CONTAINER ===")
	print("Item type: ", item_type, " Quantity: ", quantity, " Y position: ", y_pos)
	
	var container = HBoxContainer.new()
	container.position = Vector2(10, y_pos)
	add_child(container)
	
	# Label
	var label = Label.new()
	label.text = item_type.replace("_", " ").capitalize() + ": "
	label.custom_minimum_size.x = 150
	container.add_child(label)
	
	# Items
	var items_container = HBoxContainer.new()
	container.add_child(items_container)
	
	for i in range(quantity):
		print("Creating draggable item #", i+1)
		var item = create_draggable_item(item_type)
		
		# Get the level container to add 2D items
		var level_container = get_node("../../LevelContainer")
		if level_container.get_child_count() > 0:
			var level = level_container.get_child(level_num-1)
			print("level tile size: ",level.tile_size)
			level.add_child(item)
			
			# Position items more visibly (center-right area)
			item.position = Vector2(1200 + (i * 80), 200 + y_pos)
			print("Item positioned at: ", item.position)
		else:
			print("ERROR: No level found in LevelContainer")
	
	item_containers[item_type] = items_container

func create_draggable_item(item_type: String) -> DraggableItem:
	print("=== CREATING DRAGGABLE ITEM ===")
	print("Loading DraggableItem.tscn for type: ", item_type)
	
	var item = preload("res://DraggableItem.tscn").instantiate()
	item.item_type = item_type
	
	# Set color and appearance based on type
	match item_type:
		"angry_flower":
			item.item_color = Color(0.8, 0.2, 0.2)  # Dark red/angry color
		_:
			item.item_color = Color.WHITE
	
	print("Created item with type: ", item.item_type, " and color: ", item.item_color)
	return item
