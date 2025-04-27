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
		print("Ya esta llena")
		DebugConsole.log(["Ya esta llena de aceite"])
		return
	elif state== State.VACIA or state == State.CANDESCENTE:
		state = State.LLENA
		print("Antorcha llenada de aceite")
		DebugConsole.log(["Antorcha recargada de aceite"])
	elif state == State.ENCENDIDA:
		state = State.ENCENDIDA
		print("La antorcha ya esta encendida")
		DebugConsole.log(["La antorcha ya esta encendida"])
		print()
	
	
	
func desuso():
	state = State.ENCENDIDA
	print("Antorcha encendida")
	DebugConsole.log(["Antorcha encendida"])

	
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
			
		
