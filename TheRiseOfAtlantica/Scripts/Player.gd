extends KinematicBody2D

signal dead

onready var animSprite = $Sprite
onready var animator = $Sprite/AnimationPlayer
onready var immunityAnimator = $Sprite/immunity
onready var SFXPlayer : AudioStreamPlayer = $SFX1
onready var SFXPlayerAttack : AudioStreamPlayer = $SFXAttack
onready var jumpParticles = load("res://Objects/jumpLandParticles.tscn")
onready var attackEffectSPR = $attack_effect
onready var attackArea = $attackArea


enum{IDLE, DIALOG, WALK, DEAD, ATTACK}

export var state = DIALOG
export var speed = 500
export (AudioStream) var jumpSFX
export (AudioStream) var fallDownSFX
export (AudioStream) var dieSFX
export (AudioStream) var getHitSFX
export (AudioStream) var getLifeSFX
export var die_posy = 1000

var in_water = true
var gravity = 3500
var facingLeft = true
var velocity = Vector2(0,0)

const jump_force = -1200
const jump_timer_start = 0.2
var jump_timer = 0
const ground_timer_start = 0.065
var ground_timer = 0
const die_timer_start = 2
var die_timer = 0
const attack_timer_start = 0.6
var attack_timer = 0

var immunity = false
var hasJumped = false


var life = 6

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


func _process(delta: float) -> void:
	
	if life == 0:
		state = DEAD
	
	if position.y > die_posy:
		state = DEAD
	
	# fall down
	velocity.y += gravity * delta
	
	# face the sprite in the right dir
	animSprite.scale.x = -8 if facingLeft else 8
	attackEffectSPR.scale.x = 4 if facingLeft else -4
	var pxe = abs(attackEffectSPR.position.x)
	var pxa = abs(attackArea.position.x)
	attackEffectSPR.position.x = -pxe if facingLeft else pxe
	attackArea.position.x = -pxa if facingLeft else pxa
	
	# on floor -> timer ready
	if is_on_floor():
		if ground_timer <= 0 and hasJumped:
			SFXPlayer.stream = fallDownSFX
			SFXPlayer.play()
			jump_bubles()
			hasJumped = false
		ground_timer = ground_timer_start
		
	# finite state machine
	if state == DIALOG:
		if animator.is_playing():
			animator.stop()
		# pretty much do nothing
		handleFriction()
	elif state == WALK:
		# walking animation start
		if !animator.is_playing() or !animator.assigned_animation == "walk":
			animator.play("walk")
			
		# no input -> idle
		if !Input.is_action_pressed("move_left") and !Input.is_action_pressed("move_right"):
			state = IDLE
		handleJump()
		handleMove()
		handleAttack()
	elif state == IDLE:
		# idle animation start
		if !animator.is_playing() or !animator.assigned_animation == "idle":
			animator.play("idle")
		handleJump()
		handleMove()
		handleFriction()
		handleAttack()
	elif state == DEAD:
		handleDead()
		handleFriction()
	elif state == ATTACK:
		handleFriction()
		
	
	if state != DEAD:
		die_timer = die_timer_start
			
	#update timers
	if ground_timer > 0:
		ground_timer -= delta
	if jump_timer > 0:
		jump_timer -= delta
	if die_timer > 0:
		die_timer -= delta
	if attack_timer >0:
		attack_timer -= delta
			
	velocity = move_and_slide(velocity, Vector2.UP)

func handleAttack():
	if Input.is_action_just_pressed("attack") and attack_timer <= 0:
		
		# damage zombies
		var bodys = attackArea.get_overlapping_bodies()
		for b in bodys:
			if b.is_in_group("Zombies"):
				b.lose_life(facingLeft)
		
		attack_timer = attack_timer_start
		state = ATTACK
		attackEffectSPR.visible = true
		animator.stop()
		animSprite.rotation = 0
		animSprite.scale.y = 8
		SFXPlayerAttack.play()
		animSprite.play("attack", true)
		yield(animSprite, "animation_finished")
		attackEffectSPR.visible = false
		state = IDLE
	

func handleDead():
	animator.stop()
	animSprite.rotation_degrees = 90 if facingLeft else -90
	if die_timer <= 0:
		emit_signal("dead")
		state = DIALOG
	

func jump_bubles():
	if in_water:
		add_child_below_node($JumpEffects, jumpParticles.instance())


func handleFriction():
	if ground_timer > 0:
			velocity.x = lerp(velocity.x, 0, 0.15)

func handleMove():
	if Input.is_action_pressed("move_left"):
		facingLeft = true
		velocity.x = -speed
		state = WALK
	if Input.is_action_pressed("move_right"):
		facingLeft = false
		velocity.x = speed
		state = WALK
	if Input.is_action_just_pressed("jump"):
		jump_timer = jump_timer_start

func handleJump():
	
	if ground_timer <= 0:
		animator.stop()
		animSprite.scale.y = 9.5
		animSprite.scale.x = -6.5 if facingLeft else 6.5
		
	if jump_timer > 0 and ground_timer > 0:
		SFXPlayer.stream = jumpSFX
		SFXPlayer.play()
		jump_bubles()
		velocity.y = jump_force
		# can jump only once
		jump_timer = 0
		# and we are not on the ground anymore
		ground_timer = 0
		hasJumped = true
	
	if hasJumped and velocity.y < 0 and Input.is_action_just_released("jump"):
		velocity.y /= 2.0

func get_life():
	if life < 6:
		life += 1
		redraw_life()
	SFXPlayer.stream = getLifeSFX
	SFXPlayer.play()

func lose_life():
	if immunity or state == DIALOG:
		return
	if life > 1:
		life -= 1
		redraw_life()
		immunity = true
		immunityAnimator.play("immunity")
		SFXPlayer.stream = getHitSFX
		SFXPlayer.play()
		yield(immunityAnimator, "animation_finished")
		immunity = false
	elif life == 1:
		life -= 1
		redraw_life()
		state = DEAD
		SFXPlayer.stream = dieSFX
		SFXPlayer.play()
		velocity.y = jump_force
		jump_bubles()
		hasJumped = true
	
func redraw_life():
	var heart1 = $CanvasLayer/heart1
	var heart2 = $CanvasLayer/heart2
	var heart3 = $CanvasLayer/heart3
	
	if life == 6:
		heart1.region_rect.position.x = 0
		heart2.region_rect.position.x = 0
		heart3.region_rect.position.x = 0
	elif life == 5:
		heart1.region_rect.position.x = 0
		heart2.region_rect.position.x = 0
		heart3.region_rect.position.x = 16
	elif life == 4:
		heart1.region_rect.position.x = 0
		heart2.region_rect.position.x = 0
		heart3.region_rect.position.x = 32
	elif life == 3:
		heart1.region_rect.position.x = 0
		heart2.region_rect.position.x = 16
		heart3.region_rect.position.x = 32
	elif life == 2:
		heart1.region_rect.position.x = 0
		heart2.region_rect.position.x = 32
		heart3.region_rect.position.x = 32
	elif life == 1:
		heart1.region_rect.position.x = 16
		heart2.region_rect.position.x = 32
		heart3.region_rect.position.x = 32
	elif life == 0:
		heart1.region_rect.position.x = 32
		heart2.region_rect.position.x = 32
		heart3.region_rect.position.x = 32
