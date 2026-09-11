extends Control

var content: Control
var history_open: bool = false
var raise_shortcuts_open: bool = false
var pending_raise_increment: int = 100
var raise_context_hand: int = -1
var raise_context_street: int = -1
var raise_input: SpinBox
var error_label: Label
var ai_timer: Timer
var bubble_until: Dictionary = {}
var resize_refresh_queued: bool = false

func _ready() -> void:
	if App.match_system == null:
		App.show_menu()
		return
	PokerUI.install(self)
	resized.connect(_on_resized)
	ai_timer = Timer.new()
	ai_timer.one_shot = true
	ai_timer.wait_time = 0.65
	ai_timer.timeout.connect(_ai_turn)
	add_child(ai_timer)
	redraw()
	queue_ai()

func redraw() -> void:
	if content:
		remove_child(content)
		content.queue_free()
	content = Control.new()
	content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(content)
	var state: TableState = App.match_system.state
	_sync_raise_defaults(state)
	var view := TableViewQuery.execute(state)
	var felt := Control.new()
	felt.set_script(preload("res://scenes/components/table_backdrop.gd"))
	content.add_child(felt)
	# The backdrop calculates its geometry from its own size.  Give it the same
	# full-viewport rect as the seat layout, otherwise a newly-created Control
	# has a zero width and its calculated centre is the left edge of the screen.
	felt.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	felt.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var seat_positions := _seat_positions(state.players.size())
	var center_x := size.x * 0.5
	var board_scale := _board_scale()
	var board_width := 56.0 * board_scale + 64.0 * board_scale * 4.0
	PokerUI.label(content, "德州練習桌", Rect2(32, 17, 300, 49), 30)
	PokerUI.label(content, "第 %02d 手   /   %s   /   單副牌 52 張" % [state.hand_number, App.match_system.street_name()], Rect2(270, 27, 610, 32), 19, PokerUI.GOLD)
	var history_width := 178 if _compact_layout() else 214
	var history_rect := Rect2(size.x - history_width - 28, 18, history_width, 52 if _compact_layout() else 48)
	PokerUI.button(content, _history_button_text(), history_rect, _toggle_history)
	for seat in view.seats:
		_draw_seat(seat, seat_positions[seat.seat], state.actor)
	var pot_amount := state.pot_total()
	if state.hand_over:
		for award in state.awards:
			pot_amount += int(award.amount)
	var total := PokerUI.label(content, "底池  %s" % StakeFormat.bb(pot_amount), Rect2(center_x - 185, 300, 370, 44), 29, PokerUI.GOLD)
	total.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	PokerUI.cards(content, view.board, Vector2(center_x - board_width * 0.5, 356), 5, board_scale)
	var pot_text: Array[String] = []
	for index in range(view.pots.size()):
		var pot: Dictionary = view.pots[index]
		pot_text.append("%s %s" % [("未跟注" if pot.refund else ("主池" if index == 0 else "邊池%d" % index)), StakeFormat.bb(int(pot.amount))])
	var pots := PokerUI.label(content, " · ".join(pot_text), Rect2(center_x - 310, 444, 620, 72), 16, PokerUI.MUTED)
	pots.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	pots.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var status := "本手已結算" if state.hand_over else ("輪到你了" if state.actor == 0 else "%s 思考中…" % state.players[state.actor].display_name)
	var turn_label := PokerUI.label(content, status, Rect2(center_x - 280, 522, 560, 48), 22, PokerUI.GOLD)
	turn_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	turn_label.visible = not state.hand_over
	_draw_history(state)
	_draw_actions(state, view.legal)
	if state.hand_over:
		var summary := PokerUI.panel(content, Rect2(center_x - 300, 454, 600, 146), Color("112b29"), PokerUI.GOLD)
		PokerUI.label(summary, "本手結算", Rect2(14, 3, 495, 28), 19, PokerUI.GOLD)
		var text := RichTextLabel.new()
		text.position = Vector2(14, 35)
		text.size = Vector2(570, 98)
		text.text = state.summary
		text.add_theme_font_size_override("normal_font_size", PokerUI.scaled_font_size(summary, 18))
		summary.add_child(text)

