extends Area2D

var can_grab = true
var cooldown_time = 1.0

func _ready():
	set_process_input(false)

func _on_body_entered(body: Node2D) -> void:
	if body.name == "player":
		print("Player is now near the flower. Press E to pick up!")
		set_process_input(true)

func _on_body_exited(body: Node2D) -> void:
	if body.name == "player":
		print("Player has moved away from the flower.")
		set_process_input(false)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("grab") and can_grab:
		print("Player picked up the flower!")
		can_grab = false  # Disable grabbing
		create_pickup_vfx()
		
		# Start cooldown timer
		await get_tree().create_timer(cooldown_time).timeout
		can_grab = true  # Re-enable grabbing after cooldown
		queue_free()

func create_pickup_vfx():
	var vfx = get_parent().get_node("VFXSprite")
	vfx.visible = true
	vfx.play("default")
	
	# Destroy VFX after animation finishes
	vfx.animation_finished.connect(func(): vfx.queue_free())
