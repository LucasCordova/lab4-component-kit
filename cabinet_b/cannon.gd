extends Node2D
## The berry cannon in Crate Crash: slide with left and right, fire with Space.

const BERRY := preload("res://shared/berry.tscn")

@export var speed: float = 420.0

func _process(delta: float) -> void:
	var direction := Input.get_axis("move_left", "move_right")
	position.x = clampf(position.x + direction * speed * delta, 40.0, 1112.0)

	if Input.is_action_just_pressed("throw"):
		_fire()

func _fire() -> void:
	var berry := BERRY.instantiate()
	berry.direction = Vector2.UP
	berry.global_position = global_position + Vector2(0.0, -30.0)
	add_sibling(berry)