func _draw_seat(seat: Dictionary, position_value: Vector2, actor: int) -> void:
	var seat_size := _seat_size()
	var panel := PokerUI.panel(content, Rect2(position_value, seat_size), PokerUI.PANEL, PokerUI.GOLD if actor == seat.seat else Color("365049"))
	panel.name = "Seat%d" % seat.seat
	PokerUI.label(panel, seat.name + (" · 已離桌" if seat.eliminated else ""), Rect2(14, 8, seat_size.x - 28, 34), 21, PokerUI.MUTED if seat.eliminated else PokerUI.TEXT)
	PokerUI.label(panel, StakeFormat.bb(int(seat.chips)), Rect2(14, 42, 134, 30), 19, PokerUI.GOLD)
	if not seat.eliminated or not seat.cards.is_empty():
		PokerUI.cards(panel, seat.cards, Vector2(14, 82), 2, _seat_card_scale())
	PokerUI.label(panel, seat.badges, Rect2(158, 44, seat_size.x - 172, 28), 14, PokerUI.MUTED)
	PokerUI.label(panel, "本輪 %s  /  本手 %s" % [StakeFormat.bb(int(seat.bet)), StakeFormat.bb(int(seat.contribution))], Rect2(158, 76, seat_size.x - 172, 28), 14, PokerUI.MUTED)
	PokerUI.label(panel, seat.action, Rect2(158, 110, seat_size.x - 172, 54), 16, PokerUI.MUTED if seat.folded else PokerUI.TEXT)
	if not seat.bubble.is_empty() and Time.get_ticks_msec() < int(bubble_until.get(seat.seat, 0)):
		var bubble_size := Vector2(seat_size.x, 74 if _compact_layout() else 68)
		var bubble := PokerUI.panel(content, Rect2(position_value - Vector2(0, bubble_size.y + 6), bubble_size), Color("ddd7b5"))
		bubble.name = "Bubble%d" % seat.seat
		var bubble_text := PokerUI.label(bubble, "「%s」" % seat.bubble, Rect2(8, 6, bubble_size.x - 16, bubble_size.y - 12), 16, Color("233b35"))
		bubble_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		bubble_text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

func _draw_history(state: TableState) -> void:
	if not history_open:
		return
	var pane_rect := Rect2(size.x - 428, 82, 392, 704)
	if _compact_layout():
		pane_rect = Rect2(54, 86, 1332, 714)
	var pane := PokerUI.panel(content, pane_rect, Color(0.063, 0.125, 0.145, 0.97), PokerUI.GOLD)
	PokerUI.label(pane, "對手觀察 / 已公開資訊", Rect2(20, 14, 520, 40), 24, PokerUI.GOLD)
	var close_x := pane_rect.size.x - 156
	PokerUI.button(pane, "關閉", Rect2(close_x, 14, 136, 42), _toggle_history)
	var stats: Array[String] = []
	for player in state.players:
		if player.seat > 0:
			stats.append("%s　加注 %d\n證實詐唬 %d / 價值下注 %d" % [player.display_name, player.raises, player.proven_bluffs, player.value_bets])
	var overview_rect := Rect2(20, 68, 352, 214)
	var history_title_rect := Rect2(20, 296, 352, 30)
	var history_rect := Rect2(20, 336, 352, 302)
	var foot_rect := Rect2(20, 650, 352, 44)
	if _compact_layout():
		overview_rect = Rect2(20, 68, 1292, 176)
		history_title_rect = Rect2(20, 264, 1292, 34)
		history_rect = Rect2(20, 308, 1292, 332)
		foot_rect = Rect2(20, 652, 1292, 48)
	var overview := PokerUI.label(pane, "\n".join(stats), overview_rect, 16)
	overview.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	PokerUI.label(pane, "近期行動 / 攤牌", history_title_rect, 19, PokerUI.GOLD)
	var history := RichTextLabel.new()
	history.name = "History"
	history.position = history_rect.position
	history.size = history_rect.size
	history.add_theme_font_size_override("normal_font_size", PokerUI.scaled_font_size(pane, 16))
	history.text = "\n\n".join(state.history)
	history.scroll_following = true
	pane.add_child(history)
	PokerUI.label(pane, "詐唬門檻：攤牌低於兩對\n僅計入本手曾主動加注者", foot_rect, 14, PokerUI.MUTED)

