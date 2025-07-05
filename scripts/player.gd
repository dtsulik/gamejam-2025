extends CharacterBody2D

@export var speed := 100.0
@export var jump_velocity := -300.0
@export var gravity := 800.0
@export var dash_speed := 300.0
@export var dash_duration := 0.2

# Fireball settings
@export var fireball_scene: PackedScene
@export var fireball_speed := 400.0
@export var fireball_spawn_offset := 50.0  # How far in front of player to spawn

var is_dashing := false
var dash_timer := 0.0
var last_direction := 1  
var can_air_dash := true
var can_double_jump := true

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
	
	# Fireball shooting
	if Input.is_action_just_pressed("fire"):
		shoot_fireball()
	
	# Trigger dash
	if Input.is_action_just_pressed("dash") and not is_dashing:
		if is_on_floor() or can_air_dash:
			is_dashing = true
			dash_timer = dash_duration
			velocity.x = dash_speed * last_direction
			velocity.y = 0
			if not is_on_floor():
				can_air_dash = false
	
	# Dash logic
	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0.0:
			is_dashing = false
	else:
		# Normal movement and jump
		velocity.x = direction * speed
		if is_on_floor():
			can_air_dash = true
			can_double_jump = true
			if Input.is_action_just_pressed("jump"):
				velocity.y = jump_velocity
		else:
			# In air - allow double jump if available
			if Input.is_action_just_pressed("jump") and can_double_jump:
				velocity.y = jump_velocity
				can_double_jump = false
				$AnimatedSprite2D.play("double_jump")
	
	if not is_on_floor() and not is_dashing:
		velocity.y += gravity * delta
	
	move_and_slide()
	update_animation()

func update_animation():
	var sprite = $AnimatedSprite2D
	if is_dashing:
		sprite.play("dash")
		sprite.flip_h = last_direction < 0
	elif not is_on_floor():
		if velocity.y < 0:
			if sprite.animation != "double_jump":
				sprite.play("jump")
		else:
			sprite.play("fall")
	elif velocity.x != 0:
		sprite.play("run")
		sprite.flip_h = velocity.x < 0
	else:
		sprite.play("idle")

func shoot_fireball():
	if not fireball_scene:
		print("ERROR: No fireball scene assigned!")
		return

	# Create fireball instance
	var fireball = fireball_scene.instantiate()

	# Use the player sprite's center as a spawn reference
	var sprite = $AnimatedSprite2D
	var sprite_center = global_position + sprite.position

	# Calculate horizontal offset
	var spawn_position = sprite_center
	spawn_position.x += fireball_spawn_offset * last_direction

	# Optional: fine-tune vertical offset if needed
	# spawn_position.y += some_value  # e.g. -10 for hand height

	# Add fireball to the scene
	get_tree().current_scene.add_child(fireball)

	# Set fireball properties
	fireball.global_position = spawn_position
	fireball.setup(last_direction, fireball_speed)

	print("Fireball shot at: ", spawn_position, " direction: ", last_direction)
