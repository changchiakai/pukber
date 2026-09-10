class_name HandEvaluator
extends RefCounted

const NAMES = ["高牌", "一對", "兩對", "三條", "順子", "同花", "葫蘆", "四條", "同花順", "五條"]

# Direct best-five evaluation supports repeated rank AND suit across copies.
# The base-15 score encodes category followed by all tie breakers.
static func evaluate(cards: Array) -> Dictionary:
	assert(cards.size() >= 5)
	var counts: Dictionary = {}
	var suits: Array = [[], [], [], []]
	for card in cards:
		counts[card.rank] = counts.get(card.rank, 0) + 1
		suits[card.suit].append(card.rank)
	var ranks: Array = counts.keys()
	ranks.sort()
	ranks.reverse()
	var pairs: Array = []
	var trips: Array = []
	var quads: Array = []
	for rank in ranks:
		if counts[rank] >= 5:
			return result(9, [rank])
		if counts[rank] >= 4:
			quads.append(rank)
		if counts[rank] >= 3:
			trips.append(rank)
		if counts[rank] >= 2:
			pairs.append(rank)
	var best_flush: Dictionary = {}
	var best_straight_flush := 0
	for suited in suits:
		if suited.size() >= 5:
			best_straight_flush = maxi(best_straight_flush, straight_high(suited))
			suited.sort()
			suited.reverse()
			var flush := result(5, suited.slice(0, 5))
			if best_flush.is_empty() or flush.score > best_flush.score:
				best_flush = flush
	if best_straight_flush > 0:
		return result(8, [best_straight_flush])
	if not quads.is_empty():
		return result(7, [quads[0], excluding(ranks, [quads[0]])[0]])
	if not trips.is_empty():
		var other_pairs := excluding(pairs, [trips[0]])
		if not other_pairs.is_empty():
			return result(6, [trips[0], other_pairs[0]])
	if not best_flush.is_empty():
		return best_flush
	var straight := straight_high(ranks)
	if straight > 0:
		return result(4, [straight])
	if not trips.is_empty():
		return result(3, [trips[0]] + excluding(ranks, [trips[0]]).slice(0, 2))
	if pairs.size() >= 2:
		return result(2, pairs.slice(0, 2) + excluding(ranks, pairs.slice(0, 2)).slice(0, 1))
	if pairs.size() == 1:
		return result(1, [pairs[0]] + excluding(ranks, pairs).slice(0, 3))
	return result(0, ranks.slice(0, 5))

static func excluding(values: Array, excluded: Array) -> Array:
	return values.filter(func(value): return not value in excluded)

static func straight_high(values: Array) -> int:
	var unique: Dictionary = {}
	for rank in values:
		unique[rank] = true
	if unique.has(14):
		unique[1] = true
	for high in range(14, 4, -1):
		var found := true
		for offset in range(5):
			if not unique.has(high - offset):
				found = false
				break
		if found:
			return high
	return 0

static func result(category: int, kickers: Array) -> Dictionary:
	var score := category
	for index in range(5):
		score = score * 15 + (int(kickers[index]) if index < kickers.size() else 0)
	var labels: Array[String] = []
	for rank in kickers:
		labels.append(PokerCard.rank_label(rank))
	var title: String = NAMES[category]
	if category == 8 and kickers[0] == 14:
		title = "皇家同花順"
	return {"category": category, "kickers": kickers, "score": score,
		"description": title + "（比較順序：" + "、".join(labels) + "）"}
