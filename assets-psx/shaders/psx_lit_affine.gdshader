// ============================================================================
// Godot 4.x Spatial Shader: PSX Vertex Snapping + Affine UV + Gouraud Lighting
// Universo Choco Fluvial: "La Paila del Atrato" & "Maestro Vichero del Malecon"
// ============================================================================
shader_type spatial;
render_mode vertex_lighting, skip_vertex_transform, shadows_disabled, specular_disabled;

uniform sampler2D albedo_tex : source_color, filter_nearest, repeat_enable;
uniform vec2 snap_resolution = vec2(320.0, 240.0);
uniform float jitter_strength : hint_range(0.0, 1.0) = 0.85;
uniform float affine_strength : hint_range(0.0, 1.0) = 0.65;
uniform float honey_glaze : hint_range(0.0, 1.0) = 0.0;
uniform float candela_glow : hint_range(0.0, 1.0) = 0.0;

varying vec2 v_uv;
varying float v_w;

void vertex() {
    vec4 view_pos = MODELVIEW_MATRIX * vec4(VERTEX, 1.0);
    vec4 clip_pos = PROJECTION_MATRIX * view_pos;

    vec4 snapped = clip_pos;
    snapped.xyz = clip_pos.xyz / clip_pos.w;
    vec2 grid = snap_resolution * 0.5;
    snapped.xy = floor(grid * snapped.xy) / grid;
    snapped.xyz *= clip_pos.w;

    POSITION = mix(clip_pos, snapped, jitter_strength);

    NORMAL = normalize((MODELVIEW_MATRIX * vec4(NORMAL, 0.0)).xyz);
    v_w = mix(1.0, clip_pos.w, affine_strength);
    v_uv = UV * v_w;
}

void fragment() {
    vec2 uv_affine = v_uv / max(v_w, 0.0001);
    vec4 tex = texture(albedo_tex, uv_affine);
    vec3 col = tex.rgb;
    col += vec3(0.95, 0.65, 0.12) * honey_glaze * 0.25;
    col += vec3(0.95, 0.22, 0.08) * candela_glow * 0.35;
    ALBEDO = col;
}
