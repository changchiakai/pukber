class_name PokerCard
extends RefCounted

var rank: int
var suit: int
var copy_id: int

func _init(value: int = 2, color: int = 0, copy: int = 0) -> void:
	rank = value
	suit = color
	copy_id = copy

func label() -> String:
	return ["♠", "♥", "♦", "♣"][suit] + rank_label(rank)

static func rank_label(value: int) -> String:
	return {14: "A", 13: "K", 12: "Q", 11: "J"}.get(value, str(value))

func identity() -> String:
	return "%d:%d:%d" % [rank, suit, copy_id]
