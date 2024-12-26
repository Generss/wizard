extends Area2D
signal portal_entered
var entered_recently = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimatedSprite2D.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not entered_recently:
		$WarpSound.play()
		portal_entered.emit()
		$NoRepeatAssurance.start()
		entered_recently = true
	


func _on_no_repeat_assurance_timeout() -> void:
	entered_recently = false
	
func make_transparent():
	$AnimatedSprite2D.material.set_shader_parameter("transparent", true)
func make_opaque():
	$AnimatedSprite2D.material.set_shader_parameter("transparent", false)

func activate_shader(is_active:bool) -> void:
	$AnimatedSprite2D.material.set_shader_parameter("active",is_active)
