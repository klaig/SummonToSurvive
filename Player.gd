extends KinematicBody2D

var speed = 100
var creature_scene = preload("res://Creature.tscn")
var portal_scene = preload("res://Portal.tscn")
onready var health_bar = get_node("/root/GameArena/UILayer/PlayerUI/HealthBar")
var current_portal = null
var max_health = 6
var current_health = max_health
var max_mana = 3
var current_mana = max_mana
onready var mana_bar = get_node("/root/GameArena/UILayer/PlayerUI/ManaBar")
var mana_regeneration_timer = Timer.new()
var enemy_cooldowns = {}
var summon_timer = Timer.new()
var invincible = true 
var invincibility_duration = 5.0

func _ready():
	$AnimatedSprite.play("idle")
	var invincibility_timer = Timer.new()
	invincibility_timer.wait_time = invincibility_duration
	invincibility_timer.one_shot = true
	invincibility_timer.connect("timeout", self, "_on_Invincibility_timeout")
	add_child(invincibility_timer)
	invincibility_timer.start()
	mana_regeneration_timer.set_wait_time(10)
	mana_regeneration_timer.set_one_shot(false)  # The timer will keep running
	mana_regeneration_timer.connect("timeout", self, "_on_Mana_regeneration_timeout")
	add_child(mana_regeneration_timer)
	mana_regeneration_timer.start()  # Start the mana regeneration timer
	summon_timer.set_wait_time(1.0)
	summon_timer.set_one_shot(true)  # The timer stops after reaching 0
	add_child(summon_timer)

func _on_Invincibility_timeout():
	invincible = false
	
func take_damage(amount):
	if invincible:
		return
	current_health -= amount
	current_health = max(current_health, 0)  # Prevent health from going below 0
	health_bar.update_health(current_health)  # Update the visual health bar
	if current_health == 0:
		die()

func _on_Mana_regeneration_timeout():
	if current_mana < max_mana:
		current_mana += 1  # Increment mana by 1
		mana_bar.update_mana(current_mana)  # Update the visual mana bar
		
func die():
	print("Player died")
	var death_screen = preload("res://DeathScreen.tscn").instance()
	get_tree().root.add_child(death_screen)
	death_screen.show_death_screen()
	
func _physics_process(delta):
	var motion = get_input_vector() * speed
	move_and_slide(motion)
	
	# Check for collisions with enemies after moving
	for i in range(get_slide_count()):
		var collision = get_slide_collision(i)
		if collision.collider.is_in_group("enemies"):
			# Check if the enemy is in the cooldown dictionary and if its timer has expired
			if enemy_cooldowns.has(collision.collider) and enemy_cooldowns[collision.collider] > 0:
				enemy_cooldowns[collision.collider] -= delta  # Decrease the timer
				continue  # Skip taking damage if the timer is not expired

			# Apply damage and reset/set cooldown timer to 1 second
			take_damage(1)
			enemy_cooldowns[collision.collider] = 1.0
	# Decrease timers for all enemies in the dictionary
	for enemy in enemy_cooldowns.keys():
		enemy_cooldowns[enemy] -= delta
		if enemy_cooldowns[enemy] <= 0:
			enemy_cooldowns.erase(enemy)  # Remove enemy from dictionary when timer expires
				
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
	if summon_timer.is_stopped() and current_mana > 0:  # Check if the cooldown has finished
		current_portal = portal_scene.instance()
		get_tree().get_root().add_child(current_portal)
		current_portal.global_position = global_position + Vector2(50, 0)  # Offset the portal spawn position
		current_portal.connect("portal_fully_opened", self, "_on_Portal_fully_opened")
		summon_timer.start()  # Start the cooldown timer
		current_mana -= 1
		mana_bar.update_mana(current_mana)
	elif current_mana == 0:
		print("Not enough mana")
	else:
		print("Summoning on cooldown")

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
