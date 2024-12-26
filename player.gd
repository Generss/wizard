extends CharacterBody2D
signal dead
signal damage_taken

@export var projectile: PackedScene
var speed: float = 400.0
var current_hand: bool = false
var can_fire_again: bool = true
var max_hp := 10
var hp := max_hp
var displace_vector: Vector2 = Vector2(0,0)
var displace_amount: float = 10.0
var projectiles_per_second: float = 4.0
var transparent: bool = false
var flickering: bool = false
var invincible: bool = false
var arrow_following: bool = false
var arrow_target 
var group_follow_type

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Body.animation = "idle"
	$FireTimer.set_wait_time(1/projectiles_per_second)
	$ArrowSprite.visible = false

func _physics_process(delta: float) -> void:
	handle_movement(delta)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not visible: return
	handle_animation()
	handle_projectiles()
	handle_arrow()


func handle_movement(delta: float):
	velocity.x =  int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left")) 
	velocity.y = int(Input.is_action_pressed("down")) - int(Input.is_action_pressed("up"))
	velocity = velocity.normalized() * speed 
	move_and_slide()

func handle_arrow(): 
	if arrow_following:
		if is_instance_valid(arrow_target):
			var angle_between = (arrow_target.global_position - global_position).angle()
			$ArrowSprite.position = Vector2.RIGHT.rotated(angle_between) * 160
			$ArrowSprite.set_rotation(angle_between)
			if (arrow_target.global_position - global_position).length() < 160:
				toggle_detector_arrow(group_follow_type)
		else: 
			arrow_target = find_closest_in_group(group_follow_type, global_position)
			if(not is_instance_valid(arrow_target)):
				toggle_detector_arrow(group_follow_type)

func handle_animation():
	if velocity.length() == 0:
		$Legs.play("idle")
	else:
		$Legs.play("walking")
		
	$Legs.rotation = velocity.angle() - PI/2
	
	var body_direction: float = (position - get_global_mouse_position()).angle()
	$Body.rotation = body_direction - PI/2 


func handle_projectiles() -> void:
	if Input.is_action_pressed("fire") and can_fire_again:
		current_hand = not current_hand
		$Body.play("blasting")
		$Body.frame = int(current_hand)
		$FireTimer.start()
		can_fire_again = false
		create_fireball()
	


func _on_fire_timer_timeout() -> void:
	$Body.play("idle")
	can_fire_again = true
	
func create_fireball() -> void:

	$FireSound.play()
	var new_projectile := projectile.instantiate()
	new_projectile.velocity = new_projectile.velocity.rotated($Body.rotation - PI/2)
	if not current_hand:
		displace_vector = Vector2(new_projectile.velocity.y, -new_projectile.velocity.x).normalized() * displace_amount
	else:
		displace_vector = Vector2(-new_projectile.velocity.y, new_projectile.velocity.x).normalized() * displace_amount
	new_projectile.position = new_projectile.velocity.normalized() * 30 + displace_vector
	add_child(new_projectile)


func take_damage(damage:int) -> void:
	if(invincible): return 
	hp -= damage
	if hp <= 0 : 
		dead.emit()
	else:
		$HurtSound.play()
		$Body.material.set_shader_parameter("active", true)
		$Legs.material.set_shader_parameter("active", true)
		await get_tree().create_timer(0.1).timeout
		$Body.material.set_shader_parameter("active", false)
		$Legs.material.set_shader_parameter("active", false)
		damage_taken.emit()
		

	
func make_invincible(time: float):
	begin_flicker()
	invincible = true
	await get_tree().create_timer(time).timeout
	invincible = false
	end_flicker()


func begin_flicker():
	$FlickerTimer.start()
	
func end_flicker():
	$FlickerTimer.stop()
	set_transparent(false)
	
func reset_hp():
	hp = max_hp
	
func toggle_transparency():
	set_transparent(not transparent)

func set_transparent(is_transparent: bool):
	transparent = is_transparent
	if transparent:
		$Legs.hide()
		$Body.hide()
	else:
		$Legs.show()
		$Body.show()


func _on_flicker_timer_timeout() -> void:
	toggle_transparency()

func toggle_detector_arrow(group: String):
	var obj_to_follow = find_closest_in_group(group,global_position)
	arrow_target = obj_to_follow
	$ArrowSprite.visible = not $ArrowSprite.visible 
	arrow_following = not arrow_following
	group_follow_type = group

func is_detector_arrow_activated() -> bool:
	return arrow_following

func find_closest_in_group(group_name: String, reference_position: Vector2):
	var closest_object = null
	var closest_distance = INF  # Start with a very large number
	
	# Iterate over all members of the group
	for member in get_tree().get_nodes_in_group(group_name):
		if member and member is Node2D:  # Ensure the member is valid and has a position
			var distance = reference_position.distance_to(member.global_position)
			if distance < closest_distance:
				closest_distance = distance
				closest_object = member
	return closest_object
