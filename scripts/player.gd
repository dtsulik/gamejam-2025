extends CharacterBody2D

@onready var jump_sound = $sfx_jump
@onready var attack_sound = $sfx_attack
@onready var fire_sound = $sfx_fire
@onready var sfx_move: AudioStreamPlayer = $sfx_move

@export var speed := 100.0
@export var jump_velocity := -200.0
@export var gravity := 800.0
@export var dash_speed := 300.0
@export var dash_duration := 0.2

# Fireball
@export var fireball_scene: PackedScene
@export var fireball_speed := 200.0
@export var fireball_spawn_offset := 30.0

# Frostshot
@export var frostshot_scene: PackedScene
@export var frostshot_speed := 100.0
@export var frostshot_spawn_offset := 10.0

# Wind
@export var wind_scene: PackedScene
@export var wind_speed := 100.0
@export var wind_spawn_offset := 10.0

# Power flags & ammo counts
var has_fireball_ability := false
var fireball_count := 0
var max_fireball_count := 5

var has_frostshot_ability := false
var frostshot_count := 0
var max_frostshot_count := 3

var has_wind_ability := false
var wind_count := 0
var max_wind_count := 3

# Movement
var is_dashing := false
var dash_timer := 0.0
var last_direction := 1
var can_air_dash := true
var can_double_jump := true

func _physics_process(delta):
	var direction := 0
	if not is_dashing:
		if Input.is_action_pressed("move_left"):
			direction -= 1
		if Input.is_action_pressed("move_right"):
			direction += 1
		if direction != 0:
			last_direction = direction

	# Fireball
	if Input.is_action_just_pressed("fire"):
		if has_fireball_ability:
			shoot_fireball()

	# Frostshot
	if Input.is_action_just_pressed("frost"):
		if has_frostshot_ability:
			shoot_frostshot()

	# Wind
	if Input.is_action_just_pressed("wind-push"):
		if has_wind_ability:
			shoot_wind()

	# Dash
	if Input.is_action_just_pressed("dash") and not is_dashing:
		if is_on_floor() or can_air_dash:
			is_dashing = true
			dash_timer = dash_duration
			velocity.x = dash_speed * last_direction
			velocity.y = 0
			if not is_on_floor():
				can_air_dash = false

	# Movement & Jumping
	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0.0:
			is_dashing = false
	else:
		velocity.x = direction * speed
		if is_on_floor():
			can_air_dash = true
			can_double_jump = true
			if Input.is_action_just_pressed("jump"):
				velocity.y = jump_velocity
				if jump_sound:
					jump_sound.play()
		else:
			if Input.is_action_just_pressed("jump") and can_double_jump:
				velocity.y = jump_velocity
				if jump_sound:
					jump_sound.play()
				can_double_jump = false
				$AnimatedSprite2D.play("double_jump")

	if not is_on_floor() and not is_dashing:
		velocity.y += gravity * delta

	move_and_slide()
	update_animation()
	update_move_sound(direction)

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

func update_move_sound(direction):
	if is_on_floor() and direction != 0 and not is_dashing:
		if not sfx_move.playing:
			sfx_move.play()
	else:
		if sfx_move.playing:
			sfx_move.stop()

func shoot_fireball():
	if not has_fireball_ability or fireball_count <= 0 or fireball_scene == null:
		return

	var fireball = fireball_scene.instantiate()
	var sprite_node = $AnimatedSprite2D
	var spawn_position = global_position + sprite_node.position
	spawn_position.x += fireball_spawn_offset * last_direction

	fireball.global_position = spawn_position
	fireball.setup(last_direction, fireball_speed)

	get_tree().current_scene.add_child(fireball)
	if fire_sound:
		fire_sound.play()

	fireball_count -= 1

func shoot_frostshot():
	if not has_frostshot_ability or frostshot_count <= 0 or frostshot_scene == null:
		return

	var frost = frostshot_scene.instantiate()
	var sprite_node = $AnimatedSprite2D
	var spawn_position = global_position + sprite_node.position
	spawn_position.x += frostshot_spawn_offset * last_direction

	frost.global_position = spawn_position
	frost.setup(last_direction, frostshot_speed)

	get_tree().current_scene.add_child(frost)
	if attack_sound:
		attack_sound.play()

	frostshot_count -= 1

func shoot_wind():
	if not has_wind_ability or wind_count <= 0 or wind_scene == null:
		return

	var wind = wind_scene.instantiate()
	var sprite_node = $AnimatedSprite2D
	var spawn_position = global_position + sprite_node.position
	spawn_position.x += wind_spawn_offset * last_direction

	wind.global_position = spawn_position
	wind.setup(last_direction, wind_speed)

	get_tree().current_scene.add_child(wind)
	if attack_sound:
		attack_sound.play()

	wind_count -= 1

func pickup_red_flower():
	has_fireball_ability = true
	fireball_count = max_fireball_count

func pickup_blue_flower():
	has_frostshot_ability = true
	frostshot_count = max_frostshot_count

func pickup_wind_flower():
	has_wind_ability = true
	wind_count = max_wind_count
