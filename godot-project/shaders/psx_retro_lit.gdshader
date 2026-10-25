shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_lambert, specular_schlick_ggx;

uniform sampler2D albedo_tex : source_color, filter_nearest, repeat_enable;
uniform vec4 tint_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float snap_resolution : hint_range(64.0, 512.0) = 240.0;
uniform float affine_weight : hint_range(0.0, 1.0) = 0.25;
uniform vec3 sunset_fog_color : source_color = vec3(0.91, 0.48, 0.29);
uniform float fog_start = 28.0;
uniform float fog_end = 68.0;

varying float v_cam_dist;

void vertex() {
    vec4 view_pos = MODELVIEW_MATRIX * vec4(VERTEX, 1.0);
    v_cam_dist = length(view_pos.xyz);
    vec4 clip_pos = PROJECTION_MATRIX * view_pos;
    // Subtle retro PSX / Crash Bandicoot vertex snapping without distorting organic silhouettes
    vec2 grid = vec2(snap_resolution * 1.777, snap_resolution);
    clip_pos.xy = floor(clip_pos.xy / clip_pos.w * grid + 0.5) / grid * clip_pos.w;
    POSITION = clip_pos;
}

void fragment() {
    vec4 tex = texture(albedo_tex, UV) * tint_color;
    float fog_factor = clamp((v_cam_dist - fog_start) / max(1.0, (fog_end - fog_start)), 0.0, 0.65);
    ALBEDO = mix(tex.rgb, sunset_fog_color, fog_factor);
    ROUGHNESS = 0.78;
    METALLIC = 0.08;
}
