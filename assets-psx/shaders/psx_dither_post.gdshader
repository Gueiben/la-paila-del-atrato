// ============================================================================
// Godot 4.x CanvasItem Fullscreen Post-Process Shader:
// Bayer 4x4 Dithering + RGB555 15-Bit Color Depth + Aguacero Chocoano
// ============================================================================
shader_type canvas_item;

uniform sampler2D screen_tex : hint_screen_texture, filter_nearest;
uniform vec2 target_resolution = vec2(320.0, 240.0);
uniform float color_depth : hint_range(8.0, 64.0) = 31.0;
uniform float dither_strength : hint_range(0.0, 1.0) = 1.0;
uniform float rain_intensity : hint_range(0.0, 1.0) = 0.0;

const mat4 BAYER_MATRIX = mat4(
    vec4( 0.0/16.0,  8.0/16.0,  2.0/16.0, 10.0/16.0),
    vec4(12.0/16.0,  4.0/16.0, 14.0/16.0,  6.0/16.0),
    vec4( 3.0/16.0, 11.0/16.0,  1.0/16.0,  9.0/16.0),
    vec4(15.0/16.0,  7.0/16.0, 13.0/16.0,  5.0/16.0)
);

void fragment() {
    vec2 pix = floor(SCREEN_UV * target_resolution);
    vec2 uv_quant = (pix + 0.5) / target_resolution;
    vec3 col = texture(screen_tex, uv_quant).rgb;

    if (rain_intensity > 0.01) {
        vec2 r_uv = uv_quant * vec2(30.0, 7.0) + vec2(TIME * 1.3, TIME * 9.0);
        float drop = step(0.965, fract(sin(dot(floor(r_uv), vec2(12.9898, 78.233))) * 43758.5453));
        col = mix(col, vec3(0.68, 0.82, 0.88), drop * rain_intensity * 0.45);
    }

    int x = int(mod(pix.x, 4.0));
    int y = int(mod(pix.y, 4.0));
    float bayer = BAYER_MATRIX[y][x] - 0.5;
    vec3 dithered = col + bayer * (1.0 / color_depth) * dither_strength;
    vec3 final_col = floor(dithered * color_depth + 0.5) / color_depth;

    COLOR = vec4(clamp(final_col, 0.0, 1.0), 1.0);
}
