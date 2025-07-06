extends CharacterBody2D

var direction := 1.0
var speed := 150.0
var is_playing := false

func setup(dir: float, spd: float):
	direction = dir
	speed = spd
	$AnimatedSprite2D.flip_h = direction < 0

func _physics_process(delta):
	if not is_playing:
		$AnimatedSprite2D.play("wind")
		is_playing = true

	velocity.x = speed * direction
	velocity.y = 0
	move_and_slide()

	# Auto-remove if off screen
	var vp = get_viewport_rect()
	if global_position.x < -100 or global_position.x > vp.size.x + 100:
		queue_free()

func _on_animation_finished():
	queue_free()

func _ready():
	$AnimatedSprite2D.animation_finished.connect(_on_animation_finished)
