# La Paila del Atrato

Roguelike chocoano de sinergias culinarias y construccion de motor (`Sustancia x Candela`) en estetica 3D Low-Poly PSX, inspirado en los rios Atrato y San Juan (Choco, Colombia) para PC en Steam.

## Concepto y Loop Jugable
Sirve manos de hasta 5 ingredientes tipicos del Choco fluvial en tu paila de cobre mientras tus **Reliquias de Sabedora y Chirimia** disparan combos de izquierda a derecha al ritmo de clarinete, bombardino, tambora y marimba de chonta:
- **Chontaduro de Boraudo:** Ranuras propias de aderezo para **Sal de Monte** (`+Sustancia`) y **Miel de Abejas** (`x1.5 Candela` + escalado permanente por toda la partida).
- **Popocho del San Juan:** Madura al calor del fogon entre rondas (**Verde en Patacon** duplica la base del vecino izquierdo, **Pinton** equilibra y **Maduro en Tajada** absorbe la miel como `x2.0 Candela`).
- **Borojo del San Juan:** Motor de *retriggers* que reactiva los ingredientes vecinos.
- **Botellas Curadas (Viche Curado y Arrechon con Pipilongo):** Multiplicadores explosivos (`x2.0` y `x3.0 Candela`) que suben el medidor termico de la paila.
- **Queso en Hoja de Bijao:** Enfriamiento de paila y escudo contra el modificador climatico *Aguacero de Quibdo*.

## Estructura del Repositorio
- `index.html`: Prototipo interactivo jugable completo (motor `Sustancia x Candela`, postas del rio Atrato, Champa-Tienda y sintetizador Web Audio API).
- `SPEC-CURSOR-ARGON.md`: Arquitectura del pipeline de 5 fases, esquema JSON de datos y prompts de implementacion para Cursor y Gemini Argon.
- `assets-psx/textures/`: las 8 texturas `64x64` en 15-bit RGB555 con dithering Bayer 4x4 exclusivas de *La Paila del Atrato*.
- `assets-psx/models/`: Modelos 3D Low-Poly (`.obj` y `.mtl`) de bajo conteo de poligonos.
- `assets-psx/shaders/`: Shaders GLSL (Three.js/WebGL) y `.gdshader` (Godot 4) con vertex snapping, iluminacion Gouraud y post-proceso de dithering PSX.
