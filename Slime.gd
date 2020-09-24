extends Area2D


export (Vector2) var easyPlace

var damage = 10
var maxHP = 30
var HP = 30
var cash = 1



func getReward() -> int:
	return cash


func gameOver():
	self.get_node("Slime").visible = false
	self.get_node("ProgressBar").visible = false
	self.get_node("Reward").visible = true
	self.remove_from_group("slime")
	self.get_node("DeathTimer").start()


func setPosition():
	if easyPlace != Vector2(0,0):
			position = easyPlace * 16


# return true if the hit killed
func hit(incDamage) -> bool:
	if !self.get_node("ProgressBar").visible:
		self.get_node("ProgressBar").visible = true
	HP -= incDamage
	self.get_node("ProgressBar").value = HP
	if HP <= 0:
		gameOver()
		return true
	return false


func _ready():
	self.get_node("ProgressBar").max_value = maxHP
	self.get_node("ProgressBar").value = HP
	self.get_node("ProgressBar").visible = false
	self.get_node("Reward").visible = false
	self.get_node("Reward").text = "+" + String(cash)


func _on_DeathTimer_timeout():
	queue_free()
