extends Control

func _draw() -> void:
	var outer := PackedVector2Array([Vector2(145, 290), Vector2(285, 205), Vector2(795, 205), Vector2(945, 290), Vector2(945, 540), Vector2(795, 635), Vector2(285, 635), Vector2(145, 540)])
	draw_colored_polygon(outer, Color("614e32"))
	var inner := PackedVector2Array([Vector2(162, 300), Vector2(291, 222), Vector2(789, 222), Vector2(928, 300), Vector2(928, 530), Vector2(789, 618), Vector2(291, 618), Vector2(162, 530)])
	draw_colored_polygon(inner, Color("123f34"))
	for x in range(185, 920, 24):
		for y in range(280, 580, 24):
			draw_rect(Rect2(x, y, 2, 2), Color("1a493b"))
