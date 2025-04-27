extends RichTextLabel

@export var max_lines: int = 100
static var _instance: DebugConsole

func _enter_tree() -> void:
	_instance = self
	clear()

func _ready() -> void:
	bbcode_enabled = false
	scroll_following = true

# Ahora recibe un Array con *exactamente* lo que antes ibas a print(...)
static func log(args: Array) -> void:
	if not _instance:
		return
	# Convierte cada entrada a String y los une con espacios
	var combined := ""
	for i in range(args.size()):
		combined += str(args[i])
		if i < args.size() - 1:
			combined += " "
	_instance._append(combined)

func _append(msg: String) -> void:
	var lines: PackedStringArray = text.split("\n", false)
	lines.append(msg)
	if lines.size() > max_lines:
		var trimmed := PackedStringArray()
		var start := lines.size() - max_lines
		for j in range(start, lines.size()):
			trimmed.append(lines[j])
		lines = trimmed
	# Reconstruye todo el texto
	var new_text := ""
	for k in range(lines.size()):
		new_text += lines[k]
		if k < lines.size() - 1:
			new_text += "\n"
	text = new_text
	scroll_to_line(lines.size())
