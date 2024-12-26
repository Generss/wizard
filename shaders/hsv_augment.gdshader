shader_type canvas_item;

// Uniform to adjust the hue
uniform float hue : hint_range(-1.0, 1.0);
uniform float sat : hint_range(-1.0, 1.0);
uniform bool active = false;
uniform bool transparent = false;

// Function to convert RGB to HSV
vec3 rgb_to_hsv(vec3 color) {
    float max_val = max(color.r, max(color.g, color.b));
    float min_val = min(color.r, min(color.g, color.b));
    float delta = max_val - min_val;

    float h = 0.0;
    if (delta != 0.0) {
        if (max_val == color.r) {
            h = mod((color.g - color.b) / delta, 6.0);
        } else if (max_val == color.g) {
            h = (color.b - color.r) / delta + 2.0;
        } else {
            h = (color.r - color.g) / delta + 4.0;
        }
        h /= 6.0; // Normalize to [0, 1]
    }

    float s = max_val == 0.0 ? 0.0 : delta / max_val;
    float v = max_val;

    return vec3(h, s, v);
}

// Function to convert HSV back to RGB
vec3 hsv_to_rgb(vec3 hsv) {
    float h = hsv.x * 6.0; // Scale hue to [0, 6]
    float s = hsv.y;
    float v = hsv.z;

    float c = v * s;
    float x = c * (1.0 - abs(mod(h, 2.0) - 1.0));
    float m = v - c;

    vec3 rgb;
    if (h < 1.0) {
        rgb = vec3(c, x, 0.0);
    } else if (h < 2.0) {
        rgb = vec3(x, c, 0.0);
    } else if (h < 3.0) {
        rgb = vec3(0.0, c, x);
    } else if (h < 4.0) {
        rgb = vec3(0.0, x, c);
    } else if (h < 5.0) {
        rgb = vec3(x, 0.0, c);
    } else {
        rgb = vec3(c, 0.0, x);
    }

    return rgb + m;
}

void fragment() {

    // Sample the original texture color
    vec4 tex_color = texture(TEXTURE, UV);

    // Convert the RGB color to HSV
    vec3 hsv = rgb_to_hsv(tex_color.rgb);

	if(transparent && tex_color.a > 0.1) {
		tex_color.a = 0.5;
	}

	if(active) {
    	// Adjust the hue while keeping saturation and value intact
    	hsv.x = mod(hue, 1.0); // Wrap hue within [0, 1]
		hsv.y = mod(sat, 1.0);
	}
    // Convert back to RGB
    vec3 rgb = hsv_to_rgb(hsv);

    // Output the modified color with the original alpha
    COLOR = vec4(rgb, tex_color.a);
}