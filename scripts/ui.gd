extends Panel

@onready var level_label: Label = $LevelLabelContainer/LevelLabel
@onready var level_manager = $"/root/Game/LevelManager"

func _ready() -> void:
	level_manager.level_changed.connect(_on_level_changed)
	# Update initial level text
	_update_level_text(level_manager.current_level_index)

func _on_level_changed(_level_node: Node) -> void:
	_update_level_text(level_manager.current_level_index)

func _update_level_text(level_index: int) -> void:
	level_label.text = "Level %d" % (level_index + 1)