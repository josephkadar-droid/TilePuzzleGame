extends Area2D

var is_dragging = false

func _ready():
	print("=== MANUAL TEST ITEM READY ===")
	
	# Create a simple colored texture for the sprite
	var sprite = $Sprite2D
	var image = Image.create(60, 60, false, Image.FORMAT_RGB8)
	image.fill(Color.GREEN)
	var texture = ImageTexture.new()
	texture.set_image(image)
	sprite.texture = texture
	
	# Enable input
	input_pickable = true
	
	# Connect signals
	input_event.connect(_on_input_event)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
	print("Manual test item at position: ", position)

func _on_mouse_entered():
	print("MOUSE ENTERED MANUAL TEST ITEM")

func _on_mouse_exited():
	print("MOUSE EXITED MANUAL TEST ITEM")

func _on_input_event(viewport, event, shape_idx):
	print("INPUT EVENT ON MANUAL TEST ITEM: ", event)
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			print("STARTING MANUAL DRAG")
			is_dragging = true
		else:
			print("ENDING MANUAL DRAG")
			is_dragging = false

func _process(_delta):
	if is_dragging:
		global_position = get_global_mouse_position()
