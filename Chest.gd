extends Area2D


var opened = false

export (Vector2) var easyPlace
export (String) var contents



func setPosition():
	if easyPlace != Vector2(0,0):
		position = easyPlace * 16


func addLoot():
	if contents == "hpPot":
		get_node("Hover").texture = load("res://TIles/HealthPotion.png")
		get_node("HideTimer").start()


func open():
	if !opened:
		opened = true
		get_node("Chest").visible = false
		get_node("OpenedChest").visible = true
		addLoot()
		return contents
	else:
		return ""


func _on_HideTimer_timeout():
	get_node("Hover").visible = false
