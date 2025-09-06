extends Control
class_name GameManager

@export var current_level: int = 1
@export var level_scenes: Array[PackedScene] = []

@onready var level_container = $LevelContainer
@onready var ui_container = $UIContainer
@onready var inventory = $UIContainer/Inventory

var current_level_node: Level

func _ready():
	print("=== GAMEMANAGER _ready() called ===")
	print("Level container: ", level_container)
	print("UI container: ", ui_container)
	print("Inventory: ", inventory)
	load_level(current_level)

func load_level(level_num: int):
	print("=== LOADING LEVEL ===")
	print("Level number: ", level_num)
	print("Available level scenes: ", level_scenes.size())
	
	# Clear existing level
	if current_level_node:
		current_level_node.queue_free()
	
	# Load new level
	if level_num <= level_scenes.size() and level_scenes[level_num - 1]:
		print("Loading level scene: ", level_scenes[level_num - 1])
		current_level_node = level_scenes[level_num - 1].instantiate()
		level_container.add_child(current_level_node)
		current_level_node.level_completed.connect(_on_level_completed)
		
		print("Level loaded. Getting required items...")
		var required_items = current_level_node.get_required_items()
		print("Required items: ", required_items)
		
		# Setup inventory for this level
		print("Setting up inventory...")
		inventory.setup_for_level(required_items)
		print("Inventory setup complete")
	else:
		print("ERROR: Could not load level ", level_num)

func _on_level_completed():
	print("Level ", current_level, " completed!")
	current_level += 1
	if current_level <= level_scenes.size():
		await get_tree().create_timer(1.0).timeout  # Brief pause
		load_level(current_level)
	else:
		print("All levels completed!")

func next_level():
	current_level += 1
	if current_level <= level_scenes.size():
		load_level(current_level)
