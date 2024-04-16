extends KinematicBody2D

signal enemy_died

var speed = 90
var player = null

func _ready():
	add_to_group("enemies")
	player = get_node_or_null("/root/GameArena/Player")
	if $AnimatedSprite.material:
		$AnimatedSprite.material = $AnimatedSprite.material.duplicate()
		
func _physics_process(delta):
	if player:
		var direction = (player.position - position).normalized()
		move_and_slide(direction * speed)

func hit():
	# Start emitting particles
	var particles = $AnimatedSprite/HitParticles
	particles.emitting = true

	# Start the flash
	var material = $AnimatedSprite.material as ShaderMaterial
	material.set_shader_param("flash_white", true)

	# Wait for the longer of the two effects to complete
	var flash_duration = 0.2
	var wait_time = max(flash_duration, particles.lifetime)
	yield(get_tree().create_timer(wait_time), "timeout")

	# Stop both effects
	particles.emitting = false
	material.set_shader_param("flash_white", false)

	emit_signal("enemy_died")
	queue_free()
