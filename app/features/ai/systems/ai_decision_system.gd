class_name AIDecisionSystem
extends RefCounted

static func random_line(rng: RandomNumberGenerator, lines: Array[String]) -> String:
	return lines[rng.randi_range(0, lines.size() - 1)]

static func build_speech(profile: AIProfile, action: String, strong: bool, bluff: bool, claim_strong: bool) -> String:
	var lines: Array[String] = []
	if claim_strong:
		lines = [
			"我這把很強",
			"這鍋我先預約了",
			"你再跟，我就當你在捐籌碼",
			"今天牌桌像在幫我發年終",
			"先提醒一下，這圈可能是你的學費",
			"我這手有點兇",
			"你可以先想退路了",
			"這圈風向在我這",
			"這手牌不跟你客氣",
			"今天輪到我收租",
			"你這口氣像在送分",
			"我這把不是來聊天",
			"籌碼往我這邊靠了",
			"先替你默哀三秒",
			"這輪我先拿走",
			"你現在跟得有點勇",
			"這牌桌今天姓我",
			"再看下去也救不了",
			"這手夠你難受了",
			"我這張臉像會輸嗎",
			"這輪你最好保守點",
			"我這次不是來鬧的",
			"今天這鍋先歸我",
			"你差不多可以放棄了"
		]
		if action == "raise":
			lines += [
				"加注只是流程，收鍋才是重點",
				"這一下抬上去，你最好真的有東西",
				"別只會看牌，看看你的籌碼還剩多少",
				"先把門檻拉高",
				"這口價不是給你散步",
				"跟得起再說話",
				"這手我直接開價",
				"我先把壓力給滿",
				"想看河牌先買票",
				"你的猶豫我很喜歡",
				"這不是試探，是通知",
				"桌上該緊張了",
				"先把鍋蓋掀起來",
				"我抬一次，你想清楚",
				"跟這口要有理由",
				"這一抬不是開玩笑",
				"你現在退還來得及",
				"這價位你熟嗎",
				"先讓你手心冒汗",
				"我替你把難度調高",
				"這口我收得不便宜",
				"要跟這下先深呼吸"
			]
	else:
		lines = [
			"這手不太好",
			"牌一般般，但收你還夠用",
			"我先低調，免得你太早投降",
			"這圈先陪你玩玩",
			"別高興太早，桌上變數還很多",
			"這手先混一下",
			"牌不大，嘴先上",
			"我先裝作沒事",
			"先讓你猜到頭痛",
			"這輪先看風向",
			"我牌普通，表情不普通",
			"別急，我還沒演完",
			"先讓場面熱一下",
			"這手先靠氣氛",
			"我先把節奏拖住",
			"你未必比我好",
			"先把表情管理做好",
			"牌普通，膽子不普通",
			"我先安靜一下",
			"你先別急著笑",
			"這圈還早得很",
			"先不讓你看穿",
			"我這手先靠演技",
			"看起來弱，不代表真的弱"
		]
		if action == "fold":
			lines += [
				"這把先放你過，下一把記得還",
				"先讓你撿一次，不代表你真的行",
				"先撤不是怕，是懶得現在收你",
				"這口先不接",
				"你先贏一口呼吸",
				"先讓你記一分",
				"這次算你快",
				"這手先收嘴",
				"先把籌碼留著",
				"這輪先看你演",
				"今天先放你過關",
				"這把不陪你抬",
				"先讓你高興一下",
				"你先別慶祝太早",
				"我先把火收著",
				"這輪先撤兵",
				"這手先留給你",
				"先不跟你耗",
				"你這次運氣不錯",
				"這口我先省下",
				"這圈先認你吵",
				"今天先不接你的戲"
			]
		elif action == "check":
			lines += [
				"先看你怎麼演",
				"我先過，你別以為沒人在盯你",
				"先讓牌桌安靜一下，等等再說",
				"先過一手",
				"你先出招",
				"我先把節奏放慢",
				"先看你露哪張臉",
				"你先講，我先聽",
				"我先按兵不動",
				"先讓你多想一輪",
				"這圈我先看戲",
				"先過，不代表沒貨",
				"你先表態吧",
				"我先把手藏著",
				"先等你自己破功",
				"這輪先收資訊",
				"先讓你動第一步",
				"我先看你敢不敢",
				"先給你表現機會",
				"我先不把話說滿",
				"這手先留白",
				"先讓你以為安全"
			]

	if bluff:
		lines += [
			"你現在猜牌的樣子，比我的底牌還亂",
			"我話先放這，你等一下會後悔跟進",
			"別讀我了，你連自己都快讀不懂了",
			"你現在像在跟影子打架",
			"這口氣勢先借我用",
			"你先猜，猜中算你",
			"我現在全靠表情撐場",
			"你讀到的多半是假訊號",
			"別急著信你自己",
			"你現在想的都偏了",
			"我先把煙霧放滿",
			"你看到的只是我想給的",
			"這手先靠演技撐著",
			"你再讀，我再演",
			"先讓你判斷失焦",
			"我就看你敢不敢信",
			"你現在離真相很遠",
			"你以為你懂，其實沒有",
			"這圈我先混水摸魚",
			"你先被我帶節奏了",
			"我先讓場面變霧",
			"你現在信什麼都危險"
		]

	if profile.is_liar:
		lines += [
			"我這句真假不重要，重點是你會信",
			"你要是被我一句話帶走，那也太省事",
			"先猜你信哪句，我再決定怎麼贏你",
			"我講真的時候最像假的",
			"你現在信我才危險",
			"我嘴上這套不附保固",
			"真假摻著講才有意思",
			"你聽進去就算我贏",
			"我今天主打資訊污染",
			"我先丟一句試你反應",
			"你愛信不信，反正我賺",
			"我講反話也很合理",
			"真話假話我都能用",
			"你分不清就對了",
			"先看你吃哪一套",
			"我話裡有坑，你先跳",
			"你要信表情還是信牌",
			"我先亂你判斷",
			"這句像真話吧，可惜不是",
			"我今天專賣煙霧彈",
			"你越想分辨越慢",
			"我最愛看你半信半疑"
		]
	elif strong:
		lines += [
			"這次我不是在鬧，真的有貨",
			"你現在最好的操作，可能是少輸一點",
			"這手我很坦白，你照樣不好接",
			"我這次是真的有東西",
			"你現在跑還來得及",
			"這輪我講的算真話",
			"先提醒你別硬接",
			"這手沒必要裝了",
			"我這次不是空城計",
			"你現在該算退路",
			"我這輪不靠演技",
			"這手牌自己會說話",
			"我這次真沒騙你",
			"你如果跟到底會痛",
			"這圈我是真的穩",
			"我難得這麼老實",
			"這次不是唬你",
			"你現在該少輸為贏",
			"這手不是給你翻盤的",
			"今天這口我真有底",
			"你現在退還算體面"
		]
	else:
		lines += [
			"先別急著得意，我也可能只是嘴硬",
			"牌不大，氣勢先補一下",
			"你先笑沒關係，等等輪到我",
			"這手先靠嘴撐場",
			"我先把膽子借來用",
			"牌小也能先講話",
			"這圈先不讓氣勢掉",
			"我先把場面撐住",
			"手不大，聲量先大",
			"你先別把我看扁",
			"這手先求你看不懂",
			"我先用表情補牌力",
			"先把你注意力帶偏",
			"這輪先靠嘴皮子",
			"牌雖普通，戲不能少",
			"我先把弱勢演成平手",
			"你以為我虛，我就夠了",
			"先別急著判我輸",
			"這圈先保住氣勢",
			"牌一般，話不能輸",
			"先讓你多想一拍",
			"我先把氣氛撐滿"
		]

	var speech := random_line(profile.rng, lines)
	if speech == profile.last_speech:
		speech = lines[(lines.find(speech) + 1) % lines.size()]
	profile.last_speech = speech
	return speech

