extends Level

func get_init_inventory_items() -> Array[InventoryItem]:
	return [
		InventoryItem.new("angry_flower", 2)
	]
	
func get_fuckable_items() -> Array[FuckableItem]:
	return [
		TV.new()
	]
