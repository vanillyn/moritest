extends RigidBody3D
class_name Item

signal item_destroyed(item_name, value)

@export var item_name: String = "item"
@export var weight: int = 1
@export var value: int = 500
@export var show_value_on_destroy: bool = true
@export var impact_damage_threshold: float = 5.0
@export var impact_damage_multiplier: float = 10.0

var value_label_scene: PackedScene = preload("res://src/entity/item/valuables/value_label.tscn")
var item_health: float = 100.0

func _ready():
	add_to_group("Item")
	add_to_group("Destructable")
	gravity_scale = 1.0
	mass = weight * 0.5
	body_entered.connect(_on_body_entered)
	
func _on_body_entered():
	var impact_velocity = linear_velocity.length()
	
	if impact_velocity > impact_damage_threshold:
		var damage_amount = (impact_velocity - impact_damage_threshold) * impact_damage_multiplier
		item_health -= damage_amount
		
		if item_health <= 0:
			destroy()
	
func get_weight() -> int:
	return weight
	
func get_value() -> int:
	return value
	
func get_item_name() -> String:
	return item_name
	
func destroy():
	item_destroyed.emit(item_name, value)
	if show_value_on_destroy:
		show_value_lost()
	queue_free()
	
func show_value_lost():
	if not value_label_scene:
		return
		
	var label = value_label_scene.instantiate()
	label.global_position = global_position
	get_parent().add_child(label)
	label.set_value(value)

func set_weight(new_weight: int):
	weight = new_weight
	mass = weight * 0.5

func set_value(new_value: int):
	value = new_value

func get_health() -> float:
	return item_health

func get_health_percent() -> float:
	return item_health / 100.0
