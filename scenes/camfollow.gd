extends Camera2D

var movement : Node
var playertiles : TileMap 


# Called when the node enters the scene tree for the first time.
func _ready():
	movement = get_tree().root.get_child(0).get_node("movement")
	playertiles = get_tree().root.get_child(0).get_node("playertiles")

func _process(delta):
	if movement.players.size() == 0: return
	
	var center = Vector2(0, 0)
	for player in movement.players:
		center += movement.get_player_center("player" + str(player))
	center /= movement.players.size()
	center = playertiles.map_to_world(center)
	transform.origin = center
