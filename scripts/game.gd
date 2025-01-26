extends Node2D

func _ready():
	# Create a CanvasLayer for the fade overlay (always on top)
	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 100 # Ensure it's above everything
	add_child(canvas_layer)
	
	# Create fade overlay
	var fade_overlay = ColorRect.new()
	fade_overlay.color = Color.BLACK
	fade_overlay.custom_minimum_size = Vector2(1920, 1080)
	fade_overlay.size_flags_horizontal = Control.SIZE_FILL
	fade_overlay.size_flags_vertical = Control.SIZE_FILL
	fade_overlay.anchors_preset = Control.PRESET_FULL_RECT
	fade_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Add it to the CanvasLayer
	canvas_layer.add_child(fade_overlay)
	
	# Start fully black and fade in
	fade_overlay.modulate.a = 1.0
	
	# Fade in
	var tween = create_tween()
	tween.tween_property(fade_overlay, "modulate:a", 0.0, 1.0)
	# Remove both the overlay and canvas layer when done
	tween.tween_callback(func():
		canvas_layer.queue_free()
	)
