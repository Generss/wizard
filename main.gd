extends Node

@export var wall_scene: PackedScene
@export var turret_scene: PackedScene
@export var portal_scene: PackedScene
var portal
var base_width = 120
var base_height = 500
var levels: int = 1
var corridor_width = 0
var corridor_height = 0
var turrets_remaining: bool
var playing = true
const tile_size = 128.0
var activated_arrow = false 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$VictoryScreen.hide()
	$MainCamera/LevelLabel.hide()
	$Player.hide()
	playing = false
	$MainCamera.set_enabled(false)
	$DefeatScreen.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if playing: 
		$MainCamera.position = $Player.position
		$MainCamera/HealthBar.input_ratio = float($Player.hp) / float($Player.max_hp)
		#if not activated_arrow:
			#print(get_tree().get_nodes_in_group("turret").size())
			#if get_tree().get_nodes_in_group("turret").size() < 3:
				#$Player.toggle_detector_arrow("turret")
				#activated_arrow = true


func level_start() -> void:
	play_theme()
	build_corridor()
	player_setup()
	portal_setup()
	build_turrets()
	update_level_label()
	activated_arrow = false


func play_theme():
	if not $level_theme.is_playing():
		$level_theme.play()


func portal_setup():
	portal.position = Vector2(corridor_width/2 - 60, corridor_height - 120)
	if(levels == 5):
		portal.activate_shader(true)
	else:
		portal.activate_shader(false)
	
	portal.make_transparent()


func player_setup():
		$Player.make_invincible(2)
		$Player.position = Vector2(corridor_width/2 - 60,0)


func build_corridor():
	var scale_factor = pow(1.5, levels - 1)

	# Calculate scaled dimensions
	var raw_width = base_width * scale_factor	
	var raw_height = base_height * scale_factor
	
	# Round up to the nearest multiple of tile_size
	corridor_width = tile_size * ceil(raw_width / tile_size)
	corridor_height = tile_size * ceil(raw_height / tile_size)

	# Calculate how many tiles needed horizontally and vertically
	var horizontal_count = int(ceil(corridor_width / tile_size))
	var vertical_count = int(ceil(corridor_height / tile_size))

	# Place top row of walls (above the corridor)
	for x in range(horizontal_count + 2):
		var wall_top = wall_scene.instantiate()
		wall_top.position = Vector2(x * tile_size - tile_size, -tile_size)
		add_child(wall_top)

	# Place bottom row of walls (below the corridor)
	for x in range(horizontal_count + 2):
		var wall_bottom = wall_scene.instantiate()
		wall_bottom.position = Vector2(x * tile_size - tile_size, corridor_height)
		add_child(wall_bottom)

	# Place left column of walls (to the left of the corridor)
	for y in range(vertical_count):
		var wall_left = wall_scene.instantiate()
		wall_left.position = Vector2(-tile_size, y * tile_size)
		add_child(wall_left)

	# Place right column of walls (to the right of the corridor)
	for y in range(vertical_count):
		var wall_right = wall_scene.instantiate()
		wall_right.position = Vector2(corridor_width, y * tile_size)
		add_child(wall_right)


func build_turrets():
	var number_of_turrets: int = floor(pow(1.5,levels - 1) * 5)
	var spawn_box: Rect2 = Rect2(0,0,corridor_width - tile_size,corridor_height - tile_size * 2)
	var positions = []
	for i in range(number_of_turrets):
		var tries = 0
		var new_pos
		while tries < 1000:
			new_pos = Vector2(randf_range(0.0,float(spawn_box.size.x)),randf_range(0,spawn_box.size.y))
			var overlap := false 
			for pos in positions:
				if pos.distance_to(new_pos) < 64:
					overlap = true
					break
			if not overlap:
				positions.append(new_pos)
				break
			tries += 1
	for pos in positions:
		var new_turret = turret_scene.instantiate()
		new_turret.position = pos
		new_turret.target = $Player
		add_child(new_turret)
		new_turret.connect("dead", _on_turret_dead)
	
	turrets_remaining = true


func cleanup_level() -> void:
	get_tree().call_group("cleanable", "queue_free")


func next_level() -> void:
	if levels == 5 and (not turrets_remaining):
		deactivate_game()
		$VictoryScreen.show()
		return
	
	if not turrets_remaining:
		levels += 1
		cleanup_level()
		level_start()


func update_level_label():
	$MainCamera/LevelLabel.text = "level " + str(levels)


func deactivate_game():
	$level_theme.stop()
	$MainCamera/LevelLabel.hide()
	$MainCamera/HealthBar.hide()
	$Player.hide()
	playing = false
	$MainCamera.set_enabled(false)
	cleanup_level()


func handle_player_arrow() -> void:
	if get_tree().get_nodes_in_group("turret").size() < 3:
		if not $Player.is_detector_arrow_activated():
			$Player.toggle_detector_arrow("turret")

func _on_turret_dead():
	if(get_tree().get_nodes_in_group("turret").size() - 1 <= 0):
		turrets_remaining = false
		portal.make_opaque()
	else:
		handle_player_arrow()


func _on_player_dead() -> void:
	deactivate_game()
	$DefeatScreen.show("N/A")


func activate_game(level_start: int):
	levels = level_start
	if !portal:
		portal = portal_scene.instantiate()
		add_child(portal)
		portal.connect("portal_entered", next_level)
	$MainCamera/LevelLabel.show()
	$MainCamera/HealthBar.show()
	$Player.show()
	$Player.reset_hp()
	playing = true;
	$MainCamera.set_enabled(true)
	level_start()


func _on_defeat_screen_restart() -> void:
	activate_game(1)
	$DefeatScreen.hide()


func _on_title_screen_game_started() -> void:
	activate_game(1)
	$TitleScreen.hide()


func _on_player_damage_taken() -> void:
	$MainCamera/HealthBar.begin_shake()


func _on_victory_screen_victory_finished() -> void:
	$VictoryScreen.hide()
	$TitleScreen.show()