static func estimate_equity(observation: Dictionary, rng: RandomNumberGenerator) -> float:
	var unseen := PokerDeck.new(observation.deck_count).cards
	var known: Dictionary = {}
	for card in observation.hole + observation.board:
		known[card.identity()] = true
	unseen = unseen.filter(func(card): return not known.has(card.identity()))
	var samples := maxi(1, int(observation.samples))
	var equity := 0.0
	var total_weight := 0.0
	var draws: int = 5 - observation.board.size() + observation.opponents.size() * 2
	for _sample in range(samples):
		# Partial Fisher-Yates; only draw what this simulation needs.
		var pool := unseen.duplicate()
		for index in range(draws):
			var other := rng.randi_range(index, pool.size() - 1)
			var temp = pool[index]
			pool[index] = pool[other]
			pool[other] = temp
		var missing: int = 5 - observation.board.size()
		var board: Array = observation.board + pool.slice(0, missing)
		var hero: int = HandEvaluator.evaluate(observation.hole + board).score
		var ties := 1
		var lost := false
		var weight := 1.0
		for opponent in range(observation.opponents.size()):
			var start := missing + opponent * 2
			var candidate := pool.slice(start, start + 2)
			weight *= range_weight(candidate, observation.board, observation.opponents[opponent], observation)
			var score: int = HandEvaluator.evaluate(candidate + board).score
			if score > hero:
				lost = true
			if score == hero:
				ties += 1
		total_weight += weight
		if not lost:
			equity += weight / ties
	return equity / maxf(0.000001, total_weight)

