extends Node2D

@export_group("Bubble Prefabs")
@export var bubble_1: PackedScene
@export var bubble_2: PackedScene
@export var bubble_3: PackedScene
@export var bubble_4: PackedScene
@export var bubble_5: PackedScene
@export var bubble_6: PackedScene

# Dictionary to store bubble scenes by size
var bubble_scenes: Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Initialize the dictionary with bubble scenes
	bubble_scenes = {
		1: bubble_1,
		2: bubble_2,
		3: bubble_3,
		4: bubble_4,
		5: bubble_5,
		6: bubble_6
	}

func spawn_bubble(size: int) -> void:
	if size < 1 or size > 6:
		push_warning("Invalid bubble size: %d. Size must be between 1 and 6." % size)
		return
		
	var bubble_scene = bubble_scenes[size]
	if not bubble_scene:
		push_warning("No bubble scene assigned for size: %d" % size)
		return
		
	var bubble = bubble_scene.instantiate()
	add_child(bubble)
	bubble.global_position = global_position
