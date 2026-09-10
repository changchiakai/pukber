extends SceneTree

var checks: int = 0
var failures: int = 0

func _initialize() -> void:
	call_deferred("run")

func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		printerr("FAIL: " + message)

func cards(ranks: Array, suits: Array = []) -> Array:
	var result: Array = []
	for index in range(ranks.size()):
		result.append(PokerCard.new(ranks[index], suits[index] if not suits.is_empty() else index % 4, index))
	return result

func make_ai_observation(overrides: Dictionary = {}) -> Dictionary:
	var result := {
		"hole": cards([14, 13], [0, 1]),
		"board": [],
		"opponents": [{"seat": 1}, {"seat": 2}, {"seat": 3}],
		"pot": 1000,
		"chips": 10000,
		"bet": 0,
		"big_blind": 100,
		"legal": {"check": true, "call": 0, "can_raise": true, "max_to": 10000, "min_to": 100},
		"street": 0,
		"player_count": 4,
		"live_count": 4,
		"relative_button": 1,
		"relative_street": 1,
		"position_bucket": "middle",
		"in_position": false
	}
	for key in overrides.keys():
		result[key] = overrides[key]
	return result

func count_ai_raises(observation: Dictionary, liar: bool, equity: float, samples: int) -> int:
	var raises := 0
	for sample in range(samples):
		var profile := AIProfile.new(liar, 1000 + sample)
		if AIDecisionSystem.choose(observation, profile, equity).action == "raise":
			raises += 1
	return raises

func average_raise_amount(observation: Dictionary, liar: bool, equity: float, samples: int) -> float:
	var total := 0.0
	var raises := 0
	for sample in range(samples):
		var profile := AIProfile.new(liar, 2000 + sample)
		var decision := AIDecisionSystem.choose(observation, profile, equity)
		if decision.action == "raise":
			total += decision.amount
			raises += 1
	return total / maxf(1.0, raises)

func count_ai_actions(observation: Dictionary, liar: bool, equity: float, samples: int, action_name: String) -> int:
	var matches := 0
	for sample in range(samples):
		var profile := AIProfile.new(liar, 2500 + sample)
		if AIDecisionSystem.choose(observation, profile, equity).action == action_name:
			matches += 1
	return matches

func count_planned_turn_raises(flop_observation: Dictionary, turn_observation: Dictionary, liar: bool, flop_equity: float, turn_equity: float, samples: int) -> int:
	var raises := 0
	for sample in range(samples):
		var profile := AIProfile.new(liar, 3000 + sample)
		AIDecisionSystem.choose(flop_observation, profile, flop_equity)
		if AIDecisionSystem.choose(turn_observation, profile, turn_equity).action == "raise":
			raises += 1
	return raises

