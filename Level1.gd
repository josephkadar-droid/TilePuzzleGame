extends Level

func _init() -> void:
	completion_msg = "TV DESTROYED!\nLevel Complete!"

func get_init_inventory_items() -> Array[InventoryItem]:
	return [
		InventoryItem.new("angry_flower", 3)
	]
	
func get_fuckable_items() -> Array[FuckableItem]:
	return [
		TV.new()
	]
