extends Node2D

export (AudioStream) var panik_bg
export (AudioStream) var panik_foule
export (PackedScene) var level1
export (Texture) var newBg

var dialog1_text = "Bienvenue, roi d' Atlantica, a l'inauguration du tout nouveau temple sur le volcan endormi !"
var dialog2_text = "Ne vous inquietez pas, ce volcan est inactif depuis des siecles !"
var dialog3_text = "Enfin il y a bien eu celui d'Atlantis qui s'est reveille."
var dialog4_text = "Ce qui a entraine la remonte de leur cite a la surface, ah, que des loser !"

var canSkipDialog = false
var dialogueNumber = 1

onready var dialog_label = $CanvasLayer2/dialogBox/background/Label
onready var dialogAnim = $CanvasLayer2/dialogBox/AnimationPlayer
onready var dialogSound = $CanvasLayer2/dialogBox/AudioStreamPlayer
onready var fouleSound = $foule
onready var coloredRect = $RED/ColorRect
onready var thisWay = $this_way
onready var blackRect = $fadeOutLayer/fadeout
onready var fadeAnim = $fadeOutLayer/fadeout/animation
onready var bg = $CanvasLayer/bg
onready var templeAnim = $CanvasLayer/temple/templeAnim

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	thisWay.visible = false
	
	# FADE OUT
	blackRect.visible = true
	fadeAnim.play("fadeOut")
	yield(fadeAnim, "animation_finished")
	blackRect.visible = false
	
	#DIALOG ONE
	dialog_label.text = dialog1_text
	dialogAnim.play("pop")
	yield(dialogAnim, "animation_finished")
	dialog_label.text += "\n\nespace pour continuer"
	canSkipDialog = true
	dialogueNumber = 1
		
func go_panik():
	var pnjs = $pnjs.get_children()
	for p in pnjs:
		p.panik()
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if canSkipDialog:
		if Input.is_action_just_pressed("next_dialogue"):
			canSkipDialog = false
			if dialogueNumber == 1:
				#Dialogue 2
				dialogSound.play()
				dialogAnim.play("depop")
				yield(dialogAnim, "animation_finished")
				dialog_label.text = dialog2_text
				dialogAnim.play("pop")
				yield(dialogAnim, "animation_finished")
				dialog_label.text += "\n\nespace pour continuer"
				canSkipDialog = true
				dialogueNumber = 2
			elif dialogueNumber == 2:
				#Dialogue 3
				dialogSound.play()
				dialogAnim.play("depop")
				yield(dialogAnim, "animation_finished")
				dialog_label.text = dialog3_text
				dialogAnim.play("pop")
				yield(dialogAnim, "animation_finished")
				dialog_label.text += "\n\nespace pour continuer"
				canSkipDialog = true
				dialogueNumber = 3
			elif dialogueNumber == 3:
				#Dialogue 4
				dialogSound.play()
				dialogAnim.play("depop")
				yield(dialogAnim, "animation_finished")
				dialog_label.text = dialog4_text
				dialogAnim.play("pop")
				yield(dialogAnim, "animation_finished")
				dialog_label.text += "\n\nespace pour continuer"
				canSkipDialog = true
				dialogueNumber = 4
			elif dialogueNumber == 4:
				#Dialogue 3
				dialogSound.play()
				dialogAnim.play("depop")
				yield(dialogAnim, "animation_finished")
				$CanvasLayer2/dialogBox.visible = false
				
				$RED/ColorRect/AnimationPlayer.play("effect")
				bg.texture = newBg
				var bubles = $bubles.get_children()
				for b in bubles:
					b.emitting = true
				templeAnim.play("fall")
				var bg_music = $"bg music"
				bg_music.stream = panik_bg
				bg_music.play()
				$CanvasLayer/Particles2D/explosions.play()
				yield(templeAnim, "animation_finished")
				$CanvasLayer/Particles2D.emitting = true
				fouleSound.stream = panik_foule
				fouleSound.play()
				go_panik()
				thisWay.visible = true
				$Player.state = $Player.IDLE



func _on_Area2D_body_entered(body: Node) -> void:
	$Player.state = $Player.DIALOG
	blackRect.visible = true
	fadeAnim.play("fadeIn")
	yield(fadeAnim, "animation_finished")
	get_tree().change_scene_to(level1)
	
