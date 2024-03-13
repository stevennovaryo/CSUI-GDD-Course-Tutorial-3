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
var is_death = false
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

func apply_friction(friction):
	if velocity.x > 0:
		velocity.x = max(0, velocity.x - (friction + 75 * int(is_ducking)))
	else:
		velocity.x = min(0, velocity.x + (friction + 75 * int(is_ducking)))

func apply_gravity():
	velocity.y += gravity

func limit_speed():
	if is_ducking && is_on_floor():
		velocity.x = clamp(velocity.x, -horizontal_maxspeed / 2, horizontal_maxspeed / 2)
		velocity.y = clamp(velocity.y, max_upward_speed, max_falling_speed)
	else:
		velocity.x = clamp(velocity.x, -horizontal_maxspeed, horizontal_maxspeed)
		velocity.y = clamp(velocity.y, max_upward_speed, max_falling_speed)
		
		if is_ducking && !is_on_floor() && direction != Direction.NONE:
			velocity.x *= 2
			velocity.y *= 2

func _physics_process(delta):
	if is_death:
		apply_friction(horizontal_friction / 3)
		apply_gravity()
		limit_speed()
		move_and_slide(velocity, Vector2.UP)
		if 	$DeathSfxPlayer.playing:
			animation_sprite.rotate(0.05 * velocity.x / 100)
		if is_on_floor():
			animation_sprite.rotation = 0
		return
	
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
	
	apply_friction(horizontal_friction)

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
		$JumpSfxPlayer.play()
		
	apply_gravity()
	limit_speed()

	move_and_slide(velocity + dash_velocity, Vector2.UP)
		
	handle_animation()


func _on_HurtBoxPlayer_area_entered(area : Area2D):
	is_death = true
	animation_sprite.flip_v = true
	animation_sprite.play("Duck")
	shape.extents = Vector2(25, 3)
	velocity = -velocity
	
	var death_direction
	if velocity.x <= 0:
		 death_direction = 1
	else:
		death_direction = -1
		
	if abs(velocity.x) < 400:
		velocity.x = 400 * death_direction
	$DeathSfxPlayer.play()
	pass # Replace with function body.
