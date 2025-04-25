extends Node2D

@onready var barra_velocidad_viento  = $"UI/Sprites/velocidad viento/velocidad viento barra"
var velocidad_viento_n = 10

#Variables Tiempo
@export var seg_dia :float = 10
var ciclo_dia_noche: float = seg_dia 
var dia:bool = true
var nombre_dia = "Es de Dia"
var contador_dias: int = 0

#Variables Clima : [viento minimo, viento max, altura de olas, luvia:bool ]
var dic_climas = {
	"depejado" : [0, 30 ], 
	 "tormenta" : [80, 100],
	"lluvioso" : [30, 80],
	"niebla" : [0, 5]
}


var clima = dic_climas.keys()[0]
@export var dir_viento = 0


func _ready() -> void:
	print (clima)
	direccion_viento()
	velocidad_viento ()
	print(nombre_dia)
	

func _process(delta: float) -> void:
	cambio_ciclo_dia_noche(delta)
	animacion_sprites(delta)
	_animate_velocidad_viento_bar()

func cambio_ciclo_dia_noche(delta):
	
	if ciclo_dia_noche > 0 :
		
		ciclo_dia_noche -= delta
		#print(ciclo_dia_noche)
		
	else: 
		ciclo_dia_noche = seg_dia
		dia = !dia
		pool_climas()
		direccion_viento() 
		velocidad_viento()
		if dia:
			contador_dias = contador_dias + 1
			nombre_dia = "Es de Dia"
			print(nombre_dia, " Dia: ", contador_dias)
		else:
			nombre_dia = "Es de Noche"
			print(nombre_dia)

func animacion_sprites(delta):
	
	#DiayNoche
	$UI/Sprites/Disco.rotation += (PI * 2) / (2 * seg_dia) * delta # Gira el sprite del disco
	
	#Brujula
	var vel_giro = 2.0
	var dir_viento_rad = deg_to_rad(dir_viento)
	$UI/Sprites/Viento.rotation = lerp_angle($UI/Sprites/Viento.rotation, dir_viento_rad, vel_giro * delta )



func pool_climas():
	var rng = RandomNumberGenerator.new()
	var claves = dic_climas.keys()
	var idx = rng.randi_range(0 , claves.size() -1)
	var clima_elegida = claves[idx]
	clima = clima_elegida
	print(clima)

func velocidad_viento():

	var array_clima = dic_climas[clima] as Array
	var viento_min = array_clima[0]
	var viento_max = array_clima[1]
	
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	velocidad_viento_n = rng.randi_range(viento_min, viento_max)
	#print("EL viento_min es: ", viento_min)
	#print("EL viento_max es: ", viento_max)
	print("La velocidad del viento es: ", velocidad_viento_n)
	
func direccion_viento():
	var rango_max = 150
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var dir_viento_raw = rng.randi_range(dir_viento-rango_max, dir_viento+rango_max)
	
	#Formula para convertir los radianes a grados y quitar los negativos del rotation.
	#dir_viento = ((dir_viento_raw % 360) + 360) % 360  
	
	dir_viento = dir_viento_raw 
	print("Direccion Viento: ", dir_viento, " grados")
	
func _animate_velocidad_viento_bar():
	barra_velocidad_viento.value = float(velocidad_viento_n)/100 

	
func cambio_dir_viento():
	pass
	
func cambio_fuerza_viento():
	pass
	
