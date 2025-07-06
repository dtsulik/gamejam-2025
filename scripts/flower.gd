extends Area2D

var can_grab = true
var cooldown_time = 1.0
var player_in_range = null

func _ready():
	set_process_input(false)
	
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body.name == "player":
		print("Player is now near the flower. Press E to pick up!")
		player_in_range = body
		set_process_input(true)

func _on_body_exited(body: Node2D) -> void:
	if body.name == "player":
		print("Player has moved away from the flower.")
		player_in_range = null
		set_process_input(false)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("grab") and can_grab and player_in_range:
		print("Player picked up the flower!")
		can_grab = false
		
		
		player_in_range.pickup_red_flower()
		
		create_pickup_vfx()
		
		
		await get_tree().create_timer(cooldown_time).timeout
		can_grab = true
		queue_free()

func create_pickup_vfx():
	if get_parent().has_node("VFXSprite"):
		var vfx = get_parent().get_node("VFXSprite")
		vfx.visible = true
		vfx.play("default")
		vfx.animation_finished.connect(func(): vfx.queue_free())
	else:
		print("VFXSprite not found, skipping VFX")
