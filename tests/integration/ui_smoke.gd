extends SceneTree

var failures := 0
var app: Node

func _initialize() -> void:
	call_deferred("run")

func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		printerr("FAIL UI: " + message)

func frames(count: int = 3) -> void:
	for index in range(count):
		await process_frame

func screenshot(filename: String) -> void:
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	check(image.save_png(ProjectSettings.globalize_path("res://test-results/" + filename)) == OK, "save screenshot")

func click_button(button: Button) -> void:
	check(button != null and not button.disabled, "button enabled")
	if not button or button.disabled:
		return
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.position = button.get_global_rect().get_center()
	event.pressed = true
	root.push_input(event, true)
	await process_frame
	event = event.duplicate()
	event.pressed = false
	root.push_input(event, true)
	await frames()

func run() -> void:
	check(DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://test-results")) == OK, "create screenshot directory")
	app = root.get_node("App")
	change_scene_to_file("res://scenes/main_menu.tscn")
	await frames(10)
	await screenshot("menu.png")
	var menu := current_scene
	menu.count.select(3)
	menu.attitude.select(1)
	await click_button(menu.find_child("StartGame", true, false))
	await frames(10)
	check(current_scene.name == "PokerTable", "menu to table")
	if app.match_system == null:
		quit(1)
		return
	check(app.match_system.state.players.size() == 5, "selected four AI")
	check(app.match_system.state.settings.liars_majority == false, "selected honest majority")
	# Wait only for actual AI timers; human must remain the decision-maker.
	Engine.time_scale = 15.0
	var waited := 0
	while app.match_system.state.actor != 0 and waited < 500:
		await process_frame
		waited += 1
	Engine.time_scale = 1.0
	await screenshot("table.png")
	var old_actor: int = app.match_system.state.actor
	var old_history: int = app.match_system.state.history.size()
	await create_timer(1.0).timeout
	check(app.match_system.state.actor == old_actor and app.match_system.state.history.size() == old_history, "human turn waits for input")
	Engine.time_scale = 30.0
	var steps := 0
	var first_settlement := false
	while not app.match_system.state.finished and steps < 15000:
		var state: TableState = app.match_system.state
		if state.hand_over:
			if not first_settlement:
				await screenshot("settlement.png")
				first_settlement = true
			await click_button(current_scene.find_child("NextHand", true, false))
		elif state.actor == 0:
			var all_in: Button = current_scene.find_child("AllIn", true, false)
			var call: Button = current_scene.find_child("CheckCall", true, false)
			await click_button(all_in if first_settlement and not all_in.disabled else call)
		else:
			await process_frame
		steps += 1
	check(app.match_system.state.finished, "full match reaches result")
	if app.match_system.state.finished:
		if not first_settlement:
			await screenshot("settlement.png")
		await click_button(current_scene.find_child("NextHand", true, false))
		check(current_scene.name == "MatchResult", "results route")
		Engine.time_scale = 1.0
		await screenshot("result.png")
		await click_button(current_scene.find_child("Restart", true, false))
		check(current_scene.name == "PokerTable" and app.match_system.state.hand_number == 1, "restart creates new match")
		for player in app.match_system.state.players:
			check(player.chips + player.contribution == 10000, "restart restores 10000")
		app.show_result()
		await frames()
		await click_button(current_scene.find_child("BackToMenu", true, false))
		check(current_scene.name == "MainMenu", "back to menu")
	print("UI SMOKE: %d failures; actual mouse input, menu/table/result/restart verified" % failures)
	quit(1 if failures else 0)
