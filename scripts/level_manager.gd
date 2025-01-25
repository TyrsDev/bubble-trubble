extends Node

@onready var game_manager: Node = %GameManager
@export var levels: Array[PackedScene] = []
var current_level_index: int = 0

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
	elif Input.is_action_just_pressed("ui_accept"):  # Enter key
		complete_level(100)  # Debug value of 100 points for testing

func load_current_level() -> void:
	if current_level_index >= levels.size():
		print("No more levels! Game complete!")
		return
		
	for child in get_children():
		if child.is_in_group("level"):
			child.queue_free()
	
	var level_instance = levels[current_level_index].instantiate()
	level_instance.add_to_group("level")
	add_child(level_instance)

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
