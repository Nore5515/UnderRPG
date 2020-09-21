extends Node2D


var tiles
onready var player = self.get_parent().get_node("Player")
onready var camera: Camera2D = get_tree().get_nodes_in_group("camera")[0]
onready var tilemap: TileMap = self.get_node("TileMap")
onready var chests = get_tree().get_nodes_in_group("chest")
onready var chest = load("res://Chest.tscn")
onready var slimes = get_tree().get_nodes_in_group("slime")
onready var slime = load("res://Slime.tscn")

# these are the 3 phases of boulders
var boulders = {
	"1": 6,
	"2": 7,
	"3": 8
}
# gates index
var gates = {
	"1": 9,
	"2": 10
}

# Empty tile index
var empty = 5
# Dirt tile index
var dirt = 0

var rng = RandomNumberGenerator.new()

# 22x18 is default
var potentialMap
var mapSize = Vector2(22,18)
export (Vector2) var mapXRange
export (Vector2) var mapYRange
var rockChance = 0.25
var slimeChance = 0.01
var chestChance = 0.01

onready var deathY# = tilemap.world_to_map(self.get_node("Red").position).y
var initDeathY = -5



func updateMapSizes() -> void:
	if mapXRange != Vector2() && mapYRange != Vector2():
		mapSize.x = rng.randi_range(mapXRange.x, mapXRange.y)
		mapSize.y = rng.randi_range(mapYRange.x, mapYRange.y)
		var betterMapSize = mapSize
		betterMapSize.x += 4
		betterMapSize.y += 4
		camera.updateLimits(betterMapSize * 16)


func addSlime(mapLoc: Vector2) -> void:
	var instance = slime.instance()
	self.add_child(instance)
	instance.position = tilemap.map_to_world(mapLoc)


func addChest(mapLoc: Vector2) -> void:
	var instance = chest.instance()
	self.add_child(instance)
	instance.contents = "hpPot"
	instance.position = tilemap.map_to_world(mapLoc)


func checkAndInteract(mapLoc: Vector2) -> bool:
	mapLoc = tilemap.world_to_map(mapLoc)
	if tilemap.get_cellv(mapLoc) == boulders["1"]:
		tilemap.set_cellv(mapLoc, boulders["2"])
		return true
	elif tilemap.get_cellv(mapLoc) == boulders["2"]:
		tilemap.set_cellv(mapLoc, boulders["3"])
		return true
	elif tilemap.get_cellv(mapLoc) == boulders["3"]:
		tilemap.set_cellv(mapLoc, dirt)
		return true
	elif tilemap.get_cellv(mapLoc) == gates["1"]:
		tilemap.set_cellv(mapLoc, gates["2"])
		return true
	elif tilemap.get_cellv(mapLoc) == gates["2"]:
		player.reachGate()
		return true
	else:
		return false


func checkDeath(mapLoc: Vector2) -> bool:
	if mapLoc.y == deathY:
		print ("Death Y(",deathY,") does equal ", mapLoc)
		return true
	return false


func paintDeath(deathTick) -> void:
	if deathTick == 3:
		self.get_node("Red").modulate = Color.white
	elif deathTick == 1:
		self.get_node("Red").modulate = Color.gray
	elif deathTick == 2:
		self.get_node("Red").modulate = Color.darkred


func moveDeath() -> void:
	self.get_node("Red").position = Vector2(self.get_node("Red").position.x, self.get_node("Red").position.y + 16)
	deathY += 1
	var playerLoc = tilemap.world_to_map(player.position)
	if playerLoc.y == deathY:
		player.gameover()


func readyChests() -> void:
	for chest in chests:
		chest.setPosition()


func readySlimes() -> void:
	for slime in slimes:
		slime.setPosition()


func readyDeath() -> void:
	if get_node("/root/Global").level + initDeathY  > 0:
		deathY = 0
	else:
		deathY = get_node("/root/Global").level + initDeathY
	self.get_node("Red").position.y = tilemap.map_to_world(Vector2(0,deathY)).y


func isAdjacentToAnything(mapLoc: Vector2) -> bool:
	if isAdjacentToPlayer(mapLoc):
		return true
	if isAdjacentToChests(mapLoc):
		return true
	if isAdjacentToEnemies(mapLoc):
		return true
	if isAdjacentToEdges(mapLoc):
		return true
	return false


func isAdjacentToEdges(mapLoc: Vector2) -> bool:
	if mapLoc.x == 0:
		return true
	elif mapLoc.y == 0:
		return true
	elif mapLoc.x == mapSize.x-1:
		return true
	elif mapLoc.y == mapSize.y-1:
		return true
	return false


func isAdjacentToEnemies(mapLoc: Vector2) -> bool:
	slimes = get_tree().get_nodes_in_group("slime")
	var slimeLoc
	for slime in slimes:
		slimeLoc = tilemap.world_to_map(slime.position)
		if slimeLoc.distance_to(mapLoc) < 1.5:
			return true
	return false


