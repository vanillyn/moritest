extends Weapon
class_name Knife

@export var melee_range: float = 2.5
@export var swing_arc: float = 60.0

var area: Area3D
var collision_shape: CollisionShape3D

func new_weapon():
	weapon_name = "knife"
	damage = 50
	fire_rate = 0.5
	weapon_range = melee_range
	ammo_capacity = -1
	beam_duration = 0.0
	
	area = Area3D.new()
	add_child(area)
	
	collision_shape = CollisionShape3D.new()
	var shape = BoxShape3D.new()
	shape.size = Vector3(2, 2, melee_range)
	collision_shape.shape = shape
	collision_shape.position = Vector3(0, 0, -melee_range / 2)
	area.add_child(collision_shape)
	
	collision_shape.disabled = true
	
func on_fire():
	collision_shape.disabled = false
	await get_tree().create_timer(0.1).timeout
	
	var bodies = area.get_overlapping_bodies()
	for body in bodies:
		if body.has_method("take_damage"):
			body.take_damage(damage)
		elif body.is_in_group("Destructable"):
			if body.has_method("destroy"):
				body.destroy()
			else:
				body.queue_free()
	
	collision_shape.disabled = true
