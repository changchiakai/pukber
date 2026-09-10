class_name TableState
extends RefCounted

var settings: MatchSettings
var players: Array = []
var deck: PokerDeck
var board: Array = []
var dealer: int = -1
var small_blind_seat: int = -1
var big_blind_seat: int = -1
var actor: int = -1
var street: int = 0
var current_bet: int = 0
var min_raise: int = 100
# Last price at which each seat acted; cumulative short raises can reopen action.
var acted_at: Dictionary = {}
var hand_number: int = 0
var hand_over: bool = false
var finished: bool = false
var champion: int = -1
var history: Array[String] = []
var summary: String = ""
var awards: Array = []

func live_seats() -> Array:
	var result: Array = []
	for player in players:
		if not player.eliminated:
			result.append(player.seat)
	return result

func contenders() -> Array:
	var result: Array = []
	for player in players:
		if not player.eliminated and not player.folded:
			result.append(player.seat)
	return result

func pot_total() -> int:
	var total := 0
	for player in players:
		total += player.contribution
	return total

func record(message: String) -> void:
	history.append("第 %d 手 · %s" % [hand_number, message])
	if history.size() > 300:
		history.pop_front()
