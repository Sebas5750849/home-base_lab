extends Node

var testing: bool
const supabase_url = "https://dwuljxbensnlylflfmqq.supabase.co"
const supabase_key = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImR3dWxqeGJlbnNubHlsZmxmbXFxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjUyOTAxMTMsImV4cCI6MjA4MDg2NjExM30.gW94SJAYutdK3rJSoECZEPmiSegjK0GcHQkgNMcN2_A"

func send_death_event(player_id: String, position: Vector2, level: String) -> void:
	var url = supabase_url + "/rest/v1/death_events"
	var payload = {
		"player_id": player_id,
		"death_x": position.x,
		"death_y": position.y,
		"death_level": level
	}
	
	var headers = ["Content-Type: application/json", "apikey: "+ supabase_key, "Authorization: Bearer " + supabase_key, "Prefer: return=minimal"]
	
	
	var request = HTTPRequest.new()
	add_child(request)
	
	request.request(url, headers, HTTPClient.METHOD_POST, JSON.stringify(payload))
	
func send_damage_event(player_id: String, position: Vector2, level: String) -> void:
	var url = supabase_url + "/rest/v1/damage_events"
	var payload = {
		"player_id": player_id,
		"damage_x": position.x,
		"damage_y": position.y,
		"damage_level": level
	}
	
	var headers = ["Content-Type: application/json", "apikey: "+ supabase_key, "Authorization: Bearer " + supabase_key, "Prefer: return=minimal"]
	
	
	var request = HTTPRequest.new()
	add_child(request)
	
	request.request(url, headers, HTTPClient.METHOD_POST, JSON.stringify(payload))
