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

# BREAK METHOD - called when TV should be destroyed
func fuck_item():
	if is_broken:
		return  # Already broken, don't break again
	
	print("=== TV BREAKING ===")
	is_broken = true
	
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
