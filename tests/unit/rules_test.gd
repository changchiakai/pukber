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
		check(deck.cards.size() == (count + 1) * 104, "correct deck size")
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
	check(HandEvaluator.evaluate(cards([14, 14, 14, 14, 14, 2, 3])).category == 9, "seven card five of kind")
	check(HandEvaluator.evaluate(cards([14, 14, 12, 10, 8], [0, 0, 0, 0, 0])).kickers == [14, 14, 12, 10, 8], "duplicate suited ranks retained in flush")
	check(HandEvaluator.evaluate(cards([14, 14, 12, 11, 10], [0, 0, 0, 0, 0])).category == 5, "duplicates do not complete straight")
	check(HandEvaluator.evaluate(cards([14, 14, 8, 8, 13])).score > HandEvaluator.evaluate(cards([14, 14, 8, 8, 12])).score, "kicker comparison")
	var rng := RandomNumberGenerator.new()
	rng.seed = 842
	for iteration in range(250):
		var deck := PokerDeck.new(10)
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
	var liar_raises := 0
	var honest_raises := 0
	for sample in range(5000):
		if AIDecisionSystem.choose(fake, liar, 0.15).action == "raise":
			liar_raises += 1
		if AIDecisionSystem.choose(fake, honest, 0.15).action == "raise":
			honest_raises += 1
	check(liar_raises > honest_raises * 3, "measurable weak-hand bluff frequency")
	print("BLUFF MEASUREMENT: liar %d/5000, honest %d/5000" % [liar_raises, honest_raises])
