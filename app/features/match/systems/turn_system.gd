class_name TurnSystem
extends RefCounted

signal event_occurred(event_name: String, details: Dictionary)

var state := TableState.new()
var rng := RandomNumberGenerator.new()

func start(settings: MatchSettings, random_seed: int = -1) -> void:
	state = TableState.new()
	state.settings = settings
	if random_seed < 0:
		rng.randomize()
	else:
		rng.seed = random_seed
	var count := clampi(settings.ai_count, 1, 4)
	settings.ai_count = count
	var majority: int = [0, 1, 2, 2, 3][count]
	var types: Array = []
	for index in range(count):
		types.append(settings.liars_majority if index < majority else not settings.liars_majority)
	for index in range(count - 1, 0, -1):
		var other := rng.randi_range(0, index)
		var temp = types[index]
		types[index] = types[other]
		types[other] = temp
	for index in range(count + 1):
		var player := PlayerState.new(index)
		player.chips = settings.initial_chips
		if index > 0:
			player.profile = AIProfile.new(types[index - 1], rng.randi())
		state.players.append(player)
	state.dealer = rng.randi_range(0, count)
	begin_hand(false)

func next_live(after: int) -> int:
	for offset in range(1, state.players.size() + 1):
		var seat := posmod(after + offset, state.players.size())
		if not state.players[seat].eliminated:
			return seat
	return -1

func begin_hand(rotate: bool = true) -> void:
	if state.finished:
		return
	if rotate:
		state.dealer = next_live(state.dealer)
	state.hand_number += 1
	state.hand_over = false
	state.street = 0
	state.board.clear()
	state.summary = ""
	state.awards.clear()
	state.acted_at.clear()
	state.current_bet = state.settings.big_blind
	state.min_raise = state.settings.big_blind
	state.deck = PokerDeck.new(state.settings.deck_count(), state.settings.short_deck)
	state.deck.shuffle_with(rng)
	for player in state.players:
		player.reset_hand()
		if player.profile:
			player.profile.reset_hand_plan()
		if not player.eliminated:
			player.hands_played += 1
	var live := state.live_seats()
	state.small_blind_seat = state.dealer if live.size() == 2 else next_live(state.dealer)
	state.big_blind_seat = next_live(state.small_blind_seat)
	post_blind(state.small_blind_seat, state.settings.small_blind, "小盲")
	post_blind(state.big_blind_seat, state.settings.big_blind, "大盲")
	# Two passes, starting left of the button.
	for pass_index in range(2):
		var seat := next_live(state.dealer)
		for _index in range(live.size()):
			state.players[seat].hole.append(state.deck.draw())
			seat = next_live(seat)
	state.record("開始 · 莊家 %s · %s %d 張" % [state.players[state.dealer].display_name, "短牌德州" if state.settings.short_deck else "標準德州", state.settings.cards_per_deck()])
	event_occurred.emit("hand_started", {"hand": state.hand_number})
	event_occurred.emit("cards_dealt", {})
	progress(state.big_blind_seat)

func post_blind(seat: int, amount: int, title: String) -> void:
	var player: PlayerState = state.players[seat]
	BettingSystem.commit(player, amount)
	player.last_action = "%s %s" % [title, StakeFormat.bb(player.street_bet)]
	state.record(player.display_name + " " + player.last_action)

func act(seat: int, action: String, amount: int = 0, speech: String = "") -> String:
	if seat == 0:
		_record_review_decision(action, amount)
	var error := BettingSystem.apply(state, seat, action, amount)
	if not error.is_empty():
		if seat == 0:
			state.review_decisions.pop_back()
		return error
	var player: PlayerState = state.players[seat]
	player.bubble = speech
	state.record(player.display_name + " · " + street_name() + " · " + player.last_action + (" · 「%s」" % speech if not speech.is_empty() else ""))
	event_occurred.emit("player_acted", {"seat": seat, "action": action})
	progress(seat)
	return ""

func _record_review_decision(action: String, amount: int) -> void:
	var observation := AIObservationQuery.execute(state, 0)
	state.review_decisions.append({
		"hand": state.hand_number, "street": state.street,
		"action": action, "raise_to": amount,
		"hole": observation.hole, "board": observation.board,
		"opponents": observation.opponents, "pot": observation.pot,
		"chips": observation.chips, "bet": observation.bet,
		"big_blind": observation.big_blind, "legal": observation.legal,
		"player_count": observation.player_count, "in_position": observation.in_position
	})

