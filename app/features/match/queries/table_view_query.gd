class_name TableViewQuery
extends RefCounted

static func execute(state: TableState) -> Dictionary:
	var seats: Array = []
	for player in state.players:
		var badges: Array[String] = []
		if player.seat == state.dealer:
			badges.append("莊家")
		if player.seat == state.small_blind_seat:
			badges.append("小盲")
		if player.seat == state.big_blind_seat:
			badges.append("大盲")
		seats.append({"seat": player.seat, "name": player.display_name, "chips": player.chips,
			"bet": player.street_bet, "contribution": player.contribution, "badges": " / ".join(badges),
			"cards": player.hole.duplicate() if player.seat == 0 or player.revealed else [],
			"folded": player.folded, "eliminated": player.eliminated, "action": player.last_action,
			"bubble": player.bubble, "raises": player.raises, "bluffs": player.proven_bluffs, "value": player.value_bets})
	return {"seats": seats, "pots": PotSystem.build(state.players), "board": state.board.duplicate(),
		"legal": BettingSystem.legal(state, 0), "summary": state.summary}