func isAdjacentToChests(mapLoc: Vector2) -> bool:
	chests = get_tree().get_nodes_in_group("chest")
	var chestLoc
	for chest in chests:
		chestLoc = tilemap.world_to_map(chest.position)
		if chestLoc.distance_to(mapLoc) < 1.5:
			return true
	return false


func isAdjacentToPlayer(mapLoc: Vector2) -> bool:
	var playerLoc = tilemap.world_to_map(player.position)
	if playerLoc.distance_to(mapLoc) < 1.5:
		return true
	return false


func updateWithNewMap():
	tilemap.clear()
	updateMapSizes()
	potentialMap = create2DArray(mapSize)
	slimes = get_tree().get_nodes_in_group("slime")
	chests = get_tree().get_nodes_in_group("chest")
	for x in range(potentialMap.size()):
		for y in range(potentialMap[x].size()):
			if isAdjacentToEdges(Vector2(x,y)):
				tilemap.set_cellv(Vector2(x, y), 4)
			else:
				if y == mapSize.y-1:
					print ("Something wrong")
				tilemap.set_cellv(Vector2(x, y), potentialMap[x][y])
	tilemap.set_cellv(Vector2(potentialMap.size()*0.5, potentialMap[0].size()-1), gates["1"])


func _ready():
	rng.randomize()
	updateMapSizes()
	player.setPosition()
	player.updateFromGlobal()
	readyChests()
	readySlimes()
	readyDeath()
	updateWithNewMap()
	camera.levelTextStart("Level " + String(get_node("/root/Global").level))


# returns a 2D array of tiles, with randomly placed thingies
func create2DArray(size: Vector2):
	var matrix = []
	for x in range(size.x):
		matrix.append([])
		for y in range(size.y):
			# If it's NOT adjacent to anything
			if !isAdjacentToAnything(Vector2(x,y)):
				# Slime first
				if rng.randf() < slimeChance:
					#print ("Slime added at ", x, ",",y)
					addSlime(Vector2(x,y))
					matrix[x].append(0)
				# Then Chest
				elif rng.randf() < chestChance:
					#print ("Chest added at ", x, ",",y)
					addChest(Vector2(x,y))
					matrix[x].append(0)
				# Then Rock
				elif rng.randf() < rockChance:
					matrix[x].append(boulders["1"])
				else:
					matrix[x].append(0)
			else: 
				matrix[x].append(0)
	return matrix


func isEmpty(location: Vector2) -> bool:
	var mapCoords = tilemap.world_to_map(location)
	# 5 is the empty
	if tilemap.get_cellv(mapCoords) == 5:
		return true
	return false


func paintEmpty(mapLoc: Vector2) -> void:
	var mapCoords = tilemap.world_to_map(mapLoc)
	# 5 IS THE EMPTY TILE 
	tilemap.set_cellv(mapCoords, 5)


func isBlocker(mapLoc: Vector2) -> bool:
	# 4 IS THE ROCK, ADD MORE AS WE ADD MORE
	if tilemap.get_cellv(mapLoc) == 4:
		return true
	# Check the boulders
	if tilemap.get_cellv(mapLoc) == boulders["1"] ||\
	tilemap.get_cellv(mapLoc) == boulders["2"] ||\
	tilemap.get_cellv(mapLoc) == boulders["3"]:
		return true
	# Check gates!
	if tilemap.get_cellv(mapLoc) == gates["1"] ||\
	tilemap.get_cellv(mapLoc) == gates["2"]:
		return true
	else:
		return false


func isOccupied(location: Vector2) -> bool:
	var mapCoords = tilemap.world_to_map(location)
	chests = get_tree().get_nodes_in_group("chest")
	slimes = get_tree().get_nodes_in_group("slime")
	if isBlocker(mapCoords):
		return true
	if checkChests(mapCoords):
		return true
	if checkSlimes(mapCoords):
		return true
	if checkDeath(mapCoords):
		return true
	return false


func checkSlimes(mapLoc: Vector2):
	var slimeMapLoc
	for slime in slimes:
		slimeMapLoc = tilemap.world_to_map(slime.position)
		#print (slimeMapLoc, "=?", mapLoc)
		if slimeMapLoc == mapLoc:
			if slime.hit(player.damage):
				player.getXP(slime.xpReward)
			else:
				player.hit(slime.damage)
			return true
	return false


func checkChests(mapLoc: Vector2):
	var chestMapLoc
	for chest in chests:
		chestMapLoc = tilemap.world_to_map(chest.position)
		#print (chestMapLoc, "=?", mapLoc)
		if chestMapLoc == mapLoc:
			var loot = chest.open()
			if loot == "hpPot":
				player.addLoot("hpPot", 1)
				player.checkDeath()
			return true
	return false
