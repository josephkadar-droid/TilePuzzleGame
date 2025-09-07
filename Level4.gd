extends Level

func _init() -> void:
	completion_msg = "Next time you'll water us before you eat!\nLevel Complete!"

func get_init_inventory_items() -> Array[InventoryItem]:
	return [
		InventoryItem.new("angry_flower", 1)
	]
	
func get_fuckable_items() -> Array[FuckableItem]:
	return [
		
	]
