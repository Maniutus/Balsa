extends StaticBody2D

@onready var anim = $AnimatedSprite2D
@onready var luz = get_node("Luz Antorcha")


enum State { VACIA, LLENA, CANDESCENTE, ENCENDIDA }
var state = State.VACIA

var tiempo_max:float = 10
var t_descuento:float = tiempo_max

func _process(delta: float) -> void:
	duraccion_antorcha(delta)
	
func _physics_process(delta):
	animaciones()
	
func uso():
	if state == State.LLENA:
		return
	elif state== State.VACIA or state == State.CANDESCENTE:
		state = State.LLENA
	elif state == State.ENCENDIDA:
		state = State.ENCENDIDA
	
	
	
func desuso():
	state = State.ENCENDIDA

	
func animaciones():
	var desired_anim = "Vacia"

	if state == State.VACIA:
		desired_anim = "Vacia"
		luz.enabled = false
	elif state == State.LLENA:
		desired_anim = "Llena"
		luz.enabled = false
	elif state == State.CANDESCENTE:
		desired_anim = "Candescente"
		luz.enabled = false
	elif state == State.ENCENDIDA:
		desired_anim = "Encendida"
		luz.enabled = true
		
		
	if anim.animation != desired_anim:
		anim.play(desired_anim)
		
	
func duraccion_antorcha(delta):

	if state == State.ENCENDIDA:
		if t_descuento > 0:
			t_descuento -= delta
			
		else:
			t_descuento = tiempo_max
			state = State.CANDESCENTE
			
		
