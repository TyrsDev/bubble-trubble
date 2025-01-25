extends Node


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	# Check if Spacebar is pressed
	if Input.is_action_just_pressed("ui_accept"): # "ui_accept" is mapped to Spacebar by default
		restart_scene()

func restart_scene():
	# Get the current scene path and reload it
	get_tree().reload_current_scene()