static func decide(observation: Dictionary, profile: AIProfile) -> Dictionary:
	var equity := estimate_equity(observation, profile.rng)
	return choose(observation, profile, equity)

static func board_texture(board: Array) -> Dictionary:
	var suit_counts := [0, 0, 0, 0]
	var ranks: Array = []
	var unique_ranks: Dictionary = {}
	for card in board:
		suit_counts[card.suit] += 1
		ranks.append(card.rank)
		unique_ranks[card.rank] = true
	ranks.sort()
	var max_suited := 0
	for count in suit_counts:
		max_suited = maxi(max_suited, count)
	var paired := unique_ranks.size() < board.size()
	var close_links := 0
	for index in range(ranks.size() - 1):
		var gap := int(ranks[index + 1]) - int(ranks[index])
		if gap <= 1:
			close_links += 2
		elif gap == 2:
			close_links += 1
	var wetness := 0.0
	if max_suited >= 3:
		wetness += 0.32 + float(max_suited - 3) * 0.12
	if close_links > 0:
		wetness += minf(0.36, close_links * 0.09)
	if paired:
		wetness -= 0.08
	if board.size() <= 1:
		wetness = 0.0
	return {
		"paired": paired,
		"max_suited": max_suited,
		"connectedness": close_links,
		"wetness": clampf(wetness, 0.0, 1.0)
	}

static func choose_bet_fraction(observation: Dictionary, profile: AIProfile, strong: bool, bluff: bool, texture: Dictionary) -> float:
	var street := int(observation.get("street", 0))
	var in_position := bool(observation.get("in_position", false))
	var bucket := String(observation.get("position_bucket", "middle"))
	var wetness := float(texture.get("wetness", 0.0))
	var options: Array = []
	if street == 0:
		options = [2.2, 2.6, 3.1, 3.6]
		if strong:
			options = [2.6, 3.1, 3.6, 4.2]
		elif bluff:
			options = [2.2, 2.6, 3.1]
		if bucket == "early":
			options.append(4.6 if strong else 3.8)
		if bucket == "late" and not strong:
			options.erase(4.2)
		return options[profile.rng.randi_range(0, options.size() - 1)]
	if wetness >= 0.55:
		options = [0.55, 0.7, 0.85, 1.05] if strong else [0.45, 0.6, 0.8]
	else:
		options = [0.33, 0.5, 0.66, 0.8] if strong else [0.25, 0.4, 0.55]
	if bluff and wetness < 0.45:
		options = [0.33, 0.45, 0.6]
	elif bluff:
		options = [0.5, 0.66, 0.8]
	if in_position and options.size() > 2:
		options.remove_at(options.size() - 1)
	if not in_position and strong:
		options.append(minf(1.15, options[options.size() - 1] + 0.15))
	var selected := float(options[profile.rng.randi_range(0, options.size() - 1)])
	if bluff:
		selected += profile.bluff_size_bias
	elif strong:
		selected += profile.value_size_bias
	return selected

static func opponent_tendencies(opponents: Array) -> Dictionary:
	var tight_count := 0
	var loose_count := 0
	var calling_count := 0
	var reraiser_count := 0
	var fold_sum := 0.0
	var call_sum := 0.0
	var reraise_sum := 0.0
	var bluff_sum := 0.0
	for opponent in opponents:
		var model: Dictionary = opponent.get("model", {})
		var style := String(model.get("style", "balanced"))
		match style:
			"tight":
				tight_count += 1
			"loose":
				loose_count += 1
			"calling_station":
				calling_count += 1
			"reraiser":
				reraiser_count += 1
		fold_sum += float(model.get("fold_to_bet_rate", 0.0))
		call_sum += float(model.get("call_rate", 0.0))
		reraise_sum += float(model.get("reraise_rate", 0.0))
		bluff_sum += float(model.get("bluff_showdown_rate", 0.0))
	var count := maxf(1.0, float(opponents.size()))
	return {
		"tight_count": tight_count,
		"loose_count": loose_count,
		"calling_count": calling_count,
		"reraiser_count": reraiser_count,
		"avg_fold_rate": fold_sum / count,
		"avg_call_rate": call_sum / count,
		"avg_reraise_rate": reraise_sum / count,
		"avg_bluff_showdown_rate": bluff_sum / count
	}

