extends Node


@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var detection_collision_shape = $Vision/CollisionShape2D
@onready var aoe_area = $Vision

@export_group("Enemy Properties")
@export var detection_radius: float = 16.0
@export var damage_amount: int = 1
@export var damage_frame: int = 5 # Frame to apply damage

var bubble_count = 0
var is_attacking = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if detection_collision_shape.shape is CircleShape2D:
		detection_collision_shape.shape.radius = detection_radius
	animated_sprite_2d.animation_finished.connect(_on_animation_finished)

func _on_vision_body_entered(body: Node2D) -> void:
	if (body.is_in_group("bubble")):
		bubble_count += 1
		if not is_attacking:
			start_attack()


func _on_vision_body_exited(body: Node2D) -> void:
	if (body.is_in_group("bubble")):
		bubble_count -= 1


func _on_animated_sprite_2d_frame_changed() -> void:
	if animated_sprite_2d.animation == "attack":
		if animated_sprite_2d.frame == damage_frame:
			apply_aoe_damage()


func _on_animation_finished():
	print("Animation finished: ", animated_sprite_2d.animation)
	if animated_sprite_2d.animation == "attack":
		is_attacking = false
		if bubble_count > 0:
			start_attack()
		else:
			animated_sprite_2d.play("idle")


func start_attack():
	is_attacking = true
	animated_sprite_2d.play("attack")


func apply_aoe_damage():
	var overlapping_bubbles = aoe_area.get_overlapping_bodies()
	for bubble in overlapping_bubbles:
		if bubble.is_in_group("bubble"):
			bubble.apply_damage(damage_amount)
