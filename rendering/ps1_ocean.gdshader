// PS1 shader by Ben Forster for Godot 4.x
// https://github.com/ben-forster/godot-ps1/blob/main/ps1_shader.shader

// Use vertex lighting and skip vertext transform
// Use specular Schlick GGX and diffuse Lambert wrapping
shader_type spatial;
render_mode vertex_lighting, skip_vertex_transform, specular_schlick_ggx, diffuse_lambert_wrap;
 
// Textures
uniform sampler2D albedo_texture: hint_default_black;
uniform sampler2D specular_texture: hint_default_black;
uniform sampler2D emission_texture: hint_default_black;

// Amount to jitter vertices (0 = no jitter, 1 = maximum jitter)
uniform float vertex_jitter_amount: hint_range(0.0, 1.0) = 0.5;

// Whether or not to jitter the z coordinate
uniform bool jitter_z_coordinate = true;

// Whether or not to jitter vertices based on depth
uniform bool jitter_depth_independent = true;

// Whether or not to use affine texture mapping
uniform bool affine_texture_mapping = true;

// Alpha scissor threshold (0 = fully transparent, 1 = fully opaque)
uniform float alpha_scissor_threshold: hint_range(0.0, 1.0) = 1.0;

// UV scales for scaling the texture coordinates
uniform float uv_scale_x: hint_range(0.0, 1024.0) = 1.0;
uniform float uv_scale_y: hint_range(0.0, 1024.0) = 1.0;

uniform vec2 ocean_wave_velocity = vec2(0.0);
uniform float ocean_wave_height = 1.0;
uniform float ocean_wave_frequency = 1.0;

uniform sampler3D noise_texture;

uniform float time;

void vertex() {
	vec3 p = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	vec2 _v = normalize(ocean_wave_velocity) * p.xz * ocean_wave_frequency;
	float noise = texture(noise_texture, vec3(p.x/64.0,time/(64.0*1000.0*2.0),p.z/64.0)).r;
	VERTEX.y += sin(_v.x + _v.y + (time/1000.0)*length(ocean_wave_velocity)) * ocean_wave_height;
	VERTEX.y += (noise-0.5)*2.0;
	
	// Transform normal vector
    NORMAL = normalize((MODELVIEW_MATRIX * vec4(NORMAL, 0.0)).xyz);

	// Transform vertex position
	VERTEX = (MODELVIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
 
	// Save original z coordiante
	float z_orig = VERTEX.z;

	// Claculate amount to jitter vertices
	float jitter_amount = (1.0 - vertex_jitter_amount) * min(VIEWPORT_SIZE.x, VIEWPORT_SIZE.y) / 2.0;
 
	// Jitter vertices based on depth
	if (jitter_depth_independent) {
		float w = (PROJECTION_MATRIX * vec4(VERTEX, 1.0)).w;
		VERTEX = round(VERTEX / w * jitter_amount) / jitter_amount * w;
	} else {
		VERTEX = round(VERTEX * jitter_amount) / jitter_amount;
	}
 
     // Revert z coordinate if not using z jittering
	if (!jitter_z_coordinate) {
		VERTEX.z = z_orig;
	}
 
	// Apply affine texture mapping
	if (affine_texture_mapping) {
		UV *= VERTEX.z;
	}
}
 
void fragment() {
	// Calculate UV coordinates
	vec2 uv = UV * vec2(uv_scale_x, uv_scale_y);

	// Revert affine texture mapping
	if (affine_texture_mapping) {
		uv /= VERTEX.z;
	}
 
	// Apply textures
	ALBEDO = texture(albedo_texture, uv).rgb;
	ALPHA = texture(albedo_texture, uv).a;
	ALPHA_SCISSOR_THRESHOLD = alpha_scissor_threshold;
	EMISSION = texture(emission_texture, uv).rgb;
	SPECULAR = texture(specular_texture, uv).r;
}