extends Weapon
class_name Pistol

var raycast: RayCast3D

func new_weapon():
	weapon_name = "meow"
	damage = 25
	fire_rate = 0.2
	weapon_range = 100.0
	ammo_capacity = -1
	beam_duration = 0.15
	beam_color = Color(0.3, 0.8, 1.0, 0.8)
	
	raycast = RayCast3D.new()
	raycast.target_position = Vector3(0, 0, -weapon_range)
	raycast.enabled = true
	add_child(raycast)
	
	setup_beam_visual()
	
func setup_beam_visual():
	beam_line = MeshInstance3D.new()
	var material = StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = beam_color
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	beam_line.material_override = material
	add_child(beam_line)
	beam_line.visible = false
	
func on_fire():
	raycast.force_raycast_update()
	
	var hit_point = Vector3.ZERO
	var hit_something = false
	
	if raycast.is_colliding():
		hit_point = to_local(raycast.get_collision_point())
		var target = raycast.get_collider()
		
		print("hit: " + str(target.name))
		
		if target.has_method("damage"):
			target.damage(damage)
			hit_something = true
		elif target.has_method("take_damage"):
			target.take_damage(damage)
			hit_something = true
		elif target.is_in_group("Destructable"):
			if target.has_method("destroy"):
				target.destroy()
			else:
				target.queue_free()
			hit_something = true
	else:
		hit_point = raycast.target_position
		
	show_beam(Vector3.ZERO, hit_point)
