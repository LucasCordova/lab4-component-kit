extends CharacterBody2D
## Blitz in Bandit Brawl: move with the arrows or WASD, throw a berry with Space.

const BERRY := preload("res://shared/berry.tscn")

@export var speed: float = 260.0

var facing: Vector2 = Vector2.RIGHT

func _physics_process(_delta: float) -> void:
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if direction != Vector2.ZERO:
		facing = direction.normalized()
	velocity = direction * speed
	move_and_slide()

	if Input.is_action_just_pressed("throw"):
		_throw()

func _throw() -> void:
	var berry := BERRY.instantiate()
	berry.direction = facing
	berry.global_position = global_position + facing * 24.0
	add_sibling(berry)
