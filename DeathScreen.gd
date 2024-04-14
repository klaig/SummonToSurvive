extends Control

func _ready():
	visible = false 
	var try_again_button = get_node("CanvasLayer/ButtonTryAgain")
	try_again_button.connect("pressed", self, "on_Try_again_pressed")

	var exit_button = get_node("CanvasLayer/ButtonExitToMenu")
	exit_button.connect("pressed", self, "on_Exit_to_menu_pressed")
	self.pause_mode = Node.PAUSE_MODE_PROCESS

func show_death_screen():
	print("Showing death screen")
	visible = true
	get_tree().paused = true 

func on_Try_again_pressed():
	print("Try again pressed")
	queue_free()
	get_tree().paused = false
	get_tree().reload_current_scene()
	
func on_Exit_to_menu_pressed():
	print("Exit to menu pressed")
	queue_free()
	get_tree().paused = false
	get_tree().quit()
