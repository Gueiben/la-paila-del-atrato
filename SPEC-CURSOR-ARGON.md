# Especificacion Tecnica de Produccion: "La Paila del Atrato: Candela en Quibdo 3D" (Action-Roguelike 3D Chocoano)

**Preparado para:** Andres Gallego
**Motor / Stack para PC (Steam) y Web:** Godot Engine 4.3 (`godot-project/` con `CharacterBody3D`, modelos `.glb` esculpidos con normales suaves y shader `.gdshader`) + Motor 3D Z-Buffer Per-Pixel con Perspective-Correct UV Mapping e Iluminacion Gouraud/Phong en `index.html`.

---

## 1. Arquitectura de Gameplay 3D en el Malecon y las 5 Zonas de Quibdo

El juego es un **Horde-Survivor / Action-Roguelike 3D en Tercera Persona** con modelos 3D organicos esculpidos, sombreado Gouraud por vertice, brillo especular y texturas UV pintadas a mano, ambientado en las 5 zonas emblematicas de Quibdo (con la **Catedral de San Francisco de Asis** al norte, el **Malecon del Rio Atrato** al oeste, **Alameda Reyes** en el centro, el **Sendero de Arcilla del Tutunendo** al este y los **Esteros y Aserrio del Atrato** al sur).

### A. Controlador Fisico 3D del Jugador (Salto + Barrida Chocoana)
- **Movimiento Base (`WASD`):** Velocidad `8.2 m/s` relativa al angulo `camYaw` de la camara en tercera persona, sin congelar nunca el movimiento al subir de nivel.
- **Salto Acrobatico (`Espacio`):** Impulso vertical `vy = 8.2 m/s` con conservacion de momento horizontal.
- **Barrida Chocoana (`Shift`):** Sube la velocidad a `12.2 m/s` y aplica empuje fisico (**Pataconazo!**) a cualquier enemigo con el que colisiones al deslizarte.

### B. Sistema de Empuje Fisico ("Pataconazo!") y Hordas 3D
Cada impacto de arma aplica tanto dano (`dmg * candelaMult`) como un vector tridimensional de empuje (`impulse = dir * knockbackForce * knockbackMult` + `vy = 3.5..6.8 m/s`), lanzando fisicamente a los enemigos por los aires con amortiguacion exponencial y textos flotantes 3D.

---

## 2. Personajes Chocoanos Esculpidos con Silueta Propia

1. **Janfry ("Camino Como Hombre"):** Nino chocoano con camiseta deportiva amarilla/roja de la seleccion, pantaloneta azul, corte afro bajito con linea marcada (sin sombrero), tenis blancos y sonrisa grande.
2. **Dona Cruz la Chontadurera:** Sabedora con vestido tradicional chocoano fucsia/turquesa/amarillo, turbante afro multicolor en la cabeza y batea redonda de madera tallada llena de chontaduros naranjas brillantes con miel.
3. **Tostao / Flow Quibdoseno:** Cantante con camisa abierta estampada del Pacifico, gafas de sol negras con marco dorado, gorra plana hacia atras, cadena dorada y microfono en mano.
4. **Mototaxista de la Yesquita:** Chaqueta impermeable azul/negra, casco deportivo, jean y su moto **Yamaha DT / BWS** modelada en 3D con llantas redondas, guardabarros alto, farola, manubrio y sillin.
5. **Jonyer ("Obvio Bobis"):** Camiseta urbana morada/dorada de San Pacho, bermuda, afro alto estilizado y gafas oscuras.
6. **El Rey del Bunde de San Pacho:** Traje festivo con capa multicolor de San Pacho, sombrero chocoano adornado con cintas y tambora/requinto de chirimia colgado al pecho.
7. **El Mohan del Baudo (Jefe):** Criatura mitica grande con melena larga de musgo de rio, ojos brillantes ambarinos, torso musculoso oscuro y baston de guadua encantada.

---

## 3. Catalogo de Armas Automaticas 3D y Altares del Choco

```json
{
  "weapons": [
    {
      "id": "chontaduro_rafaga",
      "name": "Rafaga de Chontaduro con Miel y Sal",
      "baseDamage": 25,
      "cooldown": 0.38,
      "knockback": 4.5,
      "behavior": "Dispara chontaduros ovoides esculpidos en 3D al enemigo mas cercano."
    },
    {
      "id": "popocho_pataconazo",
      "name": "Mazo Pataconazo de Popocho",
      "baseDamage": 48,
      "cooldown": 3.2,
      "radius": 7.5,
      "knockback": 11.0,
      "behavior": "Onda expansiva radial que sacude el suelo y manda a volar por los aires a toda la horda cercana."
    },
    {
      "id": "borojo_orbitals",
      "name": "Orbes Orbitales de Borojo Potencia",
      "baseDamage": 24,
      "orbitRadius": 2.75,
      "angularSpeed": 4.2,
      "behavior": "Frutas 3D de Borojo que giran alrededor del jugador golpeando enemigos y protegiendo el paso."
    },
    {
      "id": "viche_arrechon_bombs",
      "name": "Bombardeo de Botellas Curadas (Viche y Pipilongo)",
      "baseDamage": 54,
      "cooldown": 2.2,
      "behavior": "Lanza botellas torneadas en arco parabolico que estallan en fuego dorado de Candela."
    }
  ],
  "shrines": [
    { "id": "altar_malecon", "name": "Altar del Malecon", "effect": "Otorga Bendicion de San Pacho inmediata" },
    { "id": "altar_san_pacho", "name": "Altar de San Pacho", "effect": "Sube de nivel un arma sin detener la carrera" },
    { "id": "totem_tutunendo", "name": "Totem del Tutunendo", "effect": "Cura +30 HP y sube +25% el Multiplicador de Candela" }
  ]
}
```
