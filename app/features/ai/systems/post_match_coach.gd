class_name PostMatchCoach
extends RefCounted

# Offline equity-and-pot-odds coaching. This ranks a player's finished-match
# decisions; it is deliberately not presented as a solved GTO strategy.
static func top_decisions(decisions: Array[Dictionary], limit: int = 3) -> Array[Dictionary]:
	var reviewed: Array[Dictionary] = []
	for decision in decisions:
		reviewed.append(_review(decision))
	reviewed.sort_custom(func(left, right): return float(left.impact) > float(right.impact))
	return reviewed.slice(0, mini(limit, reviewed.size()))

static func _review(decision: Dictionary) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = int(decision.hand) * 1009 + int(decision.street) * 97 + int(decision.pot)
	var opponents: Array = decision.opponents
	var equity := AIDecisionSystem.estimate_equity({
		"deck_count": 1, "hole": decision.hole, "board": decision.board,
		"opponents": opponents, "samples": 144
	}, rng)
	var legal: Dictionary = decision.legal
	var call_amount := int(legal.call)
	var pot_odds := float(call_amount) / maxf(1.0, float(int(decision.pot) + call_amount))
	var fair_share := 1.0 / maxf(1.0, float(opponents.size() + 1))
	var action := String(decision.action)
	var gap := 0.0
	var recommendation := "保留彈性，觀察下一街。"
	var reason := "此時沒有明顯偏離基於權益與底池賠率的保守策略。"
	if action == "fold":
		gap = maxf(0.0, equity - pot_odds - 0.04)
		if gap > 0.0:
			recommendation = "較值得考慮跟注"
			reason = "估計權益 %.0f%% 高於所需的 %.0f%%；棄牌可能過度放棄底池。" % [equity * 100.0, pot_odds * 100.0]
	elif action == "call":
		gap = maxf(0.0, pot_odds - equity - 0.03)
		if gap > 0.0:
			recommendation = "較值得考慮棄牌"
			reason = "估計權益 %.0f%% 低於跟注所需的 %.0f%%；這次跟注承受較高風險。" % [equity * 100.0, pot_odds * 100.0]
	elif action == "raise" or action == "all_in":
		gap = maxf(0.0, fair_share + 0.10 - equity)
		if gap > 0.0:
			recommendation = "較值得放慢節奏"
			reason = "估計權益僅 %.0f%%；在多人池主動加注需要更清楚的棄牌權益或讀牌依據。" % [equity * 100.0]
	elif action == "check":
		gap = maxf(0.0, equity - 0.68) * 0.55
		if gap > 0.0:
			recommendation = "可考慮小額價值下注"
			reason = "估計權益 %.0f%%；在可免費過牌的局面，強牌常能用小尺寸累積價值。" % [equity * 100.0]
	var impact := gap * maxf(float(decision.pot), float(decision.big_blind))
	return decision.merged({"equity": equity, "impact": impact, "recommendation": recommendation, "reason": reason})

static func street_name(street: int) -> String:
	return ["翻牌前", "翻牌", "轉牌", "河牌"][clampi(street, 0, 3)]

static func action_name(action: String) -> String:
	return {"fold": "棄牌", "check": "過牌", "call": "跟注", "raise": "加注", "all_in": "全下"}.get(action, action)
