extends Node2D

var rng = RandomNumberGenerator.new()

var buildingNumLevel = 0
var startGame = false
var scrollSpeed = 0.20
const scrollSpeedInc = 0.01
var lowerMouseBound = 106
var leftBound = 155 #right edge of the left bound
var rightBound = 445
var frameName = "Building1"
var horizBoundFlag = false
var areaFlag = false
var score = 0
var scoreBody
#var resetFlag = true

signal lost

func _ready():
	startGame = false
	horizBoundFlag = false
	areaFlag = false
	$Start.visible = true

func assignFrameName(buildingNumber):
	match buildingNumber:
		1:
			frameName = "Building1"
		2:
			frameName = "Building2"
		3:
			frameName = "Building3"
		4:
			frameName = "Building4"
	return frameName

func _physics_process(delta):
	if startGame == true:
		scrollElements()
		$CursorBuilding.visible = true
		
		if horizBoundFlag == true:
			$CursorBuilding.position.y = get_global_mouse_position().y
		else:
			$CursorBuilding.position = get_global_mouse_position()
		
	if get_global_mouse_position().x - ($CursorBuilding.frames.get_frame(frameName, 0).get_width() / 2) < leftBound + 1 : #horizontal bound checker
		horizBoundFlag = true
		$CursorBuilding.position.x = leftBound + ($CursorBuilding.frames.get_frame(frameName, 0).get_width() / 2)
	elif get_global_mouse_position().x + ($CursorBuilding.frames.get_frame(frameName, 0).get_width() / 2) > rightBound - 1:
		$CursorBuilding.position.x = rightBound - ($CursorBuilding.frames.get_frame(frameName, 0).get_width() / 2)
	else:
		horizBoundFlag = false
	
	if !$ScoreArea/VisibilityNotifier2D.is_on_screen():
		#get_tree().paused = true
		#$LoseTimer.start()
		get_tree().change_scene("res://Level.tscn")
	
	if !$ScoreArea.get_overlapping_bodies().empty():
		$ScoreArea.position.y -= 3
		
	computeScore($ScoreArea.position.y)

func playBuildNoise():
	var buildNoise = RandomNumberGenerator.new()
	buildNoise.randomize()
	var buildNoiseNum = buildNoise.randi_range(1, 3)
	match buildNoiseNum:
		1: $SFX/DropBuilding1.playing = true
		
		2: $SFX/DropBuilding2.playing = true
		
		3: $SFX/DropBuilding3.playing = true
		
		_: $SFX/DropBuilding1.playing = true
		
func playLandNoise():
	var landNoise = RandomNumberGenerator.new()
	landNoise.randomize()
	var landNoiseNum = landNoise.randi_range(1, 3)
	match landNoiseNum:
		1: $SFX/Landing1.playing = true
		
		2: $SFX/Landing2.playing = true
		
		3: $SFX/Landing3.playing = true
		
		_: $SFX/Landing1.playing = true

func computeScore(vertPos):
	score = -(vertPos / 3)
	score = stepify(score, 1)

func scrollElements():
	$Camera2D.position.y -= scrollSpeed
	lowerMouseBound -= scrollSpeed
	$ClickArea.position.y -= scrollSpeed

func generateBuilding():
	rng.randomize()
	var buildingNumber = rng.randi_range(1, 4)
	assignFrameName(buildingNumber)
	return buildingNumber

func _input(event):
	var buildingInstance
	
	if event is InputEventMouseButton and !areaFlag and get_global_mouse_position().y < lowerMouseBound:
		if !startGame:
			$Start.visible = false
			$DiffTimer.start()
			startGame = true
			buildingNumLevel = generateBuilding()
			match buildingNumLevel:
				1: 
					$CursorBuilding.play("Building1")
				2: 
					$CursorBuilding.play("Building2")
				3: 
					$CursorBuilding.play("Building3")
				4: 
					$CursorBuilding.play("Building4")
				_: 
					$CursorBuilding.play("Building1")
			return
		
		if event.button_index == BUTTON_LEFT and event.pressed: #select and preload building
			match buildingNumLevel:
				1: 
					buildingInstance = preload("res://Building1.tscn")
					add_to_group("structures")
				
				2: 
					buildingInstance = preload("res://Building2.tscn")
					add_to_group("structures")
				
				3: 
					buildingInstance = preload("res://Building3.tscn")
					add_to_group("structures")
				4: 
					buildingInstance = preload("res://Building4.tscn")
					add_to_group("structures")
			
			var building = buildingInstance.instance() #instance building
			building.add_to_group("falling")
			$BuildingsFolder.add_child(building)
			
			scrollSpeed += scrollSpeedInc
			
			playBuildNoise()
			
			if get_global_mouse_position().x - ($CursorBuilding.frames.get_frame(frameName, 0).get_width() / 2) < leftBound + 1 : #places building within bound
				building.position.x = leftBound + ($CursorBuilding.frames.get_frame(frameName, 0).get_width() / 2)
				building.position.y = get_global_mouse_position().y
			elif get_global_mouse_position().x + ($CursorBuilding.frames.get_frame(frameName, 0).get_width() / 2) > rightBound - 1:
				building.position.x = rightBound - ($CursorBuilding.frames.get_frame(frameName, 0).get_width() / 2)
				building.position.y = get_global_mouse_position().y
			else:
				building.position = get_global_mouse_position()
			
			buildingNumLevel = generateBuilding()
			match buildingNumLevel:
				1: 
					$CursorBuilding.play("Building1")
				2: 
					$CursorBuilding.play("Building2")
				3: 
					$CursorBuilding.play("Building3")
				4: 
					$CursorBuilding.play("Building4")
				_: 
					$CursorBuilding.play("Building1")

func _on_Bound_body_entered(body):
	emit_signal("lost")
	showScore()
	$SFX/Fail.playing = true
	$Camera2D.setScore($Camera2D.position.y)
	get_tree().call_group("falling", "queue_free")
	$HUD/HUDLayer/RestartMenu/CenterContainer/VBoxContainer/ScoreLabel.visible = true
	get_tree().paused = true
	$LoseTimer.start()
	
func showScore():
	$HUD/HUDLayer/RestartMenu.visible = true
	$HUD/HUDLayer/RestartMenu/CenterContainer/Background.set_modulate(Color(1,1,1,0))
	$HUD/HUDLayer/PlayAgain.set_modulate(Color(1,1,1,0))
	#$HUD/HUDLayer/RestartMenu/CenterContainer/VBoxContainer/PlayAgain.disabled = true
	$HUD/HUDLayer/ClickSprite.visible = false

func _on_DiffTimer_timeout():
	pass
	#scrollSpeed += scrollSpeedInc


func _on_ClickArea_body_entered(body):
	areaFlag = true
	$HUD/HUDLayer/ClickSprite.set_modulate(Color(1,1,1,0.65))


func _on_ClickArea_body_exited(body):
	areaFlag = false
	$HUD/HUDLayer/ClickSprite.set_modulate(Color(1,1,1,1))


func _on_ScoreArea_body_entered(body):
	if body.get_collision_layer() == 1:
		if body != scoreBody:
			playLandNoise()
		body.remove_from_group("falling")
		body.add_to_group("buildings")
		body.emitParticles()

func _on_LoseTimer_timeout():
	$Camera2D.loseScroll()


func _on_Camera2D_bottomed_out():
	$HUD.showPlayAgain()

func _on_HUD_play_again():
	#get_tree().call_group("buildings", "queue_free")
	$SFX/ButtonClick.playing = true
	get_tree().change_scene("res://Level.tscn")
	

func _on_ScoreArea_body_exited(body):
	scoreBody = body
