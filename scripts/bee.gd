extends Node2D

@onready var animated_sprite_2d = $Body
@onready var detection_collision_shape = $Vision/CollisionShape2D
@onready var vision_area = $Vision
@onready var stinger_point = $Body/StingerPoint

@export_group("Enemy Properties")
@export var detection_radius: float = 32.0
@export var damage_amount: int = 1
@export var attack_cooldown: float = 2.0
@export var projectile_speed: float = 100.0

# Store original stinger offset
var stinger_offset = Vector2.ZERO

var current_target: Node2D = null
var last_target: Node2D = null # Store the last target for fadeaway shots
var can_attack: bool = true
var attack_timer: float = 0.0
var is_attacking: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if detection_collision_shape.shape is CircleShape2D:
		detection_collision_shape.shape.radius = detection_radius
	animated_sprite_2d.frame_changed.connect(_on_frame_changed)
	animated_sprite_2d.animation_finished.connect(_on_body_animation_finished)
	
	# Save original stinger position
	stinger_offset = stinger_point.position
	
	# Make sure the default animation loops
	if not animated_sprite_2d.sprite_frames.get_animation_loop("default"):
		print("Warning: Default animation should be set to loop!")

func _process(delta: float) -> void:
	if current_target and is_instance_valid(current_target):
		face_target(current_target)
	
	if not can_attack:
		attack_timer += delta
		if attack_timer >= attack_cooldown:
			can_attack = true
			attack_timer = 0.0
	
	# If we're not attacking and we have a valid target, start a new attack
	if current_target and is_instance_valid(current_target) and can_attack and not is_attacking:
		start_attack()
	elif not is_instance_valid(current_target) and not is_attacking:
		# If we don't have a target and we're not in an attack animation, make sure we're in default
		if animated_sprite_2d.animation != "default":
			animated_sprite_2d.play("default")

# Face the target by flipping sprite appropriately
func face_target(target: Node2D) -> void:
	var direction = (target.global_position - global_position).normalized()
	if direction.x < 0:
		animated_sprite_2d.flip_h = false
		stinger_point.position = stinger_offset
	else:
		animated_sprite_2d.flip_h = true
		stinger_point.position = Vector2(-stinger_offset.x, stinger_offset.y)

func _on_vision_body_entered(body: Node2D) -> void:
	if body.is_in_group("bubble") and current_target == null:
		current_target = body

func _on_vision_body_exited(body: Node2D) -> void:
	if body == current_target:
		print("Target exited vision: ", body)
		last_target = current_target # Store the exiting target
		current_target = null
		# Try to find a new target immediately when current one leaves
		find_new_target()

# Add a new function to find targets
func find_new_target() -> bool:
	print("Looking for new target...")
	var bodies = vision_area.get_overlapping_bodies()
	var closest_target = null
	var closest_distance = INF
	
	for body in bodies:
		if body.is_in_group("bubble"):
			var distance = global_position.distance_to(body.global_position)
			if distance < closest_distance:
				closest_distance = distance
				closest_target = body
	
	if closest_target:
		print("Found new target: ", closest_target)
		current_target = closest_target
		return true
	return false

func start_attack():
	can_attack = false
	is_attacking = true
	
	# Always play attack_left due to sprite being flipped when facing right
	animated_sprite_2d.play("attack_left")

func _on_frame_changed() -> void:
	# If we're attacking and reach frame 2, try to spawn a projectile
	if is_attacking and animated_sprite_2d.frame == 2:
		var target_to_shoot = current_target
		
		# If current target isn't valid, try to find a new one
		if not target_to_shoot or not is_instance_valid(target_to_shoot):
			if find_new_target():
				target_to_shoot = current_target
				print("Found new target mid-attack, spawning projectile at new target")
			elif last_target and is_instance_valid(last_target):
				# If no new target found, use the last target for a "fadeaway shot"
				target_to_shoot = last_target
				print("No valid targets in range, shooting fadeaway at last target")
		
		# Spawn the projectile if we have any target
		if target_to_shoot and is_instance_valid(target_to_shoot):
			print("Spawning projectile at target: ", target_to_shoot)
			spawn_projectile_at(target_to_shoot)
			last_target = null
		else:
			print("No valid target for projectile")

func spawn_projectile() -> void:
	spawn_projectile_at(current_target)

func spawn_projectile_at(target: Node2D) -> void:
	var projectile = preload("res://scenes/enemies/bee_projectile.tscn").instantiate()
	get_tree().root.add_child(projectile)
	projectile.global_position = stinger_point.global_position
	projectile.setup(target, projectile_speed, damage_amount)

func _on_body_animation_finished():
	# Print animation name
	print(animated_sprite_2d.animation + " finished.")
	
	# If this was an attack animation
	if animated_sprite_2d.animation.begins_with("attack"):
		is_attacking = false
		can_attack = true # Make sure we can attack again
		
		# Check if we still have a valid target
		if current_target and is_instance_valid(current_target):
			print("Target still valid after attack, starting new attack")
			if can_attack: # Double-check we can attack
				start_attack()
		else:
			# Otherwise go back to default animation
			animated_sprite_2d.play("default")
			
			# Look for a new target
			if find_new_target() and can_attack:
				print("Found new target after attack, starting new attack")
				start_attack()
