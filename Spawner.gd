extends Node

var enemy_scene = preload("res://Enemy.tscn")
var timer = Timer.new()

# Edge coordinates for spawning
var left_edge = -370
var right_edge = 450
var top_edge = -415
var bottom_edge = 400

func _ready():
	timer.wait_time = 2.0  # Spawn an enemy every 2 seconds
	timer.autostart = true
	timer.connect("timeout", self, "_on_Timer_timeout")
	add_child(timer)

func _on_Timer_timeout():
	var enemy = enemy_scene.instance()
	get_parent().add_child(enemy)  # Add to the game arena, not the spawner
	enemy.position = choose_spawn_position()  # Use the function to choose spawn position

func choose_spawn_position():
	var side = randi() % 4  # Randomly choose a side
	var position = Vector2()

	match side:
		0:  # Top edge
			position.x = rand_range(left_edge, right_edge)
			position.y = top_edge
		1:  # Right edge
			position.x = right_edge
			position.y = rand_range(top_edge, bottom_edge)
		2:  # Bottom edge
			position.x = rand_range(left_edge, right_edge)
			position.y = bottom_edge
		3:  # Left edge
			position.x = left_edge
			position.y = rand_range(top_edge, bottom_edge)
	return position
