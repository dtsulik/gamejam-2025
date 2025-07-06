# flower.gd — Handles red/blue flower pickup logic

extends Area2D

@export var is_red_flower: bool = true
@export var is_blue_flower: bool = false
@export var pickup_message: String = "Flower collected!"

var can_grab := true
var cooldown_time := 1.0
var player_in_range = null

func _ready():
	set_process_input(false)
	
	# Set animation depending on flower type
	if is_red_flower:
		$AnimatedSprite2D.play("default")
	elif is_blue_flower:
		$AnimatedSprite2D.play("blue_flower")

func _on_body_entered(body: Node2D):
	if body.name == "player":
		player_in_range = body
		set_process_input(true)

func _on_body_exited(body: Node2D):
	if body.name == "player":
		player_in_range = null
		set_process_input(false)

func _input(event: InputEvent):
	if event.is_action_pressed("grab") and can_grab and player_in_range:
		print(pickup_message)
		can_grab = false

		# Call appropriate player pickup method
		if is_red_flower:
			player_in_range.pickup_red_flower()
		elif is_blue_flower:
			player_in_range.pickup_blue_flower()

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
