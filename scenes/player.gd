extends CharacterBody2D

@export var speed := 100.0
@export var jump_velocity := -300.0
@export var gravity := 800.0
@export var dash_speed := 300.0
@export var dash_duration := 0.2

var is_dashing := false
var dash_timer := 0.0
var last_direction := 1  # 1 = right, -1 = left
var can_air_dash := true

func _physics_process(delta):
	var direction := 0

	if not is_dashing:
		# Handle left/right movement
		if Input.is_action_pressed("move_left"):
			direction -= 1
		if Input.is_action_pressed("move_right"):
			direction += 1

		if direction != 0:
			last_direction = direction

	# Trigger dash
	if Input.is_action_just_pressed("dash") and not is_dashing:
		if is_on_floor() or can_air_dash:
			is_dashing = true
			dash_timer = dash_duration
			velocity.x = dash_speed * last_direction
			velocity.y = 0  # Lock vertical movement during dash

			if not is_on_floor():
				can_air_dash = false  # Consume air dash

	# Dash logic
	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0.0:
			is_dashing = false
	else:
		# Normal movement and jump
		velocity.x = direction * speed

		if is_on_floor():
			can_air_dash = true  # Reset air dash on landing
			if Input.is_action_just_pressed("jump"):
				velocity.y = jump_velocity

	# Apply gravity only when not dashing
	if not is_on_floor() and not is_dashing:
		velocity.y += gravity * delta

	# Move the character
	move_and_slide()

	# Animation
	var sprite = $AnimatedSprite2D

	if is_dashing:
		sprite.play("dash")
		sprite.flip_h = last_direction < 0
	elif not is_on_floor():
		if velocity.y < 0:
			sprite.play("jump")
		else:
			sprite.play("fall")
	elif velocity.x != 0:
		sprite.play("run")
		sprite.flip_h = velocity.x < 0
	else:
		sprite.play("idle")
