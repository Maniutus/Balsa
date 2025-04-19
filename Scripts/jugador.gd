extends CharacterBody2D

# — Estadísticas
const GRAVITY = 800.0
const WALK_SPEED = 150.0
const SWIM_SPEED = 80.0

#— Velocidades de la barra (en valor 0–100 por segundo)
var BAR_SPEED_DOWN := STAMINA_DRAIN_RATE   / STAMINA_MAX * 100.0
var BAR_SPEED_UP   := STAMINA_RECOVER_RATE / STAMINA_MAX * 100.0

const STAMINA_MAX         = 5.0  # segundos de nado
const STAMINA_DRAIN_RATE  = 1.0  # por segundo
const STAMINA_RECOVER_RATE= 0.5  # por segundo

# — Estados
enum State { ON_LAND, IN_WATER }
var state = State.ON_LAND
var time_accum := 0.0
var stamina := STAMINA_MAX

# — Capa de “suelo” (tiles de balsa) es la 1 → bitmask = 1 << 0

const SUELO_MASK = 1 << 0

# — Referencias
@onready var water_detector = $Waterdetector
@onready var stamina_bar     = $UI/StaminaBar
@onready var anim            = $AnimatedSprite2D

func _ready():
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

#— Señales de WaterDetector —
func _on_Waterdetector_body_entered(body):
		state = State.ON_LAND
		print("Sobre suelo")
		print(state)

func _on_Waterdetector_body_exited(body):
		state = State.IN_WATER
		print("Sobre agua")
		print(state)

func _process(delta):
	time_accum += delta
	_animate_stamina_bar(delta)

func _physics_process(delta):
	
	# 1) Input
	var dir = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down")  - Input.get_action_strength("ui_up")
	).normalized()

	# 2) Elegir animación según estado y movimiento
	var desired_anim = "Idle_Land"
	if state == State.ON_LAND:
		if dir != Vector2.ZERO:
			desired_anim = "Walk"
		else:
			desired_anim = "Idle_Land"
	else:  # IN_WATER
		if dir != Vector2.ZERO:
			desired_anim = "Swim"
			print("Swim")
		else:
			desired_anim = "Idle_Swim"

	if anim.animation != desired_anim:
		anim.play(desired_anim)

	# 4) Movimiento y stamina
	match state:
		State.ON_LAND:
			velocity = dir * WALK_SPEED
			_recover_stamina(delta)
		State.IN_WATER:
			velocity = dir * SWIM_SPEED
			_drain_stamina(delta)

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
	global_position = get_tree().root.get_node("Main/SpawnPoint").global_position
	stamina = STAMINA_MAX
	state = State.ON_LAND
	stamina_bar.value    = stamina_bar.max_value
	stamina_bar.modulate = Color(1,1,1)
