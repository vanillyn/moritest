extends Entity
class_name Enemy

enum State {
	IDLE,
	CHASE,
	ATTACK,
	RETREAT
}

@export_group("Combat")
@export var attack_damage: int = 10
@export var min_attack_distance: float = 15.0
@export var max_attack_distance: float = 30.0
@export var retreat_distance: float = 8.0
@export var weapon_scene: PackedScene = null

@export_group("AI")
@export var aim_offset_range: float = 2.0
@export var aim_update_interval: float = 0.5
@export var state_change_cooldown: float = 1.0

@export_group("Loot")
@export var health_orb_drop: PackedScene = preload("res://src/entity/health/health_orb_drop.tscn")
@export var is_boss: bool = false
@export var enemy_orb_drop: PackedScene = null

var player = null
var current_state: State = State.IDLE
var weapon: Weapon = null
var aim_target: Vector3 = Vector3.ZERO
var aim_timer: float = 0.0
var state_timer: float = 0.0

func _ready():
	super._ready()
	add_to_group("Enemy")
	entity_type = "enemy"
	
func new_entity():
	player = get_tree().get_first_node_in_group("Player")
	
	if weapon_scene:
		weapon = weapon_scene.instantiate()
		add_child(weapon)
	
func _physics_process(delta):
	if dead or not player:
		return
		
	apply_gravity(delta)
	update_ai_state(delta)
	execute_state(delta)
	move_and_slide()
	
func update_ai_state(delta):
	if state_timer > 0:
		state_timer -= delta
		return
		
	var distance = global_position.distance_to(player.global_position)
	var old_state = current_state
	
	if distance < retreat_distance:
		current_state = State.RETREAT
	elif distance < min_attack_distance:
		current_state = State.ATTACK
	elif distance < max_attack_distance:
		if randf() < 0.7:
			current_state = State.ATTACK
		else:
			current_state = State.CHASE
	else:
		current_state = State.CHASE
		
	if old_state != current_state:
		state_timer = state_change_cooldown
		
func execute_state(delta):
	match current_state:
		State.IDLE:
			velocity.x = 0
			velocity.z = 0
			
		State.CHASE:
			move_towards_player()
			update_aim(delta)
			
		State.ATTACK:
			velocity.x = 0
			velocity.z = 0
			update_aim(delta)
			look_at_player()
			attempt_fire()
			
		State.RETREAT:
			move_away_from_player()
			update_aim(delta)
			
func move_towards_player():
	var direction = (player.global_position - global_position).normalized()
	velocity.x = direction.x * movement_speed
	velocity.z = direction.z * movement_speed
	
func move_away_from_player():
	var direction = (global_position - player.global_position).normalized()
	velocity.x = direction.x * movement_speed * 0.7
	velocity.z = direction.z * movement_speed * 0.7
	
func look_at_player():
	var target_pos = player.global_position
	target_pos.y = global_position.y
	look_at(target_pos, Vector3.UP)
	
func update_aim(delta):
	aim_timer -= delta
	
	if aim_timer <= 0:
		var offset = Vector3(
			randf_range(-aim_offset_range, aim_offset_range),
			randf_range(-aim_offset_range * 0.5, aim_offset_range * 0.5),
			randf_range(-aim_offset_range, aim_offset_range)
		)
		aim_target = player.global_position + offset
		aim_timer = aim_update_interval
		
	if weapon:
		weapon.look_at(aim_target, Vector3.UP)
		
func attempt_fire():
	if weapon and weapon.can_fire and not weapon.is_reloading:
		weapon.attempt_fire()
		
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
