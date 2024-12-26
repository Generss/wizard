extends Node
signal restart

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func hide():
	$ColorRect.hide()
	$Line1.hide()
	$RestartButton.hide()
	$RestartButton.disabled = true
	
func show(message: String):
	$ColorRect.show()
	$Line1.begin()
	$Line1.show()
	await $Line1.finished_line
	$RestartButton.show()
	$RestartButton.disabled = false	


func _on_restart_button_pressed() -> void:
	restart.emit()
