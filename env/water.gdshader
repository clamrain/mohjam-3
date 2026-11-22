shader_type spatial;

uniform vec3 water_albedo: source_color;
uniform sampler2D water_normal;
uniform sampler2D water_texture;
uniform float brightness;
uniform float caustic_intensity;
uniform sampler2D screen_texture: hint_screen_texture, repeat_disable;

uniform float sig_contrast: hint_range(0.0,100.0) = 5.0;
uniform float sig_brightness: hint_range(0.0,10.0) = 0.0;

uniform float uv_scale = 1.0;

float sigmoid(float x) {
	return 1.0 / (1.0 + exp(-sig_contrast * (x-sig_brightness)));
}

float displace(vec2 _uv, float _time) {
	return texture(water_texture, vec2(_uv.x + sin(_time), _uv.y + cos(_time))).r * caustic_intensity;
}

void fragment() {

	float _time = TIME/4.0;
	vec2 _uv = UV*uv_scale;
	float noise = 0.0;
	noise += displace(_uv, _time/6.0);
	noise += displace(_uv, _time/5.0+PI/2.0);
	noise += displace(_uv, _time/7.0+PI);
	noise += displace(_uv, _time/3.0+PI*1.5);
	noise = sigmoid(noise);

	//noise = pow(noise, caustic_intensity);
	ALBEDO = water_albedo/2.0 + noise*water_albedo*brightness;
}