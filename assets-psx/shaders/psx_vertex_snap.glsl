// ============================================================================
// PSX Vertex Snapping + Gouraud Lighting + Affine UV Warping (Three.js / WebGL)
// Universo Choco Fluvial: "La Paila del Atrato" & "Maestro Vichero del Malecon"
// ============================================================================

// --- VERTEX SHADER ---
#ifdef VERTEX_SHADER
uniform vec2 uSnapResolution;   // Ej: vec2(320.0, 240.0) o vec2(160.0, 120.0)
uniform float uJitterStrength;  // 0.0 (off) a 1.0 (PS1 puro)
uniform vec3 uLightDir;         // Direccion del fogon / sol de selva
uniform vec3 uAmbientColor;     // Color ambiental humedo del Atrato
uniform vec3 uLightColor;       // Color calido de leña / lampara del malecon
uniform float uAffineStrength;  // 0.0 (perspectiva correcta) a 1.0 (affine PS1)

varying vec2 vUv;
varying float vAffineW;
varying vec3 vVertexColor;
varying float vFogDepth;

void main() {
    vec4 viewPos = modelViewMatrix * vec4(position, 1.0);
    vec4 clipPos = projectionMatrix * viewPos;

    // 1. Vertex Snapping en coordenadas de pantalla (NDC cuantizado a rejilla PSX)
    vec2 grid = uSnapResolution * 0.5;
    vec4 snappedClip = clipPos;
    snappedClip.xyz = clipPos.xyz / clipPos.w;
    snappedClip.xy = floor(grid * snappedClip.xy) / grid;
    snappedClip.xyz *= clipPos.w;

    gl_Position = mix(clipPos, snappedClip, uJitterStrength);

    // 2. Iluminacion Gouraud por vertice (estilo PlayStation 1)
    vec3 worldNormal = normalize(mat3(modelMatrix) * normal);
    float ndotl = max(dot(worldNormal, normalize(uLightDir)), 0.0);
    // Cuantizamos la luz en 8 escalones para acentuar las facetas low-poly
    float steppedLight = floor(ndotl * 8.0) / 8.0;
    vVertexColor = uAmbientColor + uLightColor * steppedLight;

    // 3. Emulacion de mapeo afin de texturas (sin correccion de perspectiva)
    float wVal = mix(1.0, clipPos.w, uAffineStrength);
    vUv = uv * wVal;
    vAffineW = wVal;
    vFogDepth = -viewPos.z;
}
#endif

// --- FRAGMENT SHADER ---
#ifdef FRAGMENT_SHADER
uniform sampler2D uMap;
uniform vec3 uFogColor;         // Gris/verde bruma de aguacero en Quibdo (#1c2d27)
uniform float uFogNear;
uniform float uFogFar;
uniform float uHoneyGlaze;      // 0.0 a 1.0: brillo dorado cuando el Chontaduro tiene Miel
uniform float uCandelaGlow;     // 0.0 a 1.0: pulso rojo/ambar cuando sube la Candela

varying vec2 vUv;
varying float vAffineW;
varying vec3 vVertexColor;
varying float vFogDepth;

void main() {
    vec2 finalUv = vUv / max(vAffineW, 0.0001);
    vec4 texel = texture2D(uMap, fract(finalUv));

    vec3 lit = texel.rgb * vVertexColor;

    // Brillo de Miel de Monte y Candela de Paila
    lit += vec3(0.95, 0.65, 0.12) * uHoneyGlaze * 0.28;
    lit += vec3(0.95, 0.22, 0.08) * uCandelaGlow * 0.35;

    // Niebla de aguacero fluvial
    float fogFactor = smoothstep(uFogNear, uFogFar, vFogDepth);
    vec3 finalRgb = mix(lit, uFogColor, fogFactor);

    gl_FragColor = vec4(finalRgb, texel.a);
}
#endif
