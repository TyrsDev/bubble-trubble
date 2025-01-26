extends Node

@onready var sheep_sprite: AnimatedSprite2D = $Sheep/Sheepie
const HAPPINESS_THRESHOLD = 3
var current_happiness = 0
var is_happy = false

func _ready() -> void:
	start_crying()
	$Sheep.body_entered.connect(_on_sheep_body_entered)

func start_crying() -> void:
	sheep_sprite.play("start_cry")
	sheep_sprite.animation_finished.connect(_on_start_cry_finished)

func _on_start_cry_finished() -> void:
	if sheep_sprite.animation == "start_cry":
		sheep_sprite.animation_finished.disconnect(_on_start_cry_finished)
		sheep_sprite.play("cry_loop")

# New function to handle CharacterBody2D collisions
func _on_sheep_body_entered(body: CharacterBody2D) -> void:
	if is_happy:
		return
		
	if body.is_in_group("bubble"):
		body.queue_free() # Consume the bubble
		current_happiness += 1
		
		if current_happiness >= HAPPINESS_THRESHOLD:
			become_happy()

func become_happy() -> void:
	is_happy = true
	sheep_sprite.play("stop_cry")
	sheep_sprite.animation_finished.connect(_on_stop_cry_finished)

func _on_stop_cry_finished() -> void:
	if sheep_sprite.animation == "stop_cry":
		sheep_sprite.animation_finished.disconnect(_on_stop_cry_finished)
		sheep_sprite.play("idle")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
