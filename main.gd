extends Node2D
## The cabinet picker. Press 1 or 2 to walk up to a cabinet.

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pick_a"):
		get_tree().change_scene_to_file("res://cabinet_a/cabinet_a.tscn")
	elif Input.is_action_just_pressed("pick_b"):
		get_tree().change_scene_to_file("res://cabinet_b/cabinet_b.tscn")
