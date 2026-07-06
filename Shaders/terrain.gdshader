shader_type spatial;

uniform sampler2D heightmap;
uniform float terrain_height;

void vertex() {
}

void fragment() {
	ALBEDO.rgb = vec3(1.0 ,1.0, 1.0);
}