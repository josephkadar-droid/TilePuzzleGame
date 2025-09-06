extends Area2D
class_name PlacementSpot

signal item_placed

@export var accepted_item_types: Array[String] = ["any"]
@export var highlight_color: Color = Color.GREEN
@export var invalid_color: Color = Color.RED

var filled_item: DraggableItem = null
var parent_object: PlaceableObject = null
var highlight_sprite: Sprite2D
var is_highlighted: bool = false

func _ready():
	# Create visual feedback
	highlight_sprite = Sprite2D.new()
	highlight_sprite.texture = create_highlight_texture()
	highlight_sprite.modulate = highlight_color
	highlight_sprite.modulate.a = 0.0
	add_child(highlight_sprite)
	
	# Set up collision
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(60, 60)
	collision.shape = shape
	add_child(collision)
	
	# Connect area signals
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

func create_highlight_texture() -> ImageTexture:
	var image = Image.create(64, 64, false, Image.FORMAT_RGBA8)
	image.fill(Color.WHITE)
	var texture = ImageTexture.new()
	texture.set_image(image)
	return texture

func _on_area_entered(area: Area2D):
	if area.get_parent() is DraggableItem:
		var item = area.get_parent() as DraggableItem
		if item.is_being_dragged and can_accept_item(item):
			show_highlight(true)
		else:
			show_highlight(false, true)

func _on_area_exited(area: Area2D):
	if area.get_parent() is DraggableItem:
		hide_highlight()

func show_highlight(valid: bool = true, invalid: bool = false):
	is_highlighted = true
	var tween = create_tween()
	if invalid:
		highlight_sprite.modulate = invalid_color
	else:
		highlight_sprite.modulate = highlight_color
	tween.tween_property(highlight_sprite, "modulate:a", 0.5, 0.2)

func hide_highlight():
	is_highlighted = false
	var tween = create_tween()
	tween.tween_property(highlight_sprite, "modulate:a", 0.0, 0.2)

func can_accept_item(item: DraggableItem) -> bool:
	if filled_item != null:
		return false
	
	if "any" in accepted_item_types:
		return true
	
	return item.item_type in accepted_item_types

func place_item(item: DraggableItem) -> bool:
	if not can_accept_item(item):
		return false
	
	filled_item = item
	item.place_at_spot(self)
	item_placed.emit()
	hide_highlight()
	return true

func is_filled() -> bool:
	return filled_item != null

func remove_item():
	if filled_item:
		filled_item = null
