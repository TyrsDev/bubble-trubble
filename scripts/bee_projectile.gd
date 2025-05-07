extends Node2D

var target: Node2D
var speed: float
var damage: int

func setup(target_node: Node2D, projectile_speed: float, damage_amount: int) -> void:
	target = target_node
	speed = projectile_speed
	damage = damage_amount

func _process(delta: float) -> void:
	if not is_instance_valid(target):
		queue_free()
		return
	
	# Move towards target
	var direction = (target.global_position - global_position).normalized()
	global_position += direction * speed * delta
	
	# Check if we've reached the target
	if global_position.distance_to(target.global_position) < 5.0:
		if is_instance_valid(target):
			target.apply_damage(damage)
		queue_free()