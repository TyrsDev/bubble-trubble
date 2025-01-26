extends Control

# Scene to load when Play is pressed
const GAME_SCENE = preload("res://scenes/game.tscn")

# Add a ColorRect for fading
@onready var fade_overlay = ColorRect.new()

func _ready():
	# Connect button signals
	$Panel/MarginContainer/VBoxContainer/PlayButton.pressed.connect(_on_play_pressed)
	$Panel/MarginContainer/VBoxContainer/ExitButton.pressed.connect(_on_exit_pressed)
	
	# Setup fade overlay
	fade_overlay.color = Color.BLACK
	fade_overlay.modulate.a = 0
	fade_overlay.anchors_preset = Control.PRESET_FULL_RECT
	add_child(fade_overlay)
	
	# Give initial focus to Play button for keyboard/gamepad navigation
	$Panel/MarginContainer/VBoxContainer/PlayButton.grab_focus()

func _on_play_pressed():
	# Fade out and change scene
	var tween = create_tween()
	tween.tween_property(fade_overlay, "modulate:a", 1.0, 0.5)
	tween.tween_callback(func(): get_tree().change_scene_to_packed(GAME_SCENE))

func _on_exit_pressed():
	# Quit the game
	get_tree().quit()