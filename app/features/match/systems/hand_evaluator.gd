class_name HandEvaluator
extends RefCounted

const NAMES = ["高牌", "一對", "兩對", "三條", "順子", "同花", "葫蘆", "四條", "同花順", "五條"]

# Direct best-five evaluation for standard hold'em hands.
# The score encodes category and rank order only. Suits identify physical cards,
# but never affect a hand's category or tie-break.
static func evaluate(cards: Array, short_deck: bool = false) -> Dictionary:
	assert(cards.size() >= 5)
	var counts: Dictionary = {}
	var by_rank: Dictionary = {}
	var suits: Array = [[], [], [], []]
	for card in cards:
		counts[card.rank] = counts.get(card.rank, 0) + 1
		if not by_rank.has(card.rank):
			by_rank[card.rank] = []
		by_rank[card.rank].append(card)
		suits[card.suit].append(card)
	for rank in by_rank.keys():
		var ranked_cards: Array = by_rank[rank]
		ranked_cards.sort_custom(func(a, b): return compare_cards_desc(a, b))
		by_rank[rank] = ranked_cards
	for suit in range(suits.size()):
		var suited_cards: Array = suits[suit]
		suited_cards.sort_custom(func(a, b): return compare_cards_desc(a, b))
		suits[suit] = suited_cards
	var ranks: Array = by_rank.keys()
	ranks.sort()
	ranks.reverse()
	var pairs: Array = []
	var trips: Array = []
	var quads: Array = []
	for rank in ranks:
		if counts[rank] >= 5:
			return result(9, [rank], by_rank[rank].slice(0, 5))
		if counts[rank] >= 4:
			quads.append(rank)
		if counts[rank] >= 3:
			trips.append(rank)
		if counts[rank] >= 2:
			pairs.append(rank)
	var best_flush: Dictionary = {}
	var best_straight_flush: Dictionary = {}
	for suited in suits:
		if suited.size() >= 5:
			var straight_flush_cards := best_straight_cards(suited, short_deck)
			if not straight_flush_cards.is_empty():
				var straight_flush := result(8, [straight_flush_cards[0].rank], straight_flush_cards)
				if best_straight_flush.is_empty() or straight_flush.score > best_straight_flush.score:
					best_straight_flush = straight_flush
			var flush_cards: Array = suited.slice(0, 5)
			var flush := result(5, card_ranks(flush_cards), flush_cards, short_deck)
			if best_flush.is_empty() or flush.score > best_flush.score:
				best_flush = flush
	if not best_straight_flush.is_empty():
		return best_straight_flush
	if not quads.is_empty():
		var quad_cards: Array = by_rank[quads[0]].slice(0, 4)
		var quad_kicker_cards := top_cards_excluding(ranks, by_rank, [quads[0]], 1)
		return result(7, [quads[0], excluding(ranks, [quads[0]])[0]], quad_cards + quad_kicker_cards)
	if not trips.is_empty():
		var other_pairs := excluding(pairs, [trips[0]])
		if not other_pairs.is_empty():
			var trip_cards: Array = by_rank[trips[0]].slice(0, 3)
			var pair_cards: Array = by_rank[other_pairs[0]].slice(0, 2)
			return result(6, [trips[0], other_pairs[0]], trip_cards + pair_cards, short_deck)
	if not best_flush.is_empty():
		return best_flush
	var straight_cards := best_straight_cards(cards, short_deck)
	if not straight_cards.is_empty():
		return result(4, [straight_cards[0].rank], straight_cards)
	if not trips.is_empty():
		var trips_cards: Array = by_rank[trips[0]].slice(0, 3)
		var trip_kickers := top_cards_excluding(ranks, by_rank, [trips[0]], 2)
		return result(3, [trips[0]] + excluding(ranks, [trips[0]]).slice(0, 2), trips_cards + trip_kickers)
	if pairs.size() >= 2:
		var high_pair_cards: Array = by_rank[pairs[0]].slice(0, 2)
		var low_pair_cards: Array = by_rank[pairs[1]].slice(0, 2)
		var two_pair_kicker := top_cards_excluding(ranks, by_rank, pairs.slice(0, 2), 1)
		return result(2, pairs.slice(0, 2) + excluding(ranks, pairs.slice(0, 2)).slice(0, 1), high_pair_cards + low_pair_cards + two_pair_kicker)
	if pairs.size() == 1:
		var pair_cards: Array = by_rank[pairs[0]].slice(0, 2)
		var pair_kickers := top_cards_excluding(ranks, by_rank, pairs, 3)
		return result(1, [pairs[0]] + excluding(ranks, pairs).slice(0, 3), pair_cards + pair_kickers)
	var high_cards := top_cards(cards, 5)
	return result(0, card_ranks(high_cards), high_cards)

