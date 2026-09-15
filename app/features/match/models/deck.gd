class_name PokerDeck
extends RefCounted

var cards: Array = []

func _init(copies: int = 1, short_deck: bool = false) -> void:
	for copy in range(copies):
		for suit in range(4):
			for rank in range(6 if short_deck else 2, 15):
				cards.append(PokerCard.new(rank, suit, copy))

func shuffle_with(rng: RandomNumberGenerator) -> void:
	for i in range(cards.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var temp = cards[i]
		cards[i] = cards[j]
		cards[j] = temp

func draw() -> PokerCard:
	assert(not cards.is_empty(), "牌堆不足")
	return cards.pop_back()
