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
	print("Spawner ready: ", get_path())  # Print full path on ready
	# Initialize the dictionary with bubble scenes
	bubble_scenes = {
		1: bubble_1,
		2: bubble_2,
		3: bubble_3,
		4: bubble_4,
		5: bubble_5,
		6: bubble_6
	}
	
	# Debug print available bubble scenes
	print("Spawner initialized with scenes at path: ", get_path())
	for size in bubble_scenes:
		print("Size ", size, ": ", "Available" if bubble_scenes[size] else "Missing")

func spawn_bubble(size: int) -> void:
	print("Spawning bubble of size: ", size)
	if size < 1 or size > 6:
		push_warning("Invalid bubble size: %d. Size must be between 1 and 6." % size)
		return
		
	var bubble_scene = bubble_scenes[size]
	if not bubble_scene:
		push_warning("No bubble scene assigned for size: %d" % size)
		return
		
	print("Instantiating bubble scene for size: ", size)
	var bubble = bubble_scene.instantiate()
	add_child(bubble)
	bubble.global_position = global_position
	print("Bubble spawned at position: ", global_position)

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		if is_instance_valid(self):
			print("Spawner being deleted: ", get_path())
		else:
			print("Spawner being deleted")
