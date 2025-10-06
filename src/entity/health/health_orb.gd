extends Area3D

@export var heal_amount: int = 15
@export var speed: float = 7.0
@export var range_detection: float = 10.0

var player = null
var moving: bool = false

func _ready():
	body_entered.connect(_on_body_entered)
	player = get_tree().get_first_node_in_group("Player")
	
func _process(delta):
	if player:
		var distance = global_position.distance_to(player.global_position)
		
		if distance < range_detection:
			moving = true
			
			if moving: 
				var direction = (player.global_position - global_position).normalized()
				global_position += direction * speed * delta
				
func _on_body_entered(body):
	if body.is_in_group("Player"):
		body.heal(heal_amount)
		queue_free()
