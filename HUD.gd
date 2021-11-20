extends Control

signal play_again

var gameLost = false

func _ready():
	$HUDLayer/RestartMenu.visible = false
	$HUDLayer/PauseMenu.visible = false
	$HUDLayer/PlayAgain.visible = false
	$HUDLayer/ClickSprite.visible = true
	$HUDLayer/PauseMenu/Resume.disabled = true

func showPlayAgain():
	#$HUD/HUDLayer/RestartMenu/CenterContainer/VBoxContainer/PlayAgain.disabled = false
	$HUDLayer/RestartMenu/CenterContainer/Background.set_modulate(Color(1,1,1,1))
	$HUDLayer/PlayAgain.set_modulate(Color(1,1,1,1))
	$HUDLayer/PlayAgain.visible = true

func _on_PlayAgain_pressed():
	gameLost = false
	get_tree().paused = false
	$HUDLayer/PlayAgain.visible = false
	emit_signal("play_again")
	
func _input(event):
	if event.is_action_pressed("toggle_fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen
	
	if event.is_action_pressed("game_pause") and !gameLost:
		get_tree().paused = true
		$HUDLayer/PauseMenu/Resume.disabled = false
		$HUDLayer/PauseMenu.visible = true


func _on_Camera2D_update_score(position, height):
	position = -(position / 3)
	position = stepify(position, 1)
	height = stepify((height / 3), 1)
	var score = height - position
	$HUDLayer/RestartMenu/CenterContainer/VBoxContainer/ScoreLabel.text = str("SCORE: ", score)


func _on_Resume_pressed():
	get_tree().paused = false
	$HUDLayer/PauseMenu.visible = false


func _on_Level_lost():
	gameLost = true


func _on_Settings_pressed():
	$HUDLayer/Settings.visible = true


func _on_Settings_close_settings():
	$HUDLayer/Settings.visible = false


func _on_Exit_pressed():
	get_tree().change_scene("res://MainMenu.tscn")
