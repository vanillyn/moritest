extends Entity
class_name Player

@export_group("Movement")
@export var walk_speed: float = 5.0
@export var dash_speed: float = 12.0
@export var dash_duration: float = 0.3
@export var dash_cooldown: float = 1.0
@export var jump_velocity: float = 4.5

@export_group("Beam")
@export var beam_strength: int = 1
@export var beam_range: float = 5.0

@export_group("Combat")
@export var health_drain_per_second: float = 2.0
@export var damage_drain_duration: float = 3.0

@export_group("Inventory")
@export var max_inv: int = 3

@onready var view: Camera3D = $Pivot/View
@onready var collision_shape: CollisionShape3D = $PlayerCollision

var inv: Array = []
var mouse_sens: float = 0.002

var is_dashing: bool = false
var dash_timer: float = 0.0
var dash_cooldown_timer: float = 0.0
var dash_direction: Vector3 = Vector3.ZERO

var damage_drain_timer: float = 0.0
var damage_accumulator: float = 0.0

func _ready():
	super._ready()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	add_to_group("Player")
	entity_type = "player"

func _input(event):
	if event is InputEventMouseMotion:
		var hand = $Pivot/View/Hand
		if hand and hand.has_method("is_rotating") and hand.is_rotating():
			return
			
		rotate_y(-event.relative.x * mouse_sens)
		view.rotate_x(-event.relative.y * mouse_sens)
		view.rotation.x = clamp(view.rotation.x, -PI/2, PI/2)

func _physics_process(delta):
	handle_constant_drain(delta)
	handle_damage_drain(delta)
	handle_movement(delta)
	move_and_slide()
	
func handle_constant_drain(delta):
	damage_accumulator += health_drain_per_second * delta
	
	if damage_accumulator >= 1.0:
		var damage_to_deal = int(damage_accumulator)
		damage(damage_to_deal)
		damage_accumulator -= damage_to_deal
	
func handle_damage_drain(delta):
	if damage_drain_timer > 0:
		damage_drain_timer -= delta
	
func handle_movement(delta):
	apply_gravity(delta)
	
	var input_dir = Input.get_vector("mvl", "mvr", "mvf", "mvb")
	var move_dir = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if dash_cooldown_timer > 0:
		dash_cooldown_timer -= delta
	
	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false
		else:
			velocity.x = dash_direction.x * dash_speed
			velocity.z = dash_direction.z * dash_speed
			return
	
	if Input.is_action_just_pressed("mvdash") and is_on_floor() and move_dir.length() > 0 and dash_cooldown_timer <= 0:
		start_dash(move_dir)
		return
	
	if Input.is_action_just_pressed("mvj") and is_on_floor():
		velocity.y = jump_velocity
	
	if move_dir:
		velocity.x = move_dir.x * walk_speed
		velocity.z = move_dir.z * walk_speed
	else:
		velocity.x = move_toward(velocity.x, 0, walk_speed)
		velocity.z = move_toward(velocity.z, 0, walk_speed)

func start_dash(direction: Vector3):
	is_dashing = true
	dash_timer = dash_duration
	dash_cooldown_timer = dash_cooldown
	dash_direction = direction
	
func damage(amount: int):
	super.damage(amount)
	if not dead and amount > 0:
		damage_drain_timer = damage_drain_duration
	
func take(item):
	if inv.size() < max_inv:
		inv.append(item)
		
func on_death():
	health = max_health
	damage_drain_timer = 0.0
	damage_accumulator = 0.0
	position = Vector3(3, 3, 3)
	dead = false

func get_inventory() -> Array:
	return inv

func get_inventory_size() -> int:
	return inv.size()

func get_max_inventory() -> int:
	return max_inv

func is_inventory_full() -> bool:
	return inv.size() >= max_inv
