extends SceneTree

var failures := 0
var total_hands := 0
var total_actions := 0

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	for seed_value in range(160):
		var settings := MatchSettings.new()
		settings.ai_count = seed_value % 4 + 1
		settings.liars_majority = seed_value % 2 == 0
		settings.simulation_samples = 12
		var game := StartMatchCommand.execute(settings, seed_value)
		var state := game.state
		var rng := RandomNumberGenerator.new()
		rng.seed = seed_value + 1000
		var actions := 0
		while not state.finished and actions < 25000:
			if state.hand_over:
				game.begin_hand()
				continue
			var seat := state.actor
			if seat < 0:
				fail("stalled actor", seed_value)
				break
			var legal := BettingSystem.legal(state, seat)
			var action := "check" if legal.check else "call"
			var amount := 0
			if seed_value < 24 and seat > 0:
				var decision := AIDecisionSystem.decide(AIObservationQuery.execute(state, seat), state.players[seat].profile)
				action = decision.action
				amount = decision.amount
			else:
				var roll := rng.randf()
				if roll < 0.12:
					action = "fold"
				elif roll < 0.32 and legal.all_in:
					action = "all_in"
				elif roll < 0.57 and legal.can_raise:
					action = "raise"
					amount = mini(legal.max_to, legal.min_to + rng.randi_range(0, 500))
			var error := game.act(seat, action, amount)
			if not error.is_empty():
				fail(error, seed_value)
				break
			var chips := state.pot_total()
			for player in state.players:
				chips += player.chips
				if player.chips < 0:
					fail("negative chips", seed_value)
			if chips != (settings.ai_count + 1) * settings.initial_chips:
				fail("chip conservation", seed_value)
				break
			actions += 1
		if not state.finished:
			fail("match did not finish", seed_value)
		total_hands += state.hand_number
		total_actions += actions
		if seed_value % 20 == 19:
			print("SIMULATION: %d/160 matches completed" % (seed_value + 1))
	print("SIMULATION: 160 matches, %d hands, %d actions, %d failures" % [total_hands, total_actions, failures])
	quit(1 if failures else 0)

func fail(message: String, seed_value: int) -> void:
	failures += 1
	printerr("FAIL seed %d: %s" % [seed_value, message])
