extends Node

var playertiles : TileMap 
var enemytiles : TileMap 
var hovertiles : TileMap 
var cam : Camera2D

var selectedplayer : String

var dialog : Node 
var stepper : Node

var players : Array

var cooldown = 0
var delay = 0.2

func _ready():
	playertiles = get_tree().root.get_child(0).get_node("playertiles")
	enemytiles = get_tree().root.get_child(0).get_node("enemytiles")
	hovertiles = get_tree().root.get_child(0).get_node("hovertiles")
	stepper = get_tree().root.get_child(0).get_node("stepper")
	dialog = get_tree().root.get_child(0).get_node("dialog")
	cam = get_tree().root.get_child(0).get_node("camera")
	players.append(0)
	players.append(1)
	
func get_world_mouse_pos():
	return cam.get_global_mouse_position()
	
func _process(delta):
	cooldown -= delta
	process_hover(delta)
	if Input.is_action_just_pressed("sel"):
		if selectedplayer == "":
			var mouse_pos = get_world_mouse_pos()
			var indx = playertiles.get_cellv(playertiles.world_to_map(mouse_pos))
			if indx != -1:
				var tilename = playertiles.tile_set.tile_get_name(indx)
				if "player" in tilename: 
					load_hover(tilename)
					selectedplayer = tilename
		else:
			var mouse_pos = get_world_mouse_pos()
			var mouse_cent = playertiles.world_to_map(mouse_pos)
			player_move(selectedplayer, mouse_cent)
			dump_hover()
			selectedplayer = ""
		
	var hotkey = -1
	if Input.is_action_just_pressed("1"): hotkey = 0
	if Input.is_action_just_pressed("2"): hotkey = 1
	if Input.is_action_just_pressed("3"): hotkey = 2
	if Input.is_action_just_pressed("4"): hotkey = 3
	if Input.is_action_just_pressed("5"): hotkey = 4
	if hotkey != -1:
		var name = "player" + str(hotkey)
		load_hover(name)
		selectedplayer = name
	
func validate_move(playername : String, dest : Vector2):
	var mindist = 10000
	var hovercells = get_hover_cells(playername)
	for hovercell in hovercells:
		var enemycell = enemytiles.get_cellv(hovercell)
		if enemycell != -1:
			if "wall" in enemytiles.tile_set.tile_get_name(enemycell):
				return false
				
		for player in players:
			var playerstring = "player" + str(player)
			if playerstring == playername: continue
			var indx = playertiles.tile_set.find_tile_by_name(playerstring)
			var cells = playertiles.get_used_cells_by_id(indx)
			for cell in cells:
				if cell.x == hovercell.x and cell.y == hovercell.y:
					return false
				mindist = min(mindist, hovercell.distance_to(cell))
			
	return mindist < 2
	
func player_move(playername : String, dest : Vector2):
	if !validate_move(playername, dest): return
	
	dialog.moved()
	
	var indx = playertiles.tile_set.find_tile_by_name(playername)
	var hovercells = get_hover_cells(playername)
	var cells = playertiles.get_used_cells_by_id(indx)
	for cell in cells: playertiles.set_cellv(cell, -1)
	for cell in hovercells: 
		playertiles.set_cellv(cell, indx)
		if cell.y < -156: dialog.ending()
	
	check_friend()
	
	stepper.step(delay)
	
	cooldown = delay
	
func check_friend():
	var ids = playertiles.tile_set.get_tiles_ids()
	var dist = 10000
	for id in ids:
		var tilename = playertiles.tile_set.tile_get_name(id)
		if "player" in tilename:
			var playernum = int(tilename.substr(6))
			if playernum in players: continue
			var friendcells = playertiles.get_used_cells_by_id(id)
			for player in players:
				var playerstring = "player" + str(player)
				var playerindx = playertiles.tile_set.find_tile_by_name(playerstring)
				var playercells = playertiles.get_used_cells_by_id(playerindx)
				for f in friendcells:
					for p in playercells:
						dist = min(dist, f.distance_to(p))
			if dist < 2:
				players.append(playernum)
				dialog.friend(tilename)
				break
		
	
func get_hover_cells(playername : String):
	var mouse_pos = get_world_mouse_pos() + Vector2(32, 32)
	var mouse_cent = playertiles.world_to_map(mouse_pos)
	var indx = playertiles.tile_set.find_tile_by_name(playername)
	var cells = playertiles.get_used_cells_by_id(indx)
	var center = get_player_center(playername)
	var movecells = []
	for cell in cells: 
		var normcell = cell - center
		var trancell = normcell + mouse_cent
		movecells.append(trancell.floor())
	return movecells
	
func process_hover(delta):
	var mouse_pos = get_world_mouse_pos() + Vector2(32, 32)
	
	var indx = playertiles.tile_set.find_tile_by_name(selectedplayer)
	var indx_err = playertiles.tile_set.find_tile_by_name("error")
	
	hovertiles.clear()
	var hovercells = get_hover_cells(selectedplayer)
	var mouse_cent = playertiles.world_to_map(mouse_pos)
	var valid = validate_move(selectedplayer, mouse_cent)
	for cell in hovercells:
		if valid: hovertiles.set_cellv(cell, indx)
		else: hovertiles.set_cellv(cell, indx_err)
	
func get_player_center(playername : String):
	var indx = playertiles.tile_set.find_tile_by_name(playername)
	var cells = playertiles.get_used_cells_by_id(indx)
	var low = Vector2(10000, 10000)
	var high = Vector2(-10000, -10000)
	for cell in cells:
		low.x = min(low.x, cell.x)
		low.y = min(low.y, cell.y)
		high.x = max(high.x, cell.x)
		high.y = max(high.y, cell.y)
	var center = (low + high) / 2.0
	return center
	
func load_hover(playername : String):
	dump_hover()

func dump_hover():
	hovertiles.clear()
