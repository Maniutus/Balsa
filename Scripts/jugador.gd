extends CharacterBody2D


# — Estadísticas
const GRAVITY = 800.0
const WALK_SPEED = 150.0
const SWIM_SPEED = 80.0
const MESA_SPEED : float = 0.0

#— Velocidades de la barra (en valor 0–100 por segundo)
var BAR_SPEED_DOWN := STAMINA_DRAIN_RATE   / STAMINA_MAX * 100.0
var BAR_SPEED_UP   := STAMINA_RECOVER_RATE / STAMINA_MAX * 100.0

const STAMINA_MAX         = 5.0  # segundos de nado
const STAMINA_DRAIN_RATE  = 1.0  # por segundo
const STAMINA_RECOVER_RATE= 0.5  # por segundo

# — Estado Nadando
enum State { ON_LAND, IN_WATER, EN_MESA }
var state = State.ON_LAND
var time_accum := 0.0
var stamina := STAMINA_MAX

# — Capa de “suelo” (tiles de balsa) es la 1 → bitmask = 1 << 0

const SUELO_MASK = 1 << 0

# — Referencias
@onready var water_detector = $Waterdetector
@onready var stamina_bar     = $UI/StaminaBar
@onready var anim            = $AnimatedSprite2D
@onready var nodo_barca  = get_node("/root/Main/NodoBarca")
@onready var nodo_mundo = get_parent().get_parent() 

#Diccionario Mesas
@onready var dic_mesas = {
	"vela" : "vela_script_path", 
	"cofre" : "cofre_script_path",
	"workshop": "workshop_script_path",
}

#preloads
const vela_script_path = preload("res://Scripts/vela.gd")
const cofre_script_path = preload("res://Scripts/cofre.gd")
#const workshop_script_path = preload()

#var acceso a mesas
var mesa = null
var mesa_nombre: String =""
enum CONTACTO {ON, OFF}
var contacto = CONTACTO.OFF
var action = false

func _ready():
	print("Estado inicial del jugador:", state)
	# Conectar señales del WaterDetector
	water_detector.body_entered.connect(_on_Waterdetector_body_entered)
	water_detector.body_exited.connect(_on_Waterdetector_body_exited)
	# Preparar proceso
	set_process(true)
	set_physics_process(true)
	# Inicializar barra de stamina
	stamina_bar.min_value = 0
	stamina_bar.max_value = 100
	stamina_bar.value     = 100
	# Inicializar animación
	anim.play("Idle_Land")
	
	print(nodo_barca,"///",nodo_mundo)

#— Señales de WaterDetector —
func _on_Waterdetector_body_entered(_body):
		state = State.ON_LAND
		print("Sobre suelo")

func _on_Waterdetector_body_exited(_body):
		state = State.IN_WATER
		print("Sobre agua")

func _process(delta):
	time_accum += delta
	_animate_stamina_bar(delta)
	interaction()
	

func _physics_process(delta):
	
	# 1) Input
	var dir = Vector2(
		Input.get_action_strength("der") - Input.get_action_strength("izq"),
		Input.get_action_strength("down")  - Input.get_action_strength("up")
	).normalized()

	#animación según estado y movimiento
	var desired_anim = "Idle_Land"
	if state == State.ON_LAND:
		if dir != Vector2.ZERO:
			desired_anim = "Walk"
		else:
			desired_anim = "Idle_Land"
	elif state == State.IN_WATER: 
		if dir != Vector2.ZERO:
			desired_anim = "Swim"
		else:
			desired_anim = "Idle_Swim"
	elif state == State.EN_MESA:
		desired_anim = "Idle_Land"
		

	if anim.animation != desired_anim:
		anim.play(desired_anim)

	#Movimiento y stamina
	match state:
		State.ON_LAND:
			velocity = dir * WALK_SPEED
			_recover_stamina(delta)
			estado_padre_jugador()
			
		State.IN_WATER:
			velocity = dir * SWIM_SPEED
			_drain_stamina(delta)
			estado_padre_jugador()
			
		State.EN_MESA:
			velocity = dir * MESA_SPEED
			_recover_stamina(delta)
			estado_padre_jugador()
			

	move_and_slide()

#— Drena stamina real
func _drain_stamina(delta):
	stamina = max(stamina - STAMINA_DRAIN_RATE * delta, 0.0)
	if stamina == 0.0:
		_drown()

func _recover_stamina(delta):
	stamina = min(stamina + STAMINA_RECOVER_RATE * delta, STAMINA_MAX)

func _animate_stamina_bar(delta):
	var target = stamina / STAMINA_MAX * 100.0
	var curr   = stamina_bar.value
	if curr > target:
		stamina_bar.value = max(curr - BAR_SPEED_DOWN * delta, target)
	elif curr < target:
		stamina_bar.value = min(curr + BAR_SPEED_UP * delta, target)

	# Parpadeo cuando bajo <20%
	if stamina < STAMINA_MAX * 0.2:
		var pulse = 0.5 + 0.5 * sin(time_accum * 10.0)
		stamina_bar.modulate = Color(1, pulse * 0.5, pulse * 0.5)
	else:
		stamina_bar.modulate = Color(1,1,1)

func _drown():
	print("¡Te has ahogado!")
	global_position = get_parent().get_node("../Barca/SpawnPoint").global_position
	stamina = STAMINA_MAX
	state = State.ON_LAND
	stamina_bar.value    = stamina_bar.max_value
	stamina_bar.modulate = Color(1,1,1)
	


func _on_mesadetector_area_entered(area: Area2D) -> void:
	if area.is_in_group("mesas"):
		contacto= CONTACTO.ON
		#llamado para saber que mesa
		var nodo_mesa = area.get_parent()
		mesa_nombre = nodo_mesa.name
		mesa = nodo_mesa
		
		
		
		print ("Cerca de ", mesa_nombre,mesa)
	
	
func _on_mesadetector_area_exited(area: Area2D) -> void:
	if area.is_in_group("mesas"):
		contacto= CONTACTO.OFF
		
#Codigo de Interaccion
func interaction():

	if contacto == CONTACTO.ON and Input.is_action_just_pressed("E"):
		action = !action
		if action  :
			state = State.EN_MESA
			#m_player = MOVIMIENTO_PLAYER.OFF
			mesa.uso() # Llamado a la funcion uso de la mesa seleccionada $vela as script
			print(mesa_nombre, "Activada", mesa)
		elif !action :
			state = State.ON_LAND
			#m_player = MOVIMIENTO_PLAYER.ON
			mesa.desuso() 
			print (mesa_nombre, "Desactivada")
			

var new_state = state
func estado_padre_jugador(): #funcion que hace que el jugador se desconecte de la barca cuando se baja.
	"""
	if new_state == state:
		return
		
	else:
		var global_pos = global_position
		get_parent().remove_child(self)
	
		if state == State.ON_LAND:
			nodo_barca.add_child(self,2)
			new_state = state
			print("Pasando de LAND a WATER")
		elif state == State.IN_WATER:
			nodo_mundo.add_child(self)
			new_state = state
			print("Pasando de WATER a LAND")
			
		global_position = global_pos
		
		
	"""
