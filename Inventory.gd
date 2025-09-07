extends Control
class_name Inventory

var item_scenes: Dictionary = {}
var item_containers: Dictionary = {}

func _ready():
	print("=== INVENTORY _ready() called ===")
	setup_item_scenes()

func setup_item_scenes():
	pass
