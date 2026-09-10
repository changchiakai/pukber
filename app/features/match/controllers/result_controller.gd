extends Control

func _ready() -> void:
	PokerUI.install(self)
	if App.match_system == null:
		App.show_menu()
		return
	var state: TableState = App.match_system.state
	PokerUI.label(self, "PUKER  /  MATCH REPORT", Rect2(94, 52, 1100, 38), 18, PokerUI.GOLD)
	var title := "冠軍：%s" % state.players[state.champion].display_name if state.champion >= 0 else "你已出局"
	PokerUI.label(self, title, Rect2(90, 114, 1260, 86), 56)
	PokerUI.label(self, "第 %d 手結束 · 真實態度揭曉" % state.hand_number, Rect2(94, 208, 1200, 40), 24, PokerUI.MUTED)
	var rows := state.players.duplicate()
	rows.sort_custom(func(a, b): return a.chips > b.chips)
	PokerUI.label(self, "名次 / 玩家", Rect2(112, 282, 300, 40), 18, PokerUI.GOLD)
	PokerUI.label(self, "剩餘 BB", Rect2(414, 282, 210, 40), 18, PokerUI.GOLD)
	PokerUI.label(self, "真實態度", Rect2(644, 282, 270, 40), 18, PokerUI.GOLD)
	PokerUI.label(self, "加注 / 證實詐唬 / 價值下注", Rect2(959, 282, 360, 40), 18, PokerUI.GOLD)
	for index in range(rows.size()):
		var player: PlayerState = rows[index]
		var row := PokerUI.panel(self, Rect2(94, 335 + index * 67, 1248, 58))
		var rank_text := "第 %d 名" % player.finish_rank if player.finish_rank > 0 else "尚未分出名次"
		PokerUI.label(row, rank_text + "  " + player.display_name, Rect2(18, 7, 300, 42), 20)
		PokerUI.label(row, StakeFormat.bb(player.chips), Rect2(320, 7, 210, 42), 20, PokerUI.GOLD)
		PokerUI.label(row, "真人玩家" if player.seat == 0 else ("說謊型" if player.profile.is_liar else "說實話型"), Rect2(550, 7, 270, 42), 20)
		PokerUI.label(row, "%d   /   %d   /   %d" % [player.raises, player.proven_bluffs, player.value_bets], Rect2(865, 7, 330, 42), 20)
	var note := "同手淘汰者並列名次。詐唬／價值下注只按已攤牌資訊計算，不等同真實性格。"
	if state.champion < 0:
		note = "真人出局後本場停止；存活 AI 尚未分出冠軍。已淘汰名次保留。\n" + note
	PokerUI.label(self, note, Rect2(95, 692, 1248, 62), 17, PokerUI.MUTED)
	PokerUI.button(self, "AI 復盤：3 個關鍵決策", Rect2(94, 795, 450, 60), App.show_review).name = "OpenReview"
	PokerUI.button(self, "重新開始", Rect2(730, 795, 300, 60), App.start_match).name = "Restart"
	PokerUI.button(self, "回主選單", Rect2(1050, 795, 292, 60), App.show_menu).name = "BackToMenu"
