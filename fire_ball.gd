extends Area2D

signal hit_detected
var damage: int = 2
var velocity = Vector2.RIGHT
var speed:float = 600.0
var disabled: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Explosion.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += velocity.normalized() * speed * delta


func _on_body_entered(body: Node2D) -> void:
	if disabled: return
	disabled = true
	speed = 0
	position = global_position
	top_level = true
	$Sprite2D.hide()
	$Explosion.show()
	$Explosion.play()
	$LittleExplosionSound.play()
	if body.is_in_group("damageable"):
		body.take_damage(damage)
	await $Explosion.animation_finished
	queue_free()
