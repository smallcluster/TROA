extends Node2D

export (String) var messages = "Premier message;Deuxieme message"
onready var dialogue = $Dialogue
onready var playerDetector = $PlayerDetector

func _ready() -> void:
	dialogue.set_dialogue(messages)
	$sprite.region_rect.position.x = 16*(randi()%3)
	$sprite.region_rect.position.y = 16*(randi()%8)
	$sprite.scale.x = -8 if (rand_range(0, 1) < 0.5) else 8
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("talk"):
		var bodys = playerDetector.get_overlapping_bodies()
		for b in bodys:
			if b.is_in_group("Player"):
				dialogue.show_next_message()
				break
