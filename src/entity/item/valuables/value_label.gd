extends Node3D

@export var lifetime: float = 2.0
@export var float_speed: float = 1.0

var label: Label3D
var timer: float = 0.0

func _ready():
	label = Label3D.new()
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = true
	label.modulate = Color(1, 0.2, 0.2, 1)
	label.outline_size = 8
	label.outline_modulate = Color(0, 0, 0, 1)
	add_child(label)
	
func set_value(val: int):
	label.text = "-$" + str(val)
	
func _process(delta):
	timer += delta
	position.y += float_speed * delta
	
	var alpha = 1.0 - (timer / lifetime)
	label.modulate.a = alpha
	
	if timer >= lifetime:
		queue_free()
