extends Panel

@onready var level_label: Label = $LevelLabelContainer/LevelLabel
@onready var score_label: Label = $ScoreLabelContainer/ScoreLabel
@onready var level_manager = $"/root/Game/LevelManager"
@onready var game_manager = $"/root/Game/%GameManager"

func _ready() -> void:
	level_manager.level_changed.connect(_on_level_changed)
	# Update initial level text
	_update_level_text(level_manager.current_level_index)
	
	# Connect score signal
	game_manager.score_changed.connect(_on_score_changed)
	
	# Initialize score display
	_on_score_changed(game_manager.get_score())

func _on_level_changed(_level_node: Node) -> void:
	_update_level_text(level_manager.current_level_index)

func _update_level_text(level_index: int) -> void:
	level_label.text = "Level %d" % (level_index + 1)

func _on_score_changed(new_score: int) -> void:
	score_label.text = "Score: %d" % new_score
