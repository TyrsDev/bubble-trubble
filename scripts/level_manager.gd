extends Node

@onready var game_manager: Node = %GameManager
@export var levels: Array[PackedScene] = []
var current_level_index: int = 0

signal level_changed(level_node: Node)

func _ready() -> void:
	# Clear any editor-placed level before loading the first runtime level
	for child in get_children():
		if child.is_in_group("level"):
			child.queue_free()
	
	load_current_level()

func _process(_delta) -> void:
	if Input.is_action_just_pressed("ui_text_backspace"):
		restart_current_level()
	elif Input.is_action_just_pressed("ui_cancel"):  # Esc key
		reset_to_first_level()
	elif Input.is_action_just_pressed("ui_right"):  # Right arrow
		complete_level(100)  # Debug value of 100 points for testing
	elif Input.is_action_just_pressed("ui_left"):  # Left arrow
		if current_level_index > 0:
			current_level_index -= 1
			load_current_level()

func load_current_level() -> void:
	if current_level_index >= levels.size():
		print("No more levels! Game complete!")
		return
		
	# First clear old levels
	for child in get_children():
		if child.is_in_group("level"):
			child.queue_free()
	
	# Create and add new level
	var level_instance = levels[current_level_index].instantiate()
	level_instance.add_to_group("level")
	add_child(level_instance)
	
	# Finally emit the signal after the level is in the tree
	level_changed.emit(level_instance)

func complete_level(score: int) -> void:
	game_manager.add_score(score)
	
	current_level_index += 1
	if current_level_index < levels.size():
		load_current_level()
	else:
		print("Congratulations! All levels complete!")

func restart_current_level() -> void:
	load_current_level()

func reset_to_first_level() -> void:
	current_level_index = 0
	game_manager.reset_score()
	load_current_level()
