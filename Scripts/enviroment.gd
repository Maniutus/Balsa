extends Node2D

#Variables Tiempo
@export var min_dia = 30
var ciclo_dia_noche = min_dia
var dia:bool = true

#Variables Clima : [viento minimo, viento max]
var climas = {
	"depejado" : [0, 50], 
	 "tormenta" : [80, 150],
	"lluvioso" : [30, 100],
	"niebla" : [0, 20]
}



func _ready() -> void:
	pass


func _process(delta: float) -> void:
	cambio_ciclo_dia_noche(delta)
	disco_dia_noche(delta)

func cambio_ciclo_dia_noche(delta):
	if ciclo_dia_noche > 0 :
		
		ciclo_dia_noche -= delta
		#print(ciclo_dia_noche)
		
	else: 
		ciclo_dia_noche = min_dia
		dia = !dia
		print(dia, ciclo_dia_noche)

func disco_dia_noche(delta):
		#const TAU = PI * 2
	#var omega = (PI * 2) / (2 * min_dia) 
	$Dia_Noche.rotation += (PI * 2) / (2 * min_dia) * delta

func clima( d:Dictionary ):
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var vals = d.values()  # Array de valores
	print()
	return vals[rng.randi_range(0, vals.size() - 1)]
	
