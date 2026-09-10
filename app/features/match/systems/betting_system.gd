class_name BettingSystem
extends RefCounted

static func legal(state: TableState, seat: int) -> Dictionary:
	var player: PlayerState = state.players[seat]
	var active := seat == state.actor and not state.hand_over and not state.finished and player.can_act()
	var cost := maxi(0, state.current_bet - player.street_bet)
	var reopened: bool = not state.acted_at.has(seat) or state.current_bet - int(state.acted_at[seat]) >= state.min_raise
	var opponent_can_call := false
	for other in state.players:
		if other.seat != seat and other.can_act():
			opponent_can_call = true
	if not opponent_can_call:
		var actual_wager := 0
		for other in state.players:
			if other.seat != seat and not other.folded and not other.eliminated:
				actual_wager = maxi(actual_wager, other.street_bet)
		cost = maxi(0, actual_wager - player.street_bet)
	var maximum := player.street_bet + player.chips
	var can_raise: bool = active and reopened and opponent_can_call and maximum > state.current_bet
	return {"active": active, "call": mini(cost, player.chips), "check": active and cost == 0,
		"can_raise": can_raise, "min_to": state.current_bet + state.min_raise, "max_to": maximum,
		"all_in": active and (maximum <= state.current_bet or can_raise)}

static func commit(player: PlayerState, amount: int) -> void:
	var paid := mini(amount, player.chips)
	player.chips -= paid
	player.street_bet += paid
	player.contribution += paid

static func apply(state: TableState, seat: int, action: String, raise_to: int = 0) -> String:
	var options := legal(state, seat)
	if not options.active:
		return "目前不是你的回合。"
	var player: PlayerState = state.players[seat]
	var faced_bet := int(options.call) > 0
	if action == "all_in":
		if not options.all_in:
			return "不足額加注未重新開放加注權。"
		if options.max_to <= state.current_bet:
			action = "call"
		else:
			action = "raise"
			raise_to = options.max_to
	match action:
		"fold":
			player.folded = true
			if faced_bet:
				player.fold_to_bet += 1
			player.last_action = "棄牌"
		"check":
			if not options.check:
				return "有待跟注金額，無法過牌。"
			player.last_action = "過牌"
		"call":
			if int(options.call) > 0:
				player.call_actions += 1
				if state.street == 0 and not player.entered_pot_this_hand:
					player.voluntary_puts += 1
					player.entered_pot_this_hand = true
			commit(player, options.call)
			player.last_action = "跟注 %s" % StakeFormat.bb(int(options.call)) if options.call > 0 else "過牌"
		"raise":
			if not options.can_raise or raise_to > options.max_to or raise_to <= state.current_bet:
				return "加注金額不合法。"
			if raise_to < options.min_to and raise_to != options.max_to:
				return "最小加注至 %s；不足時只能全下。" % StakeFormat.bb(int(options.min_to))
			var was_reraise := (state.current_bet > state.settings.big_blind) if state.street == 0 else state.current_bet > 0
			var increment := raise_to - state.current_bet
			if increment >= state.min_raise:
				state.min_raise = increment
			commit(player, raise_to - player.street_bet)
			state.current_bet = raise_to
			player.last_action = "加注至 %s" % StakeFormat.bb(raise_to)
			player.raises += 1
			if state.street == 0 and not player.entered_pot_this_hand:
				player.voluntary_puts += 1
				player.entered_pot_this_hand = true
			if was_reraise:
				player.reraises += 1
			player.aggressive_this_hand = true
			player.aggressive_this_street = true
			if not player.recent_pressure.is_empty():
				player.recent_pressure[player.recent_pressure.size() - 1] = 1
		_:
			return "未知操作。"
	if player.chips == 0 and not player.folded:
		player.last_action += " · 全下"
	state.acted_at[seat] = state.current_bet
	return ""
