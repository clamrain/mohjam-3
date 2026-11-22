shader_type canvas_item;

uniform vec3 water_albedo: source_color;
uniform sampler2D water_texture;
uniform sampler2D water_texture_normal;
uniform sampler2D screen_texture: hint_screen_texture, repeat_disable;

uniform float animation_speed = 0.0;
uniform float animation_freq = 0.0;
uniform float animation_ampl = 0.0;
uniform int resolution: hint_range(1, 256) = 64;
uniform float spikiness: hint_range(0.0,16.0) = 1.0;

uniform float sig_contrast: hint_range(0.0,100.0) = 5.0;
uniform float sig_brightness: hint_range(0.0,1.0) = 0.0;

uniform float uv_scale = 1.0;

vec3 sigmoid(vec3 x) {
	return 1.0 / (1.0 + exp(-sig_contrast * (x-sig_brightness)));
}

float snap(float f, float s) {
	return floor(f / s) * s;
}

void fragment() {
	vec2 _uv = UV * uv_scale;
	
	//_uv = vec2(snap(_uv.x, 1.0/float(resolution)), snap(_uv.y, 1.0/float(resolution)));
	_uv.x += sin(TIME * animation_speed + (_uv.x + _uv.y) * animation_freq) * animation_ampl;
	_uv.y += cos(TIME * animation_speed + (_uv.x + _uv.y) * animation_freq) * animation_ampl;
	
	
	vec3 tex = pow(texture(water_texture, _uv).rgb, vec3(spikiness));
	vec3 tex_normal = pow(texture(water_texture_normal, _uv).rgb, vec3(spikiness));
	
	vec3 albedo = water_albedo;
	albedo += tex;
	albedo = sigmoid(albedo);
	
	NORMAL_MAP = tex_normal;
	//ROUGHNESS = 0.2;
	COLOR.rgb = albedo;
	//ALBEDO = vec3(mod(_uv.x, 1.0), mod(_uv.y, 1.0), 0.0);
}