extends Node

var panel : Panel
var label : Label

var current = "init"
var text = {
	"init": {
		"text": "Noooo! Navigation anomaly! Help!",
		"next": "init2"
	},
	"init2": {
		"text": "The ship fractured!",
		"next": "init3"
	},
	"init3": {
		"text": "This is the main vault chamber! We should be in the atrium!",
		"next": "init4"
	},
	"init4": {
		"text": "INTRUDER ALERT! ALL DEFENSIVE SYSTEM ACTIVATED! DIE THIEF!",
		"next": "init5"
	},
	"init5": {
		"text": "We are doomed.",
		"next": "close"
	}
}

func _ready():
	panel = get_tree().root.get_child(0).get_node("gui").get_node("panel")
	label = panel.get_node("label")
	label.text = text[current].text
	current = text[current].next
	
	panel.connect("gui_input", self, "proceed")
	
func moved():
	panel.hide()
	current = "close"
	
func proceed(event: InputEvent):
	if Input.is_action_just_pressed("proceed"):
		if current == "close":
			panel.hide()
			return
		label.text = text[current].text
		current = text[current].next