func run() -> void:
	test_deck()
	test_evaluator()
	test_betting()
	test_pots()
	test_flow()
	test_privacy_and_ai()
	print("RULES: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)

func test_deck() -> void:
	for count in range(1, 5):
		var settings := MatchSettings.new()
		settings.ai_count = count
		var deck := PokerDeck.new(settings.deck_count())
		check(deck.cards.size() == 52, "correct deck size")
		var identities := {}
		for card in deck.cards:
			identities[card.identity()] = true
		check(identities.size() == deck.cards.size(), "physical cards unique")

func test_evaluator() -> void:
	var fixtures: Array = [
		[[14, 11, 9, 6, 3], [], 0], [[14, 14, 9, 6, 3], [], 1],
		[[14, 14, 8, 8, 13], [], 2], [[7, 7, 7, 14, 3], [], 3],
		[[14, 2, 3, 4, 5], [], 4], [[14, 11, 9, 6, 3], [0, 0, 0, 0, 0], 5],
		[[8, 8, 8, 5, 5], [], 6], [[9, 9, 9, 9, 14], [], 7],
		[[10, 11, 12, 13, 14], [0, 0, 0, 0, 0], 8], [[2, 2, 2, 2, 2], [], 9]]
	var previous := -1
	for fixture in fixtures:
		var hand := HandEvaluator.evaluate(cards(fixture[0], fixture[1]))
		check(hand.category == fixture[2], "category %d" % fixture[2])
		check(hand.score > previous, "category ordering")
		previous = hand.score
	check(HandEvaluator.evaluate(cards([14, 2, 3, 4, 5])).kickers == [5], "wheel")
	check(HandEvaluator.evaluate(cards([14, 2, 3, 4, 5, 6, 9])).kickers == [6], "highest straight")
	check(HandEvaluator.evaluate(cards([14, 14, 14, 13, 13, 13, 2])).kickers == [14, 13], "two triples full house")
	check(HandEvaluator.evaluate(cards([14, 14, 13, 13, 12, 12, 11])).kickers == [14, 13, 12], "three pairs kicker")
	check(HandEvaluator.evaluate(cards([10, 11, 12, 13, 14], [0, 0, 0, 0, 0])).category == 8, "royal flush is straight flush")
	check(HandEvaluator.evaluate(cards([14, 13, 12, 10, 8], [0, 0, 0, 0, 0])).kickers == [14, 13, 12, 10, 8], "flush keeps top five ranks")
	check(HandEvaluator.evaluate(cards([14, 13, 12, 11, 10])).category == 4, "broadway straight without flush")
	check(HandEvaluator.evaluate(cards([14, 14, 8, 8, 13])).score > HandEvaluator.evaluate(cards([14, 14, 8, 8, 12])).score, "kicker comparison")
	check(HandEvaluator.evaluate(cards([14, 13, 11, 9, 7], [0, 1, 2, 3, 0])).score > HandEvaluator.evaluate(cards([14, 13, 11, 9, 7], [1, 1, 2, 3, 0])).score, "suit ordering breaks rank ties")
	check("♠" in HandEvaluator.evaluate(cards([14, 13, 11, 9, 7], [0, 1, 2, 3, 0])).description, "description shows suit order")
	var rng := RandomNumberGenerator.new()
	rng.seed = 842
	for iteration in range(250):
		var deck := PokerDeck.new(1)
		deck.shuffle_with(rng)
		var seven := deck.cards.slice(0, 7)
		var best := -1
		for a in range(7):
			for b in range(a + 1, 7):
				var five: Array = []
				for c in range(7):
					if c != a and c != b:
						five.append(seven[c])
				best = maxi(best, HandEvaluator.evaluate(five).score)
		check(HandEvaluator.evaluate(seven).score == best, "best-five enumeration %d" % iteration)

func betting_state(count: int = 3) -> TableState:
	var state := TableState.new()
	state.settings = MatchSettings.new()
	state.current_bet = 100
	state.min_raise = 100
	state.actor = 0
	for index in range(count):
		state.players.append(PlayerState.new(index))
	return state

func test_betting() -> void:
	var state := betting_state()
	check(not BettingSystem.apply(state, 0, "check").is_empty(), "cannot check facing bet")
	check(not BettingSystem.apply(state, 1, "call").is_empty(), "wrong actor rejected")
	check(not BettingSystem.apply(state, 0, "raise", 150).is_empty(), "underraise rejected")
	check(state.players[0].chips == 10000, "invalid action is atomic")
	check(BettingSystem.apply(state, 0, "raise", 300).is_empty(), "full raise")
	check(state.min_raise == 200 and state.current_bet == 300, "minimum tracks last increment")
	state.actor = 1
	state.players[1].chips = 350
	check(BettingSystem.apply(state, 1, "all_in").is_empty(), "short all in allowed")
	check(state.min_raise == 200, "short raise retains minimum")
	state.actor = 0
	check(not BettingSystem.legal(state, 0).can_raise, "short raise does not reopen")
	check(not BettingSystem.legal(state, 0).all_in, "cannot bypass reopening via all in")
	state.actor = 2
	check(BettingSystem.legal(state, 2).can_raise, "unacted seat can raise")
	state.players[2].chips = 500
	check(BettingSystem.apply(state, 2, "all_in").is_empty(), "second short raise")
	state.actor = 0
	# No solvent opponents remain: even reopened action cannot raise into nobody.
	check(not BettingSystem.legal(state, 0).can_raise, "no dry side-pot raise")
	state = betting_state(4)
	state.acted_at[0] = 100
	state.current_bet = 200
	check(BettingSystem.legal(state, 0).can_raise, "cumulative short raises reopen at full increment")
	state.players[0].chips = 35
	check(BettingSystem.apply(state, 0, "call").is_empty(), "short call allowed")
	check(state.players[0].chips == 0 and state.players[0].contribution == 35, "short call never negative")

func test_pots() -> void:
	var state := betting_state()
	for index in range(3):
		state.players[index].chips = 0
		state.players[index].contribution = [100, 300, 500][index]
	var pots := PotSystem.build(state.players)
	check(pots.size() == 3 and pots[0].amount == 300 and pots[1].amount == 400 and pots[2].amount == 200, "main side refund tiers")
	PotSystem.settle(state, {0: 30, 1: 20, 2: 10})
	check(state.players[0].chips == 300 and state.players[1].chips == 400 and state.players[2].chips == 200, "side pot eligibility and refund")
	state = betting_state()
	state.dealer = 0
	for player in state.players:
		player.chips = 0
		player.contribution = 5
	state.players[2].folded = true
	PotSystem.settle(state, {0: 10, 1: 10})
	check(state.players[0].chips == 7 and state.players[1].chips == 8 and state.players[2].chips == 0, "dead money and clockwise odd chip")

func test_flow() -> void:
	var settings := MatchSettings.new()
	settings.ai_count = 1
	var game := StartMatchCommand.execute(settings, 17)
	var state := game.state
	check(state.small_blind_seat == state.dealer and state.actor == state.dealer, "heads up button small blind first preflop")
	check(state.pot_total() == 150, "default blinds")
	check(state.players[0].chips + state.players[0].contribution == 10000, "initial 10000")
	var actions := 0
	while not state.hand_over and actions < 20:
		var seat := state.actor
		check(game.act(seat, "call").is_empty(), "check-call complete hand")
		if state.street == 1 and state.acted_at.is_empty():
			check(state.actor == state.big_blind_seat, "heads up postflop big blind first")
		actions += 1
	check(state.hand_over and state.board.size() == 5, "all four streets showdown")
	check(state.players[0].revealed and state.players[1].revealed, "showdown reveals contenders")
	var previous_dealer := state.dealer
	game.begin_hand()
	check(state.dealer != previous_dealer and state.hand_number == 2, "dealer rotates")
	game.act(state.actor, "fold")
	check(state.hand_over and not state.players[0].revealed and not state.players[1].revealed, "fold win never reveals holes")
	# Force a deterministic human bust with a rigged public board and holes.
	game.begin_hand()
	state.players[0].hole = cards([2, 3])
	state.players[1].hole = cards([14, 14])
	state.board = cards([14, 14, 14, 8, 9])
	state.street = 3
	for player in state.players:
		player.chips = 0
		player.contribution = 10000
	game.finish_hand(true)
	check(state.finished and state.champion == 1 and state.players[0].finish_rank == 2, "human bust and champion")
	var hand_number := state.hand_number
	game.begin_hand()
	check(state.hand_number == hand_number, "finished match does not restart automatically")
	game = StartMatchCommand.execute(settings, 18)
	# Next dealer posts 50; the opponent has only 30 to post as big blind.
	game.state.players[game.state.dealer].chips = 30
	game.state.players[1 - game.state.dealer].chips = 19970
	game.begin_hand()
	check(game.state.hand_over and game.state.board.size() == 5, "short big blind heads-up runs out without phantom call")
	for count in range(1, 5):
		for mode in [false, true]:
			settings = MatchSettings.new()
			settings.ai_count = count
			settings.liars_majority = mode
			game = StartMatchCommand.execute(settings, 78 + count)
			var major := 0
			for player in game.state.players:
				if player.profile and player.profile.is_liar == mode:
					major += 1
			check(major == [0, 1, 2, 2, 3][count], "exact personality distribution")

func test_privacy_and_ai() -> void:
	var settings := MatchSettings.new()
	settings.simulation_samples = 24
	var game := StartMatchCommand.execute(settings, 99)
	var state := game.state
	var observation := AIObservationQuery.execute(state, 1)
	check(not observation.has("deck") and not observation.has("players"), "AI has no private table reference")
	check(not observation.opponents[0].has("hole"), "opponents expose no holes")
	check(observation.has("street") and observation.has("position_bucket") and observation.has("in_position"), "AI gets public street and position context")
	check(observation.street == state.street and observation.player_count == state.contenders().size(), "AI context derived from public table state")
	state.players[0].hands_played = 20
	state.players[0].voluntary_puts = 3
	state.players[0].call_actions = 2
	state.players[0].fold_to_bet = 9
	state.players[0].reraises = 0
	state.players[2].hands_played = 20
	state.players[2].voluntary_puts = 12
	state.players[2].call_actions = 7
	state.players[2].fold_to_bet = 1
	state.players[2].reraises = 0
	state.players[3].hands_played = 20
	state.players[3].voluntary_puts = 9
	state.players[3].call_actions = 2
	state.players[3].fold_to_bet = 1
	state.players[3].reraises = 5
	observation = AIObservationQuery.execute(state, 1)
	check(observation.opponents[0].model["style"] == "tight", "AI tags tight opponents from public tendencies")
	check(observation.opponents[1].model["style"] == "calling_station", "AI tags calling stations from public tendencies")
	check(observation.opponents[2].model["style"] == "reraiser", "AI tags reraisers from public tendencies")
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	var equity := AIDecisionSystem.estimate_equity(observation, rng)
	state.players[0].hole = cards([14, 14])
	state.deck.cards.reverse()
	rng.seed = 7
	check(equity == AIDecisionSystem.estimate_equity(AIObservationQuery.execute(state, 1), rng), "equity independent of hidden holes and real deck")
	observation.hole[0].rank = 2
	check(observation.hole[0] != state.players[1].hole[0], "observation cards copied")
	var view := TableViewQuery.execute(state)
	check(view.seats[1].cards.is_empty() and not view.seats[1].has("profile"), "normal UI hides cards and identity")
	check(not view.has("equity"), "normal UI hides equity")
	var fake := {"opponents": [{"seat": 1}], "pot": 1000, "chips": 10000, "bet": 0, "big_blind": 100,
		"legal": {"check": true, "call": 0, "can_raise": true, "max_to": 10000, "min_to": 100}}
	var liar := AIProfile.new(true, 112)
	var honest := AIProfile.new(false, 112)
	check(liar.bluff_size_bias > honest.bluff_size_bias and honest.trap_rate > liar.trap_rate and liar.float_rate > honest.float_rate, "personality parameters diverge on size trap float")
	var liar_raises := 0
	var honest_raises := 0
	for sample in range(5000):
		if AIDecisionSystem.choose(fake, liar, 0.15).action == "raise":
			liar_raises += 1
		if AIDecisionSystem.choose(fake, honest, 0.15).action == "raise":
			honest_raises += 1
	check(liar_raises > honest_raises * 3, "measurable weak-hand bluff frequency")
	var dry_texture := AIDecisionSystem.board_texture(cards([14, 7, 2], [0, 1, 2]))
	var wet_texture := AIDecisionSystem.board_texture(cards([11, 10, 9], [0, 0, 0]))
	check(wet_texture.wetness > dry_texture.wetness, "wet boards score above dry boards")
	var early := make_ai_observation({"position_bucket": "early", "in_position": false, "street": 0, "relative_button": 3, "relative_street": 0})
	var late := make_ai_observation({"position_bucket": "late", "in_position": true, "street": 0, "relative_button": 0, "relative_street": 3})
	var early_raises := count_ai_raises(early, false, 0.36, 2000)
	var late_raises := count_ai_raises(late, false, 0.36, 2000)
	check(late_raises > early_raises * 6, "late position opens much wider than early")
	var dry_board := make_ai_observation({
		"board": cards([14, 7, 2], [0, 1, 2]),
		"street": 1,
		"in_position": false,
		"position_bucket": "middle",
		"relative_street": 1
	})
	var wet_board := make_ai_observation({
		"board": cards([11, 10, 9], [0, 0, 0]),
		"street": 1,
		"in_position": false,
		"position_bucket": "middle",
		"relative_street": 1
	})
	var dry_average := average_raise_amount(dry_board, false, 0.74, 1200)
	var wet_average := average_raise_amount(wet_board, false, 0.74, 1200)
	check(wet_average > dry_average + 80.0, "wet boards use larger protection sizing")
	var tight_table := make_ai_observation({
		"opponents": [
			{"seat": 1, "model": {"style": "tight", "fold_to_bet_rate": 0.4, "call_rate": 0.1, "reraise_rate": 0.04, "bluff_showdown_rate": 0.1}},
			{"seat": 2, "model": {"style": "tight", "fold_to_bet_rate": 0.32, "call_rate": 0.12, "reraise_rate": 0.05, "bluff_showdown_rate": 0.08}}
		],
		"player_count": 3,
		"in_position": true,
		"position_bucket": "late"
	})
	var calling_table := make_ai_observation({
		"opponents": [
			{"seat": 1, "model": {"style": "calling_station", "fold_to_bet_rate": 0.08, "call_rate": 0.42, "reraise_rate": 0.03, "bluff_showdown_rate": 0.12}},
			{"seat": 2, "model": {"style": "calling_station", "fold_to_bet_rate": 0.06, "call_rate": 0.36, "reraise_rate": 0.02, "bluff_showdown_rate": 0.1}}
		],
		"player_count": 3,
		"in_position": true,
		"position_bucket": "late"
	})
	check(count_ai_raises(tight_table, true, 0.24, 2000) > count_ai_raises(calling_table, true, 0.24, 2000) * 2, "AI bluffs tighter folders more than calling stations")
	var bluff_size_spot := make_ai_observation({
		"board": cards([13, 8, 2], [0, 1, 2]),
		"street": 1,
		"in_position": true,
		"position_bucket": "late",
		"player_count": 3,
		"pot": 1400,
		"opponents": [{"seat": 1, "model": {"style": "tight", "fold_to_bet_rate": 0.38, "call_rate": 0.08, "reraise_rate": 0.02}}]
	})
	check(average_raise_amount(bluff_size_spot, true, 0.24, 1200) > average_raise_amount(bluff_size_spot, false, 0.24, 1200) + 70.0, "liar uses bigger bluff sizing than honest")
	var float_spot := make_ai_observation({
		"board": cards([12, 8, 4], [0, 1, 2]),
		"street": 1,
		"in_position": true,
		"position_bucket": "late",
		"player_count": 3,
		"pot": 1200,
		"legal": {"check": false, "call": 180, "can_raise": true, "max_to": 10000, "min_to": 460},
		"opponents": [{"seat": 1, "model": {"style": "reraiser", "fold_to_bet_rate": 0.12, "call_rate": 0.14, "reraise_rate": 0.22, "bluff_showdown_rate": 0.22}}]
	})
	check(count_ai_actions(float_spot, true, 0.36, 2200, "call") > count_ai_actions(float_spot, false, 0.36, 2200, "call") * 2, "liar floats marginal in-position spots more than honest")
	var pressure_flop := make_ai_observation({
		"board": cards([14, 8, 3], [0, 1, 2]),
		"street": 1,
		"in_position": true,
		"position_bucket": "late",
		"player_count": 3,
		"opponents": [{"seat": 1, "model": {"style": "tight", "fold_to_bet_rate": 0.35, "call_rate": 0.1, "reraise_rate": 0.04}}]
	})
	var pressure_turn := make_ai_observation({
		"board": cards([14, 8, 3, 2], [0, 1, 2, 3]),
		"street": 2,
		"in_position": true,
		"position_bucket": "late",
		"player_count": 3,
		"pot": 1800,
		"opponents": [{"seat": 1, "model": {"style": "tight", "fold_to_bet_rate": 0.35, "call_rate": 0.1, "reraise_rate": 0.04}}]
	})
	var pressure_raises := count_planned_turn_raises(pressure_flop, pressure_turn, true, 0.78, 0.5, 1600)
	var fresh_turn_raises := count_ai_raises(pressure_turn, true, 0.5, 1600)
	check(pressure_raises > fresh_turn_raises, "pressure plan continues barreling on turn more than one-shot logic")
	var control_flop := make_ai_observation({
		"board": cards([11, 10, 9], [0, 0, 1]),
		"street": 1,
		"in_position": false,
		"position_bucket": "middle",
		"player_count": 3,
		"opponents": [{"seat": 1, "model": {"style": "reraiser", "fold_to_bet_rate": 0.12, "call_rate": 0.16, "reraise_rate": 0.24}}]
	})
	var control_turn := make_ai_observation({
		"board": cards([11, 10, 9, 4], [0, 0, 1, 2]),
		"street": 2,
		"in_position": false,
		"position_bucket": "middle",
		"player_count": 3,
		"pot": 1800,
		"legal": {"check": false, "call": 250, "can_raise": true, "max_to": 10000, "min_to": 600},
		"opponents": [{"seat": 1, "model": {"style": "reraiser", "fold_to_bet_rate": 0.12, "call_rate": 0.16, "reraise_rate": 0.24}}]
	})
	var control_raises := count_planned_turn_raises(control_flop, control_turn, false, 0.43, 0.45, 1600)
	var fresh_control_raises := count_ai_raises(control_turn, false, 0.45, 1600)
	check(control_raises < fresh_control_raises, "control plan suppresses thin turn aggression")
	print("BLUFF MEASUREMENT: liar %d/5000, honest %d/5000" % [liar_raises, honest_raises])
