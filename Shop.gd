extends Node2D


onready var pivot = $Pivot
onready var global = get_node("/root/Global")

var items = []
var item1: Item
var item2: Item
var item3: Item

var shopOdds = {
	"hpPot": 0.25,
	"coinUp": 0.10
}



func buyItem(item: Item, number: int):
	if global.playerStats["cash"] >= 1:
		global.playerStats["cash"] -= 1
		print(global.addLoot(item.type, 1))
		if number == 1:
			$Item1.visible = false
		elif number == 2:
			$Item2.visible = false
		elif number == 3:
			$Item3.visible = false


func _ready():
	item1 = Item.new()
	items.append(item1)
	item2 = Item.new()
	items.append(item2)
	item3 = Item.new()
	items.append(item3)
	genItems()
	updateItems()


func updateItems():
	
	var itemNum = 0
	
	for item in items:
		
		var img
		itemNum += 1
		
		if item.type == "hpPot":
			img = load("res://TIles/HealthPotion.png")
		elif item.type == "coinUp":
			img = load ("res://Arts/coinUp.png")
		
		if itemNum == 1:
			$Item1.texture_normal = img
		if itemNum == 2:
			$Item2.texture_normal = img
		if itemNum == 3:
			$Item3.texture_normal = img
		

func genItems():
	print("HGEN")
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var temp
	var currentItem = item1
	
	for item in items:
		while item.type == "":
			temp = rng.randf()
			if temp < shopOdds["hpPot"]:
				item.setItem("hpPot",get_node("/root/Global"))
			else:
				temp -= shopOdds["hpPot"]
				if temp < shopOdds["coinUp"]:
					item.setItem("coinUp",get_node("/root/Global"))
	
	updateItems()
	

func _process(delta):
	pivot.look_at(get_global_mouse_position())
	$Control/CurrentCash.text = String(global.playerStats["cash"])


func _input(event):
	
	if event.is_action_pressed("click"):
		$Pivot/openMouthFrog.visible = true
		$Pivot/closedMouthFrog.visible = false
		$TongueTimer.start()


func _on_TongueTimer_timeout():
	$Pivot/openMouthFrog.visible = false
	$Pivot/closedMouthFrog.visible = true


func _on_Item1_pressed():
	buyItem(item1, 1)
func _on_Item2_pressed():
	buyItem(item2, 2)
func _on_Item3_pressed():
	buyItem(item3, 3)


func _on_Button_pressed():
	get_tree().change_scene("res://Main.tscn")
