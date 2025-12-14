extends Control

func _ready():
	$AnimationPlayer.play("RESET")
	
func resume():
	get_tree().paused = false
	$AnimationPlayer.play_backwards("blur")
	
func pause():
	get_tree().paused = true
	$AnimationPlayer.play("blur")
	$PanelContainer/VBoxContainer/Resume.grab_focus()

func testEsc():
	if Input.is_action_just_pressed("pause") and !get_tree().paused:
		pause()
	elif Input.is_action_just_pressed("pause") and get_tree().paused:
		resume()
		
func _on_resume_pressed() -> void:
	resume()

func _on_restart_pressed() -> void:
	resume()
	get_tree().reload_current_scene()
	PlayerVar.health = PlayerVar.MAX_HEALTH

func _on_options_pressed() -> void:
	var options = preload("res://scenes/Menus/options_menu.tscn").instantiate()
	add_child(options)

	options.back.connect(func():
		options.queue_free()
	)

func _on_quit_pressed() -> void:
	resume()
	get_tree().change_scene_to_file("res://scenes/Menus/HomeScreenScenes/StartScreen.tscn")

func _process(delta):
	testEsc()
