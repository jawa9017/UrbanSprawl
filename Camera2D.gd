extends Camera2D

signal bottomed_out

signal update_score(position, height)

var score = 0

var finalHeight = 0

onready var scoreFlag = false

func _physics_process(delta):
	emit_signal("update_score", self.position.y, finalHeight)

func setScore(position):
	finalHeight = -1 * self.position.y
	scoreFlag = true
	score = position

func loseScroll():
	$Tween.interpolate_property(self, "position", self.position, Vector2(0, 0), 3, Tween.TRANS_CIRC, Tween.EASE_OUT)
	$Tween.start()
	
	$BottomTimer.start()
	
func _on_BottomTimer_timeout():
	emit_signal("bottomed_out")
