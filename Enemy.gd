extends KinematicBody2D

var speed = 90
var player = null

func _ready():
	player = get_node_or_null("/root/GameArena/Player")

func _physics_process(delta):
	if player:
		var direction = (player.position - position).normalized()
		move_and_slide(direction * speed)
