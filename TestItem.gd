extends DraggableItem

func _ready():
	print("=== TEST ITEM READY ===")
	item_type = "test"
	item_color = Color.BLUE
	
	# Call parent _ready()
	super._ready()
	
	print("Test item position: ", position)
	print("Test item global_position: ", global_position)
