extends Control

@export var crosshair_size: int = 20
@export var crosshair_thickness: int = 2
@export var crosshair_gap: int = 5
@export var crosshair_color: Color = Color(1, 1, 1, 0.8)

func _ready():
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	
func _draw():
	var center = size / 2

	draw_line(
		Vector2(center.x, center.y - crosshair_gap - crosshair_size),
		Vector2(center.x, center.y - crosshair_gap),
		crosshair_color,
		crosshair_thickness
	)

	draw_line(
		Vector2(center.x, center.y + crosshair_gap),
		Vector2(center.x, center.y + crosshair_gap + crosshair_size),
		crosshair_color,
		crosshair_thickness
	)
	
	draw_line(
		Vector2(center.x - crosshair_gap - crosshair_size, center.y),
		Vector2(center.x - crosshair_gap, center.y),
		crosshair_color,
		crosshair_thickness
	)
	
	draw_line(
		Vector2(center.x + crosshair_gap, center.y),
		Vector2(center.x + crosshair_gap + crosshair_size, center.y),
		crosshair_color,
		crosshair_thickness
	)
