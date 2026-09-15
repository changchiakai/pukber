extends Control

const INITIAL_CHIP_OPTIONS := [10000, 50000, 100000]

var count: OptionButton
var attitude: OptionButton
var chips: OptionButton
var deck_hint: Label
var short_deck: CheckButton

func _ready() -> void:
	PokerUI.install(self)
	PokerUI.label(self, "OFFLINE HOLD’EM  /  AI COACH", Rect2(88, 72, 800, 32), 18, PokerUI.GOLD)
	PokerUI.label(self, "德州練習桌", Rect2(88, 157, 650, 100), 76)
	PokerUI.label(self, "玩一手，學一手。", Rect2(94, 258, 650, 42), 24, PokerUI.GOLD)
	PokerUI.label(self, "牌會說話，人不一定。", Rect2(92, 310, 630, 52), 30, PokerUI.MUTED)
	PokerUI.cards(self, [PokerCard.new(14, 0), PokerCard.new(14, 1), PokerCard.new(14, 2), PokerCard.new(14, 3), PokerCard.new(13, 0)], Vector2(95, 393), 0, 1.45)
	PokerUI.label(self, "單副牌 · 標準德州撲克 · 觀察對手的每一次下注", Rect2(92, 548, 620, 42), 19, PokerUI.GOLD)
	PokerUI.label(self, "完全離線的單人德州撲克\n從下注、發言與攤牌紀錄，辨別誰在虛張聲勢。\n起始籌碼可選 100 BB / 500 BB / 1,000 BB。", Rect2(92, 618, 650, 128), 20, PokerUI.MUTED)
	var setup := PokerUI.panel(self, Rect2(800, 52, 545, 776))
	PokerUI.label(setup, "設定你的牌局", Rect2(34, 26, 450, 48), 30)
	PokerUI.label(setup, "電腦對手", Rect2(34, 103, 450, 32))
	count = OptionButton.new()
	count.name = "AICount"
	count.position = Vector2(34, 143)
	count.size = Vector2(475, 52)
	for number in range(1, 5):
		count.add_item("%d 名 AI  +  你" % number)
	count.selected = App.settings.ai_count - 1
	setup.add_child(count)
	count.item_selected.connect(_selection_changed)
	PokerUI.label(setup, "本場態度分布", Rect2(34, 219, 450, 32))
	attitude = OptionButton.new()
	attitude.name = "Attitude"
	attitude.position = Vector2(34, 261)
	attitude.size = Vector2(475, 52)
	attitude.add_item("較多說謊者")
	attitude.add_item("較多說實話者")
	attitude.selected = 0 if App.settings.liars_majority else 1
	setup.add_child(attitude)
	attitude.item_selected.connect(_selection_changed)
	PokerUI.label(setup, "起始籌碼", Rect2(34, 337, 450, 32))
	chips = OptionButton.new()
	chips.name = "InitialChips"
	chips.position = Vector2(34, 377)
	chips.size = Vector2(475, 52)
	for amount in INITIAL_CHIP_OPTIONS:
		chips.add_item(_format_chips(amount))
	chips.selected = maxi(0, INITIAL_CHIP_OPTIONS.find(App.settings.initial_chips))
	setup.add_child(chips)
	chips.item_selected.connect(_selection_changed)
	short_deck = CheckButton.new()
	short_deck.name = "ShortDeck"
	short_deck.text = "以短牌德州進行（36 張；同花 ＞ 葫蘆）"
	short_deck.position = Vector2(34, 446)
	short_deck.size = Vector2(475, 34)
	short_deck.button_pressed = App.settings.short_deck
	setup.add_child(short_deck)
	short_deck.toggled.connect(func(_enabled: bool): _selection_changed(0))
	deck_hint = PokerUI.label(setup, "", Rect2(34, 488, 475, 86), 15, PokerUI.MUTED)
	deck_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_selection_changed(count.selected)
	var start := PokerUI.accent_button(setup, "入座，開始遊戲   →", Rect2(34, 592, 475, 56), _start)
	start.name = "StartGame"
	PokerUI.button(setup, "離開遊戲", Rect2(34, 666, 475, 44), func(): get_tree().quit())
	PokerUI.label(self, "NO LIMIT    /    小盲 0.5 BB · 大盲 1 BB    /    AI 身分於結束後揭曉", Rect2(90, 850, 1240, 34), 17, PokerUI.MUTED)
	start.grab_focus()

func _selection_changed(_index: int) -> void:
	if deck_hint:
		var is_short_deck: bool = short_deck and short_deck.button_pressed
		var rules := "短牌 36 張 · 同花＞葫蘆 · A-6-7-8-9 可成順" if is_short_deck else "標準牌 52 張"
		var detail := "短牌模式移除 2、3、4、5；三條仍低於順子。" if is_short_deck else "標準模式使用完整 52 張牌與一般牌型大小。"
		deck_hint.text = "%d 名 AI 對上你 · 每人 %s\n%s\n%s" % [count.selected + 1, _format_chips(INITIAL_CHIP_OPTIONS[chips.selected]), rules, detail]

func _start() -> void:
	App.settings.ai_count = count.selected + 1
	App.settings.liars_majority = attitude.selected == 0
	App.settings.initial_chips = INITIAL_CHIP_OPTIONS[chips.selected]
	App.settings.short_deck = short_deck.button_pressed
	App.start_match()

func _format_chips(amount: int) -> String:
	return StakeFormat.bb(amount)
