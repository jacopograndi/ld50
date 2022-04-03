extends Node

var panel : Panel
var label : Label

var current = "init"
var text = {
	"init": {
		"text": "Navigation anomaly! We teleported in the wrong place!",
		"next": "init2"
	},
	"init2": {
		"text": "THIS IS THE VAULT OF THE KING'S SPACE CASTLE! PERPARE TO DIE!",
		"next": "init3"
	},
	"init3": {
		"text": "We are doomed.",
		"next": "close"
	},
	"player2": {
		"text": "I found a piece of my ship! Now I can use it!",
		"next": "close"
	},
	"player3": {
		"text": "Another piece! This one has the log disk intact.",
		"next": "disk1"
	},
	"disk1": {
		"text": "Hmm, the logs stop a minute before the incident.",
		"next": "close"
	},
	"player4": {
		"text": "This is the last piece! Maybe i can make it outside in time!",
		"next": "close"
	},
	"ending1": {
		"text": "Hello! I'm the king.",
		"next": "ending2"
	},
	"ending2": {
		"text": "Sorry for the confusion, the defences are so irritable.",
		"next": "ending3"
	},
	"ending3": {
		"text": "Anyway, you made it as expected.",
		"next": "ending4"
	},
	"ending4": {
		"text": "Come then. Have a tea.",
		"next": "end"
	},
}

func _ready():
	panel = get_tree().root.get_child(0).get_node("gui").get_node("panel")
	label = panel.get_node("label")
	next()
	
	panel.connect("gui_input", self, "proceed")
	
func next():
	if current == "end":
		get_tree().change_scene("res://scenes/menu.tscn")
		return
	panel.show()
	label.text = text[current].text
	current = text[current].next

func moved():
	panel.hide()
	current = "close"
	
func ending():
	current = "ending1"
	next()
	
func friend(name):
	current = name
	next()
	
func proceed(event: InputEvent):
	if Input.is_action_just_pressed("proceed"):
		if current == "close":
			panel.hide()
			return
		next()
