extends StaticBody2D


@onready var enviroment_node = $"../../../Enviroment"

enum State { VELA_QUITADA, VELA_BAJA, VELA_MEDIA, VELA_FULL }
var velo_velas = 0.0

var vela_textures := [
	preload("res://Assets/Velas/vela_0.png"),
	preload("res://Assets/Velas/vela_1.png"),
	preload("res://Assets/Velas/vela_2.png"),
	preload("res://Assets/Velas/vela_3.png"),
]

var state_marcha: int = State.VELA_QUITADA
var en_uso: bool = false
@export var rotate_speed: float = 90.0  # grados/segundo
var apuntado_vela = rotation_degrees
var multiplicador_fuerza = 0.5

func _ready() -> void:
	#print(">> Vela: _ready() llamada")
	DebugConsole.log([enviroment_node])
	DebugConsole.log([enviroment_node.dir_viento,enviroment_node.velocidad_viento_n])
	set_process(true)
	
	
func uso():
	en_uso = true
	#print(">> Vela: uso() → en_uso =", en_uso)
	#DebugConsole.log([">> Vela: uso() → en_uso =", en_uso])
	$UI.visible = true
	
	
func desuso():
	en_uso = false
	#print(">> Vela: desuso() → en_uso =", en_uso)
	#DebugConsole.log([">> Vela: desuso() → en_uso =", en_uso])
	$UI.visible = false
	
	
func _process(delta: float) -> void:
	#DebugConsole.log([velo_velas])
	#print(">> Vela: _process() tick — en_uso =", en_uso)
	#DebugConsole.log([">> Vela: _process() tick — en_uso =", en_uso])
	calcula_vela_velocidad()
	
	if not en_uso:
		return

	if Input.is_action_pressed("izq"):
		rotation_degrees -= rotate_speed * delta
		apuntado_vela = rotation_degrees
		print("Vela gira izquierda")
		DebugConsole.log(["Vela gira izquierda", apuntado_vela])
	elif Input.is_action_pressed("der"):
		rotation_degrees += rotate_speed * delta
		apuntado_vela = rotation_degrees
		print("Vela gira derecha")
		DebugConsole.log(["Vela gira derecha ", apuntado_vela])

	var count := State.values().size()
	if Input.is_action_just_pressed("up") and state_marcha < count - 1:
		state_marcha += 1
		_update_state()
		print("Marcha arriba")
		DebugConsole.log(["Marcha arriba"])
	elif Input.is_action_just_pressed("down") and state_marcha > 0:
		state_marcha -= 1
		_update_state()
		print("Marcha abajo")
		DebugConsole.log(["Marcha abajo"])
		
		
func _update_state():

	$Sprite.texture = vela_textures[state_marcha]
	print("Estado de vela cambiado a: ", state_marcha)
	DebugConsole.log(["Estado de vela cambiado a: ", state_marcha])
	
func calcula_vela_velocidad() -> void:
	
	var dir_viento: float  = enviroment_node.dir_viento    # en grados
	var velo_viento: float = enviroment_node.velocidad_viento_n   # unidades de velocidad

	
	var delta_ang = wrapf(rotation_degrees - dir_viento + 180.0, 0.0, 360.0) - 180.0
	var diff = abs(delta_ang) 


	var coeff: float
	if diff <= 90.0:
		coeff = 1.0 - diff / 90.0
	else:
		coeff = ((diff - 90.0) / 90.0) * 0.2

	var sail_mul = 0
	match state_marcha:
		State.VELA_QUITADA:
			sail_mul = 0
		State.VELA_BAJA:
			sail_mul = 1
		State.VELA_MEDIA:
			sail_mul = 2
		State.VELA_FULL:
			sail_mul = 4

	
	velo_velas = velo_viento * coeff * sail_mul * multiplicador_fuerza

	
