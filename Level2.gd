extends Level

func _init() -> void:
	completion_msg = "You destroyed Timmy's Homelab!\nLevel Complete!"

func get_init_inventory_items() -> Array[InventoryItem]:
	return [
		InventoryItem.new("angry_flower", 2)
	]
	
func get_fuckable_items() -> Array[FuckableItem]:
	return [
		#Homelab.new()
	]
