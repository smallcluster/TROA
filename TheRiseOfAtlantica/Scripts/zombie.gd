extends KinematicBody2D


enum{WALK, DEAD, IDLE}

onready var sprite : Sprite = $sprite
onready var spriteAnimator : AnimationPlayer = $sprite/AnimationPlayer
onready var groundRay : RayCast2D = $GroundDetector
onready var jumpParticles = load("res://Objects/jumpLandParticles.tscn")
onready var playerDetector : Area2D = $PlayerDetector
onready var wallDetector : RayCast2D = $WallDetector

export var speed = 400
export var die_posy = 1000

var state = WALK
var gravity = 3500
var facingLeft = true
var velocity = Vector2(0,0)
var life = 3
const jump_force = -1000
const knock_back_force = 800

var idle_timer_start_collided = 1.5
var idle_timer_start = 2
var idle_timer = 0

var platformEnd = false
var damaged = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	sprite.region_rect.position.x = 16 if rand_range(0, 1) < 0.5 else 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if position.y > die_posy:
		queue_free()
	
	# fall down
	velocity.y += gravity * delta
	
	# face the sprite in the right dir
	sprite.scale.x = -8 if facingLeft else 8
	var px = abs(wallDetector.position.x)
	var px2 = abs(groundRay.position.x)
	wallDetector.position.x = -px if facingLeft else px
	groundRay.position.x = -px2 if facingLeft else px2
	wallDetector.cast_to.x = -20 if facingLeft else 20
	
	if state == IDLE:
		# idle animation start
		if !spriteAnimator.is_playing() or !spriteAnimator.assigned_animation == "idle":
			spriteAnimator.play("idle")
		if idle_timer <= 0:
			facingLeft = not facingLeft
			state = WALK
		handleFriction()
		handleFall()
		handlePlayerCollision()
		
	elif state == WALK:
		wallDetector.enabled = true
		# WALK animation start
		if !spriteAnimator.is_playing() or !spriteAnimator.assigned_animation == "walk":
			spriteAnimator.play("walk")
		
		if is_on_floor():
			velocity.x = -speed if facingLeft else speed
		
		if !groundRay.is_colliding() and !platformEnd and is_on_floor():
			platformEnd = true
			idle_timer = idle_timer_start
			state = IDLE
			velocity.x = 0
		if platformEnd and groundRay.is_colliding():
			platformEnd = false
		
		if wallDetector.is_colliding():
			wallDetector.enabled = false
			facingLeft = !facingLeft
				
		handleFall()
		handlePlayerCollision()
	elif state == DEAD:
		spriteAnimator.stop()
		sprite.scale.y = 8
		handleFriction()
		sprite.rotation_degrees = 90 if facingLeft else -90
			
	if idle_timer > 0:
		idle_timer -= delta
		
	velocity = move_and_slide(velocity, Vector2.UP)
	
func handleFriction():
	if is_on_floor():
		velocity.x = lerp(velocity.x, 0, 0.15)
		
func lose_life(left):
	if life > 1:
		life -= 1
		velocity.x = -knock_back_force if left else knock_back_force
		$sprite/ColorAnim.play("effect")
	elif life == 1:
		life -= 1
		state = DEAD
		$sprite/ColorAnim.play("effect")
		velocity.x = -knock_back_force/2.0 if left else knock_back_force/2.0
		velocity.y = jump_force
		jump_bubles()
		
func handleFall():
	if !is_on_floor():
		sprite.scale.y = 9.5
		sprite.scale.x = -6.5 if facingLeft else 6.5
		
func jump_bubles():
	add_child_below_node($JumpEffects, jumpParticles.instance())
	
func handlePlayerCollision():
	var bodys = playerDetector.get_overlapping_bodies()
	for b in bodys:
		if b.is_in_group("Player"):
			b.lose_life()
			idle_timer = idle_timer_start_collided
			state = IDLE
			velocity.x = 0
			break
		



