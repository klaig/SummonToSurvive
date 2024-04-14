extends KinematicBody2D

var speed = 100
var creature_scene = preload("res://Creature.tscn")
var portal_scene = preload("res://Portal.tscn")
var current_portal = null
var max_health = 50
var current_health = max_health

func _ready():
	$AnimatedSprite.play("idle")

func _physics_process(delta):
	var motion = get_input_vector() * speed
	move_and_slide(motion)

	if motion == Vector2.ZERO and $AnimatedSprite.animation != "idle":
		$AnimatedSprite.play("idle")
	if Input.is_action_just_pressed('ui_summon'):
		summon_portal()

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

func summon_portal():
	current_portal = portal_scene.instance()
	get_tree().get_root().add_child(current_portal)
	current_portal.global_position = global_position + Vector2(50, 0)  # Offset the portal spawn position
	current_portal.connect("portal_fully_opened", self, "_on_Portal_fully_opened")

func _on_Portal_fully_opened():
	current_portal.disconnect("portal_fully_opened", self, "_on_Portal_fully_opened")
	summon_creature(current_portal.global_position, current_portal)
	
func summon_creature(portal_position, portal):
	var creature = creature_scene.instance()
	get_tree().get_root().add_child(creature)
	creature.global_position = portal_position + Vector2(0, -10)
	creature.modulate = Color(1, 1, 1, 0)  # Start fully transparent
	creature.call_deferred("fade_in")
	creature.connect("fade_in_completed", self, "_on_Creature_fully_visible", [portal])
	
func _on_Creature_fully_visible(portal):
	if is_instance_valid(portal):
		portal.start_fade_out()
