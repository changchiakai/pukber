class_name PokerUI
extends RefCounted

const BG := Color("091419")
const PANEL := Color("14272c")
const TEXT := Color("edf2e9")
const MUTED := Color("adc1b8")
const GOLD := Color("e6ba68")
const GREEN := Color("25745c")
const UI_FONT: FontFile = preload("res://Iansui-Regular.ttf")

static func install(root: Control) -> void:
	var theme := Theme.new()
	# Embed the Chinese font in exported builds instead of relying on browser/OS fonts.
	theme.default_font = UI_FONT
	theme.default_font_size = 18
	theme.set_color("font_color", "Label", TEXT)
	theme.set_color("font_color", "Button", TEXT)
	theme.set_color("font_disabled_color", "Button", Color("83918c"))
	theme.set_color("font_color", "RichTextLabel", TEXT)
	theme.set_stylebox("normal", "Button", box(PANEL, Color("426058")))
	theme.set_stylebox("hover", "Button", box(Color("285346"), GOLD))
	theme.set_stylebox("pressed", "Button", box(GREEN, GOLD))
	theme.set_stylebox("focus", "Button", box(Color(0, 0, 0, 0), GOLD, 3))
	theme.set_stylebox("disabled", "Button", box(Color("142025"), Color("293835")))
	root.theme = theme
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var backdrop := ColorRect.new()
	backdrop.color = BG
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(backdrop)

static func box(color: Color, border: Color = Color("365049"), width: int = 1) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.set_border_width_all(width)
	style.border_color = border
	style.content_margin_left = 16
	style.content_margin_right = 16
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	return style

static func panel(parent: Node, rect: Rect2, color: Color = PANEL, border: Color = Color("365049")) -> Panel:
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
	node.add_theme_font_size_override("font_size", font_size)
	node.add_theme_color_override("font_color", color)
	parent.add_child(node)
	return node

static func button(parent: Node, text: String, rect: Rect2, callback: Callable) -> Button:
	var node := Button.new()
	node.text = text
	node.position = rect.position
	node.size = rect.size
	node.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	node.pressed.connect(callback)
	parent.add_child(node)
	return node

static func cards(parent: Node, values: Array, origin: Vector2, hidden_count: int = 0, scale_factor: float = 1.0) -> void:
	var count := values.size() if not values.is_empty() else hidden_count
	for index in range(count):
		var card = values[index] if not values.is_empty() else null
		var node := panel(parent, Rect2(origin + Vector2(index * 64 * scale_factor, 0), Vector2(56, 78) * scale_factor), Color("eeeade") if card else Color("214f50"), Color("9db3a2"))
		if card:
			var color := Color("ad3542") if card.suit in [1, 2] else Color("172b32")
			label(node, PokerCard.rank_label(card.rank), Rect2(6, 1, 45, 29), int(23 * scale_factor), color)
			label(node, ["♠", "♥", "♦", "♣"][card.suit], Rect2(15 * scale_factor, 33 * scale_factor, 40, 35), int(29 * scale_factor), color)
		else:
			label(node, "▪\n▪", Rect2(17 * scale_factor, 9 * scale_factor, 28, 62), int(25 * scale_factor), GOLD)
