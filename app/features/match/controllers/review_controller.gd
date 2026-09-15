extends Control

func _ready() -> void:
	PokerUI.install(self)
	if App.match_system == null or not App.match_system.state.finished:
		App.show_menu()
		return
	var reviews := PostMatchCoach.top_decisions(App.match_system.state.review_decisions)
	PokerUI.label(self, "AI 復盤", Rect2(94, 50, 600, 56), 42, PokerUI.GOLD)
	PokerUI.label(self, "本場最值得檢討的 3 個決策", Rect2(96, 112, 850, 36), 23)
	PokerUI.label(self, "賽後近似分析：以 Monte Carlo 權益與底池賠率排序，不是即時輔助或完整 Solver 解。", Rect2(96, 152, 1170, 31), 16, PokerUI.MUTED)
	if reviews.is_empty():
		PokerUI.label(self, "本場沒有可復盤的真人決策。", Rect2(96, 270, 900, 50), 25, PokerUI.MUTED)
	else:
		for index in range(reviews.size()):
			_draw_review(reviews[index], index)
	PokerUI.accent_button(self, "返回結算", Rect2(1050, 794, 292, 60), App.show_result).name = "BackToResult"

func _draw_review(review: Dictionary, index: int) -> void:
	var panel := PokerUI.panel(self, Rect2(94, 212 + index * 180, 1248, 156), Color("112b29"), PokerUI.GOLD)
	var title := "#%d  第 %d 手・%s・你選擇%s" % [index + 1, review.hand, PostMatchCoach.street_name(review.street), PostMatchCoach.action_name(review.action)]
	PokerUI.label(panel, title, Rect2(22, 13, 700, 34), 21, PokerUI.GOLD)
	PokerUI.cards(panel, review.hole, Vector2(748, 14), 2, 0.7)
	PokerUI.cards(panel, review.board, Vector2(900, 14), 5, 0.58)
	PokerUI.label(panel, "建議：%s" % review.recommendation, Rect2(22, 57, 1160, 33), 21)
	var detail := PokerUI.label(panel, review.reason, Rect2(22, 94, 1160, 48), 16, PokerUI.MUTED)
	detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
