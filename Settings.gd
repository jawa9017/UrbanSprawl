extends Control

#onready var global = get_node("/.../global")

signal close_settings

var musicVolume

export var audio_bus_name := "Music"

onready var _bus1 := AudioServer.get_bus_index(audio_bus_name)

export var audio_bus_name2 := "SFX"

onready var _bus2 := AudioServer.get_bus_index(audio_bus_name2)

func _ready():
	$MusicSlider.value = 0.45
	$music.playing = true
	$MusicSlider.value = db2linear(AudioServer.get_bus_volume_db(_bus1))
	$SFXSlider.value = db2linear(AudioServer.get_bus_volume_db(_bus2))

func _on_HSlider_value_changed(value):
	AudioServer.set_bus_volume_db(_bus1, linear2db(value))


func _on_Back_pressed():
	emit_signal("close_settings")


func _on_SFXSlider_value_changed(value):
	AudioServer.set_bus_volume_db(_bus2, linear2db(value))
