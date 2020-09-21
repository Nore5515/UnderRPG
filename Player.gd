extends Node2D



var maxDigPower = 100
var digPower = 100
var digEnergyRequired = 1

var XP = 0
var maxXP = 100

var damage = 10
var speed = 16

var deathTick = 0
var deathTickMax = 3

export (Vector2) var easyPlace

var items = {
	"hpPot": {
		"name": "Health Potion",
		"count": 0,
		"healAmount": 30
	},
	"empty": {
		"name": "EMPTY ERR",
		"count": -1
	}
}

var inventory = {
	"Col1": {
		"Row1": items["hpPot"]
	},
	"Col2": {
		"Row1": items["empty"]
	}
}

onready var tileManager = self.get_parent().get_node("TileManager")

var selecting



func updateFromGlobal() -> void:
	if get_node("/root/Global").playerStats["alive"]:
		digPower = get_node("/root/Global").playerStats["digPower"]
		XP = get_node("/root/Global").playerStats["XP"]
		items = get_node("/root/Global").items
		inventory = get_node("/root/Global").playerInv


func getXP(incXP: int) -> void:
	XP += incXP
	if XP >= maxXP:
		print ("Level up!")
		XP -= maxXP


func reachGate() -> void:
	get_node("/root/Global").playerStats = {
		"digPower": digPower,
		"XP": XP,
		"alive": true
	}
	get_node("/root/Global").playerInv = inventory
	get_node("/root/Global").items = items
	get_node("/root/Global").nextLevel()
	get_tree().change_scene("res://Main.tscn")


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
	get_tree().change_scene("res://TitleScene.tscn")


func activateLoot(lootName: String):
	if lootName == "Health Potion":
		if items["hpPot"]["count"] > 0:
			items["hpPot"]["count"] -= 1
			checkDeath()
			if digPower + items["hpPot"]["healAmount"] > maxDigPower:
				digPower = maxDigPower
			else:
				digPower += items["hpPot"]["healAmount"]
	else:
		print ("nah")
	

func addLoot(itemName: String, amount: int) -> void:
	items[itemName]["count"] += amount
	

func getItemCount (itemName: String) -> int:
	return items[itemName]["count"]
	

func useLoot(lootLoc) -> void:
	var temp
	# JUST FOR MY SAKE
	lootLoc = Vector2(lootLoc.x + 1, lootLoc.y + 1)
	if lootLoc.y == 1:
		temp = inventory["Col1"]
	elif lootLoc.y == 2:
		temp = inventory["Col2"]
	
	if lootLoc.x == 1:
		temp = temp["Row1"]
		
	activateLoot(temp["name"])
	

func setSelecting(incBool) -> void:
	selecting = incBool


func hit(incDamage) -> void:
	digPower -= incDamage
	checkDeath()


# HEY WE SHOULD BE CHECKING OCCUPIED EVERY TIME
func move(dir: Vector2) -> void:
	if tileManager.isOccupied(dir*speed + position):
		if tileManager.checkAndInteract(dir*speed + position):
			digPower -= digEnergyRequired
			checkDeath()
	else:
		if tileManager.isEmpty(dir*speed + position):
			translate(dir * speed)
			checkDeath()
		elif digPower-digEnergyRequired < 0:
			# dont move cus it'd put you in negative
			pass
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
