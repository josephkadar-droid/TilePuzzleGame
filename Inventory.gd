extends Control
class_name Inventory

var item_scenes: Dictionary = {}
var item_containers: Dictionary = {}

func _ready():
	setup_item_scenes()

func setup_item_scenes():
	# You'll assign these in the editor or load them
	# For now, we'll create them programmatically
	pass

func setup_for_level(required_items: Dictionary):
	# Clear existing items
	for child in get_children():
		child.queue_free()
	
	item_containers.clear()
	
	# Create item containers
	var y_offset = 0
	for item_type in required_items.keys():
		var quantity = required_items[item_type]
		create_item_container(item_type, quantity, y_offset)
		y_offset += 70

func create_item_container(item_type: String, quantity: int, y_pos: int):
	var container = HBoxContainer.new()
	container.position = Vector2(10, y_pos)
	add_child(container)
	
	# Label
	var label = Label.new()
	label.text = item_type + ": "
	label.custom_minimum_size.x = 100
	container.add_child(label)
	
	# Items
	var items_container = HBoxContainer.new()
	container.add_child(items_container)
	
	for i in range(quantity):
		var item = create_draggable_item(item_type)
		items_container.add_child(item)
	
	item_containers[item_type] = items_container

func create_draggable_item(item_type: String) -> DraggableItem:
	var item = preload("res://DraggableItem.tscn").instantiate()
	item.item_type = item_type
	
	# Set color based on type
	match item_type:
		"apple":
			item.item_color = Color.RED
		"banana":
			item.item_color = Color.YELLOW
		"orange":
			item.item_color = Color.ORANGE
		_:
			item.item_color = Color.WHITE
	
	return item
