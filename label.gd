extends RichTextLabel
signal finished_line
var finished_typing: bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if finished_typing:
		finished_line.emit()
		finished_typing = false

func begin():
	visible_ratio = 0
	get_node("../TypewriterTimer").start()
	$"../TextSound".play()
	

func _on_typewriter_timer_timeout() -> void:
	if visible_ratio >= 1:
		get_node("../TypewriterTimer").stop()
		finished_typing = true
		$"../TextSound".stop()
	else:
		visible_characters += 1
