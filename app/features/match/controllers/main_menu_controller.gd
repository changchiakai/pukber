extends Control

const INITIAL_CHIP_OPTIONS := [10000, 50000, 100000]

var count: OptionButton
var attitude: OptionButton
var chips: OptionButton
var deck_hint: Label

func _ready() -> void:
	PokerUI.install(self)
	PokerUI.label(self, "OFFLINE HOLD’EM  /  AI COACH", Rect2(88, 72, 800, 32), 18, PokerUI.GOLD)
	PokerUI.label(self, "德州練習桌", Rect2(88, 157, 650, 100), 76)
	PokerUI.label(self, "玩一手，學一手。", Rect2(94, 258, 650, 42), 24, PokerUI.GOLD)
	PokerUI.label(self, "牌會說話，人不一定。", Rect2(92, 310, 630, 52), 30, PokerUI.MUTED)
	PokerUI.cards(self, [PokerCard.new(14, 0), PokerCard.new(14, 1), PokerCard.new(14, 2), PokerCard.new(14, 3), PokerCard.new(13, 0)], Vector2(95, 393), 0, 1.45)
	PokerUI.label(self, "單副牌 · 標準德州撲克 · 觀察對手的每一次下注", Rect2(92, 548, 620, 42), 19, PokerUI.GOLD)
	PokerUI.label(self, "完全離線的單人德州撲克\n從下注、發言與攤牌紀錄，辨別誰在虛張聲勢。\n起始籌碼可選 100 BB / 500 BB / 1,000 BB。", Rect2(92, 618, 650, 128), 20, PokerUI.MUTED)
	var setup := PokerUI.panel(self, Rect2(800, 152, 545, 676))
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
	deck_hint = PokerUI.label(setup, "", Rect2(34, 450, 475, 68), 18, PokerUI.MUTED)
	_selection_changed(count.selected)
	var start := PokerUI.accent_button(setup, "入座，開始遊戲   →", Rect2(34, 528, 475, 62), _start)
	start.name = "StartGame"
	PokerUI.button(setup, "離開遊戲", Rect2(34, 608, 475, 46), func(): get_tree().quit())
	PokerUI.label(self, "NO LIMIT    /    小盲 0.5 BB · 大盲 1 BB    /    AI 身分於結束後揭曉", Rect2(90, 850, 1240, 34), 17, PokerUI.MUTED)
	start.grab_focus()

func _selection_changed(_index: int) -> void:
	if deck_hint:
		deck_hint.text = "%d 名 AI 對上你 · 單副牌 52 張\n每人 %s 籌碼，對局中隱藏 AI 類型與勝率。" % [count.selected + 1, _format_chips(INITIAL_CHIP_OPTIONS[chips.selected])]

func _start() -> void:
	App.settings.ai_count = count.selected + 1
	App.settings.liars_majority = attitude.selected == 0
	App.settings.initial_chips = INITIAL_CHIP_OPTIONS[chips.selected]
	App.start_match()

func _format_chips(amount: int) -> String:
	return StakeFormat.bb(amount)
