extends Node

@export_group('Bubble Properties')
@export var hp: int
@export var speed: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("bubble")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
