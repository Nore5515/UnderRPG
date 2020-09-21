extends Node2D


var playerStats = {
	"digPower": 0,
	"XP": 0,
	"alive": false
}

var playerInv
var items

var level = 1



func reset() -> void:
	playerStats = {
		"digPower": 0,
		"XP": 0,
		"alive": false
	}
	playerInv = null
	items = null
	level = 1
	

func nextLevel() -> void:
	level += 1
