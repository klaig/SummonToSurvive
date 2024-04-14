extends Control

var full_texture = preload("res://assets/magic_bar.png")
var empty_texture = preload("res://assets/empty_bar.png")

func _ready():
	setup_mana_units()

func setup_mana_units():
	var offsets = [0, 33, 66]  # X offsets for each mana unit
	var width = 32
	var height = 16
	var y_offset = 20

	# Setup each mana sprite region
	for i in range(3):
		var sprite = get_node("ManaUnit" + str(i + 1))
		sprite.texture = full_texture  # Start with full texture
		sprite.region_enabled = true
		sprite.region_rect = Rect2(offsets[i], y_offset, width, height)

func update_mana(current_mana):
	for i in range(3): 
		var sprite = get_node("ManaUnit" + str(i + 1))
		if i < current_mana:
			sprite.texture = full_texture  # Mana available
		else:
			sprite.texture = empty_texture  # Mana used
