extends Node 


@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var detection_collision_shape = $Vision/CollisionShape2D

@export_group("Enemy Properties")
@export var detection_radius: float = 16.0

var bubble_count = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if detection_collision_shape.shape is CircleShape2D:
		detection_collision_shape.shape.radius = detection_radius
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_vision_body_entered(body: Node2D) -> void:
	if (body.is_in_group("bubble")):
		bubble_count += 1
		_update_animation()


func _on_vision_body_exited(body: Node2D) -> void:
	if (body.is_in_group("bubble")):
		bubble_count -= 1
		_update_animation()


func _update_animation():
	if (bubble_count > 0):
		animated_sprite_2d.animation = "attack"
	else:
		animated_sprite_2d.animation = "idle"
