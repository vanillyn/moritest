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
@export var damage_rate: float = 2.0
@export var damage_over_time_duration: float = 3.0

@export_group("Inventory")
@export var max_inv: int = 3

@onready var view: Camera3D = $Pivot/View
@onready var collision_shape: CollisionShape3D = $PlayerCollision

var inv: Array = []
var health_drain_time: float = 0.0
var current_damage_rate: float = 0.0
var mouse_sens: float = 0.002

var is_dashing: bool = false
var dash_timer: float = 0.0
var dash_cooldown_timer: float = 0.0
var dash_direction: Vector3 = Vector3.ZERO

func _ready():
	super._ready()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	add_to_group("Player")
	entity_type = "player"

func _input(event):
	if event is InputEventMouseMotion:
		var hand = $Pivot/View/Hand
		if hand and hand.is_rotating():
			return
			
		rotate_y(-event.relative.x * mouse_sens)
		view.rotate_x(-event.relative.y * mouse_sens)
		view.rotation.x = clamp(view.rotation.x, -PI/2, PI/2)

func _physics_process(delta):
	handle_damage_over_time(delta)
	handle_movement(delta)
	move_and_slide()
	
func handle_damage_over_time(delta):
	if health_drain_time > 0:
		health_drain_time -= delta
		damage(int(current_damage_rate * delta))
		
		if health_drain_time <= 0:
			current_damage_rate = 0.0
	
func handle_movement(delta):
	apply_gravity(delta)
	
	var input_dir = Input.get_vector("mvl", "mvr", "mvf", "mvb")
	var move_dir = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	# handle dash cooldown
	if dash_cooldown_timer > 0:
		dash_cooldown_timer -= delta
	
	# handle dashing
	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false
		else:
			velocity.x = dash_direction.x * dash_speed
			velocity.z = dash_direction.z * dash_speed
			return
	
	# check for dash input
	if Input.is_action_just_pressed("mvdash") and is_on_floor() and move_dir.length() > 0 and dash_cooldown_timer <= 0:
		start_dash(move_dir)
		return
	
	# handle jump
	if Input.is_action_just_pressed("mvj") and is_on_floor():
		velocity.y = jump_velocity
	
	# apply movement
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
	current_damage_rate = damage_rate
	health_drain_time = damage_over_time_duration
	
func take(item):
	if inv.size() < max_inv:
		inv.append(item)
		print("picked up: " + str(item))
		
func on_death():
	health = max_health
	health_drain_time = 0.0
	current_damage_rate = 0.0
	position = Vector3.ZERO
	dead = false
