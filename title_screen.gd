extends Node
signal game_started

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	show()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_start_button_pressed() -> void:
	game_started.emit()

func hide():
	$AnimatedSprite2D.hide()
	$Title.hide()
	$StartButton.hide()
	$OpeningVoice.stop()
	$OpeningVoice2.stop()
	$Thunder.stop()

func show():
	$AnimatedSprite2D.show()
	$OpeningVoice.play()
	$StartButton.dissapear()
	$Title.dissapear()
	$AnimatedSprite2D.play("begin")
	await $OpeningVoice.finished
	$Thunder.play()
	$AnimatedSprite2D.play("middle")
	await $AnimatedSprite2D.animation_finished
	$OpeningVoice2.play()
	$AnimatedSprite2D.play("end")
	$Title.show()
	$StartButton.show()
	$StartButton.appear()
	$Title.appear()
