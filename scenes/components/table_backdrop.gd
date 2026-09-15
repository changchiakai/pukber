extends Control

func _draw() -> void:
	var offset_x := size.x * 0.5 - 545.0
	var shift := Vector2(offset_x, 0)
	var outer := PackedVector2Array([
		Vector2(145, 290) + shift,
		Vector2(285, 205) + shift,
		Vector2(795, 205) + shift,
		Vector2(945, 290) + shift,
		Vector2(945, 540) + shift,
		Vector2(795, 635) + shift,
		Vector2(285, 635) + shift,
		Vector2(145, 540) + shift
	])
	# Layered rail, rim and felt make the table readable without obscuring play state.
	draw_colored_polygon(outer, Color("1d1510"))
	draw_polyline(outer + PackedVector2Array([outer[0]]), Color("07090a"), 12.0, true)
	draw_polyline(outer + PackedVector2Array([outer[0]]), Color("d0a652"), 3.0, true)
	var inner := PackedVector2Array([
		Vector2(162, 300) + shift,
		Vector2(291, 222) + shift,
		Vector2(789, 222) + shift,
		Vector2(928, 300) + shift,
		Vector2(928, 530) + shift,
		Vector2(789, 618) + shift,
		Vector2(291, 618) + shift,
		Vector2(162, 530) + shift
	])
	draw_colored_polygon(inner, Color("0a473b"))
	draw_polyline(inner + PackedVector2Array([inner[0]]), Color("328c70"), 2.0, true)
	draw_arc(Vector2(size.x * 0.5, 420), 186, 0.0, TAU, 96, Color("5fbb91", 0.16), 1.0, true)
	for x in range(185, 920, 24):
		for y in range(280, 580, 24):
			draw_circle(Vector2(x + offset_x, y), 1.2, Color("16705b"))
	var centre := Vector2(size.x * 0.5, 420)
	draw_circle(centre, 134, Color("031a19", 0.27))
	draw_arc(centre, 128, 0.0, TAU, 64, Color("d0a652", 0.44), 1.5, true)
	draw_arc(centre, 134, 0.0, TAU, 64, Color("2d8b70", 0.62), 2.0, true)
	draw_arc(centre, 138, 0.0, TAU, 64, Color("071d20", 0.8), 1.0, true)
