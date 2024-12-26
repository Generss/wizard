extends Button

var alpha_per_second: float = 0.5
var appearing: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if appearing:
		self_modulate.a += alpha_per_second * delta
		if self_modulate.a >= 1:
			appearing = false

func dissapear():
	self_modulate.a = 0
	appearing = false

func appear():
	appearing = true
