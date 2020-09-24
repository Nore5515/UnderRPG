extends Camera2D


onready var player = self.get_parent().get_node("Player")
onready var ui = self.get_parent().get_node("CanvasLayer").get_node("UI")
onready var inv = ui.get_node("Inv")
onready var selector = ui.get_node("Inv").get_node("Selector")
const followSpeed = 4.0
onready var potionIcon = load("res://TIles/HealthPotion.png")

var selecting = false
var levelTextFading = false

var invX = 0
var invBufferX = 0
var invMaxX = 0
var invY = 0
var invBufferY = 16
var invMaxY = 4

var currentInvTiles = []



func updateInv() -> void:
	for item in currentInvTiles:
		item.visible = false
	var y = 0
	var inst
	if get_node("/root/Global").playerInv != null:
		if get_node("/root/Global").playerInv.size() > 0:
			for item in get_node("/root/Global").playerInv:
				inst = Sprite.new()
				currentInvTiles.append(inst)
				inst.texture = load("res://TIles/HealthPotion.png")
				inst.centered = false
				inst.position = Vector2(0, y)
				inv.add_child(inst)
				y += 16
		

func updateLimits(newLimits: Vector2) -> void:
	self.limit_right = newLimits.x
	self.limit_bottom = newLimits.y


# RUNS PRE ON-READY
func levelTextStart(levelText) -> void:
	self.get_parent().get_node("CanvasLayer").get_node("UI").get_node("LevelText").text = levelText
	self.get_parent().get_node("CanvasLayer").get_node("UI").get_node("LevelText").get_node("LevelTextFadeoutTimer").start()


func moveSelect(dir: Vector2):
	if invX + dir.x < 0 || invX + dir.x > invMaxX ||\
	   invY + dir.y < 0 || invY + dir.y > invMaxY:
		pass
	else:
		selector.translate(Vector2(dir.x * invBufferX, dir.y * invBufferY)) 
		invX += dir.x
		invY += dir.y


func _input(event):
	updateUI()
	updateInv()
	if event.is_action_pressed("Inv"):
		inv.visible = !inv.visible
		selecting = !selecting
		player.setSelecting(selecting)
	if selecting:
		if event.is_action_pressed("left"):
			moveSelect(Vector2(-1,0))
		if event.is_action_pressed("right"):
			moveSelect(Vector2(1,0))
		if event.is_action_pressed("up"):
			moveSelect(Vector2(0,-1))
		if event.is_action_pressed("down"):
			moveSelect(Vector2(0,1))
		if event.is_action_pressed("select"):
			player.useLoot(Vector2(invX, invY))


func updateUI():
	ui.get_node("CashBar").max_value = player.maxCash
	ui.get_node("CashBar").value = player.cash
	ui.get_node("DigBar").max_value = player.maxDigPower
	ui.get_node("DigBar").value = player.digPower
	if levelTextFading:
		fadeLevelText()
	updateInv()


func followPlayer(delta):
	var player_pos = player.position
	self.position = self.position.linear_interpolate(player_pos, delta*followSpeed)


func _process(delta):
	followPlayer(delta)
	#updateUI()


# LERP THE ALPHA ON THE MODULATE TO FADEOUT
func _on_LevelTextFadeoutTimer_timeout():
	levelTextFading = true
	#ui.get_node("LevelText").visible = false


func fadeLevelText():
	ui.get_node("LevelText").modulate.a = lerp(ui.get_node("LevelText").modulate.a, 0, 0.04) #-= 0.01
	if ui.get_node("LevelText").modulate.a <= 0.04:
		levelTextFading = false
		print ("Bye!")
		ui.get_node("LevelText").visible = false
