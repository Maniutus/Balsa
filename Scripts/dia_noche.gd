extends CanvasModulate


@export var gradient: GradientTexture1D
@onready var enviroment_node = get_parent()

var fase_onda: float = 0.0

func _process(delta: float) -> void:
	var seg_dia = enviroment_node.seg_dia
	var periodo = seg_dia * 2.0
	var omega = TAU / periodo
	fase_onda += delta * omega
	if fase_onda >= TAU:
		fase_onda -= TAU
	var valor = (sin(fase_onda) + 1.0) * 0.5
	color = gradient.gradient.sample(valor)
