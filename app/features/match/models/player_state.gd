class_name PlayerState
extends RefCounted

var seat: int
var display_name: String
var chips: int = 10000
var hole: Array = []
var street_bet: int = 0
var contribution: int = 0
var folded: bool = false
var eliminated: bool = false
var revealed: bool = false
var last_action: String = "等待發牌"
var bubble: String = ""
var profile: AIProfile
var raises: int = 0
var proven_bluffs: int = 0
var value_bets: int = 0
var hands_played: int = 0
var voluntary_puts: int = 0
var call_actions: int = 0
var fold_to_bet: int = 0
var reraises: int = 0
var aggressive_this_hand: bool = false
var finish_rank: int = 0
var entered_pot_this_hand: bool = false

func _init(index: int = 0) -> void:
	seat = index
	display_name = "你" if index == 0 else ["", "毛毛", "小高", "枯枝", "小明"][index]

func reset_hand() -> void:
	hole.clear()
	street_bet = 0
	contribution = 0
	folded = eliminated
	revealed = false
	last_action = "已離桌" if eliminated else "等待行動"
	bubble = ""
	aggressive_this_hand = false
	entered_pot_this_hand = false

func can_act() -> bool:
	return not eliminated and not folded and chips > 0
