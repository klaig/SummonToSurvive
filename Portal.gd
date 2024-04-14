extends Node2D

signal portal_fully_opened

func _ready():
	modulate = Color(1, 1, 1, 0)  # Start fully transparent
	$AnimatedSprite.play("open")
	start_fade_in()

func start_fade_in():
	var tween = $FadeTween
	tween.interpolate_property(self, "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1), 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.connect("tween_completed", self, "_on_fade_in_completed")
	tween.start()

func _on_fade_in_completed(object, key):
	emit_signal("portal_fully_opened")

func start_fade_out():
	var tween = $FadeTween
	tween.interpolate_property(self, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	if not tween.is_connected("tween_completed", self, "_on_fade_out_completed"):
		tween.connect("tween_completed", self, "_on_fade_out_completed", [], CONNECT_ONESHOT)
	tween.start()
	
func _on_fade_out_completed(object, key):
	$FadeTween.disconnect("tween_completed", self, "_on_fade_out_completed")
	queue_free() 
