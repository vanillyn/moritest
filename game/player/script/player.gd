extends CharacterBody3D

@export var speed: float = 5.0
@export var jump_vol: float = 4.5

@export var attacked_rate: float = 4.0
@export var damage_rate: float = 2.0
@export var attacked_dur: float = 3.0

var g: float = 9.8
var max_health: int = 100
var health: int = 100
var max_inv: int = 3
var inv: Array = []
var health_drain_time: float = 0.0

@onready var view: Camera3D = $Pivot/View
@export var mouse_sens: float = 0.002

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sens)
		view.rotate_x(-event.relative.y * mouse_sens)
		view.rotation.x = clamp(view.rotation.x, -PI/2, PI/2)

func _physics_process(delta):
	var loss = damage_rate
	
	if health_drain_time > 0:
		loss += attacked_rate
		health_drain_time -= delta

	if health <= 0:
		die()
		
	if not is_on_floor():
		velocity.y -= g * delta
		
	if Input.is_action_just_pressed("mvj") and is_on_floor():
		velocity.y = jump_vol
		
	var direction = Input.get_vector("mvl", "mvr", "mvf", "mvb")
	var move = (transform.basis * Vector3(direction.x, 0, direction.y)).normalized()
	
	if move:
		velocity.x = move.x * speed
		velocity.z = move.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
		
	move_and_slide()
	
func take_damage(amount):
	health -= amount
	health_drain_time = attacked_dur
	if health <= 0:
		die()
		
func heal(amount):
	health = min(health + amount, max_health)
	
func take(item):
	inv.append(item)
	print(inv)
	
func die():
	health = max_health
	health_drain_time = 0.0
	position = Vector3.ZERO
