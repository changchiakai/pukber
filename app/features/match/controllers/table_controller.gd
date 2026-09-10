extends Control

var content: Control
var history_open: bool = true
var raise_input: SpinBox
var error_label: Label
var ai_timer: Timer
var bubble_until: Dictionary = {}

func _ready() -> void:
	if App.match_system == null:
		App.show_menu()
		return
	PokerUI.install(self)
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
	var view := TableViewQuery.execute(state)
	var felt := Control.new()
	felt.set_script(preload("res://scenes/components/table_backdrop.gd"))
	felt.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(felt)
	PokerUI.label(content, "讀心牌桌", Rect2(32, 17, 240, 49), 30)
	PokerUI.label(content, "第 %02d 手   /   %s   /   %d 副牌" % [state.hand_number, App.match_system.street_name(), state.settings.deck_count()], Rect2(270, 27, 610, 32), 19, PokerUI.GOLD)
	PokerUI.button(content, "%s觀察紀錄" % ("收合" if history_open else "展開"), Rect2(1120, 20, 278, 46), _toggle_history)
	var positions := [Vector2(420, 591), Vector2(28, 315), Vector2(240, 108), Vector2(620, 108), Vector2(840, 315)]
	# Use balanced positions for smaller tables while retaining the human at bottom.
	if state.players.size() == 2:
		positions[1] = Vector2(420, 108)
	elif state.players.size() == 3:
		positions[1] = Vector2(240, 108)
		positions[2] = Vector2(620, 108)
	elif state.players.size() == 4:
		positions[1] = Vector2(28, 315)
		positions[2] = Vector2(420, 108)
		positions[3] = Vector2(840, 315)
	for seat in view.seats:
		_draw_seat(seat, positions[seat.seat], state.actor)
	var pot_amount := state.pot_total()
	if state.hand_over:
		for award in state.awards:
			pot_amount += int(award.amount)
	var total := PokerUI.label(content, "底池  %s" % pot_amount, Rect2(355, 302, 370, 44), 29, PokerUI.GOLD)
	total.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	PokerUI.cards(content, view.board, Vector2(380, 357), 5)
	var pot_text: Array[String] = []
	for index in range(view.pots.size()):
		var pot: Dictionary = view.pots[index]
		pot_text.append("%s %d" % [("未跟注" if pot.refund else ("主池" if index == 0 else "邊池%d" % index)), pot.amount])
	var pots := PokerUI.label(content, " · ".join(pot_text), Rect2(282, 450, 520, 62), 16, PokerUI.MUTED)
	pots.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	pots.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var status := "本手已結算" if state.hand_over else ("輪到你了" if state.actor == 0 else "%s 思考中…" % state.players[state.actor].display_name)
	var turn_label := PokerUI.label(content, status, Rect2(302, 525, 490, 42), 22, PokerUI.GOLD)
	turn_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	turn_label.visible = not state.hand_over
	_draw_history(state)
	_draw_actions(state, view.legal)
	if state.hand_over:
		var summary := PokerUI.panel(content, Rect2(282, 455, 540, 127), Color("112b29"), PokerUI.GOLD)
		PokerUI.label(summary, "本手結算", Rect2(14, 3, 495, 28), 19, PokerUI.GOLD)
		var text := RichTextLabel.new()
		text.position = Vector2(14, 35)
		text.size = Vector2(510, 81)
		text.text = state.summary
		text.add_theme_font_size_override("normal_font_size", 18)
		summary.add_child(text)

func _draw_seat(seat: Dictionary, position_value: Vector2, actor: int) -> void:
	var panel := PokerUI.panel(content, Rect2(position_value, Vector2(235, 180)), PokerUI.PANEL, PokerUI.GOLD if actor == seat.seat else Color("365049"))
	panel.name = "Seat%d" % seat.seat
	PokerUI.label(panel, seat.name + (" · 已離桌" if seat.eliminated else ""), Rect2(13, 6, 208, 28), 21, PokerUI.MUTED if seat.eliminated else PokerUI.TEXT)
	PokerUI.label(panel, "%d 籌碼" % seat.chips, Rect2(13, 36, 208, 28), 19, PokerUI.GOLD)
	if not seat.eliminated or not seat.cards.is_empty():
		PokerUI.cards(panel, seat.cards, Vector2(13, 72), 2, 0.7)
	PokerUI.label(panel, seat.badges, Rect2(111, 69, 121, 26), 14, PokerUI.MUTED)
	PokerUI.label(panel, "本輪 %d\n本手 %d" % [seat.bet, seat.contribution], Rect2(111, 94, 121, 46), 14, PokerUI.MUTED)
	PokerUI.label(panel, seat.action, Rect2(13, 145, 214, 28), 16, PokerUI.MUTED if seat.folded else PokerUI.TEXT)
	if not seat.bubble.is_empty() and Time.get_ticks_msec() < int(bubble_until.get(seat.seat, 0)):
		var bubble := PokerUI.panel(content, Rect2(position_value - Vector2(0, 37), Vector2(235, 32)), Color("ddd7b5"))
		bubble.name = "Bubble%d" % seat.seat
		PokerUI.label(bubble, "「%s」" % seat.bubble, Rect2(8, 0, 222, 30), 16, Color("233b35"))

