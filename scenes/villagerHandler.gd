extends KinematicBody2D

export(NodePath) var playerNodePath

export var horizontal_maxspeed = 200
export var horizontal_friction = 50
export var speed = 1
export var gravity = 200
export var jump_speed = 800
export var max_falling_speed = 350
export var max_upward_speed = -1500

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var player : KinematicBody2D
var velocity = Vector2()

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_node(playerNodePath)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _physics_process(delta):
	if player != null:
		if player.is_death:
			velocity.x = 0
			$AnimatedSprite.play("sit")
		elif player.position.x < position.x:
			velocity.x = velocity.x - speed
			$AnimatedSprite.flip_h = false;
			$CollisionShape2D.position.x = -abs($CollisionShape2D.position.x) 
		elif player.position.x > position.x:
			velocity.x = velocity.x + speed
			$AnimatedSprite.flip_h = true;
			$CollisionShape2D.position.x = abs($CollisionShape2D.position.x) 
	if is_on_wall():
		velocity.x *= -1;
	velocity.x = clamp(velocity.x, -horizontal_maxspeed, horizontal_maxspeed)
	velocity.y = gravity
	move_and_slide(velocity, Vector2.UP)
