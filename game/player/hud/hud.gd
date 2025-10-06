extends Control

@onready var health_bar: ProgressBar = $Health
@onready var inv_container: HBoxContainer = $InvContainer

var player = null
var inv_slots: Array = []
var item_mesh: Array = []

func _ready():
	player = get_parent()
	get_inventory()

func get_inventory():
	for i in range(player.max_inv):
		var slot = create_slot()
		inv_container.add_child(slot)
		inv_slots.append(slot)
		item_mesh.append(null)
		
func create_slot():
	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(80, 80)
	
	var viewport_container = SubViewportContainer.new()
	viewport_container.stretch = true
	panel.add_child(viewport_container)
	
	var viewport = SubViewport.new()
	viewport.size = Vector2(80, 80)
	viewport.transparent_bg = true
	viewport_container.add_child(viewport)
	
	var camera = Camera3D.new()
	camera.position = Vector3(0,0,2)
	viewport.add_child(camera)
	
	var light = DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-45, 45, 0)
	viewport.add_child(light)
	
	return panel

func _process(delta):
	if player:
		health_bar.value = (float(player.health) / float(player.max_health)) * 100
		_update(delta)

func _update(delta):
	for i in range(inv_slots.size()):
		var slot = inv_slots[i]
		var viewport = slot.get_child(0).get_child(0)
		
		if i < player.inv.size():
			if item_mesh[i] == null:
				var mesh = MeshInstance3D.new()
				mesh.mesh = BoxMesh.new()
				viewport.add_child(mesh)
				item_mesh[i] = mesh
			if item_mesh[i]:
				item_mesh[i].rotate_y(delta * 2)
			else:
				if item_mesh[i] != null:
					item_mesh[i].queue_free()
					item_mesh[i] = null
	
