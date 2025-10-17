extends RayCast3D

signal item_picked_up(item)
signal item_released(item)

@export var beam_range: float = 5.0
@export var beam_strength: int = 1
@export var rotation_sensitivity: float = 0.003
@export var pull_strength: float = 15.0
@export var min_hold_distance: float = 1.5
@export var max_hold_distance: float = 8.0
@export var scroll_speed: float = 0.3

var held_item: RigidBody3D = null
var hold_distance: float = 3.0
var target_hold_distance: float = 3.0
var weight_ratio: float = 1.0
var rotating: bool = false
var accumulated_rotation: Vector2 = Vector2.ZERO

func _ready():
	target_position = Vector3(0, 0, -beam_range)
	
func _input(event):
	if event.is_action_pressed("acg"):
		try_pickup()
	elif event.is_action_released("acg"):
		release_item()
		
	if event.is_action_pressed("aci") and held_item:
		rotating = true
		accumulated_rotation = Vector2.ZERO
	elif event.is_action_released("aci"):
		rotating = false
		
	if rotating and event is InputEventMouseMotion:
		accumulated_rotation += event.relative
		
	if held_item:
		if event.is_action_pressed("acsu"):
			adjust_distance(-scroll_speed)
		elif event.is_action_pressed("acsd"):
			adjust_distance(scroll_speed)
		
func _physics_process(delta):
	if not held_item or not is_instance_valid(held_item):
		held_item = null
		return
		
	if held_item.is_in_group("Item"):
		held_item.remove_from_group("Item")
		
	var distance_change_speed = 5.0 * weight_ratio
	hold_distance = lerp(hold_distance, target_hold_distance, distance_change_speed * delta)
		
	var target_pos = global_position + (-global_transform.basis.z * hold_distance)
	
	var item_weight = held_item.get_weight() if held_item.has_method("get_weight") else 1
	weight_ratio = clamp(float(beam_strength) / float(item_weight), 0.1, 1.0)
	
	var actual_target = target_pos
	if weight_ratio < 1.0:
		var sag_amount = (1.0 - weight_ratio) * 2.0
		actual_target.y -= sag_amount
	
	var direction = (actual_target - held_item.global_position)
	var distance = direction.length()
	
	if distance > 0.1:
		direction = direction.normalized()
		var force_mult = pull_strength * weight_ratio * distance
		held_item.linear_velocity = direction * force_mult
	else:
		held_item.linear_velocity = held_item.linear_velocity.lerp(Vector3.ZERO, 10 * delta)
	
	held_item.linear_velocity *= 0.9
	
	if rotating and accumulated_rotation.length() > 0:
		var rotation_mult = weight_ratio
		var torque = Vector3(
			-accumulated_rotation.y * rotation_sensitivity * rotation_mult * 50,
			-accumulated_rotation.x * rotation_sensitivity * rotation_mult * 50,
			0
		)
		held_item.apply_torque(torque)
		accumulated_rotation = Vector2.ZERO
	else:
		held_item.angular_velocity *= 0.8
		
	if weight_ratio < 1.0:
		var extra_gravity = (1.0 - weight_ratio) * 9.8
		held_item.apply_central_force(Vector3.DOWN * extra_gravity * held_item.mass)
			
func try_pickup():
	if held_item:
		return
		
	force_raycast_update()
	
	if is_colliding():
		var target = get_collider()
		
		if target is RigidBody3D and target.has_method("get_weight"):
			pickup_item(target)
				
func pickup_item(item: RigidBody3D):
	held_item = item
	hold_distance = global_position.distance_to(item.global_position)
	target_hold_distance = clamp(hold_distance, min_hold_distance, max_hold_distance)
	
	var item_weight = item.get_weight() if item.has_method("get_weight") else 1
	weight_ratio = clamp(float(beam_strength) / float(item_weight), 0.1, 1.0)
	
	held_item.gravity_scale = 0.2 * (1.0 - weight_ratio)
	held_item.linear_damp = 2.0
	held_item.angular_damp = 2.0
	
	item_picked_up.emit(item)
	
func adjust_distance(amount: float):
	if held_item:
		var adjusted_amount = amount * weight_ratio
		target_hold_distance = clamp(target_hold_distance + adjusted_amount, min_hold_distance, max_hold_distance)
		
func release_item():
	if not held_item:
		return
		
	if not held_item.is_in_group("Item"):
		held_item.add_to_group("Item")

	held_item.gravity_scale = 1.0
	held_item.linear_damp = 0.1
	held_item.angular_damp = 0.1
	
	item_released.emit(held_item)
	held_item = null
	weight_ratio = 1.0
	rotating = false

func is_rotating() -> bool:
	return rotating

func is_holding() -> bool:
	return held_item != null

func get_held_item() -> RigidBody3D:
	return held_item

func get_hold_strength() -> float:
	return weight_ratio
