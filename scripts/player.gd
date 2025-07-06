extends CharacterBody2D

@export var speed := 100.0
@export var jump_velocity := -300.0
@export var gravity := 800.0
@export var dash_speed := 300.0
@export var dash_duration := 0.2

# Fireball settings
@export var fireball_scene: PackedScene
@export var fireball_speed := 200.0
@export var fireball_spawn_offset := 40.0

# Fireball pickup system
var has_fireball_ability := false
var fireball_count := 0
var max_fireball_count := 5

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
	
	# DEBUG: Print when fire button is pressed
	if Input.is_action_just_pressed("fire"):
		print("Fire button pressed! Has ability: ", has_fireball_ability, " Count: ", fireball_count)
	
	# Fireball shooting - only if player has the ability
	if Input.is_action_just_pressed("fire") and has_fireball_ability:
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
	print("shoot_fireball() called")
	
	# Check if player has ability and ammo
	if not has_fireball_ability or fireball_count <= 0:
		print("Cannot shoot fireball! Has ability: ", has_fireball_ability, " Count: ", fireball_count)
		return
	
	if not fireball_scene:
		print("ERROR: No fireball scene assigned!")
		return
	
	print("Creating fireball...")
	
	# Create fireball instance
	var fireball = fireball_scene.instantiate()
	
	# Use the player sprite's center as a spawn reference
	var sprite = $AnimatedSprite2D
	var sprite_center = global_position + sprite.position
	
	# Calculate horizontal offset
	var spawn_position = sprite_center
	spawn_position.x += fireball_spawn_offset * last_direction
	
	# Add fireball to the scene
	get_tree().current_scene.add_child(fireball)
	
	# Set fireball properties
	fireball.global_position = spawn_position
	fireball.setup(last_direction, fireball_speed)
	
	# Decrease ammo count
	fireball_count -= 1
	
	print("Fireball shot! Remaining: ", fireball_count)

# Called when player picks up the red flower
func pickup_red_flower():
	print("pickup_red_flower() called")
	has_fireball_ability = true
	fireball_count = 5
	print("Red flower picked up! Can now shoot 5 fireballs!")
	print("Current state - Has ability: ", has_fireball_ability, " Count: ", fireball_count)

# For checking if player can shoot (useful for UI)
func can_shoot_fireball() -> bool:
	return has_fireball_ability and fireball_count > 0
