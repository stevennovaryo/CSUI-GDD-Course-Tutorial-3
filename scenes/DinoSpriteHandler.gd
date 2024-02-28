extends AnimatedSprite


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

var flippedH = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func _process(delta):
	if Input.is_action_pressed('ui_right'):
		play("Move")
		flippedH = false
	elif Input.is_action_pressed('ui_left'):
		play("Move")
		flippedH = true
	else:
		stop()
	flip_h = flippedH
