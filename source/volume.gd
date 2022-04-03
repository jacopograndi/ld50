extends Node

var music

func _ready():
	music = get_tree().root.get_child(0).get_node("music")

func _on_HSlider_value_changed(value):
	music.volume_db = log(value) * 20
