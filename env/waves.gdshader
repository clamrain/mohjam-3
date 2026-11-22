shader_type spatial;

void vertex() {
	VERTEX = vec3(
		VERTEX.x,
		VERTEX.y,
		VERTEX.z+2.0
	);
}

void fragment() {
	ALPHA = 0.0;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
