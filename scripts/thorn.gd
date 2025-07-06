extends CharacterBody2D

@export var is_burning := false
@export var burn_duration := 0.5

func _ready():
	print("Thorny plant created at position: ", global_position)
	
	# Start with idle animation
	$AnimatedSprite2D.play("idle")
	print("Playing idle animation")
	
	# Connect to animation finished signal
	$AnimatedSprite2D.animation_finished.connect(_on_animation_finished)
	
	# Add to group for identification
	add_to_group("destructible_plants")
	
	# Connect Area2D signals for fireball detection
	if has_node("HitDetector"):
		print("Found HitDetector Area2D, connecting signals")
		$HitDetector.body_entered.connect(_on_hit_detector_body_entered)
	else:
		print("WARNING: No HitDetector Area2D found! Add one for fireball detection")

# Remove _physics_process entirely since the plant doesn't move
# The CharacterBody2D collision will handle blocking the player

func _on_hit_detector_body_entered(body):
	print("HitDetector: Something entered - ", body.name)
	
	# Check if it's a fireball
	if body.has_method("explode") or "fireball" in body.name.to_lower():
		print("HitDetector: Hit by fireball!")
		hit_by_fireball()
		
		# Make the fireball explode
		if body.has_method("explode"):
			body.explode()

func hit_by_fireball():
	if is_burning:
		print("Already burning, ignoring hit")
		return
	
	print("Thorny plant hit by fireball!")
	is_burning = true
	
	# Play burning animation
	$AnimatedSprite2D.play("burning")
	print("Playing burning animation")
	
	# Create a timer to destroy the plant after burning animation
	var timer = Timer.new()
	timer.wait_time = burn_duration
	timer.one_shot = true
	timer.timeout.connect(_on_burn_complete)
	add_child(timer)
	timer.start()
	print("Started burn timer for ", burn_duration, " seconds")

func _on_animation_finished():
	print("Animation finished: ", $AnimatedSprite2D.animation)
	if is_burning and $AnimatedSprite2D.animation == "burning":
		print("Burning animation finished, destroying plant")
		_on_burn_complete()

func _on_burn_complete():
	print("Thorny plant destroyed!")
	queue_free()
