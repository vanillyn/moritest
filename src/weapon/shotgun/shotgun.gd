extends Weapon
class_name Shotgun

@export var pellet_count: int = 8
@export var spread_angle: float = 15.0

var raycasts: Array[RayCast3D] = []

func new_weapon():
	weapon_name = "shotgun"
	damage = 15
	fire_rate = 0.8
	weapon_range = 50.0
	ammo_capacity = 6
	reload_time = 2.0
	beam_duration = 0.08
	beam_color = Color(1.0, 0.5, 0.0, 0.6)
	
	for i in range(pellet_count):
		var raycast = RayCast3D.new()
		raycast.target_position = Vector3(0, 0, -weapon_range)
		add_child(raycast)
		raycasts.append(raycast)
	
	beam_line = MeshInstance3D.new()
	var material = StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = beam_color
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	beam_line.material_override = material
	add_child(beam_line)
	beam_line.visible = false
	
func on_fire():
	var mesh = ImmediateMesh.new()
	mesh.surface_begin(Mesh.PRIMITIVE_LINES)
	
	var hit_targets = {}
	
	for raycast in raycasts:
		var spread_x = randf_range(-spread_angle, spread_angle)
		var spread_y = randf_range(-spread_angle, spread_angle)
		
		var spread_rad_x = deg_to_rad(spread_x)
		var spread_rad_y = deg_to_rad(spread_y)
		
		var direction = Vector3(0, 0, -weapon_range)
		direction = direction.rotated(Vector3.UP, spread_rad_x)
		direction = direction.rotated(Vector3.RIGHT, spread_rad_y)
		
		raycast.target_position = direction
		raycast.force_raycast_update()
		
		var hit_point = Vector3.ZERO
		if raycast.is_colliding():
			hit_point = to_local(raycast.get_collision_point())
			var target = raycast.get_collider()
			
			if target not in hit_targets:
				hit_targets[target] = 0
			hit_targets[target] += 1
		else:
			hit_point = direction
			
		mesh.surface_add_vertex(Vector3.ZERO)
		mesh.surface_add_vertex(hit_point)
	
	for target in hit_targets:
		var pellets_hit = hit_targets[target]
		if target.has_method("take_damage"):
			target.take_damage(damage * pellets_hit)
		elif target.is_in_group("Destructable"):
			if target.has_method("destroy"):
				target.destroy()
			else:
				target.queue_free()
	
	mesh.surface_end()
	beam_line.mesh = mesh
	beam_line.visible = true
	beam_timer = beam_duration
