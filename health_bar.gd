extends Sprite2D
var max_width: float = 98
var input_ratio: float = 1
const HEIGHT = 23

var init_position: Vector2 
var shaking: bool = false
var shake_intensity = 10.0  # Max offset in pixels
var noise_offset = Vector2(randf() * 100.0, randf() * 100.0)  # Random starting point for Perlin noise
var step: float = 0
var noise

func _ready() -> void:
	init_position = position
	noise = FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_PERLIN  # Use Perlin noise
	noise.frequency = 2.0  # Controls how "fast" the noise changes

func _process(delta: float) -> void:
	var new_width: float = max_width * input_ratio
	$HealthMeter._set_size(Vector2(new_width,HEIGHT))
	shake(delta)

func begin_shake():
	shaking = true
	await get_tree().create_timer(0.2).timeout
	position = init_position
	shaking = false

func shake(delta: float):
	
	if not shaking: return
	
	step += delta
	var offset_x = noise.get_noise_2d(noise_offset.x, step) * shake_intensity
	var offset_y = noise.get_noise_2d(noise_offset.y, step) * shake_intensity

		# Apply the offset to the node's position
	position = init_position + Vector2(offset_x, offset_y)

		# Increment the noise offset to animate the shake
	noise_offset += Vector2(0.1, 0.1)
