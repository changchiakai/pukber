class_name AIObservationQuery
extends RefCounted

# This is the ONLY table -> AI boundary. Never pass state, deck or PlayerState.
# Cards are copied, so an AI cannot mutate domain state through the observation.
static func execute(state: TableState, seat: int) -> Dictionary:
	var player: PlayerState = state.players[seat]
	var opponents: Array = []
	for other in state.players:
		if other.seat != seat and not other.eliminated and not other.folded:
			opponents.append({"seat": other.seat, "chips": other.chips, "bet": other.street_bet})
	return {"hole": copy_cards(player.hole), "board": copy_cards(state.board),
		"opponents": opponents, "pot": state.pot_total(), "chips": player.chips,
		"bet": player.street_bet, "deck_count": state.settings.deck_count(),
		"big_blind": state.settings.big_blind, "legal": BettingSystem.legal(state, seat),
		"history": state.history.duplicate(), "samples": state.settings.simulation_samples}

static func copy_cards(cards: Array) -> Array:
	var result: Array = []
	for card in cards:
		result.append(PokerCard.new(card.rank, card.suit, card.copy_id))
	return result
