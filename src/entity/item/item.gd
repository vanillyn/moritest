extends RigidBody3D
class_name Item

@export var item_name: String = "item"
@export var weight: int = 1
@export var value: int = 500
@export var fragility: float = 1.0
@export var damage_threshold: float = 3.0
@export var is_indestructable: bool = false

var initial_value: int = 500
var value_label_scene: PackedScene = preload("res://src/entity/item/valuables/value_label.tscn")
var last_collision_time: float = 0.0
var collision_cooldown: float = 0.1

func _ready():
	add_to_group("Item")
	if not is_indestructable:
		add_to_group("Destructable")
	gravity_scale = 1.0
	mass = weight * 0.5
	initial_value = value
	
	body_entered.connect(_on_body_collision)
	
func _on_body_collision(body):
	if is_indestructable:
		return
		
	var current_time = Time.get_ticks_msec() / 1000.0
	if current_time - last_collision_time < collision_cooldown:
		return
		
	var impact_velocity = linear_velocity.length()
	
	if impact_velocity > damage_threshold:
		var damage_amount = int((impact_velocity - damage_threshold) * fragility * 100)
		take_damage(damage_amount)
		last_collision_time = current_time
	
func take_damage(amount: int):
	if is_indestructable or amount <= 0:
		return
		
	value = max(0, value - amount)
	show_value_lost(amount)
	
	var value_percentage = float(value) / float(initial_value)
	if value_percentage <= 0.1:
		destroy()
	
func get_weight() -> int:
	return weight
	
func get_value() -> int:
	return value
	
func get_item_name() -> String:
	return item_name
	
func destroy():
	if is_indestructable:
		return
		
	if value > 0:
		show_value_lost(value)
	queue_free()
	
func show_value_lost(amount: int):
	if value_label_scene and amount > 0:
		var label = value_label_scene.instantiate()
		label.global_position = global_position
		get_parent().add_child(label)
		label.set_value(amount)
