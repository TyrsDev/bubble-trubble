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
	else:
		animation.play("damage")

func pop():
	is_dead = true
	animation.play("burst")


func _on_bubble_1_animation_finished() -> void:
	print("Burst bubble 1")
	queue_free()

func _on_bubble_2_animation_finished() -> void:
	if (animation.animation == "burst"):
		print("Burst bubble 2")
		queue_free()
	
func _on_bubble_3_animation_finished() -> void:
	if (animation.animation == "burst"):
		print("Burst bubble 3")
		queue_free()

func _on_bubble_4_animation_finished() -> void:
	if (animation.animation == "burst"):
		print("Burst bubble 4")
		queue_free()

func _on_bubble_5_animation_finished() -> void:
	if (animation.animation == "burst"):
		print("Burst bubble 5")
		queue_free()

func _on_bubble_6_animation_finished() -> void:
	if (animation.animation == "burst"):
		print("Burst bubble 6")
		queue_free()
