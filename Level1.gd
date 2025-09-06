extends Level

func get_init_inventory_items() -> Array[InventoryItem]:
	return [
		InventoryItem.new("angry_flower", 3)
	]
	
func get_fuckable_items() -> Array[TFuckableItem]:
	return [
		TFuckableItem.new("tv", 1)
	]
