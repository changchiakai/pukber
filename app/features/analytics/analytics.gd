extends Node

# Web-only, privacy-preserving Umami event bridge. Event payloads must never
# contain cards, player names, AI profiles, or other private match state.
func track(event_name: String, data: Dictionary = {}) -> void:
	if not OS.has_feature("web"):
		return
	var event_json: String = JSON.stringify(event_name)
	var data_json: String = JSON.stringify(data)
	var script: String = "if (window.umami && typeof window.umami.track === 'function') { window.umami.track(%s, %s); }" % [event_json, data_json]
	JavaScriptBridge.eval(script, true)
