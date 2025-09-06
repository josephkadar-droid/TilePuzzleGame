extends ShelfSpot

class_name InanimateObject

func _ready() -> void:
	is_placed = true
	item_placed.emit(true)
