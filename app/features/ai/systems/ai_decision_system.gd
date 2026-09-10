class_name AIDecisionSystem
extends RefCounted

static func estimate_equity(observation: Dictionary, rng: RandomNumberGenerator) -> float:
	var unseen := PokerDeck.new(observation.deck_count).cards
	var known: Dictionary = {}
	for card in observation.hole + observation.board:
		known[card.identity()] = true
	unseen = unseen.filter(func(card): return not known.has(card.identity()))
	var samples := maxi(1, int(observation.samples))
	var equity := 0.0
	var draws: int = 5 - observation.board.size() + observation.opponents.size() * 2
	for _sample in range(samples):
		# Partial Fisher-Yates; only draw what this simulation needs.
		var pool := unseen.duplicate()
		for index in range(draws):
			var other := rng.randi_range(index, pool.size() - 1)
			var temp = pool[index]
			pool[index] = pool[other]
			pool[other] = temp
		var missing: int = 5 - observation.board.size()
		var board: Array = observation.board + pool.slice(0, missing)
		var hero: int = HandEvaluator.evaluate(observation.hole + board).score
		var ties := 1
		var lost := false
		for opponent in range(observation.opponents.size()):
			var start := missing + opponent * 2
			var score: int = HandEvaluator.evaluate(pool.slice(start, start + 2) + board).score
			if score > hero:
				lost = true
				break
			if score == hero:
				ties += 1
		if not lost:
			equity += 1.0 / ties
	return equity / samples

static func decide(observation: Dictionary, profile: AIProfile) -> Dictionary:
	var equity := estimate_equity(observation, profile.rng)
	return choose(observation, profile, equity)

static func choose(observation: Dictionary, profile: AIProfile, equity: float) -> Dictionary:
	var legal: Dictionary = observation.legal
	var fair_share: float = 1.0 / (observation.opponents.size() + 1)
	var strength := clampf(equity + profile.rng.randf_range(-0.05, 0.05), 0.0, 1.0)
	var strong: bool = strength > fair_share + 0.12
	var bluff: bool = not strong and profile.rng.randf() < profile.bluff_rate
	var pot_odds := float(legal.call) / maxf(1.0, observation.pot + legal.call)
	var action := "check" if legal.check else "call"
	var amount := 0
	var budget := int(observation.chips * (0.22 if bluff else 0.65))
	if legal.can_raise and (strong or bluff) and profile.rng.randf() < profile.aggression:
		var target := int(observation.bet + legal.call + maxi(observation.big_blind, int(observation.pot * (0.45 if bluff else 0.65))))
		amount = mini(legal.max_to, maxi(legal.min_to, target))
		if amount - int(observation.bet) <= budget or (strong and strength > 0.72):
			action = "raise"
	if action != "raise" and not legal.check:
		if strength + profile.risk_tolerance < pot_odds or (legal.call > observation.chips * 0.45 and strength < fair_share and not bluff):
			action = "fold"
	var claim_strong := strong
	if profile.rng.randf() < (0.65 if profile.is_liar else 0.08):
		claim_strong = not claim_strong
	var speech := "我這把很強" if claim_strong else "這手不太好"
	return {"action": action, "amount": amount, "speech": speech}
