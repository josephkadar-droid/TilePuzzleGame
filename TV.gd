# TV.gd - Television object that can be broken by falling objects
extends FuckableItem
class_name TV

# SPRITE REFERENCES - handles both intact and broken TV visuals
var tv_sprite: Sprite2D
var is_broken: bool = false

var width: int = 120
var height: int = 80

# INITIALIZATION - creates the TV sprite when scene loads
func _ready():
	print("=== TV _ready() called ===")
	create_tv_sprite()
	create_collision_shape()

# SPRITE CREATION - generates pixel art TV sprite
func create_tv_sprite():
	tv_sprite = Sprite2D.new()
	tv_sprite.texture = create_intact_tv_texture()
	add_child(tv_sprite)
	print("TV sprite created")
	
func create_collision_shape():
	var rectShape = RectangleShape2D.new()
	rectShape.size = Vector2(width, height)
	var colShape = CollisionShape2D.new()
	colShape.shape = rectShape
	
	add_child(colShape)

# INTACT TV TEXTURE - creates normal TV appearance
func create_intact_tv_texture() -> ImageTexture:
	var image = Image.create(width, height, false, Image.FORMAT_RGB8)
	image.fill(Color.TRANSPARENT)
	
	# TV Body (dark gray/black)
	var tv_body_color = Color(0.2, 0.2, 0.2)
	for y in range(5, 75):
		for x in range(5, 115):
			image.set_pixel(x, y, tv_body_color)
	
	# TV Screen (blue/black when off)
	var screen_color = Color(0.1, 0.1, 0.3)
	for y in range(10, 55):
		for x in range(15, 105):
			image.set_pixel(x, y, screen_color)
	
	# TV Stand/Legs (darker gray)
	var stand_color = Color(0.15, 0.15, 0.15)
	for y in range(75, 80):
		for x in range(25, 35):  # Left leg
			image.set_pixel(x, y, stand_color)
		for x in range(85, 95):  # Right leg
			image.set_pixel(x, y, stand_color)
	
	# Control panel (lighter gray)
	var control_color = Color(0.4, 0.4, 0.4)
	for y in range(60, 70):
		for x in range(110, 115):
			image.set_pixel(x, y, control_color)
	
	# Screen reflection (light blue)
	var reflection_color = Color(0.3, 0.3, 0.5)
	for y in range(15, 25):
		for x in range(20, 40):
			image.set_pixel(x, y, reflection_color)
	
	var texture = ImageTexture.new()
	texture.set_image(image)
	return texture

# BROKEN TV TEXTURE - creates damaged TV appearance
func create_broken_tv_texture() -> ImageTexture:
	var image = Image.create(width, height, false, Image.FORMAT_RGB8)
	image.fill(Color.TRANSPARENT)
	
	# Damaged TV Body (same as intact but with cracks)
	var tv_body_color = Color(0.2, 0.2, 0.2)
	for y in range(5, 75):
		for x in range(5, 115):
			image.set_pixel(x, y, tv_body_color)
	
	# Cracked/broken screen (darker with crack lines)
	var broken_screen_color = Color(0.05, 0.05, 0.1)
	for y in range(10, 55):
		for x in range(15, 105):
			image.set_pixel(x, y, broken_screen_color)
	
	# Crack lines on screen (white/gray lines)
	var crack_color = Color(0.7, 0.7, 0.7)
	# Diagonal crack from top-left to bottom-right
	for i in range(45):
		var x = 15 + i * 2
		var y = 10 + i
		if x < 105 and y < 55:
			image.set_pixel(x, y, crack_color)
			image.set_pixel(x + 1, y, crack_color)
	
	# Horizontal crack
	for x in range(30, 80):
		image.set_pixel(x, 35, crack_color)
		image.set_pixel(x, 36, crack_color)
	
	# Broken stand (one leg missing)
	var stand_color = Color(0.15, 0.15, 0.15)
	for y in range(75, 80):
		for x in range(25, 35):  # Left leg intact
			image.set_pixel(x, y, stand_color)
		# Right leg partially broken/missing
		for x in range(85, 90):  # Shorter right leg
			image.set_pixel(x, y, stand_color)
	
	# Damage particles/debris
	var debris_color = Color(0.3, 0.3, 0.3)
	# Small debris pieces around the TV
	image.set_pixel(10, 72, debris_color)
	image.set_pixel(12, 73, debris_color)
	image.set_pixel(108, 71, debris_color)
	image.set_pixel(110, 74, debris_color)
	
	var texture = ImageTexture.new()
	texture.set_image(image)
	return texture

# BREAK METHOD - called when TV should be destroyed
func fuck_item():
	if is_broken:
		return  # Already broken, don't break again
	
	print("=== TV BREAKING ===")
	is_broken = true
	
	# Change sprite to broken version
	tv_sprite.texture = create_broken_tv_texture()
	
	# Add screen shake effect
	var shake_tween = create_tween()
	var original_pos = position
	shake_tween.tween_method(shake_item, 0.0, 1.0, 0.5)
	shake_tween.tween_callback(func(): position = original_pos)

# SHAKE EFFECT - creates impact animation
func shake_item(progress: float):
	var shake_intensity = 5.0 * (1.0 - progress)  # Decreases over time
	var offset = Vector2(
		randf_range(-shake_intensity, shake_intensity),
		randf_range(-shake_intensity, shake_intensity)
	)
	position = position + offset
