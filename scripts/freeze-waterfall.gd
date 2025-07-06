extends CollisionShape2D

@export var is_frozen := false

func _ready() -> void:
	var parent = get_parent()
	var walkable = parent.find_children("walkable", "TileMap")
	walkable[0].process_mode = PROCESS_MODE_INHERIT
	get_parent().body_entered.connect(_on_body_entered)

func debug_name(node):
	print(node.name)

func _on_body_entered(body):
	print("Something entered")
	if "frost" in body.name.to_lower():
		print("Frost hit")
		if is_frozen:
			print("Already frozen")
			return
		is_frozen = true
		var parent = get_parent()
		print("Parent: ", parent, "Name: ", parent.name)
		var anim_players = parent.find_children("*", "AnimatedSprite2D")
		print("Freezing: ", anim_players.all(debug_name))
		for player in anim_players:
			print("Stopping: ", player)
			player.stop()
		var walkable = parent.find_children("walkable", "TileMap")
		print("enabling walk over: ", walkable)
		if walkable:
			walkable[0].process_mode = PROCESS_MODE_DISABLED
