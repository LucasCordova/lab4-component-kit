extends Node2D
## Cabinet B: Crate Crash. Crates fall toward the fig orchard. Escape walks back to the picker.

const CRATE := preload("res://cabinet_b/crate.tscn")

@export var spawn_every: float = 1.4

var _since_spawn: float = 0.0

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("back"):
		get_tree().change_scene_to_file("res://main.tscn")

	_since_spawn += delta
	if _since_spawn >= spawn_every:
		_since_spawn = 0.0
		_spawn_crate()

func _spawn_crate() -> void:
	var crate := CRATE.instantiate()
	crate.position = Vector2(randf_range(60.0, 1092.0), -30.0)
	add_child(crate)
