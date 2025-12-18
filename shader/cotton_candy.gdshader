shader_type spatial;
render_mode unshaded, depth_draw_opaque;

uniform vec3 movement_dir = vec3(0.0);
uniform float height_scale = 0.25;
uniform float wave_speed = 0.15;
uniform float global_alpha = 0.95;
uniform float squash_strength = 0.15;


uniform vec4 color_low : source_color = vec4(0.9, 0.8, 0.9, 1.0);
uniform vec4 color_high : source_color = vec4(1.0, 0.9, 1.0, 1.0);

uniform bool enable_fresnel = true;
uniform float fresnel_power = 2.5;
uniform float fresnel_alpha_strength = 0.15;

uniform vec3 light_dir = vec3(0.5, -0.5, 0.0);

varying float softness;

float hash(vec2 p){
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

float noise(vec2 p){
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);

    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));

    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

float fbm(vec2 p, float t){
    float v = 0.0;
    float a = 0.5;

    vec2 drift = vec2(movement_dir.x, movement_dir.z) * t * wave_speed;

    for(int i = 0; i < 5; i++){
        v += noise(p + drift) * a;
        p *= 2.0;
        drift *= 2.0;
        a *= 0.5;
    }
    return v;
}

float directional_wave(vec3 pos, float t){
    vec3 dir = movement_dir;
    float len = length(dir);
    if (len > 0.0001) {
        dir /= len;
    } else {
        return 0.0;
    }

    float phase = dot(pos, dir) + t * wave_speed;
    return sin(phase);
}


float fresnel_term(vec3 n, vec3 v, float p){
    return pow(1.0 - clamp(dot(n, v), 0.0, 1.0), p);
}

void vertex(){
    vec3 original_pos = VERTEX;

    vec3 dir = movement_dir;
    float len = length(dir);
    if (len > 0.0001) {
        dir /= len;
    } else {
        dir = vec3(0.0);
    }

    float strength = clamp(length(movement_dir) * squash_strength, 0.0, squash_strength);

    vec3 parallel = dir * dot(original_pos, dir);
    vec3 perpendicular = original_pos - parallel;

    vec3 deformed =
        parallel * (1.0 - strength) +
        perpendicular * (1.0 + strength);

    VERTEX = deformed;

    float n = noise(original_pos.xz * 1.5);
    softness = clamp(n, 0.0, 1.0);
}

void fragment(){
    vec3 n = normalize(NORMAL);
    vec3 v = normalize(VIEW);
    vec3 l = normalize(-light_dir);

    float ndotl = max(dot(n, l), 0.0);
    float fres = enable_fresnel ? fresnel_term(n, v, fresnel_power) : 0.0;

    vec3 base_col = mix(color_low.rgb, color_high.rgb, softness);
    vec3 lit_col = base_col * (0.65 + 0.35 * ndotl);
    vec3 final_col = mix(lit_col, vec3(1.0), fres * 0.4);

    ALBEDO = final_col;
    ALPHA = global_alpha - fres * fresnel_alpha_strength;
}
