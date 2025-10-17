extends Node3D
class_name Weapon

signal weapon_fired
signal weapon_reloaded
signal ammo_changed(current, max)

@export_group("Weapon")
@export var weapon_name: String = "weapon"
@export var damage: int = 25
@export var fire_rate: float = 0.15
@export var weapon_range: float = 100.0
@export var ammo_capacity: int = -1
@export var reload_time: float = 1.0
@export var auto_reload: bool = false

@export_group("Visual")
@export var beam_duration: float = 0.05
@export var beam_color: Color = Color(1, 0.3, 0.1, 0.8)
@export var beam_width: float = 0.05

var current_ammo: int = -1
var can_fire: bool = true
var is_reloading: bool = false
var fire_timer: float = 0.0
var reload_timer: float = 0.0
var beam_line: MeshInstance3D
var beam_timer: float = 0.0

func _ready():
	if ammo_capacity > 0:
		current_ammo = ammo_capacity
	new_weapon()
	
func new_weapon():
	pass
	
func _process(delta):
	if fire_timer > 0:
		fire_timer -= delta
		if fire_timer <= 0:
			can_fire = true
			
	if is_reloading:
		reload_timer -= delta
		if reload_timer <= 0:
			finish_reload()
			
	if beam_timer > 0:
		beam_timer -= delta
		if beam_timer <= 0 and beam_line:
			beam_line.visible = false
		
func _input(event):
	if event.is_action_pressed("acf") and can_fire and not is_reloading:
		attempt_fire()
	elif event.is_action_pressed("acr") and can_reload():
		start_reload()
		
func attempt_fire():
	if ammo_capacity > 0 and current_ammo <= 0:
		if auto_reload and can_reload():
			start_reload()
		return
		
	fire()
	
	if ammo_capacity > 0:
		current_ammo -= 1
		ammo_changed.emit(current_ammo, ammo_capacity)
	
func fire():
	can_fire = false
	fire_timer = fire_rate
	weapon_fired.emit()
	on_fire()
	
func on_fire():
	pass
	
func start_reload():
	if is_reloading or (ammo_capacity > 0 and current_ammo >= ammo_capacity):
		return
		
	is_reloading = true
	reload_timer = reload_time
	can_fire = false
	
func finish_reload():
	is_reloading = false
	current_ammo = ammo_capacity
	can_fire = true
	weapon_reloaded.emit()
	ammo_changed.emit(current_ammo, ammo_capacity)
	
func can_reload() -> bool:
	return ammo_capacity > 0 and current_ammo < ammo_capacity and not is_reloading
	
func show_beam(start: Vector3, end: Vector3):
	if not beam_line:
		return
		
	var mesh = ImmediateMesh.new()
	mesh.surface_begin(Mesh.PRIMITIVE_LINES)
	mesh.surface_add_vertex(start)
	mesh.surface_add_vertex(end)
	mesh.surface_end()
	
	beam_line.mesh = mesh
	beam_line.visible = true
	beam_timer = beam_duration

func get_ammo() -> int:
	return current_ammo

func get_max_ammo() -> int:
	return ammo_capacity

func get_ammo_percent() -> float:
	if ammo_capacity <= 0:
		return 1.0
	return float(current_ammo) / float(ammo_capacity)

func is_ready() -> bool:
	return can_fire and not is_reloading

func get_reload_progress() -> float:
	if not is_reloading:
		return 1.0
	return 1.0 - (reload_timer / reload_time)
