class_name PokerUI
extends RefCounted

const BG := Color("06131c")
const PANEL := Color("102532")
const PANEL_ELEVATED := Color("163443")
const TEXT := Color("f3f5ef")
const MUTED := Color("aec3c5")
const GOLD := Color("f0c56b")
const GOLD_DIM := Color("9d7738")
const GREEN := Color("16745f")
const GREEN_BRIGHT := Color("249879")
const DANGER := Color("9f3946")
const UI_FONT: FontFile = preload("res://Iansui-Regular.ttf")

static func install(root: Control) -> void:
	var scale := ui_scale(root)
	var theme := Theme.new()
	# Embed the Chinese font in exported builds instead of relying on browser/OS fonts.
	theme.default_font = UI_FONT
	theme.default_font_size = scaled_font_size(root, 18)
	theme.set_color("font_color", "Label", TEXT)
	theme.set_color("font_color", "Button", TEXT)
	theme.set_color("font_color", "OptionButton", TEXT)
	theme.set_color("font_color", "SpinBox", TEXT)
	theme.set_color("font_color", "LineEdit", TEXT)
	theme.set_color("font_disabled_color", "Button", Color("83918c"))
	theme.set_color("font_color", "RichTextLabel", TEXT)
	theme.set_stylebox("normal", "Button", box(PANEL_ELEVATED, Color("2f5360"), 1, 10))
	theme.set_stylebox("hover", "Button", box(Color("1b4a55"), GOLD, 2, 10))
	theme.set_stylebox("pressed", "Button", box(GREEN, GOLD, 2, 10))
	theme.set_stylebox("focus", "Button", focus_box())
	theme.set_stylebox("disabled", "Button", box(Color("10202a"), Color("263b43"), 1, 10))
	theme.set_stylebox("normal", "OptionButton", box(PANEL_ELEVATED, Color("365c67"), 1, 8))
	theme.set_stylebox("hover", "OptionButton", box(Color("1a4752"), GOLD, 1, 8))
	theme.set_stylebox("normal", "SpinBox", box(PANEL_ELEVATED, Color("365c67"), 1, 8))
	theme.set_stylebox("normal", "LineEdit", box(PANEL_ELEVATED, Color("365c67"), 1, 8))
	theme.set_constant("h_separation", "HBoxContainer", int(round(10 * scale)))
	root.theme = theme
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var backdrop := TextureRect.new()
	backdrop.texture = background_texture()
	backdrop.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	backdrop.stretch_mode = TextureRect.STRETCH_SCALE
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(backdrop)
	var vignette := TextureRect.new()
	vignette.texture = vignette_texture()
	vignette.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	vignette.stretch_mode = TextureRect.STRETCH_SCALE
	vignette.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(vignette)

static func background_texture() -> GradientTexture2D:
	var gradient := Gradient.new()
	gradient.offsets = PackedFloat32Array([0.0, 0.48, 1.0])
	gradient.colors = PackedColorArray([Color("06131c"), Color("0a202a"), Color("061018")])
	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	texture.width = 1440
	texture.height = 900
	texture.fill_from = Vector2(0.15, 0.0)
	texture.fill_to = Vector2(0.85, 1.0)
	return texture

static func vignette_texture() -> GradientTexture2D:
	var gradient := Gradient.new()
	gradient.offsets = PackedFloat32Array([0.0, 0.5, 1.0])
	gradient.colors = PackedColorArray([Color(0.0, 0.0, 0.0, 0.34), Color(0.0, 0.0, 0.0, 0.0), Color(0.0, 0.0, 0.0, 0.44)])
	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	texture.width = 1440
	texture.height = 900
	texture.fill_from = Vector2(0.5, 0.08)
	texture.fill_to = Vector2(0.5, 0.95)
	return texture

static func box(color: Color, border: Color = Color("365c67"), width: int = 1, radius: int = 12) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.set_border_width_all(width)
	style.border_color = border
	style.set_corner_radius_all(radius)
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.3)
	style.shadow_size = 8
	style.shadow_offset = Vector2(0, 3)
	style.content_margin_left = 16
	style.content_margin_right = 16
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	return style

