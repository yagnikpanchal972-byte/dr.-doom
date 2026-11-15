
extends CharacterBody2D

@onready var jump_sound = $JumpSound
@onready var story_label = get_parent().get_node("CanvasLayer/Label")

const SPEED = 190.0

# Charge jump settings
const MIN_JUMP_FORCE = 300.0
const MAX_JUMP_FORCE = 900.0
const CHARGE_SPEED = 450.0

# Automatic idle bounce settings
const IDLE_BOUNCE_FORCE = 150.0
const IDLE_BOUNCE_INTERVAL = 0.50

var jump_charge = 0.0
var charging = false
var idle_bounce_timer = 0.0


func _ready():
	story_label.show()


func _physics_process(delta: float) -> void:

	# Hide story when player starts controlling the character
	if Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("ui_right") or Input.is_action_just_pressed("ui_accept"):
		story_label.hide()

	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Movement direction
	var direction := Input.get_axis("ui_left", "ui_right")

	# Start charging jump
	if is_on_floor() and Input.is_action_just_pressed("ui_accept"):
		charging = true
		jump_charge = 0.0

	# Increase jump power while holding Space
	if charging and Input.is_action_pressed("ui_accept"):
		jump_charge += CHARGE_SPEED * delta
		jump_charge = min(jump_charge, MAX_JUMP_FORCE - MIN_JUMP_FORCE)

	# Release Space for powerful jump
	if charging and Input.is_action_just_released("ui_accept"):
		velocity.y = -(MIN_JUMP_FORCE + jump_charge)
		jump_sound.play()

		charging = false
		jump_charge = 0.0
		idle_bounce_timer = 0.0

	# Automatic small bouncing when standing still
	elif is_on_floor() and direction == 0 and abs(velocity.x) < 5.0 and not charging and not Input.is_action_pressed("ui_accept"):

		idle_bounce_timer += delta

		if idle_bounce_timer >= IDLE_BOUNCE_INTERVAL:
			velocity.y = -IDLE_BOUNCE_FORCE
			idle_bounce_timer = 0.0

	else:
		idle_bounce_timer = 0.0

	# Horizontal movement
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# Apply movement
	move_and_slide()
