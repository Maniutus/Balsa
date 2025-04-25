extends CharacterBody2D

@onready var enviroment_node = get_node("../UI/Enviroment")
@onready var map_barca       = get_node("Tile Barca") 

var referencia_tiles: float = 9				#tiles iniciales
var multiplicador_fuerza: float = 2         #Variable multiplicadora de fuerza por viento 

func _physics_process(delta: float) -> void:
	
	var velocidad_viento = enviroment_node.velocidad_viento_n        
	var dir_viento_deg =  enviroment_node.dir_viento 
	var dir_viento_rad = deg_to_rad(dir_viento_deg)
	
	# 2. Cuenta tiles de la barca
	var num_tile = map_barca.get_used_cells().size()
	num_tile = max(num_tile, 1)  # el 1 parece ser para no dividir por 0

	# 3. Factor de “masa” ≈ inverso al número de tiles
	var factor_tamaño = referencia_tiles / num_tile        
	
	var dir = Vector2.UP.rotated(dir_viento_rad)
	
	velocity = dir * velocidad_viento * multiplicador_fuerza * factor_tamaño
	
	move_and_slide()
	

	
