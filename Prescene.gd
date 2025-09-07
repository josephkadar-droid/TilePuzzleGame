extends Sprite2D

class_name Prescene

func _ready():
	await get_tree().create_timer(3).timeout
	
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 1.5)