func pending_seats() -> Array:
	var pending: Array = []
	var actors: Array = []
	for player in state.players:
		if player.can_act():
			actors.append(player.seat)
	for seat in actors:
		var player: PlayerState = state.players[seat]
		# A sole solvent player must only respond to an outstanding wager.
		var target := state.current_bet
		if actors.size() == 1:
			target = 0
			for other in state.players:
				if other.seat != seat and not other.folded and not other.eliminated:
					target = maxi(target, other.street_bet)
		if player.street_bet < target or (actors.size() > 1 and not state.acted_at.has(seat)):
			pending.append(seat)
	return pending

func progress(after: int) -> void:
	if state.contenders().size() == 1:
		finish_hand(false)
		return
	var pending := pending_seats()
	if not pending.is_empty():
		for offset in range(1, state.players.size() + 1):
			var seat := posmod(after + offset, state.players.size())
			if seat in pending:
				state.actor = seat
				return
	if state.street == 3:
		finish_hand(true)
		return
	advance_street()

func advance_street() -> void:
	state.street += 1
	state.current_bet = 0
	state.min_raise = state.settings.big_blind
	state.acted_at.clear()
	for player in state.players:
		player.street_bet = 0
		player.aggressive_this_street = false
		player.bubble = ""
	state.deck.draw() # Burn card remains unknown to every AI.
	for _index in range(3 if state.street == 1 else 1):
		state.board.append(state.deck.draw())
	state.record(street_name() + " · " + cards_text(state.board))
	event_occurred.emit("street_advanced", {"street": state.street})
	progress(state.dealer)

func finish_hand(showdown: bool) -> void:
	state.actor = -1
	state.hand_over = true
	event_occurred.emit("hand_finished", {"hand": state.hand_number, "showdown": showdown})
	var scores: Dictionary = {}
	var descriptions: Array[String] = []
	if showdown:
		event_occurred.emit("showdown_started", {})
	for seat in state.contenders():
		var player: PlayerState = state.players[seat]
		if showdown:
			player.revealed = true
			var hand := HandEvaluator.evaluate(player.hole + state.board, state.settings.short_deck)
			scores[seat] = hand.score
			var text: String = player.display_name + "：" + cards_text(player.hole) + " · " + hand.description
			state.record("攤牌 · " + text)
			if player.aggressive_this_hand and seat > 0:
				# Public, deliberately simple threshold: below two pair = weak.
				if hand.category < 2:
					player.proven_bluffs += 1
				else:
					player.value_bets += 1
		else:
			scores[seat] = 0
	state.awards = PotSystem.settle(state, scores)
	for award in state.awards:
		var player: PlayerState = state.players[award.seat]
		var message := "%s %s %s" % [player.display_name, "取回未跟注籌碼" if award.refund else "贏得", StakeFormat.bb(int(award.amount))]
		if showdown and not award.refund:
			message += " · " + HandEvaluator.evaluate(player.hole + state.board, state.settings.short_deck).description
		descriptions.append(message)
		state.record(message)
		event_occurred.emit("pot_awarded", award)
	state.summary = "\n".join(descriptions)
	if not showdown:
		state.summary += "\n其他玩家棄牌，底牌不公開。"
	for player in state.players:
		player.contribution = 0
		player.street_bet = 0
	# Simultaneous eliminations share rank; starting-stack order is not inferred.
	var remaining := 0
	for player in state.players:
		if player.chips > 0:
			remaining += 1
	for player in state.players:
		if player.chips == 0 and not player.eliminated:
			player.eliminated = true
			player.finish_rank = remaining + 1
			state.record(player.display_name + " 已淘汰")
			event_occurred.emit("player_eliminated", {"seat": player.seat})
	if remaining == 1:
		state.finished = true
		state.champion = state.live_seats()[0]
		state.players[state.champion].finish_rank = 1
	elif state.players[0].eliminated:
		# Human bust ends their match immediately. Surviving AI have no fabricated ranks.
		state.finished = true
	if state.finished:
		event_occurred.emit("match_finished", {"champion": state.champion})

func street_name() -> String:
	return ["翻牌前", "翻牌", "轉牌", "河牌"][state.street]

static func cards_text(cards: Array) -> String:
	var labels: Array[String] = []
	for card in cards:
		labels.append(card.label())
	return " ".join(labels)
