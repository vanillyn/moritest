extends Entity
class_name Enemy

@export_group("Combat")
@export var attack_damage: int = 10
@export var attack_cooldown: float = 1.0

@export_group("Loot")
@export var health_orb_drop: PackedScene = preload("res://src/entity/health/health_orb_drop.tscn")
@export var is_boss: bool = false
@export var enemy_orb_drop: PackedScene = null

var player = null
var attack_timer: float = 0.0

func _ready():
	super._ready()
	add_to_group("Enemy")
	entity_type = "enemy"
	
func setup_entity():
	player = get_tree().get_first_node_in_group("Player")
	
func _physics_process(delta):
	if dead or not player:
		return
		
	apply_gravity(delta)
	move_towards_player(delta)
	handle_attack(delta)
	move_and_slide()
	
func move_towards_player(delta):
	var direction = (player.global_position - global_position).normalized()
	velocity.x = direction.x * movement_speed
	velocity.z = direction.z * movement_speed
	
func handle_attack(delta):
	if attack_timer > 0:
		attack_timer -= delta
		
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision.get_collider().is_in_group("Player"):
			attempt_attack()
			
func attempt_attack():
	if attack_timer <= 0 and player:
		player.take_damage(damage)
		attack_timer = attack_cooldown
		
func on_death():
	drop_loot()
	queue_free()
	
func drop_loot():
	if health_orb_drop:
		var orb = health_orb_drop.instantiate()
		orb.global_position = global_position
		get_parent().add_child(orb)
		
	if is_boss and enemy_orb_drop:
		var item = enemy_orb_drop.instantiate()
		item.global_position = global_position
		get_parent().add_child(item)
