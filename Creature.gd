extends KinematicBody2D

signal fade_in_completed

var speed = 80
var attack_range = 100
var target = null
var target_update_interval = 1.0  # Time in seconds to update target
var time_since_last_target_update = 0
var is_fully_visible = false
var projectile_scene = preload("res://Projectile.tscn")
var shooting_cooldown = 0.5  # Cooldown in seconds between shots
var time_since_last_shot = 0.0  # Time tracker for cooldown


func _ready():
	fade_in()
	if !$DespawnTimer.is_connected("timeout", self, "_on_DespawnTimer_timeout"):
		$DespawnTimer.connect("timeout", self, "_on_DespawnTimer_timeout")
	$DespawnTimer.start()

func fade_in():
	var tween = Tween.new()
	add_child(tween)
	tween.interpolate_property(self, "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1), 0.8, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.connect("tween_completed", self, "_on_tween_completed")
	tween.start()

func _on_tween_completed(object, key):
	emit_signal("fade_in_completed")  # Notify that fade-in is complete
	is_fully_visible = true
	find_nearest_enemy()  # Start finding enemies after fully visible
	
func find_nearest_enemy():
	var enemies = get_tree().get_nodes_in_group("enemies")
	var min_distance = INF
	for enemy in enemies:
		var distance = position.distance_to(enemy.position)
		if distance < min_distance:
			min_distance = distance
			target = enemy

func _physics_process(delta):
	if not is_fully_visible:
		return  # Do nothing if not fully visible
	time_since_last_shot += delta
	time_since_last_target_update += delta
	if time_since_last_target_update >= target_update_interval or target == null or not is_instance_valid(target):
		find_nearest_enemy()  # Update target every interval or if target is lost
		time_since_last_target_update = 0  # Reset the timer

	move_and_attack()

func shoot(direction):
	var projectile = projectile_scene.instance()
	projectile.position = position
	projectile.direction = direction.normalized()
	get_parent().add_child(projectile)  # Add the projectile to the game world

	
func move_and_attack():
	if target and is_instance_valid(target):
		var direction = (target.position - position).normalized()
		var distance = position.distance_to(target.position)
		move_and_slide(direction * speed)
		if distance <= attack_range and time_since_last_shot >= shooting_cooldown:
			shoot(direction)
			time_since_last_shot = 0
		else:
			find_nearest_enemy()

func _on_DespawnTimer_timeout():
	queue_free()  # Despawn the creature after timer runs out
