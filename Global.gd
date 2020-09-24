extends Node2D


var playerStats = {
	"digPower": 0,
	"maxDigPower": 0,
	"cash": 0,
	"alive": false
}

var playerInv = []

var level = 1



func updateStats(_digPower, _maxDigPower, _cash) -> void:
	print ("Updating global dig power with ", _digPower)
	playerStats["digPower"] = _digPower
	playerStats["maxDigPower"] = _maxDigPower
	playerStats["cash"] = _cash
	playerStats["alive"] = true


func reduceDigPower(amount: int) -> bool:
	playerStats["digPower"] -= amount
	if playerStats["digPower"] < 0:
		return false
	return true


func getReward(rewardAmount: int) -> void:
	playerStats["cash"] += rewardAmount


func addHealth(healAmount: int) -> void:
	print ("Adding Health, ", healAmount, " to ", playerStats["digPower"])
	if playerStats["digPower"] + healAmount > playerStats["maxDigPower"]:
		print ("\tSetting to max! ", playerStats["maxDigPower"])
		playerStats["digPower"] = playerStats["maxDigPower"]
	else:
		print ("\tJust normal adding.")
		playerStats["digPower"] += healAmount
	print ("\tJust Added Health, ", healAmount, " to ", playerStats["digPower"])


func addLoot(itemName: String, amount: int) -> void:
	var newItem
	for x in range(amount):
		newItem = Item.new()
		newItem.setItem("hpPot", get_node("/root/Global"))
		addItem(newItem)


func addItem(item: Item) -> bool:
	#print ("Adding item ", item.type)
	playerInv.append(item)
	return true


func reset() -> void:
	playerStats = {
		"digPower": 0,
		"cash": 0,
		"alive": false
	}
	playerInv = null
	level = 1


func nextLevel() -> void:
	level += 1
	if level % 4 == 0:
		get_tree().change_scene("res://Shop.tscn")
	else:
		get_tree().change_scene("res://Main.tscn")
