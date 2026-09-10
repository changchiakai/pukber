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
	draw_colored_polygon(outer, Color("614e32"))
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
	draw_colored_polygon(inner, Color("123f34"))
	for x in range(185, 920, 24):
		for y in range(280, 580, 24):
			draw_rect(Rect2(x + offset_x, y, 2, 2), Color("1a493b"))
