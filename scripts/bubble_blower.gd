extends TextureButton

@export var lung_bar: ProgressBar
@export var soap_bar: ProgressBar

var lung_capacity: float = 6.0
const LUNG_CAPACITY_MAX: float = 6.0
var remaining_soap: float = 100.0
const SOAP_CAPACITY_MAX: float = 100.0

var is_blowing: bool = false
var air_blown: float = 0.0
var breath_level: int = 1 # New variable to track discrete breath levels

const RECOVER_RATE: float = 2.0 # How fast lung capacity recovers per second
const SOAP_COST_MULTIPLIER: float = 5.0 # How much soap is used per unit of air blown
const BREATH_INTERVAL: float = 0.5 # Time in seconds per breath level

@onready var level_manager = get_node("/root/Game/%LevelManager")
var current_spawner: Node2D = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Initialize progress bars with starting values
	set_lung_capacity(LUNG_CAPACITY_MAX)
	set_remaining_soap(SOAP_CAPACITY_MAX)
	
	# Connect button signals
	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)
	
	# Connect to level manager's signal
	if level_manager:
		print("Found level manager, connecting signal...")
		level_manager.level_changed.connect(_on_level_changed)
		
		# Find current level using group
		var current_level = get_tree().get_first_node_in_group("level")
		if current_level:
			_on_level_changed(current_level)
		else:
			print("No current level found")
	else:
		push_error("LevelManager not found")

func update_lung_bar() -> void:
	if lung_bar:
		lung_bar.value = lung_capacity

func update_soap_bar() -> void:
	if soap_bar:
		soap_bar.value = remaining_soap

func set_lung_capacity(value: float) -> void:
	lung_capacity = clamp(value, 0.0, LUNG_CAPACITY_MAX)
	update_lung_bar()

func set_remaining_soap(value: float) -> void:
	remaining_soap = clamp(value, 0.0, SOAP_CAPACITY_MAX)
	update_soap_bar()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed("ui_accept") or button_pressed:
		if Input.is_action_just_pressed("ui_accept"):
			if lung_capacity >= 1.0: # Changed from > 0.0
				breath_level = 1
				air_blown = 0.0
				is_blowing = true
				set_lung_capacity(lung_capacity - 1.0)
				set_pressed_no_signal(true)
		elif is_blowing and lung_capacity > 0.0: # This stays > 0.0 to allow continuing to blow
			air_blown += delta
			# Calculate new breath level based on time held
			var new_level = int(floor(air_blown / BREATH_INTERVAL)) + 1
			if new_level > breath_level:
				if new_level >= LUNG_CAPACITY_MAX:
					# If we reach max level, consume remaining lung capacity and set to max
					breath_level = int(LUNG_CAPACITY_MAX)
					set_lung_capacity(0.0) # Consume all remaining capacity
				elif new_level < LUNG_CAPACITY_MAX:
					# Normal level increase
					set_lung_capacity(lung_capacity - 1.0)
					breath_level = new_level
		else:
			set_pressed_no_signal(false)
	elif is_blowing:
		release_bubble() # Only release bubble when stopping naturally
	elif lung_capacity < LUNG_CAPACITY_MAX:
		# Recover lung capacity when not blowing
		set_lung_capacity(lung_capacity + (RECOVER_RATE * delta))
	
	# Release button visual state and bubble when spacebar is released
	if Input.is_action_just_released("ui_accept"):
		set_pressed_no_signal(false)
		if is_blowing:
			release_bubble()

func _on_button_down() -> void:
	if lung_capacity >= 1.0: # Changed from > 0.0
		breath_level = 1
		air_blown = 0.0
		is_blowing = true
		set_lung_capacity(lung_capacity - 1.0)

func _on_button_up() -> void:
	if is_blowing: # Only release if we were actually blowing
		release_bubble()
	set_pressed_no_signal(false)

func release_bubble() -> void:
	if is_blowing:
		# Calculate soap cost for current breath level
		var soap_cost = breath_level * SOAP_COST_MULTIPLIER
		# Only blow bubble if we have enough soap
		if remaining_soap >= soap_cost:
			# Use breath_level directly instead of calculating from air_blown
			blow_bubble(breath_level)
			set_remaining_soap(remaining_soap - soap_cost)
	
	# Reset blowing state
	is_blowing = false
	air_blown = 0.0
	breath_level = 1

func _on_level_changed(level_node: Node) -> void:
	print("Level changed signal received for level: ", level_node.get_path())
	
	# Clear old spawner reference first, but don't try to access it
	current_spawner = null
	
	# Find the spawner in the new level
	var spawner = level_node.get_node("Spawner")
	if spawner and spawner is Node2D:
		current_spawner = spawner
		# Only print path if spawner is still valid
		if is_instance_valid(spawner):
			print("Found new spawner: ", spawner.get_path())
	else:
		push_error("Could not find Spawner node in level")

func blow_bubble(bubble_size: float) -> void:
	print("Attempting to blow bubble of size: ", bubble_size)
	
	# Find current level and spawner dynamically
	var current_level = get_tree().get_first_node_in_group("level")
	if not current_level:
		print("No current level found")
		return
		
	var spawner = current_level.get_node_or_null("Spawner")
	if not spawner or not spawner is Node2D:
		print("No valid spawner found in current level")
		return
		
	print("Found spawner, spawning bubble of size: ", bubble_size)
	spawner.spawn_bubble(int(bubble_size))

# Helper function to print node tree
func print_tree_from(node: Node, indent: String = "") -> void:
	print(indent + node.name + " (" + node.get_class() + ")")
	for child in node.get_children():
		print_tree_from(child, indent + "  ")

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		print("BubbleBlower being deleted")
