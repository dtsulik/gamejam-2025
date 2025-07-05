extends CharacterBody2D

var direction: float = 1.0
var speed: float = 400.0
var lifetime: float = 5.0
var is_exploding: bool = false

func _ready():
	# Start the default animation
	$AnimatedSprite2D.play("default")
	
	# Connect animation finished signal to handle explosion end
	$AnimatedSprite2D.animation_finished.connect(_on_animation_finished)
	
	# Auto-destroy after lifetime
	var timer = Timer.new()
	timer.wait_time = lifetime
	timer.one_shot = true
	timer.timeout.connect(_on_lifetime_expired)
	add_child(timer)
	timer.start()

func setup(dir: float, spd: float):
	direction = dir
	speed = spd
	
	# Flip sprite if moving left
	$AnimatedSprite2D.flip_h = direction < 0
	
	print("Fireball setup - Direction: ", direction, " Speed: ", speed)

func _physics_process(delta):
	# Don't move if exploding
	if is_exploding:
		return
	
	# Move the fireball
	velocity.x = speed * direction
	velocity.y = 0  # Keep it horizontal
	
	move_and_slide()
	
	# Check if fireball hit anything with collision
	if get_slide_collision_count() > 0:
		explode()
		return
	
	# Optional: Add some screen boundary checking
	var viewport_size = get_viewport_rect().size
	if global_position.x < -100 or global_position.x > viewport_size.x + 100:
		queue_free()

func explode():
	if is_exploding:
		return  # Already exploding
	
	print("Fireball exploded!")
	is_exploding = true
	
	# Stop movement
	velocity = Vector2.ZERO
	
	# Play explosion animation
	$AnimatedSprite2D.play("explode")
	
	# Optional: Add explosion sound here
	# $AudioStreamPlayer2D.play()

func _on_animation_finished():
	# When explosion animation finishes, remove the fireball
	if is_exploding:
		queue_free()

func _on_lifetime_expired():
	if not is_exploding:
		explode()  # Explode instead of just disappearing
