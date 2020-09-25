extends Control


var growing = false
var shrinking = true 

var rotatingLeft = false
var rotatingRight = true

var picks = [\
	"It's not frogger, stop asking!",\
	"Wow, this spinning is annoying!",\
	"Juno's a cutie :)",\
	"This isn't accurate of the real game!",\
	"Yes, I ripped this from Minecraft!",\
	
	"Maybe I should reduce the spin...",\
	"Wikipedia, the free online Encyclopedia!",\
	"Kane helped make some of these assets!",\
	"How do game devs make their game so...nice?!",\
	"The largest star is UY Scuti!"
]
	


func _ready():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var pick = rng.randi_range(0,10)
	$Title/TitleText/Subtitle.text = picks[pick]


func _on_Button_pressed():
	get_tree().change_scene("res://Main.tscn")


func _on_HELP_pressed():
	$helpinfo.visible = !$helpinfo.visible


func _process(delta):
	
	if rotatingRight:
		$Title.rotation_degrees = lerp($Title.rotation_degrees, -30, 0.02)
		if $Title.rotation_degrees < -20:
			print ("Too Right!")
			rotatingRight = false
			rotatingLeft = true
			
	if rotatingLeft:
		$Title.rotation_degrees = lerp($Title.rotation_degrees, 30, 0.02)
		if $Title.rotation_degrees > 20:
			print ("Too Left!")
			rotatingLeft = false
			rotatingRight = true
	
	if shrinking: 
		$Title.scale = lerp($Title.scale, Vector2(0,0), 0.01)
		if $Title.scale.x < 0.5:
			print ("Too small!")
			shrinking = false
			growing = true
	
	if growing:
		$Title.scale = lerp($Title.scale, Vector2(1.5,1.5), 0.01)
		if $Title.scale.x > 1.3:
			print ("Too Big!")
			shrinking = true
			growing = false
