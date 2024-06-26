extends Control

var empty_texture = preload("res://assets/empty_bar.png")
var full_texture = preload("res://assets/health_bar.png")

func _ready():
	setup_health_units()

func setup_health_units():
	var offsets = [0]
	var widths = [17, 16, 16, 16, 16, 17]
	var height = 16 

	# Calculate offsets based on widths
	for i in range(1, 6): 
		offsets.append(offsets[i - 1] + widths[i - 1])

	# Setup each sprite region
	for i in range(6):
		var sprite = get_node("HealthUnit" + str(i + 1))
		sprite.texture = full_texture  # Set initial texture
		sprite.region_enabled = true
		sprite.region_rect = Rect2(offsets[i], 0, widths[i], height)

func update_health(current_health):
	for i in range(6):
		var sprite = get_node("HealthUnit" + str(i + 1))
		if i < current_health:
			sprite.texture = full_texture
		else:
			sprite.texture = empty_texture
