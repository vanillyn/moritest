extends Node3D

@export var cart: PackedScene = preload("res://src/entity/item/cart/valuable_container.tscn")
@export var spawn_distance: float = 2.0
@export var pickup_range: float = 3.0

var cart_instance = null
var player = null

func _ready():
	player = get_parent()
	
func _input(event):
	if event.is_action_pressed("acm"):
		toggle_cart()
		
func toggle_cart():
	if cart_instance == null:
		summon_cart()
	else:
		try_to_pick_up_cart()

func summon_cart():
	if cart:
		cart_instance = cart.instantiate()
		var spawn_pos = player.global_position + (-player.global_transform.basis.z * spawn_distance)
		cart_instance.global_position = spawn_pos
		
		get_tree().root.add_child(cart_instance)
		
func try_to_pick_up_cart():
	if cart_instance:
		var distance = player.global_position.distance_to(cart_instance.global_position)
		
		if distance <= pickup_range:
			if cart_instance.has_method("transfer_to_player"):
				cart_instance.transfer_to_player()
			cart_instance.queue_free()
			cart_instance = null
		else:
			print("cart too far away meow")
