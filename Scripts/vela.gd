extends Node2D

enum ACTIVE {ON, OFF}
var state = ACTIVE.ON
var vela_activa = false


func _physics_process(delta: float) -> void:
	interaction(delta)

func direccion():
	#Aqui iria el giro, las marchas y los cambios de sprites
	pass

func _on_interact_body_entered(body : Node2D):
	body.is_in_group("Jugadores")
	state = ACTIVE.ON
		#if Input.action_press("E"):
	print ("Vela Activa")

func _on_interact_body_exited(body: Node2D) -> void:
	body.is_in_group("Jugadores")
	state = ACTIVE.OFF
	

#Codigo de Interaccion
func interaction(delta):
	if state == ACTIVE.ON:
		if Input.is_action_just_pressed("E"):
			vela_activa = !vela_activa
			if vela_activa  :
				print("Abre Vela")
			elif !vela_activa :
				print ("Cierra Vela")
		
	

#jugador pierde movilidad 
#jugador controla la vela (marchas y direccion)
#Pulsa E 