static func seed_street_plan(observation: Dictionary, profile: AIProfile, fair_share: float, strength: float, strong: bool, bluff: bool, texture: Dictionary, tendencies: Dictionary) -> void:
	var street := int(observation.get("street", 0))
	if street < 1 or not profile.hand_plan.is_empty():
		return
	var in_position := bool(observation.get("in_position", false))
	var wetness := float(texture.get("wetness", 0.0))
	var calling_count := int(tendencies.get("calling_count", 0))
	var reraiser_count := int(tendencies.get("reraiser_count", 0))
	if strong:
		if in_position and wetness < 0.55:
			profile.set_hand_plan("pressure", street, 2 if strength > 0.74 else 1, 0.14, 0.08)
		elif wetness >= 0.55 or calling_count > 0:
			profile.set_hand_plan("pressure", street, 1, 0.12, 0.18)
		else:
			profile.set_hand_plan("control", street, 1, -0.1, -0.12)
		return
	if bluff and in_position and wetness < 0.45 and calling_count == 0:
		profile.set_hand_plan("pressure", street, 1, 0.08, 0.0)
		return
	if strength >= fair_share - 0.02 or wetness >= 0.55 or reraiser_count > 0:
		profile.set_hand_plan("control", street, 1 if street >= 2 else 2, -0.16, -0.18)

static func apply_street_plan(observation: Dictionary, profile: AIProfile, fair_share: float, strength: float, strong: bool, bluff: bool, tendencies: Dictionary, texture: Dictionary) -> Dictionary:
	var street := int(observation.get("street", 0))
	profile.roll_plan(street)
	var wetness := float(texture.get("wetness", 0.0))
	var in_position := bool(observation.get("in_position", false))
	var calling_count := int(tendencies.get("calling_count", 0))
	var pressure_active := profile.hand_plan == "pressure" and profile.has_active_plan(street)
	var control_active := profile.hand_plan == "control" and (profile.has_active_plan(street) or street == profile.plan_anchor_street)
	var continue_pressure := pressure_active and strength > fair_share - (0.05 if in_position else 0.01)
	var aggression := clampf(profile.aggression + profile.plan_aggression_bias, 0.05, 0.98) if (pressure_active or control_active) else profile.aggression
	var size_bias := profile.plan_size_bias if (pressure_active or control_active) else 0.0
	var threshold_shift := 0.0
	var fold_shift := 0.0
	if pressure_active:
		threshold_shift -= 0.05 if in_position else 0.02
		if not strong and wetness < 0.5 and calling_count == 0:
			bluff = true
	if control_active:
		threshold_shift += 0.04 if not strong else 0.01
		fold_shift += 0.05
		if wetness >= 0.55 and not in_position:
			size_bias -= 0.06
	return {
		"aggression": aggression,
		"size_bias": size_bias,
		"threshold_shift": threshold_shift,
		"fold_shift": fold_shift,
		"continue_pressure": continue_pressure,
		"pressure_active": pressure_active,
		"control_active": control_active,
		"bluff": bluff
	}

static func should_trap(observation: Dictionary, profile: AIProfile, strong: bool, texture: Dictionary, plan: Dictionary) -> bool:
	if not strong or not observation.legal.check or int(observation.get("street", 0)) < 1:
		return false
	if bool(plan.get("pressure_active", false)):
		return false
	var wetness := float(texture.get("wetness", 0.0))
	var chance := profile.trap_rate
	chance *= 1.5 if wetness < 0.42 else 0.3
	chance *= 0.9 if bool(observation.get("in_position", false)) else 1.05
	return profile.rng.randf() < clampf(chance, 0.0, 0.75)

