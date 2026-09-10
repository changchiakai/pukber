extends Node

var settings := MatchSettings.new()
var match_system: TurnSystem

func start_match() -> void:
	match_system = StartMatchCommand.execute(settings)
	get_tree().change_scene_to_file("res://scenes/poker_table.tscn")

func show_menu() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func show_result() -> void:
	get_tree().change_scene_to_file("res://scenes/match_result.tscn")

func show_review() -> void:
	get_tree().change_scene_to_file("res://scenes/match_review.tscn")
