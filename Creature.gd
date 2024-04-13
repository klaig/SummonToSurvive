extends KinematicBody2D

var speed = 80
var attack_range = 40
var target = null
var target_update_interval = 1.0  # Time in seconds to update target
var time_since_last_target_update = 0

func _ready():
	find_nearest_enemy()
	$DespawnTimer.connect("timeout", self, "_on_DespawnTimer_timeout")
	$DespawnTimer.start()

func find_nearest_enemy():
	var enemies = get_tree().get_nodes_in_group("enemies")
	var min_distance = INF
	for enemy in enemies:
		var distance = position.distance_to(enemy.position)
		if distance < min_distance:
			min_distance = distance
			target = enemy

func _physics_process(delta):
	time_since_last_target_update += delta

	if time_since_last_target_update >= target_update_interval or target == null or not is_instance_valid(target):
		find_nearest_enemy()  # Update target every interval or if target is lost
		time_since_last_target_update = 0  # Reset the timer

	if target and is_instance_valid(target):
		var direction = (target.position - position).normalized()
		var distance = position.distance_to(target.position)
		move_and_slide(direction * speed)
		if distance <= attack_range:
			attack_enemy(target)

func attack_enemy(enemy):
	if is_instance_valid(enemy):
		enemy.queue_free()  # Deletes the enemy
		find_nearest_enemy()  # Find a new target after attack

func _on_DespawnTimer_timeout():
	queue_free()  # Despawn the creature after timer runs out
