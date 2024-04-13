extends KinematicBody2D

var speed = 100
var creature_scene = preload("res://Creature.tscn")  # Make sure this path matches your creature scene

func _ready():
	$AnimatedSprite.play("idle")

func _physics_process(delta):
	var motion = Vector2.ZERO
	handle_input(delta)  # Handle movement and summoning

func handle_input(delta):
	var motion = get_input_vector() * speed
	move_and_slide(motion)

	if motion == Vector2.ZERO:
		$AnimatedSprite.play("idle")
		
	if Input.is_action_just_pressed('ui_summon'):
		summon_creature()

func get_input_vector():
	var vec = Vector2.ZERO
	if Input.is_action_pressed('ui_right'):
		$AnimatedSprite.play("walk_right")
		vec.x += 1
	if Input.is_action_pressed('ui_left'):
		$AnimatedSprite.play("walk_left")
		vec.x -= 1
	if Input.is_action_pressed('ui_down'):
		$AnimatedSprite.play("walk_down")
		vec.y += 1
	if Input.is_action_pressed('ui_up'):
		$AnimatedSprite.play("walk_up")
		vec.y -= 1
	return vec.normalized()

func summon_creature():
	var creature = creature_scene.instance()
	get_tree().get_root().add_child(creature)  # Adding directly to the root for global positioning
	creature.global_position = global_position + Vector2(50, 0)  # Maintain global offset
	print("Spawned Creature at: ", creature.global_position)

