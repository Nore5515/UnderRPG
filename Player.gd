extends Node2D



var maxDigPower = 100
var digPower = 100
var digEnergyRequired = 1

var cash = 0
var maxCash = 10

var damage = 10
var speed = 16

var deathTick = 0
var deathTickMax = 3

export (Vector2) var easyPlace

onready var tileManager = self.get_parent().get_node("TileManager")

var selecting





func _ready():
	updateFromGlobal()


func getReward(incReward: int) -> void:
	get_node("/root/Global").getReward(incReward)
	updateFromGlobal()


func updateFromGlobal() -> void:
	if get_node("/root/Global").playerStats["alive"]:
		digPower = get_node("/root/Global").playerStats["digPower"]
		maxDigPower = get_node("/root/Global").playerStats["maxDigPower"]
		cash = get_node("/root/Global").playerStats["cash"]


func reachGate() -> void:
	get_node("/root/Global").updateStats(digPower, maxDigPower, cash)
	get_node("/root/Global").nextLevel()


func checkDeath() -> void:
	deathTick += 1
	tileManager.paintDeath(deathTick)
	if deathTick >= deathTickMax:
		deathTick = 0
		tileManager.moveDeath()


func setPosition() -> void:
	if easyPlace != Vector2(0,0):
		position = easyPlace * 16


func gameover() -> void:
	get_node("/root/Global").reset()
	get_tree().change_scene("res://GameOver.tscn")


func activateLoot(loot: Item):
	if loot.type == "hpPot":
		if hasHPPotion():
			eatLoot("hpPot")
	else:
		print ("nah")
	updateFromGlobal()


func eatLoot(lootName: String) -> bool:
	for item in get_node("/root/Global").playerInv:
		if item.type == lootName:
			item.activate()
			updateFromGlobal()
			get_node("/root/Global").playerInv.erase(item)
			return true
	return false


func hasHPPotion() -> bool:
	for item in get_node("/root/Global").playerInv:
		if item.type == "hpPot":
			return true
	return false


func addLoot(itemName: String, amount: int) -> void:
	var newItem
	for x in range(amount):
		newItem = Item.new()
		newItem.setItem("hpPot", get_node("/root/Global"))
		get_node("/root/Global").addItem(newItem)
	get_node("/root/Global").updateStats(digPower, maxDigPower, cash)


func getItemCount (itemName: String) -> int:
	var count = 0
	for item in get_node("/root/Global").playerInv:
		if item.type == itemName:
			count += 1
	return count


func useLoot(lootLoc) -> void:
	if get_node("/root/Global").playerInv.size() > 0:
		var temp = 0
		temp += lootLoc.y * 4
		temp += lootLoc.x
		activateLoot(get_node("/root/Global").playerInv[temp])


func setSelecting(incBool) -> void:
	selecting = incBool


func hit(incDamage) -> void:
	digPower -= incDamage
	checkDeath()
	get_node("/root/Global").updateStats(digPower, maxDigPower, cash)


# HEY WE SHOULD BE CHECKING OCCUPIED EVERY TIME
func move(dir: Vector2) -> void:
	if tileManager.isOccupied(dir*speed + position):
		if tileManager.checkAndInteract(dir*speed + position):
			digPower -= digEnergyRequired
			checkDeath()
	else:
		# If there's air
		if tileManager.isEmpty(dir*speed + position):
			translate(dir * speed)
			checkDeath()
		elif digPower-digEnergyRequired < 0:
			# dont move cus it'd put you in negative
			pass
		# If there's dirt
		else:
			tileManager.paintEmpty(dir*speed + position)
			digPower -= digEnergyRequired
			translate(dir * speed)
			checkDeath()	


func _input(event) -> void:
	if !selecting:
		if event.is_action_pressed("left"):
			move(Vector2(-1,0))
		if event.is_action_pressed("right"):
			move(Vector2(1,0))
		if event.is_action_pressed("up"):
			move(Vector2(0,-1))
		if event.is_action_pressed("down"):
			move(Vector2(0,1))
		if event.is_action_pressed("restart"):
			get_tree().change_scene("res://Main.tscn")
		if event.is_action_pressed("skip"):
			move(Vector2(0,0))
