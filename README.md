# 德州練習桌

玩一手，學一手。

依 `docs/德州撲克開發規劃書.md` 製作的 Godot 4 / GDScript 離線 Windows MVP。

## 開始遊玩

直接開啟 `build/windows/Puker.exe`，不需要安裝 Godot 或連網。

若要編輯，使用 Godot **4.4.1 或相容的 4.x** 匯入根目錄 `project.godot`，按 F6/F5 執行場景／遊戲。此工作區的引擎位於 `.tools/godot/`，不納入版本控制。

主選單可選 1～4 名 AI 及態度分布。你固定坐在下方；操作列提供棄牌、過牌／跟注、加注至指定總額及全下。每手結算後按「下一手」，保留閱讀攤牌與紀錄的時間。真人出局或產生唯一贏家後按「查看本場結果」，可重新開始或回主選單。

## 已實作規則

- 每人起始籌碼可選 10,000、50,000 或 100,000；固定小盲 50、大盲 100；每局固定使用單副牌 52 張。
- 每手重新建立並洗牌；翻牌前、翻牌、轉牌、河牌、攤牌，支援燒牌與兩人桌盲注順序。
- 無限注、完整加注額、短額全下、累積短加注重新開放加注權、未跟注籌碼退回、主池／多邊池及平手分池。零頭按莊家左側起順時針分配。
- 單副牌標準牌型比較；A 可組最小順子；先比點數與踢腳，完全同點數時再比花色，順序為黑桃、愛心、方塊、梅花。
- AI 僅透過公開資訊查詢取得自己的底牌、公牌與下注資訊。每次決策預設 48 次 Monte Carlo 抽樣，依公開行為加權對手範圍，搭配底池賠率、位置、聽牌與固定性格進行混合決策。
- AI 真實類型與勝率在對局中隱藏，短暫繁中發言、動作與攤牌紀錄供觀察。
- 最近 300 筆事件保留於本場記憶體；累計加注、證實詐唬與價值下注統計不受紀錄裁切影響。
- AI 不補碼；真人出局立即停止本場；重新開始才重置籌碼。

## 規劃書的實作判定

1. 5.1 與 5.3 對 Monte Carlo 的描述不同，依第 9 節驗收與第 10 節已確認決定實作隨機模擬。
2. 真人出局即停止；若尚有多名 AI，結果標示「尚未分出名次」，不捏造冠軍或在背景代替玩家繼續。只剩一人時正常顯示冠軍。
3. 同手淘汰者採並列名次。規劃書未指定同手淘汰排序。
4. 已證實詐唬暫定為「本手曾主動下注／加注、進入攤牌、最終牌型低於兩對」。兩對以上算價值下注；每手每位最多記一次。此公開統計不代表真實 AI 類型。
5. 加注欄位表示「本輪總下注至多少」，不足最低額時僅可全下；無可跟注對手時禁止建立空邊池。
6. `MatchSettings.show_practice_equity` 保留為未來設定；一般 UI 不讀取或展示勝率。存檔、連線與高階 AI 不在 MVP 範圍。

## 結構

`app/app_architecture.gd` 組合設定與牌局，負責場景轉換。

`app/features/match/` 的 models 保存狀態，systems 處理牌型／下注／分池／回合，commands 執行玩家操作，queries 建立 UI 安全視圖，controllers 處理畫面與輸入。`app/features/ai/` 獨立管理性格、合法觀察與決策。所有規則系統均為不依賴場景的 `RefCounted`。

`TurnSystem.event_occurred(event_name, details)` 發送規劃書列出的九類事件；內容不包含未公開底牌。

## 測試

PowerShell，於專案根目錄執行（將 `$pokerGodot` 改成自己的 Godot 路徑）：

```powershell
$pokerGodot = '.\.tools\godot\Godot_v4.4.1-stable_win64_console.exe'
& $pokerGodot --headless --editor --path . --quit-after 3
& $pokerGodot --headless --path . --script tests/integration/check_resources.gd
& $pokerGodot --headless --path . --script tests/unit/rules_test.gd
& $pokerGodot --headless --path . --script tests/integration/match_simulation.gd
& $pokerGodot --path . --script tests/integration/ui_smoke.gd --quit-after 20000
```

UI 測試會建立 `test-results/`、擷取四個畫面並以滑鼠事件操作，測試時會加速 AI 計時。正常遊戲不加速。先建立輸出目錄再傳入 `--log-file`，避免引擎無法初始化紀錄檔。

Windows 匯出需安裝與引擎版本一致的模板：

```powershell
New-Item -ItemType Directory -Force build/windows | Out-Null
& $pokerGodot --headless --path . --export-release 'Windows Desktop' build/windows/Puker.exe
```

若特定機器的 OpenGL 驅動有問題，可依 [Godot 4.4 官方設定文件](https://docs.godotengine.org/en/4.4/classes/class_projectsettings.html) 使用 `--rendering-driver opengl3_angle` 測試 Direct3D 11 相容路徑。本機最終採原生 OpenGL 驗證通過。

完整驗證範圍見 `docs/驗證紀錄.md`。

## AI 策略更新

[AI 四條街策略與修改方式](docs/AI策略修改說明.md)

[AI 強度與趣味邏輯（目前版本）](docs/AI強度與趣味邏輯.md)：短碼門檻、位置範圍、持續下注、誘敵、對手適應與調整參數。本次僅修改來源碼與文件，未執行測試或更新匯出成品。
