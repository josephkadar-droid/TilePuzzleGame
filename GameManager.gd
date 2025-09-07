extends Control
class_name GameManager

@export var current_level: int = 1
@export var level_scenes: Array[PackedScene] = []
@export var background_music: AudioStream
@export var crash_sound: AudioStream

@onready var level_container = $LevelContainer
@onready var ui_container = $UIContainer
@onready var inventory = $UIContainer/Inventory
@onready var music_player = $MusicPlayer
@onready var effect_player = $EffectPlayer

var current_level_node: Level
var completion_popup: AcceptDialog

func _ready():
	print("=== GAMEMANAGER _ready() called ===")
	print("Level container: ", level_container)
	print("UI container: ", ui_container)
	print("Inventory: ", inventory)
	load_level(current_level)
	music_player.stream = background_music
	music_player.play()

func load_level(level_num: int):
	print("=== LOADING LEVEL ===")
	print("Level number: ", level_num)
	print("Available level scenes: ", level_scenes.size())
	
	# Clear existing level
	if current_level_node:
		current_level_node.queue_free()
	
	# Load new level
	print("scenes: ",level_scenes)
	if level_num <= level_scenes.size() and level_scenes[level_num - 1]:
		print("Loading level scene: ", level_scenes[level_num - 1])
		current_level_node = level_scenes[level_num - 1].instantiate()
		level_container.add_child(current_level_node)
		current_level_node.level_completed.connect(_on_level_completed)
		
		print("Level loaded. Getting required items...")
		var required_items = current_level_node.get_init_inventory_items()
		print("Required items: ", required_items)
		
	else:
		print("ERROR: Could not load level ", level_num)
		
	create_completion_popup()
	create_tomfoolery_area(current_level_node.get_fuckable_items())

func create_tomfoolery_area(fuckable_items: Array[FuckableItem]):
	var tomfools = TomfooleryArea.new()
	
	for fuckable_item in fuckable_items:
		tomfools.add_child(fuckable_item)
				
	current_level_node.add_child(tomfools)

func _on_level_completed():
	print("Level ", current_level, " completed!")
	completion_popup.popup_centered()
	effect_player.stream = crash_sound
	effect_player.volume_db = 40
	effect_player.play()
	#current_level += 1
	#if current_level <= level_scenes.size():
		#await get_tree().create_timer(1.0).timeout  # Brief pause
		#load_level(current_level)
	#else:
		#print("All levels completed!")

func create_completion_popup():
	completion_popup = AcceptDialog.new()
	completion_popup.title = "Level Complete!"
	completion_popup.dialog_text = current_level_node.completion_msg  # <-- HERE
	completion_popup.get_ok_button().text = "Next Level"
	
	# Increase dialog size
	completion_popup.size = Vector2(600, 300)  # Make the dialog bigger

	# Create a new theme
	var custom_theme = Theme.new()

	# Set default font size for all controls
	custom_theme.default_font_size = 30
	
	# Apply theme to the dialog
	completion_popup.theme = custom_theme

	# Make button bigger
	var ok_button = completion_popup.get_ok_button()
	ok_button.add_theme_font_size_override("font_size", 24)  # Larger button text
	ok_button.custom_minimum_size = Vector2(120, 60)  # Bigger button size
	ok_button.text = "Next Level"

	# Optional: Add some margin to text for better spacing
	var text_label = completion_popup.get_label()
	text_label.add_theme_constant_override("margin_left", 40) 
	text_label.add_theme_constant_override("margin_top", 40) 
	text_label.add_theme_constant_override("margin_right", 40)
	text_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	add_child(completion_popup)
	completion_popup.confirmed.connect(on_next_level_pressed)

func on_next_level_pressed():  # <-- Function definition here
	current_level += 1
	if current_level <= level_scenes.size():
		load_level(current_level)
	else:
		var endscene = get_node("EndScene")
		endscene.visible = true
		await get_tree().create_timer(5).timeout
		show_game_complete_popup()

func show_game_complete_popup():  # <-- Function definition here
	var final_popup = AcceptDialog.new()
	final_popup.title = "Game Complete!"
	final_popup.dialog_text = "Congratulations! You've completed all levels!"
	final_popup.get_ok_button().text = "Play Again"
	
	# Increase dialog size
	final_popup.size = Vector2(600, 300)  # Make the dialog bigger

	# Create a new theme
	var custom_theme = Theme.new()

	# Set default font size for all controls
	custom_theme.default_font_size = 30
	
	# Apply theme to the dialog
	final_popup.theme = custom_theme

	# Make button bigger
	var ok_button = final_popup.get_ok_button()
	ok_button.add_theme_font_size_override("font_size", 24)  # Larger button text
	ok_button.custom_minimum_size = Vector2(120, 60)  # Bigger button size

	# Optional: Add some margin to text for better spacing
	var text_label = final_popup.get_label()
	text_label.add_theme_constant_override("margin_left", 40) 
	text_label.add_theme_constant_override("margin_top", 40) 
	text_label.add_theme_constant_override("margin_right", 40)
	text_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
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
