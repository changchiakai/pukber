class_name PotSystem
extends RefCounted

static func build(players: Array) -> Array:
	var levels: Array = []
	for player in players:
		if player.contribution > 0 and not player.contribution in levels:
			levels.append(player.contribution)
	levels.sort()
	var pots: Array = []
	var previous := 0
	for level in levels:
		var contributors: Array = []
		var eligible: Array = []
		for player in players:
			if player.contribution >= level:
				contributors.append(player.seat)
				if not player.folded:
					eligible.append(player.seat)
		pots.append({"amount": (level - previous) * contributors.size(), "eligible": eligible,
			"contributors": contributors, "refund": contributors.size() == 1})
		previous = level
	return pots

static func settle(state: TableState, scores: Dictionary) -> Array:
	var awards: Array = []
	for pot in build(state.players):
		var winners: Array = []
		if pot.refund:
			winners = pot.contributors.duplicate()
		else:
			var best := -1
			for seat in pot.eligible:
				var score: int = scores.get(seat, 0)
				if score > best:
					best = score
					winners = [seat]
				elif score == best:
					winners.append(seat)
		assert(not winners.is_empty(), "底池必須有合法得主")
		# Odd chips go clockwise from the button, independently for each pot.
		winners.sort_custom(func(a, b): return posmod(a - state.dealer - 1, state.players.size()) < posmod(b - state.dealer - 1, state.players.size()))
		var share := int(pot.amount / winners.size())
		var remainder := int(pot.amount) % winners.size()
		for i in range(winners.size()):
			var amount := share + (1 if i < remainder else 0)
			state.players[winners[i]].chips += amount
			awards.append({"seat": winners[i], "amount": amount, "refund": pot.refund})
	return awards
