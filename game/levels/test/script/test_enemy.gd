extends CharacterBody3D

@export var speed: float = 4.0
@export var damage: int = 10
@export var cooldown: float = 1.0
@export var health: int = 50

var health_orb: PackedScene = preload("res://game/items/health_orb_drop.tscn")
var player = null
var attack_timer: float = 0.0

func _ready():
	player = get_tree().get_first_node_in_group("Player")
	
func _physics_process(delta):
	if player:
		var direction = (player.global_position - global_position).normalized()
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		
		move_and_slide()
		
		if attack_timer > 0:
			attack_timer -= delta
			
		for i in get_slide_collision_count():
			var collision = get_slide_collision(0)
			if collision.get_collider().is_in_group("Player"):
				attack_player()

func attack_player():
	if attack_timer <= 0 and player:
		player.take_damage(damage)
		attack_timer = cooldown
		
func take_damage(amount):
	health -= amount
	if health <= 0:
		die()
		
func die():
	var orb = health_orb.instantiate()
	orb.global_position = global_position
	get_parent().add_child(orb)
	
	queue_free()
