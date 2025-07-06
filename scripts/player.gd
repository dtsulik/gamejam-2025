# player.gd — Player character script

extends CharacterBody2D

@onready var jump_sound = $player/sfx_jump

@export var speed := 100.0
@export var jump_velocity := -200.0
@export var gravity := 800.0
@export var dash_speed := 300.0
@export var dash_duration := 0.2

# Fireball settings
@export var fireball_scene: PackedScene
@export var fireball_speed := 200.0
@export var fireball_spawn_offset := 30.0

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
		if Input.is_action_pressed("move_left"):
			direction -= 1
		if Input.is_action_pressed("move_right"):
			direction += 1
		if direction != 0:
			last_direction = direction

	if Input.is_action_just_pressed("fire") and has_fireball_ability:
		shoot_fireball()

	if Input.is_action_just_pressed("dash") and not is_dashing:
		if is_on_floor() or can_air_dash:
			is_dashing = true
			dash_timer = dash_duration
			velocity.x = dash_speed * last_direction
			velocity.y = 0
			if not is_on_floor():
				can_air_dash = false

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
				jump_sound.play()
		else:
			if Input.is_action_just_pressed("jump") and can_double_jump:
				velocity.y = jump_velocity
				jump_sound.play()
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
	if not has_fireball_ability or fireball_count <= 0 or fireball_scene == null:
		return

	var fireball = fireball_scene.instantiate()
	var sprite_center = global_position + $AnimatedSprite2D.position
	var spawn_position = sprite_center + Vector2(fireball_spawn_offset * last_direction, 0)

	fireball.global_position = spawn_position
	fireball.setup(last_direction, fireball_speed)

	get_tree().current_scene.add_child(fireball)
	fireball_count -= 1

# Power pickups
func pickup_red_flower():
	has_fireball_ability = true
	fireball_count = max_fireball_count
	print("Red flower picked up! Fireball ability granted!")

func pickup_blue_flower():
	print("Blue flower picked up! Granting BLUE power here!")
	# TODO: Add actual blue power logic here (e.g., shield, freeze, etc.)
