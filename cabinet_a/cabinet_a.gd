extends Node2D
## Cabinet A: Bandit Brawl. Escape walks back to the picker.

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("back"):
		get_tree().change_scene_to_file("res://main.tscn")
