extends RayCast3D

@export var damage: int = 25
@export var weapon_range: float = 100.0

func _ready():
	self.target_position = Vector3(0, 0, -weapon_range)
	
func _input(event):
	if event.is_action_pressed("acf"):
		fire()
		
func fire():
	self.force_raycast_update()
	
	if self.is_colliding():
		var target = self.get_collider()
		
		if target.has_method("take_damage"):
			target.take_damage(damage)
		elif target.is_in_group("Destructable"):
			target.queue_free()
	
