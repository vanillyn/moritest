extends RigidBody3D
class_name Item

@export var item_name: String = "item"
@export var weight: int = 1
@export var value: int = 500

var value_label_scene: PackedScene = preload("res://src/entity/item/valuables/value_label.tscn")

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
	
func destroy():
	show_value_lost()
	queue_free()
	
func show_value_lost():
	if value_label_scene:
		var label = value_label_scene.instantiate()
		label.global_position = global_position
		get_parent().add_child(label)
		label.set_value(value)
		