static func should_float(observation: Dictionary, profile: AIProfile, strong: bool, bluff: bool, fair_share: float, strength: float, pot_odds: float, tendencies: Dictionary) -> bool:
	if strong or observation.legal.check or int(observation.get("street", 0)) < 1:
		return false
	if not bool(observation.get("in_position", false)):
		return false
	if int(observation.legal.call) <= 0:
		return false
	if strength < fair_share - 0.08 or strength > fair_share + 0.13:
		return false
	if float(observation.legal.call) > float(observation.get("pot", 0)) * 0.38:
		return false
	var chance := profile.float_rate
	chance *= 1.15 if bluff else 1.0
	chance *= 1.18 if float(tendencies.get("avg_reraise_rate", 0.0)) >= 0.16 else 1.0
	chance *= 1.12 if float(tendencies.get("avg_bluff_showdown_rate", 0.0)) >= 0.18 else 1.0
	chance *= 0.72 if int(tendencies.get("calling_count", 0)) > 0 else 1.0
	chance *= 0.7 if pot_odds > strength + profile.risk_tolerance + 0.05 else 1.0
	return profile.rng.randf() < clampf(chance, 0.0, 0.72)

# Conservative hand features; nut-draw flags are candidates, never certainty.
static func hand_features(observation: Dictionary) -> Dictionary:
	var hole: Array = observation.hole
	var board: Array = observation.board
	var category := 0
	var board_category := 0
	if board.size() >= 3:
		category = int(HandEvaluator.evaluate(hole + board).category)
	if board.size() == 5:
		board_category = int(HandEvaluator.evaluate(board).category)
	var personal_pair: bool = hole[0].rank == hole[1].rank
	for card in hole:
		for public_card in board:
			personal_pair = personal_pair or card.rank == public_card.rank
	var nut_draw := false
	var draw := false
	var blocker := false
	for suit in range(4):
		var count := 0
		var owns_ace := false
		for card in board:
			if card.suit == suit:
				count += 1
		for card in hole:
			if card.suit == suit and card.rank == 14:
				owns_ace = true
		blocker = blocker or (owns_ace and count >= 3)
		var total := count
		for card in hole:
			if card.suit == suit:
				total += 1
		draw = draw or (total == 4 and total > count and board.size() < 5)
		nut_draw = nut_draw or (owns_ace and total == 4 and board.size() < 5)
	# Broadway draws with a private ace are conservative straight-nut candidates.
	var ranks: Array = []
	var has_ace := false
	for card in hole + board:
		if not ranks.has(card.rank):
			ranks.append(card.rank)
	for card in hole:
		has_ace = has_ace or card.rank == 14
	var broadway := 0
	for rank in [10, 11, 12, 13, 14]:
		if ranks.has(rank):
			broadway += 1
	nut_draw = nut_draw or (has_ace and broadway == 4 and board.size() < 5)
	# Four distinct ranks in a five-rank window, with a private contribution.
	# A2345 uses ace-low mapping; duplicate cards never inflate the count.
	if board.size() >= 3 and board.size() < 5:
		for low_rank in range(1, 11):
			var hits := 0
			var private_hit := false
			for rank in range(low_rank, low_rank + 5):
				var actual_rank := 14 if rank == 1 else rank
				if ranks.has(actual_rank):
					hits += 1
				var on_board := false
				for card in board:
					on_board = on_board or card.rank == actual_rank
				for card in hole:
					private_hit = private_hit or (card.rank == actual_rank and not on_board)
			draw = draw or (hits == 4 and private_hit)
	# Multi-deck blockers cannot remove all copies of a card.
	blocker = blocker and int(observation.get("deck_count", 1)) == 1
	return {"category": category, "made": category >= 1 and personal_pair or category >= 4 and category > board_category,
		"nut_draw": nut_draw, "draw": draw or nut_draw, "blocker": blocker}

# Decisions mix only inside a viable range. Personality never bypasses price checks.
static func facing_pressure(observation: Dictionary) -> float:
	var highest_bet := int(observation.bet)
	var read := 0.0
	for opponent in observation.opponents:
		var wager := int(opponent.get("bet", 0))
		var model: Dictionary = opponent.get("model", {})
		if wager > highest_bet:
			highest_bet = wager
			read = float(model.get("pressure_read", 0.0))
		elif wager == highest_bet and wager > int(observation.bet):
			read = minf(read, float(model.get("pressure_read", 0.0)))
	return read

