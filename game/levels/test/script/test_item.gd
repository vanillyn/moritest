extends Area3D

@export var item_name: String = "Test Item"

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	
func _on_body_entered(body):
	if body.is_in_group("Player"):
		body.take(item_name)
		queue_free()
