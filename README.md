# La Paila del Atrato: Candela en Quibdo 3D

Survivor / Action-Roguelike 3D chocoano en tercera persona ambientado en las 5 zonas de Quibdo (Malecon del Rio Atrato, Plaza de la Catedral de San Francisco de Asis, Alameda Reyes, Sendero del Tutunendo y Esteros del Sur), con proyecto nativo **Godot Engine 4.3** (`godot-project/`) y version web interactiva con **Rasterizador 3D Z-Buffer Per-Pixel, Perspective-Correct UV Mapping y Gouraud Smooth Shading** (`index.html`).

## Caracteristicas Principales
- **Motor 3D Z-Buffer Per-Pixel + Gouraud Smooth Shading:** Renderizado organico sin costuras ni distorsion afin, con iluminacion suave por vertice y brillo especular.
- **Elenco de Personajes Chocoanos con Silueta Propia:** Juega y encuentra a **Janfry** (camiseta deportiva, corte afro con linea, sin sombrero), **Dona Cruz la Chontadurera** (turbante afro colorido y batea tallada llena de chontaduros), **Tostao Flow Quibdoseno** (camisa abierta del Pacifico, gafas doradas, gorra hacia atras y microfono), **Mototaxista de la Yesquita** (con su moto **Yamaha DT / BWS** modelada en 3D), **Jonyer ("Obvio Bobis")**, **El Rey del Bunde de San Pacho** (capa festiva y tambora al pecho) y el jefe **El Mohan del Baudo**.
- **Arquitectura Emblematica de Quibdo:** Catedral de San Francisco de Asis con sus dos torres campanario, relojes circulares, arcos profundos, roseton colorido y cupula central; casas de madera de Alameda Reyes, Chiva rumbera, taxis y champas en el Rio Atrato.
- **Proyecto Nativo Godot Engine 4.3 (`godot-project/`):** Escena principal `scenes/main.tscn`, controlador `scripts/main.gd`, shader `shaders/psx_retro_lit.gdshader`, modelos `.glb`/`.obj` esculpidos en `assets/models/` y texturas UV pintadas en `assets/textures/`.

## Estructura del Repositorio
- `index.html`: Juego 3D completo listo para abrir en cualquier navegador o desde `JUGAR_WINDOWS.bat`.
- `JUGAR_WINDOWS.bat`: Lanzador directo para Windows.
- `godot-project/`: Proyecto completo de Godot Engine 4.3 verificado en modo headless.
- `SPEC-CURSOR-ARGON.md`: Especificacion tecnica de arquitectura 3D, personajes, armas y fisicas.
- `assets-psx/`: Modelos `.glb`/`.obj` esculpidos y texturas UV `.png`.
