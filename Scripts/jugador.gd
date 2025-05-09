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

@onready var stamina_bar = $UI/StaminaBar
@onready var anim = $AnimatedSprite2D
@onready var camara = $Camera2D
@onready var nodo_main = get_tree().get_root().get_node("Main")
@onready var nodo_barca  = nodo_main.get_node("Barca")
@onready var nodo_tile_barca: TileMapLayer = nodo_barca.get_node("Tile Barca") as TileMapLayer
 

#Diccionario Mesas
@onready var dic_mesas = {
	"vela" : "vela_script_path", 
	"cofre" : "cofre_script_path",
	"antorcha": "antorcha_script_path",
}

#preloads
const vela_script_path = preload("res://Scripts/vela.gd")
const cofre_script_path = preload("res://Scripts/cofre.gd")
const antorcha_script_path = preload("res://Scripts/antorcha.gd")
#const workshop_script_path = preload()

#var acceso a mesas
var mesa = null
var mesa_nombre: String =""
enum CONTACTO {ON, OFF}
var contacto = CONTACTO.OFF
var action = false
var uso_de_mesa: bool = false

func _ready():

	set_process(true)
	set_physics_process(true)
	
	stamina_bar.min_value = 0
	stamina_bar.max_value = 100
	stamina_bar.value     = 100
	
	anim.play("Idle_Land")
	



func _process(delta):
	time_accum += delta
	_animate_stamina_bar(delta)
	interaction()
	#print(uso_de_mesa)
	#DebugConsole.log([uso_de_mesa])
	
	

func _physics_process(delta):
	if uso_de_mesa == true:
		return
	else:
			
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

		_transicion_barco_agua_check()
		
		match state:
			State.ON_LAND:
				uso_de_mesa = false
				velocity = dir * WALK_SPEED
				_recover_stamina(delta)
			
			
			State.IN_WATER:
				uso_de_mesa = false
				velocity = dir * SWIM_SPEED
				_drain_stamina(delta)
			
			
			State.EN_MESA:
				uso_de_mesa = true
				#velocity = dir * 0
				_recover_stamina(delta)
			
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
	DebugConsole.log(["¡Te has ahogado!"])
	state = State.ON_LAND
	get_parent().remove_child(self)
	nodo_barca.add_child(self)
	global_position = nodo_barca.get_node("SpawnPoint").global_position
	stamina = STAMINA_MAX
	stamina_bar.value    = stamina_bar.max_value
	stamina_bar.modulate = Color(1,1,1)
	
	


func _on_mesadetector_area_entered(area: Area2D) -> void:
	if area.is_in_group("mesas"):
		contacto= CONTACTO.ON
		#llamado para saber que mesa
		var nodo_mesa = area.get_parent()
		mesa_nombre = nodo_mesa.name
		mesa = nodo_mesa
		
		
		DebugConsole.log(["Cerca de ", mesa_nombre])
		print ("Cerca de ", mesa_nombre,mesa)
	
	
func _on_mesadetector_area_exited(area: Area2D) -> void:
	if area.is_in_group("mesas"):
		contacto= CONTACTO.OFF
		
#Codigo de Interaccion
func interaction():
	if state == State.IN_WATER:
		return
		
	if contacto == CONTACTO.ON and Input.is_action_just_pressed("E"):
		action = !action
		if action  :
			uso_de_mesa = true
			state = State.EN_MESA
			mesa.uso()
			print(mesa_nombre, "Activada", mesa)
			DebugConsole.log([mesa_nombre," Activada"])
		elif !action :
			mesa.desuso()
			uso_de_mesa = false
			state = State.ON_LAND
			
			print (mesa_nombre, "Desactivada")
			DebugConsole.log([mesa_nombre," Desactivada"])
		
			
			
func _transicion_barco_agua_check():
	
	if state == State.EN_MESA:
		return

	var local_pos: Vector2 = nodo_tile_barca.to_local(global_position)
	var cell: Vector2i = nodo_tile_barca.local_to_map(local_pos)
	var tile_id: int   = nodo_tile_barca.get_cell_source_id(cell)
	var en_barco: bool  = tile_id >= 0

	if en_barco and state != State.ON_LAND:
		state = State.ON_LAND
		call_deferred("cambio_padres", nodo_barca)
		print("Subido a la barca")
		DebugConsole.log(["Subido a la barca"])
	elif not en_barco and state != State.IN_WATER:
		state = State.IN_WATER
		call_deferred("cambio_padres", nodo_main)
		print("Caído al agua")
		DebugConsole.log(["Caído al agua"])



func cambio_padres (new_parent: Node):
	#if get_parent() == new_parent:
	#	return
	var posicion_vieja = global_transform
	get_parent().remove_child(self)
	new_parent.add_child(self)
	new_parent.move_child(self, 2)
	global_transform = posicion_vieja


		
