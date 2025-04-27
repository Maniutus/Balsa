extends StaticBody2D


enum State { VELA_QUITADA, VELA_BAJA, VELA_MEDIA, VELA_FULL }

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

func _ready() -> void:
	print(">> Vela: _ready() llamada")
	DebugConsole.log([">> Vela: _ready() llamada"])
	set_process(true)
	
	
func uso():
	en_uso = true
	print(">> Vela: uso() → en_uso =", en_uso)
	DebugConsole.log([">> Vela: uso() → en_uso =", en_uso])
	$UI.visible = true
	
	
func desuso():
	en_uso = false
	#print(">> Vela: desuso() → en_uso =", en_uso)
	#DebugConsole.log([">> Vela: desuso() → en_uso =", en_uso])
	$UI.visible = false
	
	
func _process(delta: float) -> void:
	
	#print(">> Vela: _process() tick — en_uso =", en_uso)
	#DebugConsole.log([">> Vela: _process() tick — en_uso =", en_uso])
	
	if not en_uso:
		return

	if Input.is_action_pressed("izq"):
		rotation_degrees -= rotate_speed * delta
		apuntado_vela = rotation_degrees
		print("Vela gira izquierda")
		DebugConsole.log(["Vela gira izquierda ", rotation_degrees, apuntado_vela])
	elif Input.is_action_pressed("der"):
		rotation_degrees += rotate_speed * delta
		apuntado_vela = rotation_degrees
		print("Vela gira derecha")
		DebugConsole.log(["Vela gira derecha ", rotation_degrees, apuntado_vela])

	var count := State.values().size()

	if Input.is_action_just_pressed("up"):
		state_marcha = (state_marcha + 1) % count
		_update_state()
		print("Marcha arriba")
		DebugConsole.log(["Marcha arriba"])
	elif Input.is_action_just_pressed("down"):
		state_marcha = (state_marcha - 1 + count) % count
		_update_state()
		print("Marcha abajo")
		DebugConsole.log(["Marcha abajo"])

func _update_state():

	$Sprite.texture = vela_textures[state_marcha]
	print("Estado de vela cambiado a: ", state_marcha)
	DebugConsole.log(["Estado de vela cambiado a: ", state_marcha])
