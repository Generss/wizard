extends Node
signal victory_finished

func _ready() -> void:
	pass

func hide():
	$ColorRect.hide()
	$Line1.hide();
func show():
	$ColorRect.show()
	$Line1.show()
	$Line1.begin()

func _on_line_1_finished_line() -> void:
	await get_tree().create_timer(3).timeout
	victory_finished.emit()
