class_name AIObservationQuery
extends RefCounted

# This is the ONLY table -> AI boundary. Never pass state, deck or PlayerState.
# Cards are copied, so an AI cannot mutate domain state through the observation.
static func execute(state: TableState, seat: int) -> Dictionary:
	var player: PlayerState = state.players[seat]
	var opponents: Array = []
	for other in state.players:
		if other.seat != seat and not other.eliminated and not other.folded:
			opponents.append({"seat": other.seat, "chips": other.chips, "bet": other.street_bet,
				"model": _opponent_model(other)})
	var live_seats := state.live_seats()
	var contenders := state.contenders()
	var relative_button := _relative_button_position(live_seats, state.dealer, seat)
	var relative_street := _relative_street_position(contenders, state.dealer, seat)
	return {"hole": copy_cards(player.hole), "board": copy_cards(state.board),
		"opponents": opponents, "pot": state.pot_total(), "chips": player.chips,
		"bet": player.street_bet, "deck_count": state.settings.deck_count(),
		"big_blind": state.settings.big_blind, "legal": BettingSystem.legal(state, seat),
		"history": state.history.duplicate(), "samples": state.settings.simulation_samples,
		"street": state.street, "player_count": contenders.size(), "live_count": live_seats.size(),
		"relative_button": relative_button, "relative_street": relative_street,
		"position_bucket": _position_bucket(relative_button, live_seats.size()),
		"in_position": relative_street >= contenders.size() - 1}

static func copy_cards(cards: Array) -> Array:
	var result: Array = []
	for card in cards:
		result.append(PokerCard.new(card.rank, card.suit, card.copy_id))
	return result

static func _relative_button_position(live_seats: Array, dealer: int, seat: int) -> int:
	if live_seats.is_empty():
		return 0
	var ordered: Array = []
	var dealer_index := live_seats.find(dealer)
	if dealer_index == -1:
		ordered = live_seats.duplicate()
	else:
		for offset in range(live_seats.size()):
			ordered.append(live_seats[(dealer_index + offset) % live_seats.size()])
	return maxi(0, ordered.find(seat))

static func _relative_street_position(contenders: Array, dealer: int, seat: int) -> int:
	if contenders.is_empty():
		return 0
	var start_index := contenders.find(dealer)
	if start_index == -1:
		start_index = 0
	else:
		start_index = (start_index + 1) % contenders.size()
	var ordered: Array = []
	for offset in range(contenders.size()):
		ordered.append(contenders[(start_index + offset) % contenders.size()])
	return maxi(0, ordered.find(seat))

static func _position_bucket(relative_button: int, player_count: int) -> String:
	if player_count <= 2:
		return "late" if relative_button == 0 else "early"
	if relative_button == 0:
		return "late"
	if relative_button >= player_count - 2:
		return "early"
	return "middle"

static func _opponent_model(player: PlayerState) -> Dictionary:
	var hands := maxf(1.0, float(player.hands_played))
	var vpip := float(player.voluntary_puts) / hands
	var call_rate := float(player.call_actions) / hands
	var fold_rate := float(player.fold_to_bet) / hands
	var reraise_rate := float(player.reraises) / hands
	var showdown_aggression := float(player.proven_bluffs + player.value_bets)
	var bluff_showdown_rate := float(player.proven_bluffs) / maxf(1.0, showdown_aggression)
	return {
		"hands": player.hands_played,
		"vpip": vpip,
		"call_rate": call_rate,
		"fold_to_bet_rate": fold_rate,
		"reraise_rate": reraise_rate,
		"bluff_showdown_rate": bluff_showdown_rate,
		"style": _style_from_model(vpip, call_rate, fold_rate, reraise_rate)
	}

static func _style_from_model(vpip: float, call_rate: float, fold_rate: float, reraise_rate: float) -> String:
	if reraise_rate >= 0.18:
		return "reraiser"
	if vpip >= 0.45 and call_rate >= 0.24:
		return "calling_station"
	if vpip >= 0.40:
		return "loose"
	if vpip <= 0.22 or fold_rate >= 0.3:
		return "tight"
	return "balanced"