# A single unusually large raise is public information too.  It should not make
# the AI call blindly, but it must prevent a player from printing chips by using
# the same extreme sizing before a long-term tendency model has enough hands.
static func immediate_overbet_read(observation: Dictionary) -> float:
	var own_bet := int(observation.get("bet", 0))
	var largest_wager := own_bet
	for opponent in observation.opponents:
		largest_wager = maxi(largest_wager, int(opponent.get("bet", 0)))
	var extra_wager := largest_wager - own_bet
	if extra_wager <= 0:
		return 0.0
	# `pot` includes the current wager.  Compare against the pot before that
	# wager so a 10BB open into the blinds is recognised, while normal opens are not.
	var prior_pot := maxf(float(observation.get("big_blind", 1)), float(observation.get("pot", 0)) - extra_wager)
	var ratio := float(extra_wager) / prior_pot
	return clampf((ratio - 2.0) / 5.0, 0.0, 0.55)

static func speculative_start(hole: Array) -> bool:
	var high := maxi(int(hole[0].rank), int(hole[1].rank))
	var low := mini(int(hole[0].rank), int(hole[1].rank))
	var suited: bool = hole[0].suit == hole[1].suit
	return high == low or (suited and (high - low <= 3 or high == 14)) or (high - low == 1 and low >= 8)