static func compare_cards_desc(a, b) -> bool:
	if a.rank == b.rank:
		return a.copy_id > b.copy_id
	return a.rank > b.rank

static func top_cards(cards: Array, count: int) -> Array:
	var ordered := cards.duplicate()
	ordered.sort_custom(func(a, b): return compare_cards_desc(a, b))
	return ordered.slice(0, mini(count, ordered.size()))

static func top_cards_excluding(ranks: Array, by_rank: Dictionary, excluded: Array, count: int) -> Array:
	var chosen: Array = []
	for rank in ranks:
		if rank in excluded:
			continue
		for card in by_rank[rank]:
			chosen.append(card)
			if chosen.size() == count:
				return chosen
	return chosen

static func card_ranks(cards: Array) -> Array:
	var ranks: Array = []
	for card in cards:
		ranks.append(card.rank)
	return ranks

static func excluding(values: Array, excluded: Array) -> Array:
	return values.filter(func(value): return not value in excluded)

static func straight_high(values: Array, short_deck: bool = false) -> int:
	var unique: Dictionary = {}
	for rank in values:
		unique[rank] = true
	if unique.has(14):
		unique[1] = true
	if short_deck and unique.has(14) and unique.has(6) and unique.has(7) and unique.has(8) and unique.has(9):
		return 9
	for high in range(14, 4, -1):
		var found := true
		for offset in range(5):
			if not unique.has(high - offset):
				found = false
				break
		if found:
			return high
	return 0

static func best_straight_cards(cards: Array, short_deck: bool = false) -> Array:
	var by_rank: Dictionary = {}
	for card in cards:
		if not by_rank.has(card.rank):
			by_rank[card.rank] = []
		by_rank[card.rank].append(card)
	for rank in by_rank.keys():
		var ranked_cards: Array = by_rank[rank]
		ranked_cards.sort_custom(func(a, b): return compare_cards_desc(a, b))
		by_rank[rank] = ranked_cards
	var ranks: Array = by_rank.keys()
	var high := straight_high(ranks, short_deck)
	if high == 0:
		return []
	var chosen: Array = []
	var targets: Array[int] = []
	if short_deck and high == 9 and by_rank.has(14) and by_rank.has(6):
		targets.append(9)
		targets.append(8)
		targets.append(7)
		targets.append(6)
		targets.append(14)
	for offset in range(5):
		var target: int = targets[offset] if not targets.is_empty() else high - offset
		var rank: int = 14 if target == 1 else target
		chosen.append(by_rank[rank][0])
	return chosen

static func result(category: int, kickers: Array, ordered_cards: Array = [], short_deck: bool = false) -> Dictionary:
	var score_category := category
	if short_deck and category == 5:
		score_category = 6
	elif short_deck and category == 6:
		score_category = 5
	var score := score_category
	for index in range(5):
		var rank_value := int(kickers[index]) if index < kickers.size() else 0
		if index < ordered_cards.size():
			rank_value = int(ordered_cards[index].rank)
		score = score * 15 + rank_value
	var labels: Array[String] = []
	if not ordered_cards.is_empty():
		for card in ordered_cards:
			labels.append(card.label())
	else:
		for rank in kickers:
			labels.append(PokerCard.rank_label(rank))
	var title: String = NAMES[category]
	if category == 8 and kickers[0] == 14:
		title = "皇家同花順"
	return {"category": category, "kickers": kickers, "score": score,
		"description": title + "（比較順序：" + "、".join(labels) + "）"}
