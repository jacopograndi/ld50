extends Node

var popup : Popup

func _ready():
	popup = get_parent().get_node("popup");

func help():
	popup.show()
	
func ok():
	popup.hide()