static func choose(observation: Dictionary, profile: AIProfile, equity: float) -> Dictionary:
	var legal: Dictionary = observation.legal
	var street := int(observation.get("street", 0))
	var opponents: Array = observation.opponents
	var heads_up := opponents.size() == 1
	var texture := board_texture(observation.board)
	var features := hand_features(observation)
	var tendencies := opponent_tendencies(opponents)
	var bb := maxi(1, int(observation.big_blind))
	var cost := int(legal.call)
	var pot := maxf(float(bb), float(observation.pot))
	var effective := 0
	var can_fold_count := 0
	for opponent in opponents:
		effective = maxi(effective, maxi(0, int(opponent.chips) + int(opponent.bet) - int(observation.bet)))
		if int(opponent.chips) > 0:
			can_fold_count += 1
	effective = mini(int(observation.chips), effective)
	var stack_bb := float(effective) / bb
	var spr := float(maxi(0, effective - cost)) / (pot + cost)
	var odds := float(cost) / (pot + cost)
	var in_position := bool(observation.get("in_position", false))
	var pressure_read := maxf(facing_pressure(observation), immediate_overbet_read(observation))
	var margin := 0.025 + 0.015 * float(maxi(0, opponents.size() - 1))
	margin += 0.015 if street < 3 and not in_position else 0.0
	# Adapt uncertainty padding, never fabricate equity or ignore the actual price.
	margin = maxf(0.005, margin - pressure_read * (0.025 if heads_up else 0.01))
	var strength := clampf(equity, 0.0, 1.0)
	var value := strength >= (0.59 if heads_up else 0.67)
	var action := "check" if bool(legal.check) else "fold"
	var amount := 0
	var bluff := false
	var reason := "免費看牌或價格不合，保留籌碼"
	var fraction := 0.5
	var late := String(observation.get("position_bucket", "middle")) == "late"
	var facing_raise := int(observation.bet) + cost > bb
	var quality := preflop_quality(observation.hole)
	var premium := quality >= 0.82
	var raise_wanted := false
	var shove := false
	var fold_signal := float(tendencies.avg_fold_rate) >= 0.30
	var station := int(tendencies.calling_count) > 0
	var previous_raise := profile.last_plan_action == "raise" and profile.last_plan_action_street == street - 1
	if street == 0:
		var entrants := 0
		for opponent in opponents:
			if bool(opponent.get("entered_pot", false)):
				entrants += 1
		var speculative := speculative_start(observation.hole)
		# Small preflop investments need room to improve, not stack-off equity.
		var cheap_price := cost > 0 and cost <= bb * 3 and cost <= effective * 0.08
		var deep_enough := effective >= cost * 20
		var small_call_margin := 0.01 if late else 0.02
		var implied_allowance := 0.035 if speculative and deep_enough else 0.0
		var cheap_equity := strength >= maxf(0.12, odds + small_call_margin - implied_allowance)
		var open_entry := 0.45
		if late:
			open_entry = 0.33
		elif String(observation.get("position_bucket", "middle")) == "middle":
			open_entry = 0.40
		open_entry += profile.opening_bias - (0.025 if profile.is_liar else 0.0)
		if heads_up:
			open_entry -= 0.04
		var playable := quality >= open_entry
		value = quality >= 0.72
		if stack_bb <= 12.0:
			# Short-stack pushes widen only when nobody has opened yet.
			shove = playable and strength >= maxf(odds + margin, 0.40 if heads_up else 0.34)
			if facing_raise:
				shove = quality >= 0.70 and strength >= odds + margin
			if cost > 0 and strength >= odds + margin and quality >= 0.65:
				action = "call"
			raise_wanted = shove
			reason = "12BB 內依位置、牌力與價格推進"
		elif not facing_raise:
			raise_wanted = playable
			reason = "依位置開池，保留翻牌後操作空間"
			# Medium hands may limp/overlimp; premium hands still build the pot.
			var can_limp := cheap_price and cost <= bb and cheap_equity
			can_limp = can_limp and (quality >= 0.40 or speculative)
			if can_limp and quality < 0.72:
				var limp_chance := 0.80 if entrants > 0 else 0.45
				if not playable or profile.rng.randf() < limp_chance:
					action = "call"
					raise_wanted = false
					reason = "低成本跟進，保留多人翻牌與改善牌力的空間"
			if bool(legal.check) and entrants > 0 and quality < 0.72:
				raise_wanted = false
				reason = "大盲免費看翻牌，中等牌不強行趕走跟進者"
		else:
			var call_entry := (0.43 if late else 0.49) + profile.opening_bias
			var expensive := cost > bb * 4 or cost > effective * 0.15
			if expensive:
				call_entry += lerpf(0.08, 0.02, pressure_read)
				# Do not widen a multiway range.  In heads-up pots, a clear 10BB+
				# overbet can contain enough weak hands that borderline defenders stay in.
				if heads_up:
					call_entry -= pressure_read * 0.14
			call_entry -= pressure_read * 0.05
			var defend := quality >= call_entry and strength >= odds + margin
			# Existing callers improve the price; do not add a second player-count penalty.
			var cheap_entry := 0.38 if late or entrants >= 2 else 0.43
			var small_open_defend := cheap_price and cheap_equity
			small_open_defend = small_open_defend and (quality >= cheap_entry or (speculative and deep_enough))
			defend = defend or small_open_defend
			if defend and cost > 0:
				action = "call"
			raise_wanted = premium and strength >= maxf(0.56, odds + margin + 0.10)
			if int(tendencies.reraiser_count) > 0:
				raise_wanted = quality >= 0.77 and strength >= maxf(0.57, odds + margin + 0.10)
			shove = raise_wanted and stack_bb <= 25.0
			reason = "按跟注價格防守；強範圍再加注"
			if action == "call" and small_open_defend:
				reason = "小注價格合適，跟進參與翻牌"
			if action == "call" and pressure_read >= 0.4:
				reason = "對手近期頻繁施壓，放寬範圍但仍按價格防守"
		if not bool(legal.can_raise) and cost > 0 and strength >= odds + margin:
			action = "call"
	else:
		var made := bool(features.made)
		var draw := bool(features.draw) and street < 3
		var profitable_call := strength >= odds + margin
		if cost > 0 and profitable_call and (made or draw or heads_up):
			action = "call"
			reason = "依範圍權益與底池賠率防守"
		value = value and made
		# A prior raise supplies initiative, never permission to barrel blindly.
		var continuation := previous_raise and heads_up and cost == 0 and float(texture.wetness) < 0.48
		var credible := draw or (bool(features.blocker) and fold_signal)
		credible = credible or (continuation and strength >= 0.24 and street < 3)
		var bluff_allowed := heads_up and can_fold_count == opponents.size() and not station
		bluff_allowed = bluff_allowed and cost <= pot * 0.25 and credible
		var bluff_chance := profile.bluff_rate + (0.12 if continuation else 0.0)
		bluff_chance += 0.10 if fold_signal else 0.0
		bluff = not value and bluff_allowed and profile.rng.randf() < clampf(bluff_chance, 0.0, 0.55)
		raise_wanted = value or bluff
		fraction = 0.65 if float(texture.wetness) >= 0.5 else 0.40
		if street == 2:
			fraction = 0.75
			raise_wanted = bluff or (value and strength >= 0.69)
		elif street == 3:
			fraction = 0.55
		# Shared size distribution avoids mechanically identifying bluffs by size.
		fraction *= [0.85, 1.0, 1.15][profile.rng.randi_range(0, 2)]
		if station:
			fraction += 0.15
		if not heads_up and strength < 0.74:
			raise_wanted = false
		# Facing a bet, medium value prefers calling over bloating the pot.
		if cost > 0 and not bluff:
			raise_wanted = value and strength >= maxf(0.73, odds + 0.25)
		shove = raise_wanted and not bluff and strength >= 0.76 and spr <= 1.2
		var trap := value and heads_up and cost == 0 and not in_position
		trap = trap and float(texture.wetness) < 0.42 and spr > 2.0
		if trap and profile.rng.randf() < profile.trap_rate:
			raise_wanted = false
			reason = "乾燥牌面偶爾過牌誘敵，保護過牌範圍"
		elif raise_wanted:
			reason = "持續施壓或半詐唬" if bluff else "按牌面與對手跟注傾向取值"
	if bool(legal.can_raise) and (raise_wanted or shove):
		var target := 0
		if street == 0:
			target = int(bb * (2.3 if late else 2.7))
			if facing_raise:
				target = int((int(observation.bet) + cost) * (3.0 if late else 3.5))
		else:
			target = int(observation.bet) + cost + maxi(bb, int((pot + cost) * fraction))
		amount = mini(int(legal.max_to), maxi(int(legal.min_to), target))
		if shove:
			amount = int(legal.max_to)
		var risk := amount - int(observation.bet)
		var affordable_bluff := risk <= effective * 0.30 and risk <= (pot + cost) * 1.15
		# An oversized minimum raise also needs stack-off equity for value hands.
		var oversized := risk > effective * 0.45 and risk > (pot + cost) * 1.5
		if (not bluff or affordable_bluff) and (shove or not oversized or strength >= 0.73):
			action = "raise"
	if action != "raise":
		amount = 0
		bluff = false
	profile.set_hand_plan("pressure" if action == "raise" else "control", street, 1, 0.0, 0.0)
	profile.note_plan_action(street, action)
	var claim_strong := value
	if profile.rng.randf() < (0.65 if profile.is_liar else 0.08):
		claim_strong = not claim_strong
	return {"action": action, "amount": amount,
		"speech": build_speech(profile, action, value, bluff, claim_strong), "reason": reason}

