extends Control
class_name GameManager

@export var current_level: int = 1
@export var level_scenes: Array[PackedScene] = []

@onready var level_container = $LevelContainer
@onready var ui_container = $UIContainer
@onready var inventory = $UIContainer/Inventory

var current_level_node: Level
var completion_popup: AcceptDialog

func _ready():
	print("=== GAMEMANAGER _ready() called ===")
	print("Level container: ", level_container)
	print("UI container: ", ui_container)
	print("Inventory: ", inventory)
	load_level(current_level)
	create_completion_popup()

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
		var required_items = current_level_node.get_init_inventory_items()
		print("Required items: ", required_items)
		
		# Setup inventory for this level
		print("Setting up inventory...")
		inventory.setup_for_level(level_num, required_items)
		print("Inventory setup complete")
	else:
		print("ERROR: Could not load level ", level_num)
		
	create_tomfoolery_area(current_level_node.get_fuckable_items())

func create_tomfoolery_area(fuckable_items: Array[FuckableItem]):
	var tomfools = TomfooleryArea.new()
	
	for fuckable_item in fuckable_items:
		tomfools.add_child(fuckable_item)
				
	current_level_node.add_child(tomfools)

func _on_level_completed():
	print("Level ", current_level, " completed!")
	completion_popup.popup_centered()
	#current_level += 1
	#if current_level <= level_scenes.size():
		#await get_tree().create_timer(1.0).timeout  # Brief pause
		#load_level(current_level)
	#else:
		#print("All levels completed!")
		
func create_completion_popup():
	completion_popup = AcceptDialog.new()
	completion_popup.title = "Level Complete!"
	completion_popup.dialog_text = "TV DESTROYED!\nLevel Complete!"  # <-- HERE
	completion_popup.get_ok_button().text = "Next Level"
	add_child(completion_popup)
	completion_popup.confirmed.connect(on_next_level_pressed)

func on_next_level_pressed():  # <-- Function definition here
	current_level += 1
	if current_level <= level_scenes.size():
		load_level(current_level)
	else:
		show_game_complete_popup()

func show_game_complete_popup():  # <-- Function definition here
	var final_popup = AcceptDialog.new()
	final_popup.title = "Game Complete!"
	final_popup.dialog_text = "Congratulations! You've completed all levels!"
	final_popup.get_ok_button().text = "Play Again"
	add_child(final_popup)
	final_popup.confirmed.connect(on_play_again)
	final_popup.popup_centered()	

func on_play_again():
	current_level = 1
	load_level(current_level)

func next_level():
	current_level += 1
	if current_level <= level_scenes.size():
		load_level(current_level)
