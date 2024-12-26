extends StaticBody2D
signal dead

@export var max_hp: int = 10
var hp: int = max_hp
var target
var rotation_speed: float = PI/6
var current_frame: int = 0
var projectile := preload("res://projectiles/lazer.tscn")
var ready_to_fire: bool = true
var starting_rotation: float
var random_gen = RandomNumberGenerator.new()
var disabled: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimatedSprite2D.play()
	random_gen.randomize()
	starting_rotation = random_gen.randf_range(-PI,PI)
	rotation = starting_rotation
	$Explosion.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if target and not disabled:
		var angle_between: float = (target.position - position).angle()
		# Calculate the difference between angles
		var diff: float = angle_between - rotation

		# Normalize the difference to the range (-PI, PI)
		diff = fmod(diff + PI, PI * 2) - PI

		var dir: int = sign(diff)

		# If there's still a difference, rotate towards the target
		if abs(diff) > 0.01:
			rotate(rotation_speed * dir * delta)
		
		if ready_to_fire and position.distance_to(target.position) < 300:
			fire_projectile()
			ready_to_fire = false
			$CooldownTimer.start()
			
		

func fire_projectile():
	$ShootSound.play()
	var new_projectile := projectile.instantiate()
	new_projectile.rotation = get_rotation()
	new_projectile.velocity = new_projectile.velocity.rotated(get_rotation())
	new_projectile.position = position + new_projectile.velocity.normalized() * 35
	get_tree().get_current_scene().add_child(new_projectile)
	

func take_damage(damage: int):
	hp -= damage
	check_dead()
	#Set the frame so it's showing the correct amount of damage on the sprite
	$AnimatedSprite2D.frame = abs(roundi(((float(hp)/float(max_hp)) * 4) - 4))
	
func check_dead():
	if disabled: return
	
	if hp <= 0: 
		disabled = true
		$BodyShape.disabled = true
		$GunShape.disabled = true
		$ExplosionSound.play()
		$AnimatedSprite2D.hide()
		$Explosion.show()
		$Explosion.play()
		await $ExplosionSound.finished
		dead.emit()
		queue_free()
		dead.emit()



func _on_cooldown_timer_timeout() -> void:
	ready_to_fire = true
