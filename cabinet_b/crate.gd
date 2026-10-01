extends Node2D
## A falling crate. It drifts down toward the orchard, and that is all it does so far.

func _process(delta: float) -> void:
	position.y += 60.0 * delta
	if position.y > 700.0:
		queue_free()
