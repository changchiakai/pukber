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

	return random_line(profile.rng, lines)

static func estimate_equity(observation: Dictionary, rng: RandomNumberGenerator) -> float:
	var unseen := PokerDeck.new(observation.deck_count).cards
	var known: Dictionary = {}
	for card in observation.hole + observation.board:
		known[card.identity()] = true
	unseen = unseen.filter(func(card): return not known.has(card.identity()))
	var samples := maxi(1, int(observation.samples))
	var equity := 0.0
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
		for opponent in range(observation.opponents.size()):
			var start := missing + opponent * 2
			var score: int = HandEvaluator.evaluate(pool.slice(start, start + 2) + board).score
			if score > hero:
				lost = true
				break
			if score == hero:
				ties += 1
		if not lost:
			equity += 1.0 / ties
	return equity / samples

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

static func choose(observation: Dictionary, profile: AIProfile, equity: float) -> Dictionary:
	var legal: Dictionary = observation.legal
	var fair_share: float = 1.0 / (observation.opponents.size() + 1)
	var texture := board_texture(observation.get("board", []))
	var tendencies := opponent_tendencies(observation.get("opponents", []))
	var street := int(observation.get("street", 0))
	var in_position := bool(observation.get("in_position", false))
	var bucket := String(observation.get("position_bucket", "middle"))
	var heads_up := int(observation.get("player_count", observation.opponents.size() + 1)) <= 2
	var wetness := float(texture.get("wetness", 0.0))
	var strength := clampf(equity + profile.rng.randf_range(-0.05, 0.05), 0.0, 1.0)
	strength += 0.04 if in_position else -0.02
	strength += 0.03 if heads_up else 0.0
	strength -= 0.02 if street >= 1 and wetness >= 0.55 and not in_position else 0.0
	strength += 0.03 if int(tendencies.get("calling_count", 0)) > 0 and equity > 0.58 else 0.0
	strength -= 0.03 if int(tendencies.get("reraiser_count", 0)) > 0 and street == 0 and not in_position else 0.0
	strength = clampf(strength, 0.0, 1.0)
	var strength_threshold := fair_share + 0.12
	strength_threshold -= 0.03 if bucket == "late" else 0.0
	strength_threshold += 0.03 if bucket == "early" else 0.0
	strength_threshold -= 0.03 if int(tendencies.get("tight_count", 0)) > int(tendencies.get("calling_count", 0)) else 0.0
	strength_threshold += 0.03 if int(tendencies.get("reraiser_count", 0)) > 0 and not in_position else 0.0
	var strong: bool = strength > strength_threshold
	var bluff_rate := profile.bluff_rate
	bluff_rate *= 1.2 if in_position else 0.85
	bluff_rate *= 1.15 if wetness < 0.4 else 0.75
	bluff_rate *= 1.1 if heads_up else 1.0
	bluff_rate *= 1.25 if float(tendencies.get("avg_fold_rate", 0.0)) >= 0.28 else 1.0
	bluff_rate *= 0.58 if int(tendencies.get("calling_count", 0)) > 0 else 1.0
	bluff_rate *= 0.82 if int(tendencies.get("reraiser_count", 0)) > 0 and street == 0 else 1.0
	var bluff: bool = not strong and profile.rng.randf() < clampf(bluff_rate, 0.0, 0.55)
	seed_street_plan(observation, profile, fair_share, strength, strong, bluff, texture, tendencies)
	var plan := apply_street_plan(observation, profile, fair_share, strength, strong, bluff, tendencies, texture)
	bluff = bool(plan.get("bluff", bluff))
	strength_threshold += float(plan.get("threshold_shift", 0.0))
	strong = strength > strength_threshold
	var aggression := float(plan.get("aggression", profile.aggression))
	var pot_odds := float(legal.call) / maxf(1.0, observation.pot + legal.call)
	var action := "check" if legal.check else "call"
	var amount := 0
	var trap := should_trap(observation, profile, strong, texture, plan)
	var floating := should_float(observation, profile, strong, bluff, fair_share, strength, pot_odds, tendencies)
	if trap and int(observation.get("street", 0)) <= 2 and profile.hand_plan != "pressure":
		profile.set_hand_plan("pressure", int(observation.get("street", 0)), 1, 0.14, 0.1)
	if floating:
		bluff = false
		action = "call"
		if int(observation.get("street", 0)) == 1 and profile.hand_plan.is_empty():
			profile.set_hand_plan("pressure", 1, 1, 0.1, -0.04)
	var budget := int(observation.chips * (0.22 if bluff else 0.65))
	if street >= 1 and strong and wetness >= 0.55:
		budget = int(observation.chips * 0.78)
	elif in_position and not bluff:
		budget = int(observation.chips * 0.58)
	if strong and int(tendencies.get("calling_count", 0)) > 0:
		budget = maxi(budget, int(observation.chips * 0.72))
	if bluff and int(tendencies.get("tight_count", 0)) > 0:
		budget = int(observation.chips * 0.26)
	if bool(plan.get("control_active", false)) and not strong:
		budget = mini(budget, int(observation.chips * 0.38))
	if not trap and not floating and legal.can_raise and (strong or bluff or bool(plan.get("continue_pressure", false))) and profile.rng.randf() < aggression:
		var fraction := choose_bet_fraction(observation, profile, strong, bluff, texture)
		if strong and int(tendencies.get("calling_count", 0)) > 0:
			fraction += 0.12
		elif bluff and int(tendencies.get("tight_count", 0)) > 0:
			fraction -= 0.08
		fraction += float(plan.get("size_bias", 0.0))
		fraction = clampf(fraction, 0.25, 4.8)
		var target := 0
		if street == 0:
			target = int(maxf(float(legal.min_to), observation.big_blind * fraction))
		else:
			target = int(observation.bet + legal.call + maxi(observation.big_blind, int(observation.pot * fraction)))
		amount = mini(legal.max_to, maxi(legal.min_to, target))
		if amount - int(observation.bet) <= budget or (strong and strength > 0.72) or (street >= 2 and strong and in_position) or bool(plan.get("continue_pressure", false)):
			action = "raise"
	if action != "raise" and not legal.check and not floating:
		if street >= 1 and in_position and not strong and strength < fair_share and profile.float_rate < 0.15 and float(tendencies.get("avg_reraise_rate", 0.0)) >= 0.16:
			action = "fold"
		var fold_threshold := profile.risk_tolerance
		fold_threshold += 0.02 if in_position else -0.02
		fold_threshold += 0.03 if heads_up else 0.0
		fold_threshold += float(plan.get("fold_shift", 0.0))
		if strength + fold_threshold < pot_odds or (legal.call > observation.chips * (0.52 if in_position else 0.42) and strength < fair_share and not bluff):
			action = "fold"
	profile.note_plan_action(street, action)
	var claim_strong := strong
	if profile.rng.randf() < (0.65 if profile.is_liar else 0.08):
		claim_strong = not claim_strong
	var speech := build_speech(profile, action, strong, bluff, claim_strong)
	return {"action": action, "amount": amount, "speech": speech}
