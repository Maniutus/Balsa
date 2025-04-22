extends StaticBody2D


func direccion():
	#Aqui iria el giro, las marchas y los cambios de sprites
	pass

func uso():
	$UI.visible = true
	print("Vela en uso")
	
	
func desuso():
	$UI.visible = false
	print("Vela en desuso")
	
	
	

#jugador pierde movilidad 
#jugador controla la vela (marchas y direccion)
#Pulsa E 


func _on_ui_visibility_changed() -> void:
	pass # Replace with function body.
