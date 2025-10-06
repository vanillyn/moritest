extends RigidBody3D

@export var item_name: String = "Item"
@export var weight: int = 1
@export var value: int = 500

func _ready():
	add_to_group("Item")
	add_to_group("Destructable")
	gravity_scale = 1.0
	mass = weight * 0.5
	
func get_weight() -> int:
	return weight
	
func get_value() -> int:
	return value
	
func get_item_name() -> String:
	return item_name
