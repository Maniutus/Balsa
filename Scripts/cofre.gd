extends StaticBody2D

enum State { CERRADO, ABIERTO }
var state = State.CERRADO

@onready var anim = $AnimatedSprite2D
var animacion = "Cerrado"

func uso():
	state = State.ABIERTO
	$UI.visible = true
	animacion = "Abierto"
	
	if anim.animation != animacion:
		anim.play(animacion)
		
	print("cofre abierto")
	
	
func desuso():
	state = State.CERRADO
	$UI.visible = false
	animacion = "Cerrado"
	
	if anim.animation != animacion:
		anim.play(animacion)
		
	print("cofre cerrado")
