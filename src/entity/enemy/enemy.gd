extends Entity
class_name Enemy

@export_group("Combat")
@export var attack_damage: int = 10
@export var attack_cooldown: float = 1.0
@export var attack_range: float = 1.5

@export_group("Loot")
@export var health_orb_drop: PackedScene = preload("res://src/entity/health/health_orb_drop.tscn")
@export var is_boss: bool = false
@export var enemy_orb_drop: PackedScene = null
@export var drop_chance: float = 1.0

var player: Player = null
var attack_timer: float = 0.0

func _ready():
	super._ready()
	add_to_group("Enemy")
	entity_type = "enemy"
	
func new_entity():
	player = get_tree().get_first_node_in_group("Player") as Player
	
func _physics_process(delta):
	if dead or not player:
		return
		
	apply_gravity(delta)
	move_towards_player(delta)
	handle_attack(delta)
	move_and_slide()
	
func move_towards_player(_delta):
	var direction = (player.global_position - global_position).normalized()
	velocity.x = direction.x * movement_speed
	velocity.z = direction.z * movement_speed
	
func handle_attack(delta):
	if attack_timer > 0:
		attack_timer -= delta
	
	var distance_to_player = global_position.distance_to(player.global_position)
	if distance_to_player <= attack_range:
		attempt_attack()
			
func attempt_attack():
	if attack_timer <= 0 and player and not player.is_dead():
		player.damage(attack_damage)
		attack_timer = attack_cooldown
		
func on_death():
	drop_loot()
	queue_free()
	
func drop_loot():
	if randf() > drop_chance:
		return
		
	if health_orb_drop:
		var orb = health_orb_drop.instantiate()
		orb.global_position = global_position + Vector3(0, 0.5, 0)
		get_parent().add_child(orb)
		
	if is_boss and enemy_orb_drop:
		var item = enemy_orb_drop.instantiate()
		item.global_position = global_position + Vector3(0, 0.5, 0)
		get_parent().add_child(item)

func get_player() -> Player:
	return player

func is_attacking() -> bool:
	return attack_timer > 0
