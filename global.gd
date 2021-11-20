extends Node

export var audio_bus_name := "Music"

onready var _bus := AudioServer.get_bus_index(audio_bus_name)

func _input(event):
	if event.is_action_pressed("toggle_fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen
