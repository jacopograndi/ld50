extends Node

var playertiles : TileMap 
var enemytiles : TileMap 

var indx_trap_off : int
var indx_trap_med : int
var indx_trap_on : int
var indx_player0 : int
var indx_player1 : int
var indx_bullet : int
var indx_shooter : Array

var shooters : Node2D
var bullets : Node2D

var movement : Node

var shooter_scene : PackedScene
var bullet_scene : PackedScene

var init_state = {}

func _ready():
	movement = get_tree().root.get_child(0).get_node("movement")
	playertiles = get_tree().root.get_child(0).get_node("playertiles")
	enemytiles = get_tree().root.get_child(0).get_node("enemytiles")
	shooters = get_tree().root.get_child(0).get_node("shooters")
	bullets = get_tree().root.get_child(0).get_node("bullets")
	
	shooter_scene = load("res://scenes/shooter.tscn")
	bullet_scene = load("res://scenes/bullet.tscn")
	
	indx_trap_off = enemytiles.tile_set.find_tile_by_name("trap_off")
	indx_trap_med = enemytiles.tile_set.find_tile_by_name("trap_med")
	indx_trap_on = enemytiles.tile_set.find_tile_by_name("trap_on")
	indx_player0 = playertiles.tile_set.find_tile_by_name("player0")
	indx_player1 = playertiles.tile_set.find_tile_by_name("player1")
	
	var directions = {
		"N": Vector2(0, -1), 
		"NE": Vector2(1, -1), 
		"E": Vector2(1, 0), 
		"SE": Vector2(1, 1), 
		"S": Vector2(0, 1), 
		"SW": Vector2(-1, 1), 
		"W": Vector2(-1, 0), 
		"NW": Vector2(-1, -1)
	}
	
	for name in directions.keys():
		var indx = playertiles.tile_set.find_tile_by_name("wall_shooter" + name)
		indx_shooter.append(indx)
		var cells_shooter = enemytiles.get_used_cells_by_id(indx)
		for cell in cells_shooter:
			var child = shooter_scene.instance()
			child.delay = 4
			child.cooldown = 0
			child.direction = directions[name]
			child.tilepos = cell
			shooters.add_child(child)
			
	save_state()
			
func save_state():
	init_state["active_players"] = movement.players
	init_state["players"] = {}
	var ids = playertiles.tile_set.get_tiles_ids()
	var dist = 10000
	for id in ids:
		var tilename = playertiles.tile_set.tile_get_name(id)
		if "player" in tilename:
			init_state["players"][id] = playertiles.get_used_cells_by_id(id)

func load_state():
	movement.players = init_state["active_players"]
	playertiles.clear()
	for id in init_state["players"]:
		for cell in init_state["players"][id]:
			playertiles.set_cellv(cell, id)

func step():
	var cells_trap_off = enemytiles.get_used_cells_by_id(indx_trap_off)
	var cells_trap_med = enemytiles.get_used_cells_by_id(indx_trap_med)
	var cells_trap_on = enemytiles.get_used_cells_by_id(indx_trap_on)
	
	for cell in cells_trap_off:
		enemytiles.set_cellv(cell, indx_trap_med)
		
	for cell in cells_trap_med:
		enemytiles.set_cellv(cell, indx_trap_on)
		
	for cell in cells_trap_on:
		enemytiles.set_cellv(cell, indx_trap_off)
	
	for bullet in bullets.get_children():
		bullet.tilepos += bullet.direction
		bullet.transform.origin = \
			enemytiles.map_to_world(bullet.tilepos) + Vector2(32, 32)
	
	for shooter in shooters.get_children():
		shooter.cooldown -= 1
		if shooter.cooldown <= 0:
			shooter.cooldown = shooter.delay
			
			var bullet = bullet_scene.instance()
			bullet.direction = shooter.direction
			bullet.tilepos = shooter.tilepos
			bullet.transform = bullet.transform.rotated(
				Vector2(0, -1).angle_to(bullet.direction))
			bullet.transform.origin = \
				enemytiles.map_to_world(bullet.tilepos) + Vector2(32, 32)
			bullets.add_child(bullet)
		
	check_death()

func check_death():	
	var cells_trap_on = enemytiles.get_used_cells_by_id(indx_trap_on)
	for cell in cells_trap_on:
		var indx = playertiles.get_cellv(cell)
		if indx != -1: player_hit(indx)
		
	for bullet in bullets.get_children():
		var indx = playertiles.get_cellv(bullet.tilepos)
		if indx != -1: player_hit(indx)

	if movement.players.size() < 2: reset()

func player_hit(indx):
	var name = playertiles.tile_set.tile_get_name(indx)
	var playernum = int(name.substr(6))
	# is active player piece
	if playernum in movement.players:
		for pc in playertiles.get_used_cells_by_id(indx):
			playertiles.set_cellv(pc, -1)
		movement.players.erase(playernum)
		
func reset():
	for bullet in bullets.get_children(): bullet.queue_free()
	load_state()
	# reset traps 
	# reset shooters
