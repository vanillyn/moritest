extends CharacterBody3D
class_name Entity

signal health_changed(new_health, max_health)
signal died

@export_group("Entity")
@export var max_health: int = 100
@export var movement_speed: float = 5.0
@export var entity_type: String = "entity"

var health: int = 100
var dead: bool = false
var g: float = 9.8

func _ready():
	health = max_health
	new_entity()
	
func new_entity():
	pass
	
func damage(amount: int):
	if dead: 
		return
	
	health -= amount
	health_changed.emit(health, max_health)
	
	if health <= 0:
		die()
		
func heal(amount: int):
	if dead:
		return
	
	health = min(health + amount, max_health)
	health_changed.emit(health, max_health)
	
func die():
	

	if dead:
		return
	
	dead = true
	died.emit()
	_on_death()

func _on_death():
	queue_free()

func apply_gravity(delta: float):
	if not is_on_floor():
		velocity.y -= g * delta
