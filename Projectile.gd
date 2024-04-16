extends Area2D

var speed = 400  # Adjust speed as needed
var direction = Vector2.ZERO

func _ready():
	$CollisionShape2D.set_deferred("disabled", false)  # Enable collision

func _process(delta):
	position += direction * speed * delta  # Move the projectile

func _on_Projectile_body_entered(body):
	if body.is_in_group("enemies"):
		body.hit()  # Call the hit function on the enemy
		queue_free()  # Destroy the projectile
