// ============================================================================
// PSX Fullscreen Post-Process (Three.js / WebGL):
// Bayer 4x4 Ordered Dithering + 15-bit RGB555 Color Quantization + Rain Streaks
// ============================================================================
uniform sampler2D tDiffuse;
uniform vec2 uResolution;       // Ej: vec2(320.0, 240.0)
uniform float uColorDepth;      // 31.0 para 5-bit por canal (15-bit RGB555 de PS1)
uniform float uDitherStrength;  // 0.0 a 1.0
uniform float uRainIntensity;   // 0.0 (seco) a 1.0 (Aguacero de Quibdo)
uniform float uTime;

varying vec2 vUv;

float bayer4x4(vec2 pixelCoord) {
    int x = int(mod(pixelCoord.x, 4.0));
    int y = int(mod(pixelCoord.y, 4.0));
    int index = x + y * 4;
    if (index == 0) return 0.0 / 16.0;
    if (index == 1) return 8.0 / 16.0;
    if (index == 2) return 2.0 / 16.0;
    if (index == 3) return 10.0 / 16.0;
    if (index == 4) return 12.0 / 16.0;
    if (index == 5) return 4.0 / 16.0;
    if (index == 6) return 14.0 / 16.0;
    if (index == 7) return 6.0 / 16.0;
    if (index == 8) return 3.0 / 16.0;
    if (index == 9) return 11.0 / 16.0;
    if (index == 10) return 1.0 / 16.0;
    if (index == 11) return 9.0 / 16.0;
    if (index == 12) return 15.0 / 16.0;
    if (index == 13) return 7.0 / 16.0;
    if (index == 14) return 13.0 / 16.0;
    return 5.0 / 16.0;
}

void main() {
    // 1. Pixelacion a la resolucion interna del framebuffer PSX
    vec2 pixelCoord = floor(vUv * uResolution);
    vec2 snappedUv = (pixelCoord + 0.5) / uResolution;
    vec3 color = texture2D(tDiffuse, snappedUv).rgb;

    // 2. Cortina de lluvia diagonal de selva pluvial (Choco)
    if (uRainIntensity > 0.01) {
        vec2 rainUv = snappedUv * vec2(28.0, 6.0) + vec2(uTime * 1.4, uTime * 9.5);
        float streak = step(0.965, fract(sin(dot(floor(rainUv), vec2(12.9898, 78.233))) * 43758.5453));
        color = mix(color, vec3(0.68, 0.82, 0.88), streak * uRainIntensity * 0.45);
    }

    // 3. Dithering ordenado Bayer 4x4 + Cuantizacion RGB555 (32 niveles por canal)
    float dither = (bayer4x4(pixelCoord) - 0.5) * (1.0 / uColorDepth) * uDitherStrength;
    vec3 quantized = floor((color + dither) * uColorDepth + 0.5) / uColorDepth;

    gl_FragColor = vec4(clamp(quantized, 0.0, 1.0), 1.0);
}
