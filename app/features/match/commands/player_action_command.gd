class_name PlayerActionCommand
extends RefCounted

static func execute(match_system: TurnSystem, action: String, amount: int = 0) -> String:
	return match_system.act(0, action, amount)
