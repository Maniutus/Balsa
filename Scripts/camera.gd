extends Camera2D

# — Zoom mínimo y máximo
@export var zoom_min: Vector2 = Vector2(0.5, 0.5)
@export var zoom_max: Vector2 = Vector2(1.5, 1.5)

# — Cuánto cambia el zoom por “tick” de rueda
@export var zoom_step: float = 0.1

# — Qué tan rápido interpola al objetivo
@export var zoom_speed: float = 5.0

# — Objetivo de zoom al que interpolar
var zoom_target: Vector2

func _ready() -> void:
	zoom_target = zoom

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_WHEEL_DOWN:
				zoom_target.x = clamp(zoom_target.x - zoom_step, zoom_min.x, zoom_max.x)
				zoom_target.y = clamp(zoom_target.y - zoom_step, zoom_min.y, zoom_max.y)
			MOUSE_BUTTON_WHEEL_UP:
				zoom_target.x = clamp(zoom_target.x + zoom_step, zoom_min.x, zoom_max.x)
				zoom_target.y = clamp(zoom_target.y + zoom_step, zoom_min.y, zoom_max.y)
			_:
				pass

func _process(delta: float) -> void:
	# Creamos una variable TIPO-FLOAT para la interpolación,
	# evitando la inferencia automática a Variant.
	var factor: float = clamp(delta * zoom_speed, 0.0, 1.0)
	zoom = zoom.lerp(zoom_target, factor)
