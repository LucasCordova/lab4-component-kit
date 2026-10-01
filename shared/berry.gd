extends Area2D
## A thrown marionberry. It flies straight until it leaves the screen or hits a wall.
## Both cabinets throw this same scene.

@export var speed: float = 520.0

var direction: Vector2 = Vector2.RIGHT

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	if not get_viewport_rect().grow(40.0).has_point(global_position):
		queue_free()

func _on_body_entered(_body: Node2D) -> void:
	queue_free()