func _draw_actions(state: TableState, legal: Dictionary) -> void:
	var bar_height := 122 if _compact_layout() else 112
	var bottom_margin := _action_bar_bottom_margin()
	var bar := PokerUI.panel(content, Rect2(28, 780, 1372, bar_height))
	bar.anchor_left = 0.0
	bar.anchor_top = 1.0
	bar.anchor_right = 1.0
	bar.anchor_bottom = 1.0
	bar.offset_left = 28
	bar.offset_top = -(bottom_margin + bar_height)
	bar.offset_right = -40
	bar.offset_bottom = -bottom_margin
	if state.hand_over:
		PokerUI.label(bar, "牌局結束" if state.finished else "查看結算與攤牌紀錄後，繼續下一手。", Rect2(20, 22, 875, 50), 21)
		var next := PokerUI.button(bar, "查看本場結果  →" if state.finished else "下一手  →", Rect2(1004, 22, 344, 54), _next)
		next.name = "NextHand"
		return
	PokerUI.label(bar, "需跟注 %s · 最小加注至 %s" % [StakeFormat.bb(int(legal.call)), StakeFormat.bb(int(legal.min_to))], Rect2(20, 7, 630, 27), 16, PokerUI.MUTED)
	error_label = PokerUI.label(bar, "", Rect2(650, 7, 690, 27), 16, PokerUI.GOLD)
	var row_y := 52 if _compact_layout() else 48
	var button_h := 54 if _compact_layout() else 50
	var fold := PokerUI.button(bar, "棄牌", Rect2(20, row_y, 145, button_h), func(): _act("fold"))
	fold.name = "Fold"
	fold.disabled = not legal.active
	var call := PokerUI.button(bar, "過牌" if legal.check else "跟注 %s" % StakeFormat.bb(int(legal.call)), Rect2(180, row_y, 203, button_h), func(): _act("check" if legal.check else "call"))
	call.name = "CheckCall"
	call.disabled = not legal.active
	PokerUI.label(bar, "加多少", Rect2(416, row_y + 3, 100, 39), 17)
	PokerUI.label(bar, "實際加注至 %s" % StakeFormat.bb(_current_raise_to(state, legal)), Rect2(416, 13, 250, 30), 15, PokerUI.GOLD)
	raise_input = SpinBox.new()
	raise_input.name = "RaiseAmount"
	raise_input.position = Vector2(510, row_y)
	raise_input.size = Vector2(230, button_h)
	raise_input.min_value = 1
	var max_increment := _current_raise_increment_limit(state, legal)
	raise_input.max_value = float(max_increment) / StakeFormat.BIG_BLIND
	raise_input.step = 1
	raise_input.suffix = " BB"
	pending_raise_increment = clampi(pending_raise_increment, 100, max_increment)
	raise_input.value = float(pending_raise_increment) / StakeFormat.BIG_BLIND
	raise_input.editable = legal.can_raise
	raise_input.value_changed.connect(_on_raise_amount_changed)
	bar.add_child(raise_input)
	var shortcut_button := PokerUI.button(bar, "快捷 +", Rect2(760, row_y, 104, button_h), _toggle_raise_shortcuts)
	shortcut_button.name = "RaiseShortcuts"
	shortcut_button.disabled = not legal.can_raise
	var raise_button := PokerUI.button(bar, "加注", Rect2(878, row_y, 178, button_h), _raise)
	raise_button.name = "Raise"
	raise_button.disabled = not legal.can_raise
	var all_in := PokerUI.button(bar, "全下", Rect2(1072, row_y, 276, button_h), func(): _act("all_in"))
	all_in.name = "AllIn"
	all_in.disabled = not legal.all_in
	if raise_shortcuts_open and legal.can_raise:
		_draw_raise_shortcuts(bar)

func _draw_raise_shortcuts(bar: Panel) -> void:
	var quick := PokerUI.panel(bar, Rect2(314, -118, 1022, 94), Color("102025"), PokerUI.GOLD)
	PokerUI.label(quick, "快速調整", Rect2(18, 12, 180, 28), 18, PokerUI.GOLD)
	PokerUI.button(quick, "+1 BB", Rect2(18, 46, 126, 36), func(): _adjust_raise_increment(100))
	PokerUI.button(quick, "+10 BB", Rect2(156, 46, 126, 36), func(): _adjust_raise_increment(1000))
	PokerUI.button(quick, "+100 BB", Rect2(294, 46, 140, 36), func(): _adjust_raise_increment(10000))
	PokerUI.button(quick, "-1 BB", Rect2(456, 46, 126, 36), func(): _adjust_raise_increment(-100))
	PokerUI.button(quick, "-10 BB", Rect2(594, 46, 126, 36), func(): _adjust_raise_increment(-1000))
	PokerUI.button(quick, "-100 BB", Rect2(732, 46, 140, 36), func(): _adjust_raise_increment(-10000))
	PokerUI.button(quick, "收起", Rect2(884, 46, 120, 36), _toggle_raise_shortcuts)

func _on_resized() -> void:
	if resize_refresh_queued or not content:
		return
	resize_refresh_queued = true
	call_deferred("_refresh_after_resize")

func _refresh_after_resize() -> void:
	resize_refresh_queued = false
	if is_inside_tree() and content:
		redraw()

func _act(action: String, amount: int = 0) -> void:
	var error := PlayerActionCommand.execute(App.match_system, action, amount)
	if not error.is_empty():
		error_label.text = error
		return
	raise_shortcuts_open = false
	redraw()
	queue_ai()

func queue_ai() -> void:
	if not App.match_system.state.hand_over and App.match_system.state.actor > 0 and ai_timer.is_stopped():
		ai_timer.start()

