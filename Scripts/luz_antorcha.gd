extends PointLight2D

# — Rango de parpadeo de intensidad
@export_range(0.5, 2.0) var min_energy: float = 0.8
@export_range(0.5, 2.0) var max_energy: float = 1.2
@export var flicker_speed: float = 4.0   # Velocidad del parpadeo

# — Color base de la llama y variación aleatoria
@export var base_color: Color = Color(1.0, 0.8, 0.5)
@export var color_variation: float = 0.2

# — TextureScale para animar el “radio” de la luz
@export_range(0.1, 5.0) var min_texture_scale: float = 1.0
@export_range(0.1, 5.0) var max_texture_scale: float = 1.5

# — Ruido y acumulador de tiempo
var noise: FastNoiseLite
var time_accum: float = 0.0

func _ready() -> void:
	noise = FastNoiseLite.new()
	noise.seed = randi()
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.frequency = 1.0
	noise.fractal_type = FastNoiseLite.FRACTAL_FBM
	noise.fractal_octaves = 2
	noise.fractal_lacunarity = 2.0
	noise.fractal_gain = 0.5

func _process(delta: float) -> void:
	# 1) Actualiza el “tiempo” para el ruido
	time_accum += delta * flicker_speed

	# 2) Toma un valor de ruido en [-1,1] y normalízalo a [0,1]
	var n: float = noise.get_noise_1d(time_accum)
	var t: float = (n + 1.0) * 0.5

	# 3) Parpadea la intensidad (energy)
	energy = lerp(min_energy, max_energy, t)

	# 4) Parpadea el tamaño del haz (texture_scale)
	texture_scale = lerp(min_texture_scale, max_texture_scale, t)

	# 5) Pequeñas variaciones de color
	var r: float = clamp(base_color.r + randf_range(-color_variation, color_variation), 0.0, 1.0)
	var g: float = clamp(base_color.g + randf_range(-color_variation, color_variation), 0.0, 1.0)
	var b: float = clamp(base_color.b + randf_range(-color_variation, color_variation), 0.0, 1.0)
	color = Color(r, g, b)
