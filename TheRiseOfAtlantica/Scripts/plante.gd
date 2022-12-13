extends Sprite


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	region_rect.position.x = 16*(randi()%2)
	region_rect.position.y = 16*(randi()%3)
	scale.x = -8 if rand_range(0, 1) < 0.5 else 8
	$AnimationPlayer.play("wind", -1, rand_range(0.5, 1.5))
