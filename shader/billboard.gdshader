// NOTE: Shader automatically converted from Godot Engine 4.5.1.stable's StandardMaterial3D.

shader_type spatial;

render_mode unshaded, cull_disabled;

uniform sampler2D texture_albedo : source_color, filter_linear_mipmap, repeat_enable;

uniform vec3 uv1_scale;
uniform vec3 uv1_offset;

void vertex() {
	UV = UV * uv1_scale.xy + uv1_offset.xy;
	
	vec3 cam_origin = INV_VIEW_MATRIX[3].xyz;
	vec3 spr_origin = MODEL_MATRIX[3].xyz;
	
	vec3 basis_z = normalize(cam_origin - spr_origin);
	vec3 basis_y = MODEL_MATRIX[1].xyz;
	vec3 basis_x = normalize(cross(basis_y, basis_z));
	
	mat4 new_mat = MODEL_MATRIX;
	new_mat[0].xyz = basis_x;
	new_mat[2].xyz = basis_z;
	
	MODELVIEW_MATRIX = VIEW_MATRIX * new_mat;
}

void fragment() {
	vec2 base_uv = UV;

	vec4 albedo_tex = texture(texture_albedo, base_uv);
	ALBEDO = albedo_tex.rgb;
	ALPHA = albedo_tex.a;
}
