class_name StartMatchCommand
extends RefCounted

static func execute(settings: MatchSettings, random_seed: int = -1) -> TurnSystem:
	var match_system := TurnSystem.new()
	match_system.start(settings, random_seed)
	return match_system
