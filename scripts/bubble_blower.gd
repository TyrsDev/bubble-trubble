extends TextureButton

@export var lung_bar: ProgressBar
@export var soap_bar: ProgressBar

var lung_capacity: float = 6.0
const LUNG_CAPACITY_MAX: float = 6.0
var remaining_soap: float = 100.0
const SOAP_CAPACITY_MAX: float = 100.0

var is_blowing: bool = false
var air_blown: float = 0.0

const BLOW_RATE: float = 1.0  # How fast lung capacity depletes per second
const RECOVER_RATE: float = 2.0  # How fast lung capacity recovers per second
const SOAP_COST_MULTIPLIER: float = 5.0  # How much soap is used per unit of air blown

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Initialize progress bars with starting values
	set_lung_capacity(LUNG_CAPACITY_MAX)
	set_remaining_soap(SOAP_CAPACITY_MAX)
	
	# Connect button signals
	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)

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
	if Input.is_action_pressed("ui_accept") or button_pressed:  # Check either input
		if Input.is_action_just_pressed("ui_accept"):
			# Only handle button down logic, don't trigger the signal
			air_blown = 1.0
			is_blowing = true
			set_pressed_no_signal(true)
		elif lung_capacity > 0:
			air_blown += delta
			if air_blown > LUNG_CAPACITY_MAX:
				set_pressed_no_signal(false)
				is_blowing = false  # Stop blowing without releasing bubble
			else:
				set_lung_capacity(lung_capacity - (BLOW_RATE * delta))
		else:
			set_pressed_no_signal(false)
			is_blowing = false  # Stop blowing without releasing bubble
	elif is_blowing:
		release_bubble()  # Only release bubble when stopping naturally
	elif lung_capacity < LUNG_CAPACITY_MAX:
		# Recover lung capacity when not blowing
		set_lung_capacity(lung_capacity + (RECOVER_RATE * delta))
	
	# Release button visual state and bubble when spacebar is released
	if Input.is_action_just_released("ui_accept"):
		set_pressed_no_signal(false)
		if is_blowing:
			release_bubble()

func _on_button_down() -> void:
	air_blown = 1.0
	is_blowing = true

func _on_button_up() -> void:
	if is_blowing:  # Only release if we were actually blowing
		release_bubble()
	set_pressed_no_signal(false)

func release_bubble() -> void:
	if air_blown > 0:
		# Floor the air_blown value and cap it at LUNG_CAPACITY_MAX
		var final_size = floor(min(air_blown, LUNG_CAPACITY_MAX))
		blow_bubble(final_size)
		set_lung_capacity(floor(lung_capacity))
		set_remaining_soap(remaining_soap - (final_size * SOAP_COST_MULTIPLIER))
	
	# Reset blowing state
	is_blowing = false
	air_blown = 0.0

func blow_bubble(bubble_size: float) -> void:
	print("Blowing bubble with size: ", bubble_size)  # Placeholder for actual bubble spawning
	# TODO: Implement bubble spawning logic here
