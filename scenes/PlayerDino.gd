extends KinematicBody2D

export var horizontal_maxspeed = 500
export var horizontal_friction = 50
export var speed = 150
export var gravity = 50
export var jump_speed = 800
export var max_falling_speed = 350
export var max_upward_speed = -1500

var velocity = Vector2()
var dash_velocity = Vector2()
var can_jump = 2

var shape: RectangleShape2D
var animation_sprite: AnimatedSprite

func _ready():
	shape = get_node("CollisionShape2D").shape
	animation_sprite = get_node("AnimatedSprite")
	pass # Replace with function body.

enum Direction{RIGHT, LEFT, NONE}	

var is_ducking = false
var direction = Direction.NONE

func handle_animation():	
	if direction == Direction.LEFT:
		animation_sprite.flip_h = true
	if direction == Direction.RIGHT:
		animation_sprite.flip_h = false

	if direction == Direction.NONE:
		if is_ducking:
			animation_sprite.play("Duck")
		else:
			animation_sprite.play("default")
	else:
		if is_ducking:
			animation_sprite.play("DuckMove")
		else:
			animation_sprite.play("Move")

func _physics_process(delta):
	direction = Direction.NONE
	if Input.is_action_pressed('ui_right'):
		velocity.x += speed
		direction = Direction.RIGHT
	elif Input.is_action_pressed('ui_left'):
		velocity.x -= speed
		direction = Direction.LEFT
	
	if Input.is_action_pressed("ui_down"):
		is_ducking = true
		shape.extents = Vector2(25, 15)
	else:
		is_ducking = false
		shape.extents = Vector2(20, 20)
	
	if velocity.x > 0:
		velocity.x = max(0, velocity.x - (horizontal_friction + 75 * int(is_ducking)))
	else:
		velocity.x = min(0, velocity.x + (horizontal_friction + 75 * int(is_ducking)))

	if Input.is_action_just_pressed("ui_select"):
		if animation_sprite.flip_h:
			dash_velocity.x -= speed * 10
		elif !animation_sprite.flip_h:
			dash_velocity.x += speed * 10
	
	if dash_velocity.x > 0:
		dash_velocity.x = max(0, dash_velocity.x - (horizontal_friction * 3))
	else:
		dash_velocity.x = min(0, dash_velocity.x + (horizontal_friction * 3))


	if is_on_floor():
		can_jump = 2
	if Input.is_action_just_pressed("ui_up") && can_jump > 0:
		velocity.y = -jump_speed
		can_jump -= 1

	velocity.y += gravity
	
	if is_ducking && is_on_floor():
		velocity.x = clamp(velocity.x, -horizontal_maxspeed / 2, horizontal_maxspeed / 2)
		velocity.y = clamp(velocity.y, max_upward_speed, max_falling_speed)
	else:
		velocity.x = clamp(velocity.x, -horizontal_maxspeed, horizontal_maxspeed)
		velocity.y = clamp(velocity.y, max_upward_speed, max_falling_speed)
		
		if is_ducking && !is_on_floor() && direction != Direction.NONE:
			velocity.x *= 2
			velocity.y *= 2

	move_and_slide(velocity + dash_velocity, Vector2.UP)
		
	handle_animation()
