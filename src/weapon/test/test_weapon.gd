extends RayCast3D

@export var damage: int = 25
@export var weapon_range: float = 100.0
@export var fire_rate: float = 0.15
@export var beam_duration: float = 0.05

var can_fire: bool = true
var fire_timer: float = 0.0
var beam_line: MeshInstance3D
var beam_timer: float = 0.0

func _ready():
	self.target_position = Vector3(0, 0, -weapon_range)
	setup_beam()
	
func setup_beam():
	beam_line = MeshInstance3D.new()
	var mesh = ImmediateMesh.new()
	beam_line.mesh = mesh
	
	var material = StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color(1, 0.3, 0.1, 0.8)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	beam_line.material_override = material
	
	add_child(beam_line)
	beam_line.visible = false
	
func _input(event):
	if event.is_action_pressed("acf") and can_fire:
		fire()
		
func _process(delta):
	if fire_timer > 0:
		fire_timer -= delta
		if fire_timer <= 0:
			can_fire = true
			
	if beam_timer > 0:
		beam_timer -= delta
		if beam_timer <= 0:
			beam_line.visible = false
		
func fire():
	can_fire = false
	fire_timer = fire_rate
	
	self.force_raycast_update()
	
	var hit_point = Vector3.ZERO
	if self.is_colliding():
		hit_point = to_local(self.get_collision_point())
		var target = self.get_collider()
		
		if target.has_method("damage"):
			target.damage(damage)
		elif target.is_in_group("Destructable"):
			if target.has_method("destroy"):
				target.destroy()
			else:
				target.queue_free()
	else:
		hit_point = target_position
		
	show_beam(hit_point)
	
func show_beam(end_point: Vector3):
	var mesh = ImmediateMesh.new()
	mesh.surface_begin(Mesh.PRIMITIVE_LINES)
	mesh.surface_add_vertex(Vector3.ZERO)
	mesh.surface_add_vertex(end_point)
	mesh.surface_end()
	
	beam_line.mesh = mesh
	beam_line.visible = true
	beam_timer = beam_duration