static func preflop_quality(hole: Array) -> float:
	var high := maxi(int(hole[0].rank), int(hole[1].rank))
	var low := mini(int(hole[0].rank), int(hole[1].rank))
	if high == low:
		return clampf(0.5 + float(high) * 0.035, 0.0, 1.0)
	var quality := float(high + low) / 36.0
	quality += 0.07 if hole[0].suit == hole[1].suit else 0.0
	quality += 0.04 if high - low == 1 else 0.0
	quality -= 0.08 if high - low >= 5 else 0.0
	return clampf(quality, 0.0, 1.0)

# Importance weighting uses public actions only, not sampled future board cards.
static func range_weight(hole: Array, board: Array, opponent: Dictionary, observation: Dictionary) -> float:
	var model: Dictionary = opponent.get("model", {})
	var confidence := clampf(float(model.get("hands", 0)) / 30.0, 0.0, 1.0)
	var vpip := lerpf(0.3, clampf(float(model.get("vpip", 0.3)), 0.1, 0.8), confidence)
	var quality := preflop_quality(hole)
	var weight := clampf(0.5 + quality - (1.0 - vpip) * 0.5, 0.15, 1.0)
	var raised := bool(opponent.get("aggressive", false))
	var pressure_read := maxf(
		clampf(float(model.get("pressure_read", 0.0)), 0.0, 1.0),
		immediate_overbet_read(observation)
	)
	weight = lerpf(weight, 1.0, pressure_read * 0.55)
	if raised:
		# A normal raise still narrows a range.  An isolated 10BB+ overbet,
		# however, retains more weak/bluff candidates until showdown proves otherwise.
		var weak_raise_weight := lerpf(0.50, 0.95, pressure_read)
		weight *= 1.0 if quality >= 0.72 else weak_raise_weight
	if board.size() >= 3 and bool(opponent.get("street_aggressive", raised)):
		var category := int(HandEvaluator.evaluate(hole + board).category)
		var candidate_features := hand_features({"hole": hole, "board": board,
			"deck_count": observation.get("deck_count", 1)})
		# Keep plausible draws in an aggressor's range, rather than assuming made hands.
		var weak_postflop_weight := lerpf(0.35, 0.80, pressure_read)
		weight *= 1.0 if category >= 2 else (maxf(0.65, weak_postflop_weight) if category == 1 or bool(candidate_features.draw) else weak_postflop_weight)
	# Empty model callers (e.g. offline coaching) keep uniform sampling.
	if model.is_empty() and not raised and not observation.has("street"):
		return 1.0
	return maxf(0.02, weight)
