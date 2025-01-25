extends Node

signal score_changed(new_score: int)
signal high_score_changed(new_high_score: int)

var current_score: int = 0
var high_score: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_high_score()

# Add points to the current score
func add_score(points: int) -> void:
	current_score += points
	score_changed.emit(current_score)
	
	if current_score > high_score:
		high_score = current_score
		high_score_changed.emit(high_score)
		save_high_score()

# Reset the current score (useful for game over or level restart)
func reset_score() -> void:
	current_score = 0
	score_changed.emit(current_score)

# Get the current score
func get_score() -> int:
	return current_score

# Get the high score
func get_high_score() -> int:
	return high_score

# Save high score to disk
func save_high_score() -> void:
	var save_file = FileAccess.open("user://highscore.save", FileAccess.WRITE)
	save_file.store_32(high_score)

# Load high score from disk
func load_high_score() -> void:
	if FileAccess.file_exists("user://highscore.save"):
		var save_file = FileAccess.open("user://highscore.save", FileAccess.READ)
		high_score = save_file.get_32()
		high_score_changed.emit(high_score)
