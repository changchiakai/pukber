class_name MatchSettings
extends RefCounted

var ai_count: int = 3
var liars_majority: bool = true
var initial_chips: int = 10000
var small_blind: int = 50
var big_blind: int = 100
# Reserved for a future practice UI; normal mode never exposes equity.
var show_practice_equity: bool = false
var simulation_samples: int = 48

func deck_count() -> int:
	return (ai_count + 1) * 2
