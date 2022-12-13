extends Sprite

onready var anim : AnimationPlayer = $AnimationPlayer
enum {IDLE, PANIK}

var state = IDLE
var state_changed = false
export var speed = 400;
var looking;

func panik() -> void:
	state = PANIK
	speed = rand_range(250, 400)*(-1 if randi()%2==0 else 1)
	anim.play("Panic")
	anim.seek(rand_range(0, 0.3))

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	anim.play("idle")
	region_rect.position.x = 16*(randi()%3)
	region_rect.position.y = 16*(randi()%8)

func _process(delta: float) -> void:
	if state == PANIK:
		if speed < 0:
			scale.x = -8
		else:
			scale.x = 8
		position.x += speed * delta
		if position.x-64 < 0:
			speed *= -1
			position.x = 64
		elif position.x+64 > get_viewport().size.x:
			speed *= -1
			position.x = get_viewport().size.x-64
