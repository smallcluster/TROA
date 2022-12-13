extends Node2D

onready var animator : AnimationPlayer = $AnimationPlayer
onready var label : Label = $Box/Label
onready var SFXPlayer : AudioStreamPlayer = $AudioStreamPlayer

var messages = ["TEST1", "TEST2"]
var currentMessage = -1
var nbMessages = 2
var skipable = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	scale.y = 0
	skipable = false
	currentMessage = -1


func set_dialogue(diag):
	messages = diag.split(";")
	nbMessages = len(messages)
		
func show_next_message():
	if !skipable and currentMessage > -1:
		return
		
	if currentMessage == -1:
		SFXPlayer.play()
		skipable = false
		visible = true
		currentMessage = 0
		label.text = messages[currentMessage]
		animator.play("pop")
		yield(animator, "animation_finished")
		skipable = true
	else:
		skipable = false
		animator.play("depop")
		yield(animator, "animation_finished")
		currentMessage += 1
		
		if currentMessage == nbMessages:
			visible = false
			skipable = false
			currentMessage = -1
			return
		SFXPlayer.play()
		label.text = messages[currentMessage]
		animator.play("pop")
		yield(animator, "animation_finished")
		skipable = true
		
		
	
