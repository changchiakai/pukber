extends Node

var settings := MatchSettings.new()
var match_system: TurnSystem

func start_match() -> void:
	match_system = StartMatchCommand.execute(settings)
	match_system.event_occurred.connect(_on_match_event)
	Analytics.track("game_started", {
		"ai_count": settings.ai_count,
		"initial_bb": settings.initial_chips / settings.big_blind,
		"short_deck": settings.short_deck
	})
	get_tree().change_scene_to_file("res://scenes/poker_table.tscn")

func show_menu() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func show_result() -> void:
	get_tree().change_scene_to_file("res://scenes/match_result.tscn")

func show_review() -> void:
	Analytics.track("review_opened", {"short_deck": settings.short_deck})
	get_tree().change_scene_to_file("res://scenes/match_review.tscn")

func _on_match_event(event_name: String, details: Dictionary) -> void:
	if match_system == null:
		return
	var state: TableState = match_system.state
	match event_name:
		"hand_started":
			Analytics.track("hand_started", {"hand": int(details.get("hand", 0)), "short_deck": settings.short_deck})
		"player_acted":
			if int(details.get("seat", -1)) == 0:
				Analytics.track("player_action", {"hand": state.hand_number, "street": state.street,
					"action": str(details.get("action", "unknown")), "short_deck": settings.short_deck})
		"hand_finished":
			Analytics.track("hand_finished", {"hand": int(details.get("hand", 0)),
				"showdown": bool(details.get("showdown", false)), "short_deck": settings.short_deck})
		"match_finished":
			Analytics.track("match_finished", {"hands_played": state.hand_number,
				"champion_is_human": int(details.get("champion", -1)) == 0, "short_deck": settings.short_deck})
