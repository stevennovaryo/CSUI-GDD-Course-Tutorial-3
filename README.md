# Tutorial 3 - Introduction to Game Programming, Implementing Basic 2D Game Mechanics

### Fitur-fitur

Fitur sederhana:
- Pergerakan horizontal dengan arrow key dan gaya gesek horizontal.
- Gerakan melompat dengan up key dan gravitasi.

Fitur tambahan:
- *Double jump*
  - Memperbolehkan melompat dua kali.
  - Tekan tombol up key dua kali. 
- *Dashing*
  - Bergerak secara cepat ke arah kiri atau kanan.
  - Tekan tombol space.
- *Crouching*
  - Gerakan menunduk yang mempengaruhi speed berjalan, animasi, dan hitbox.
  - Tekan tombol down key.
- *Dive Bomb*, 
  - Gerakan meluncur ke bawah saat melompat
  - Tekan tombol down key saat diudara.
- Penyesuaian animasi untuk setiap moves.

### Detail Implementasi

#### Constant Variable
```gdscript
extends KinematicBody2D

export var horizontal_maxspeed = 500
export var horizontal_friction = 50
export var speed = 150
export var gravity = 50
export var jump_speed = 800
export var max_falling_speed = 350
export var max_upward_speed = -1500
```
Implementasi di mulai dengan deklarasi variabel konstanta yang merupakan parameter yang digunakan dalam perubahan kecepatan player.


#### Global Flag and Global Modifiable Variable

```gdscript
var velocity = Vector2()
var dash_velocity = Vector2()
var can_jump = 2

enum Direction{RIGHT, LEFT, NONE}	

var is_ducking = false
var direction = Direction.NONE

var shape: RectangleShape2D
var animation_sprite: AnimatedSprite

func _ready():
	shape = get_node("CollisionShape2D").shape
	animation_sprite = get_node("AnimatedSprite")
	pass # Replace with function body.
```

Kemudian, dilakukan deklarasi variabel global yang bisa berubah. Berikut detail setiap variabel:
- `velocity`, vector kecepatan player.
- `dash_velocity`, vector pertambahan kecepatan player dari move dash.
- `can_jump`, berapa kali player bisa melompat, refresh ke dua saat player menyentuh tanah.
- `is_ducking`, global flag yang diset berdasarkan input player.
- `direction`, global flag yang diset berdasarkan input player, merupakan **arah gerak player** bukan **arah hadap**.
- `shape`, collision shape yang merupakan child dari node.
- `animation_sprite`, animation sprite yang merupakan child dari node.

#### Animation Handler

```gdscript
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
```

Mengontrol animasi dan orientasi dari `animation_sprite` berdasarkan kedua global flag.

#### Physics Process: Horizontal Movement

```gdscript
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
```

Semua kode berikutnya akan ada dalam fungsi `_physics_process(delta)`. Snippet kode diatas mengatasi pergerakan horizontaol, menambahkan kecepatan sesuai dengan arah gerak dan set global flag. Terdapat juga bagian yang mengatasi gerakan *crouching* dengan mengubah hitbox, set global flag, dan mengurangi kecepatan jalan. Terakhir kode mengatasi permasalahan gaya gesek player dengan mengurangi speed hingga nol.

#### Physics Process: Dashing

```gdscript
	if Input.is_action_just_pressed("ui_select"):
		if animation_sprite.flip_h:
			dash_velocity.x -= speed * 10
		elif !animation_sprite.flip_h:
			dash_velocity.x += speed * 10
	
	if dash_velocity.x > 0:
		dash_velocity.x = max(0, dash_velocity.x - (horizontal_friction * 3))
	else:
		dash_velocity.x = min(0, dash_velocity.x + (horizontal_friction * 3))
```

Mengatasi move *dashing*, caranya mirip dengan pergerakan horizontal sebelumnya tetapi di vector berbeda dengan modifier berbeda.

#### Physics Process: Jump & Double Jump (and Gravity)

```gdscript
	if is_on_floor():
		can_jump = 2
	if Input.is_action_just_pressed("ui_up") && can_jump > 0:
		velocity.y = -jump_speed
		can_jump -= 1

  velocity.y += gravity
```

Mengatasi gerakan melompat dengan menetapkan kecepatan y sesuai dengan direction UP. Mengurangi `can_jump` setiap kali hal tersebut dilakukan. Mengatasi permasalahan gravitasi dengan menambahkan kecepatan sesuai dengan direction DOWN.

#### Physics Process: Maximum speed handling (plus ducking & diving speed modifier)

```gdscript
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
```

Mengamankan kecepatan x dan y sehingga berada dalam batas kecepatan. Batas kecepatan dan kecepatan akhir bisa disesuaikan apakah player sedang *crouching* atau *diving*. Terakhir ada `move_and_slide` untuk menerapkan semua perubahan kecepatannya dan animation handling.

### Reference
- [Godot Documentation](https://docs.godotengine.org/en/3.6)
- [CSUI Tutorial 3](https://csui-game-development.github.io/tutorials/tutorial-3/#latihan-implementasi-pergerakan-horizontal-menggunakan-script)

Note: Movement logics and other logics are implemented with the concept that I came up with accordance to Godot documentation. No other tutorials or blogs are referenced.