extends Node2D

const min_dia = 30
var ciclo_dia_noche = min_dia
var dia:bool = true


func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	cambio_ciclo_dia_noche(delta)

func cambio_ciclo_dia_noche(delta):
	if ciclo_dia_noche > 0 :
		
		ciclo_dia_noche -= delta
		print(ciclo_dia_noche)
		
	else: 
		ciclo_dia_noche = min_dia
		dia = !dia
		print(dia, ciclo_dia_noche)
		
	 
	