func _draw_history(state: TableState) -> void:
	var pane := PokerUI.panel(content, Rect2(1118, 88, 282, 665))
	if not history_open:
		PokerUI.label(pane, "觀察下注，留意話術。\n\n可展開紀錄查看\n動作與已公開的底牌。", Rect2(16, 22, 248, 180), 18, PokerUI.MUTED)
		return
	PokerUI.label(pane, "對手觀察", Rect2(16, 10, 248, 34), 22, PokerUI.GOLD)
	var stats: Array[String] = []
	for player in state.players:
		if player.seat > 0:
			stats.append("%s　加注 %d\n證實詐唬 %d / 價值下注 %d" % [player.display_name, player.raises, player.proven_bluffs, player.value_bets])
	var overview := PokerUI.label(pane, "\n".join(stats), Rect2(16, 51, 250, 217), 16)
	overview.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	PokerUI.label(pane, "近期行動 / 攤牌", Rect2(16, 278, 250, 30), 19, PokerUI.GOLD)
	var history := RichTextLabel.new()
	history.name = "History"
	history.position = Vector2(16, 321)
	history.size = Vector2(250, 275)
	history.add_theme_font_size_override("normal_font_size", 16)
	history.text = "\n\n".join(state.history)
	history.scroll_following = true
	pane.add_child(history)
	PokerUI.label(pane, "詐唬門檻：攤牌低於兩對\n僅計入本手曾主動加注者", Rect2(16, 609, 250, 47), 14, PokerUI.MUTED)

func _draw_actions(state: TableState, legal: Dictionary) -> void:
	var bar := PokerUI.panel(content, Rect2(28, 780, 1372, 98))
	if state.hand_over:
		PokerUI.label(bar, "牌局結束" if state.finished else "查看結算與攤牌紀錄後，繼續下一手。", Rect2(20, 22, 875, 50), 21)
		var next := PokerUI.button(bar, "查看本場結果  →" if state.finished else "下一手  →", Rect2(1004, 22, 344, 54), _next)
		next.name = "NextHand"
		return
	PokerUI.label(bar, "需跟注 %d · 最小加注至 %d" % [legal.call, legal.min_to], Rect2(20, 7, 630, 27), 16, PokerUI.MUTED)
	error_label = PokerUI.label(bar, "", Rect2(650, 7, 690, 27), 16, PokerUI.GOLD)
	var fold := PokerUI.button(bar, "棄牌", Rect2(20, 39, 145, 47), func(): _act("fold"))
	fold.name = "Fold"
	fold.disabled = not legal.active
	var call := PokerUI.button(bar, "過牌" if legal.check else "跟注 %d" % legal.call, Rect2(180, 39, 203, 47), func(): _act("check" if legal.check else "call"))
	call.name = "CheckCall"
	call.disabled = not legal.active
	PokerUI.label(bar, "加注至", Rect2(416, 42, 100, 39), 17)
	raise_input = SpinBox.new()
	raise_input.name = "RaiseAmount"
	raise_input.position = Vector2(510, 39)
	raise_input.size = Vector2(230, 47)
	raise_input.min_value = mini(legal.min_to, legal.max_to)
	raise_input.max_value = legal.max_to
	raise_input.step = 1
	raise_input.value = raise_input.min_value
	raise_input.editable = legal.can_raise
	bar.add_child(raise_input)
	var raise_button := PokerUI.button(bar, "加注", Rect2(760, 39, 216, 47), func(): _act("raise", int(raise_input.value)))
	raise_button.name = "Raise"
	raise_button.disabled = not legal.can_raise
	var all_in := PokerUI.button(bar, "全下", Rect2(992, 39, 356, 47), func(): _act("all_in"))
	all_in.name = "AllIn"
	all_in.disabled = not legal.all_in

func _act(action: String, amount: int = 0) -> void:
	var error := PlayerActionCommand.execute(App.match_system, action, amount)
	if not error.is_empty():
		error_label.text = error
		return
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

func _next() -> void:
	if App.match_system.state.finished:
		App.show_result()
	else:
		App.match_system.begin_hand()
		redraw()
		queue_ai()
