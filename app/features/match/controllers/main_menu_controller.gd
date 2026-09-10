extends Control

var count: OptionButton
var attitude: OptionButton
var deck_hint: Label

func _ready() -> void:
	PokerUI.install(self)
	PokerUI.label(self, "PUKER  /  OFFLINE HOLD’EM", Rect2(88, 72, 800, 32), 18, PokerUI.GOLD)
	PokerUI.label(self, "讀心牌桌", Rect2(88, 157, 650, 100), 76)
	PokerUI.label(self, "牌會說話，人不一定。", Rect2(92, 274, 630, 52), 30, PokerUI.MUTED)
	PokerUI.cards(self, [PokerCard.new(14, 0), PokerCard.new(14, 1), PokerCard.new(14, 2), PokerCard.new(14, 3), PokerCard.new(14, 0, 1)], Vector2(95, 393), 0, 1.45)
	PokerUI.label(self, "多副牌 · 五條最大 · 觀察對手的每一次下注", Rect2(92, 548, 620, 42), 19, PokerUI.GOLD)
	PokerUI.label(self, "完全離線的單人德州撲克\n從下注、發言與攤牌紀錄，辨別誰在虛張聲勢。\n每人 10,000 籌碼，直到你出局或成為最後贏家。", Rect2(92, 618, 650, 128), 20, PokerUI.MUTED)
	var setup := PokerUI.panel(self, Rect2(800, 152, 545, 605))
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
	deck_hint = PokerUI.label(setup, "", Rect2(34, 341, 475, 65), 18, PokerUI.MUTED)
	_selection_changed(count.selected)
	var start := PokerUI.button(setup, "入座，開始遊戲   →", Rect2(34, 433, 475, 62), _start)
	start.name = "StartGame"
	start.add_theme_stylebox_override("normal", PokerUI.box(PokerUI.GREEN, PokerUI.GOLD))
	PokerUI.button(setup, "離開遊戲", Rect2(34, 513, 475, 48), func(): get_tree().quit())
	PokerUI.label(self, "NO LIMIT    /    小盲 50 · 大盲 100    /    AI 身分於結束後揭曉", Rect2(90, 826, 1240, 34), 17, PokerUI.MUTED)
	start.grab_focus()

func _selection_changed(index: int) -> void:
	if deck_hint:
		deck_hint.text = "本場使用 %d 副牌 · 每人 10,000 籌碼\n對局中隱藏 AI 類型與勝率。" % ((index + 2) * 2)

func _start() -> void:
	App.settings.ai_count = count.selected + 1
	App.settings.liars_majority = attitude.selected == 0
	App.start_match()
