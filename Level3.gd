extends Level

func _init() -> void:
	completion_msg = "No more gaming for Bobby!\nThat boy aint right.\nLevel Complete!"

func get_init_inventory_items() -> Array[InventoryItem]:
	return [
		InventoryItem.new("angry_flower", 1)
	]
	
func get_fuckable_items() -> Array[FuckableItem]:
	return [
		
	]
