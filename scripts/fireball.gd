extends CharacterBody2D

var direction: float = 1.0
var speed: float = 200.0
var lifetime: float = 2.0
var is_exploding: bool = false

func _ready():
	$AnimatedSprite2D.play("default")
	$AnimatedSprite2D.animation_finished.connect(_on_animation_finished)
	
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
	if is_exploding:
		return
	
	# Move the fireball
	velocity.x = speed * direction
	velocity.y = 0  
	
	move_and_slide()
	
	# Check for collisions
	if get_slide_collision_count() > 0:
		print("Fireball hit something! Collision count: ", get_slide_collision_count())
		
		# Check what we hit
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			var collider = collision.get_collider()
			print("Fireball collided with: ", collider.name if collider else "null")
			
			# If we hit a thorny plant, trigger its burning
			if collider and collider.has_method("hit_by_fireball"):
				print("Calling hit_by_fireball on: ", collider.name)
				collider.hit_by_fireball()
			
			# If we hit a destructible plant, trigger its destruction
			elif collider and collider.is_in_group("destructible_plants"):
				print("Hit destructible plant: ", collider.name)
				if collider.has_method("hit_by_fireball"):
					collider.hit_by_fireball()
		
		explode()
		return
	
	# Check if fireball is out of bounds
	var viewport_size = get_viewport_rect().size
	if global_position.x < -100 or global_position.x > viewport_size.x + 100:
		queue_free()

func explode():
	if is_exploding:
		return 
	
	print("Fireball exploded!")
	is_exploding = true
	
	velocity = Vector2.ZERO
	$AnimatedSprite2D.play("explode")

func _on_animation_finished():
	if is_exploding:
		queue_free()

func _on_lifetime_expired():
	if not is_exploding:
		explode()