static func focus_box() -> StyleBoxFlat:
	var style := box(Color(0.0, 0.0, 0.0, 0.0), GOLD, 3, 10)
	style.expand_margin_left = 3
	style.expand_margin_right = 3
	style.expand_margin_top = 3
	style.expand_margin_bottom = 3
	return style

static func panel(parent: Node, rect: Rect2, color: Color = PANEL, border: Color = Color("365c67")) -> Panel:
	var node := Panel.new()
	node.position = rect.position
	node.size = rect.size
	node.add_theme_stylebox_override("panel", box(color, border))
	parent.add_child(node)
	return node

static func label(parent: Node, text: String, rect: Rect2, font_size: int = 18, color: Color = TEXT) -> Label:
	var node := Label.new()
	node.text = text
	node.position = rect.position
	node.size = rect.size
	node.add_theme_font_size_override("font_size", scaled_font_size(parent, font_size))
	node.add_theme_color_override("font_color", color)
	parent.add_child(node)
	return node

static func button(parent: Node, text: String, rect: Rect2, callback: Callable) -> Button:
	var node := Button.new()
	node.text = text
	node.position = rect.position
	node.size = rect.size
	node.add_theme_font_size_override("font_size", scaled_font_size(parent, 22))
	node.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	node.pressed.connect(callback)
	parent.add_child(node)
	return node

static func accent_button(parent: Node, text: String, rect: Rect2, callback: Callable) -> Button:
	var node := button(parent, text, rect, callback)
	node.add_theme_stylebox_override("normal", box(GREEN, GOLD, 2, 10))
	node.add_theme_stylebox_override("hover", box(GREEN_BRIGHT, Color("fff0b5"), 2, 10))
	node.add_theme_stylebox_override("pressed", box(Color("0d594a"), GOLD, 2, 10))
	return node

static func danger_button(parent: Node, text: String, rect: Rect2, callback: Callable) -> Button:
	var node := button(parent, text, rect, callback)
	node.add_theme_stylebox_override("normal", box(Color("57242d"), DANGER, 1, 10))
	node.add_theme_stylebox_override("hover", box(DANGER, Color("ffc3c8"), 2, 10))
	return node

static func cards(parent: Node, values: Array, origin: Vector2, hidden_count: int = 0, scale_factor: float = 1.0) -> void:
	var count := values.size() if not values.is_empty() else hidden_count
	for index in range(count):
		var card = values[index] if not values.is_empty() else null
		var card_rect := Rect2(origin + Vector2(index * 64 * scale_factor, 0), Vector2(56, 78) * scale_factor)
		var node := panel(parent, card_rect, Color("fffaf0") if card else Color("123f4a"), Color("d6c38d") if card else GOLD_DIM)
		var card_style := node.get_theme_stylebox("panel") as StyleBoxFlat
		card_style.shadow_color = Color(0.0, 0.0, 0.0, 0.5)
		card_style.shadow_size = int(round(6 * scale_factor))
		card_style.shadow_offset = Vector2(0, 3 * scale_factor)
		if card:
			var color := Color("ad3542") if card.suit in [1, 2] else Color("172b32")
			label(node, PokerCard.rank_label(card.rank), Rect2(6, 1, 45, 29), int(23 * scale_factor), color)
			label(node, ["♠", "♥", "♦", "♣"][card.suit], Rect2(15 * scale_factor, 31 * scale_factor, 40, 35), int(29 * scale_factor), color)
		else:
			var inset := panel(node, Rect2(Vector2(4, 4) * scale_factor, Vector2(48, 70) * scale_factor), Color("092830"), Color("3d8f78"))
			var emblem := label(inset, "♠", Rect2(7 * scale_factor, 8 * scale_factor, 34 * scale_factor, 34 * scale_factor), int(27 * scale_factor), GOLD)
			emblem.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

static func ui_scale(node: Node) -> float:
	var control := find_control(node)
	if control == null:
		return 1.0
	var viewport_size := control.get_viewport_rect().size
	if viewport_size.x <= 900:
		return 1.56
	return 1.28

static func compact_ui(node: Node) -> bool:
	return ui_scale(node) > 1.0

static func scaled_font_size(node: Node, font_size: int) -> int:
	return int(round(font_size * ui_scale(node)))

static func find_control(node: Node) -> Control:
	var current := node
	while current != null:
		if current is Control:
			return current as Control
		current = current.get_parent()
	return null
