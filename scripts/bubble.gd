extends CharacterBody2D

@export_group('Bubble Properties')
@export var hp: int
@export var speed: int

@onready var sprite = $Sprite2D
@onready var animation = $AnimatedSprite2D

var path: Path2D
var progress: float = 0.0

var is_dead: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("bubble")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if path:
		# Move along the path
		progress += speed * delta
		# Get position along the path
		var new_pos = path.curve.sample_baked(progress)
		# Update bubble position
		global_position = new_pos

func set_path(new_path: Path2D) -> void:
	path = new_path
	progress = 0.0 # Start at beginning of path

func apply_damage(amount: int):
	if is_dead:
		return
	
	hp -= amount		
	
	if hp <= 0:
		pop()

func pop():
	is_dead = true
	queue_free()