func _ai_turn() -> void:
	var state: TableState = App.match_system.state
	if state.hand_over or state.actor <= 0:
		return
	var seat := state.actor
	var decision := AIDecisionSystem.decide(AIObservationQuery.execute(state, seat), state.players[seat].profile)
	var error := App.match_system.act(seat, decision.action, decision.amount, decision.speech)
	assert(error.is_empty(), error)
	bubble_until[seat] = Time.get_ticks_msec() + 4000
	redraw()
	queue_ai()

func _process(_delta: float) -> void:
	if not content:
		return
	for seat in bubble_until:
		if Time.get_ticks_msec() >= int(bubble_until[seat]):
			var bubble := content.get_node_or_null("Bubble%d" % seat)
			if bubble:
				bubble.hide()

func _toggle_history() -> void:
	history_open = not history_open
	redraw()

func _toggle_raise_shortcuts() -> void:
	raise_shortcuts_open = not raise_shortcuts_open
	redraw()

func _adjust_raise_increment(amount: int) -> void:
	var maximum := _current_raise_increment_limit(App.match_system.state, BettingSystem.legal(App.match_system.state, 0))
	pending_raise_increment = clampi(pending_raise_increment + amount, 100, maximum)
	redraw()

func _on_raise_amount_changed(value: float) -> void:
	pending_raise_increment = int(value) * StakeFormat.BIG_BLIND

func _history_button_text() -> String:
	return "關閉紀錄" if history_open else "觀察紀錄"

func _compact_layout() -> bool:
	return PokerUI.compact_ui(self)

func _seat_size() -> Vector2:
	return Vector2(300, 190) if _compact_layout() else Vector2(288, 176)

func _seat_card_scale() -> float:
	return 0.9 if _compact_layout() else 0.82

func _board_scale() -> float:
	return 1.16 if _compact_layout() else 1.08

func _seat_positions(player_count: int) -> Array:
	var seat_size := _seat_size()
	var center_x := size.x * 0.5
	var top_y := 98.0
	var mid_y := 284.0
	var bottom_y := size.y - _action_bar_bottom_margin() - _action_bar_height() - seat_size.y - 26.0
	var side_margin := 34.0 if _compact_layout() else 42.0
	var upper_gap := 68.0 if _compact_layout() else 84.0
	var positions := [Vector2.ZERO, Vector2.ZERO, Vector2.ZERO, Vector2.ZERO, Vector2.ZERO]
	positions[0] = Vector2(center_x - seat_size.x * 0.5, bottom_y)
	match player_count:
		2:
			positions[1] = Vector2(center_x - seat_size.x * 0.5, top_y)
		3:
			positions[1] = Vector2(center_x - seat_size.x - upper_gap * 0.5, top_y)
			positions[2] = Vector2(center_x + upper_gap * 0.5, top_y)
		4:
			positions[1] = Vector2(side_margin, mid_y)
			positions[2] = Vector2(center_x - seat_size.x * 0.5, top_y)
			positions[3] = Vector2(size.x - seat_size.x - side_margin, mid_y)
		_:
			positions[1] = Vector2(side_margin, mid_y)
			positions[2] = Vector2(center_x - seat_size.x - upper_gap * 0.5, top_y)
			positions[3] = Vector2(center_x + upper_gap * 0.5, top_y)
			positions[4] = Vector2(size.x - seat_size.x - side_margin, mid_y)
	return positions

func _action_bar_height() -> int:
	return 122 if _compact_layout() else 112

func _action_bar_bottom_margin() -> int:
	return 58 if _compact_layout() else 34

func _sync_raise_defaults(state: TableState) -> void:
	if state.hand_number != raise_context_hand or state.street != raise_context_street or state.hand_over:
		pending_raise_increment = 100
		raise_shortcuts_open = false
		raise_context_hand = state.hand_number
		raise_context_street = state.street

func _current_raise_increment_limit(state: TableState, legal: Dictionary) -> int:
	return maxi(100, int(legal.max_to) - state.current_bet)

func _current_raise_to(state: TableState, legal: Dictionary) -> int:
	var max_increment := int(legal.max_to) - state.current_bet
	if max_increment <= 0:
		return int(legal.max_to)
	var min_increment := int(legal.min_to) - state.current_bet
	var desired_increment := clampi(pending_raise_increment, 100, _current_raise_increment_limit(state, legal))
	if max_increment < min_increment:
		return int(legal.max_to)
	return state.current_bet + maxi(min_increment, desired_increment)

func _raise() -> void:
	var state: TableState = App.match_system.state
	var legal := BettingSystem.legal(state, 0)
	_act("raise", _current_raise_to(state, legal))

func _next() -> void:
	if App.match_system.state.finished:
		App.show_result()
	else:
		App.match_system.begin_hand()
		pending_raise_increment = 100
		raise_shortcuts_open = false
		redraw()
		queue_ai()
