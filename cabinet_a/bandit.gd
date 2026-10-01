extends CharacterBody2D
## A Berry Bandit. It chases Blitz when he comes close, and that is all it does so far.

func _physics_process(_delta: float) -> void:
	var player := get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return
	var to_player: Vector2 = player.global_position - global_position
	if to_player.length() < 300.0:
		velocity = to_player.normalized() * 120.0
	else:
		velocity = Vector2.ZERO
	move_and_slide()
