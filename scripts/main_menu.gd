extends Control

# Scene to load when Play is pressed
const GAME_SCENE = preload("res://scenes/game.tscn")

# Add a ColorRect for fading
var canvas_layer: CanvasLayer
var fade_overlay: ColorRect

@onready var play_button = $Panel/MarginContainer/VBoxContainer/PlayButton
@onready var exit_button = $Panel/MarginContainer/VBoxContainer/ExitButton

func _ready():
	# Connect button signals
	play_button.pressed.connect(_on_play_pressed)
	exit_button.pressed.connect(_on_exit_pressed)
	
	# Setup canvas layer
	canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 100 # Ensure it's above everything
	add_child(canvas_layer)
	
	# Setup fade overlay
	fade_overlay = ColorRect.new()
	fade_overlay.color = Color.BLACK
	fade_overlay.custom_minimum_size = Vector2(1920, 1080) # Make it big enough
	fade_overlay.size_flags_horizontal = Control.SIZE_FILL
	fade_overlay.size_flags_vertical = Control.SIZE_FILL
	fade_overlay.anchors_preset = Control.PRESET_FULL_RECT
	fade_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas_layer.add_child(fade_overlay)
	
	# Fade in when the menu starts
	var tween = create_tween()
	tween.tween_property(fade_overlay, "modulate:a", 0.0, 1.0).from(1.0)
	
	# Give initial focus to Play button
	play_button.grab_focus()

func _on_play_pressed():
	# Disable buttons during transition
	play_button.disabled = true
	exit_button.disabled = true
	
	# Fade out and change scene
	var tween = create_tween()
	tween.tween_property(fade_overlay, "modulate:a", 1.0, 1.0)
	tween.tween_callback(func(): get_tree().change_scene_to_packed(GAME_SCENE))

func _on_exit_pressed():
	# Fade out and quit
	var tween = create_tween()
	tween.tween_property(fade_overlay, "modulate:a", 1.0, 1.0)
	tween.tween_callback(func(): get_tree().quit())
