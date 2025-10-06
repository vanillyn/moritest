extends Node3D

@export var cart_capacity: int = 20
@export var detection_range: float = 2.0

var items_stored: Array = []
var total_value: int = 0
var detection_area: Area3D

func _ready():
	add_to_group("Cart")
	setup_detection_area()
	
func setup_detection_area():
	detection_area = Area3D.new()
	add_child(detection_area)
	
	var collision = CollisionShape3D.new()
	var shape = BoxShape3D.new()
	shape.size = Vector3(detection_range, detection_range, detection_range)
	collision.shape = shape
	detection_area.add_child(collision)
	
	detection_area.body_entered.connect(_on_body_entered)
	
func _on_body_entered(body):
	if body.is_in_group("Item") and items_stored.size() < cart_capacity:
		await get_tree().create_timer(0.1).timeout
		if is_instance_valid(body) and body.is_in_group("Item"):
			add_item(body)
		
func add_item(item):
	if item.has_method("get_value"):
		items_stored.append(item)
		total_value += item.get_value()
		print("added " + item.get_item_name() + " to cart. total value: " + str(total_value))
		item.queue_free()
		
func get_total_value() -> int:
	return total_value
	
func clear_cart():
	items_stored.clear()
	total_value = 0
