extends RigidBody3D

@export var cart_capacity: int = 20
@export var detection_range: float = 2.0
@export var weight: int = 2

var items_stored: Array = []
var total_value: int = 0
var detection_area: Area3D
var player = null

func _ready():
	add_to_group("Item")
	add_to_group("Cart")
	player = get_tree().get_first_node_in_group("Player")
	setup_detection_area()
	
	gravity_scale = 1.0
	mass = weight * 0.5
	
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
	if body.is_in_group("Item") and not body.is_in_group("Cart") and items_stored.size() < cart_capacity:
		await get_tree().create_timer(0.1).timeout
		if is_instance_valid(body) and body.is_in_group("Item") and not body.is_in_group("Cart"):
			add_item(body)
		
func add_item(item):
	if item.has_method("get_value"):
		items_stored.append({
			"name": item.get_item_name(),
			"value": item.get_value()
		})
		total_value += item.get_value()
		
		print("added " + item.get_item_name() + " to cart. total value: " + str(total_value))
		item.queue_free()
		
func get_total_value() -> int:
	return total_value
	
func clear_cart():
	items_stored.clear()
	total_value = 0
	
func get_weight() -> int:
	return weight
	
func transfer_to_player():
	if player:
		for item in items_stored:
			player.take(item["name"])
		print("transferred " + str(items_stored.size()) + " items to player inventory")
		clear_cart()
