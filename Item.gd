extends Node

class_name Item, "res://Arts/itemIcon.png"


var type: String
var itemName: String
var placement: Vector2
var global

# POTION STUFF
var healAmount: int



func activate():
	if type == "hpPot":
		print ("HEALING")
		global.addHealth(healAmount)


func setItem(_type: String, _global):
	type = _type
	if type == "hpPot":
		itemName = "Health Potion"
		healAmount = 30
	global = _global
	print (type)


func setPosition(_position: Vector2):
	placement = _position
