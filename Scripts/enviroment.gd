extends Node2D

#Variables Tiempo
@export var min_dia = 1
var ciclo_dia_noche = min_dia
var dia:bool = true

#Variables Clima : [viento minimo, viento max]
var dic_climas = {
	"depejado" : [0, 50], 
	 "tormenta" : [80, 150],
	"lluvioso" : [30, 100],
	"niebla" : [0, 20]
}

var clima = dic_climas.keys()[0]

func _ready() -> void:
	
	pass

func _process(delta: float) -> void:
	cambio_ciclo_dia_noche(delta)
	disco_dia_noche(delta)
	print (clima)

func cambio_ciclo_dia_noche(delta):
	if ciclo_dia_noche > 0 :
		
		ciclo_dia_noche -= delta
		#print(ciclo_dia_noche)
		
	else: 
		ciclo_dia_noche = min_dia
		dia = !dia
		pool_climas()
		#clima = pool_climas() 
		viento()
		print(dia, ciclo_dia_noche)

func disco_dia_noche(delta):
		#const TAU = PI * 2
	#var omega = (PI * 2) / (2 * min_dia) 
	$Dia_Noche.rotation += (PI * 2) / (2 * min_dia) * delta

func pool_climas():
	var rng = RandomNumberGenerator.new()
	var claves = dic_climas.keys()
	var idx = rng.randi_range(0 , claves.size() -1)
	var clima = claves[idx]
	print(clima)

func viento():
	var array_clima = dic_climas[clima] as Array
	var viento_min = array_clima[0]
	print("EL viento_minimo es ", viento_min)
	
