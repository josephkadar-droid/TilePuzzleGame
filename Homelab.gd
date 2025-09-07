extends FuckableItem

class_name Homelab

var main_sprite: Sprite2D
var broken_sprite: Sprite2D
var is_broken: bool = false

func _ready():
	print("=== Homelab _ready() called ===")
	main_sprite = get_child(0)
	broken_sprite = get_child(1)

func fuck_item():
	if is_broken:
		return
	
	broken_sprite.visible = true
	main_sprite.visible = false
	
	# Add screen shake effect
	var shake_tween = create_tween()
	var original_pos = position
	shake_tween.tween_method(shake_item, 0.0, 1.0, 0.5)

func shake_item(progress: float):
	var shake_intensity = 5.0 * (1.0 - progress)  # Decreases over time
	var offset = Vector2(
		randf_range(-shake_intensity, shake_intensity),
		randf_range(-shake_intensity, shake_intensity)
	)
	position = position + offset
