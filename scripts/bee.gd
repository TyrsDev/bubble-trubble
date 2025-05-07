extends Node2D

@onready var animated_sprite_2d = $Body
@onready var detection_collision_shape = $Vision/CollisionShape2D
@onready var vision_area = $Vision

@export_group("Enemy Properties")
@export var detection_radius: float = 32.0
@export var damage_amount: int = 1
@export var attack_cooldown: float = 2.0
@export var projectile_speed: float = 100.0

var current_target: Node2D = null
var can_attack: bool = true
var attack_timer: float = 0.0
var is_attacking: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if detection_collision_shape.shape is CircleShape2D:
		detection_collision_shape.shape.radius = detection_radius
	animated_sprite_2d.frame_changed.connect(_on_frame_changed)

func _process(delta: float) -> void:
	if not can_attack:
		attack_timer += delta
		if attack_timer >= attack_cooldown:
			can_attack = true
			attack_timer = 0.0
	
	if current_target and can_attack and not is_attacking:
		start_attack()

func _on_vision_body_entered(body: Node2D) -> void:
	if body.is_in_group("bubble") and current_target == null:
		current_target = body
		# Face the target without rotation
		var direction = (body.global_position - global_position).normalized()
		if direction.x < 0:
			animated_sprite_2d.play("default")
			animated_sprite_2d.flip_h = false
		else:
			animated_sprite_2d.play("default")
			animated_sprite_2d.flip_h = true

func _on_vision_body_exited(body: Node2D) -> void:
	if body == current_target:
		current_target = null
		animated_sprite_2d.play("default")

func start_attack():
	can_attack = false
	is_attacking = true
	# Determine attack direction and play appropriate animation
	var direction = (current_target.global_position - global_position).normalized()
	if direction.x < 0:
		animated_sprite_2d.play("attack_left")
	else:
		animated_sprite_2d.play("attack_right")

func _on_frame_changed() -> void:
	if is_attacking and animated_sprite_2d.frame == 2:
		if is_instance_valid(current_target):
			spawn_projectile()

			# Flip the sprite based on the direction of the target mid animation
			var direction = (current_target.global_position - global_position).normalized()
			if direction.x < 0:
				animated_sprite_2d.flip_h = false
			else:
				animated_sprite_2d.flip_h = true
		else:
			# Target was destroyed, reset attack state
			is_attacking = false
			can_attack = true
			animated_sprite_2d.play("default")

func spawn_projectile() -> void:
	var projectile = preload("res://scenes/enemies/bee_projectile.tscn").instantiate()
	get_tree().root.add_child(projectile)
	projectile.global_position = global_position
	projectile.setup(current_target, projectile_speed, damage_amount)

func _on_animation_finished():
	if animated_sprite_2d.animation.begins_with("attack"):
		is_attacking = false
		animated_sprite_2d.play("default")
