extends Label

signal cursor_select()

func cursor_select() -> void:
	print(name)
	emit_signal("cursor_select")
