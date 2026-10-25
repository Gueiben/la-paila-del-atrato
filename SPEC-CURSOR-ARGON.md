# Especificacion Tecnica de Produccion: "La Paila del Atrato" (Roguelike de Sinergias Chocoano)

**Preparado para:** Andres Gallego
**Motor / Stack Recomendado para PC (Steam):** TypeScript + React / PixiJS / Phaser 3 (empaquetado con Electron/Tauri + Steamworks.js) o Godot 4.x.
**Referentes Directos:** *Balatro* (AppID 2379780), *CloverPit* (AppID 3314790) y *Backpack Battles* (AppID 2427700).

---

## 1. Arquitectura del Motor Matematico (`Sustancia x Candela`)

A diferencia de un juego de cartas tradicional donde el palo y el numero son estaticos, en **La Paila del Atrato** cada ingrediente que entra a la Paila (maximo 5 espacios ordenados de izquierda a derecha: `slot[0] ... slot[4]`) pasa por un **Pipeline Determinista de 5 Fases**:

```text
[FASE 1: Clima Fluvial] -> [FASE 2: Mapa de Retriggers] -> [FASE 3: Barrido Izq-a-Der de Paila] -> [FASE 4: Estante de Reliquias] -> [FASE 5: Chequeo de Rebote de Candela]
```

### Detalle de las 5 Fases del Pipeline:
1. **Fase 1 - Evaluacion Climatica de la Posta (Rio Atrato / San Juan):**
   - Verifica modificadores activos del embarcadero (ej. `AGUACERO_QUIBDO`).
   - Si `rainPenalty == true` y no existe una carta con tag `PROTECCION_LLUVIA` (ej. *Queso en Hoja de Bijao*) en la Paila, cualquier *Chontaduro* que tenga `hasSal == true` pero `hasMiel == false` pierde el bono de Sal en esa mano (`salWashed = true`).
2. **Fase 2 - Construccion del Vector de Disparo (`triggers[]`):**
   - Por defecto cada slot `i` en `0..N-1` tiene `triggers[i] = 1`.
   - Por cada ingrediente con `family == "BOROJO"` en la posicion `j`, se incrementa `triggers[j - 1] += 1` y `triggers[j + 1] += 1`.
3. **Fase 3 - Barrido Secuencial Izquierda a Derecha (`i = 0` hasta `N - 1`):**
   - Para cada `rep` desde `1` hasta `triggers[i]`:
     - Emite un evento visual/sonoro `ON_INGREDIENT_SCORE(slot[i], rep)` que sube el pitch del sintetizador de chirimia (clarinete/bombardino/tambora) en `+1 semitono` por rebote.
     - Suma `Sustancia` (`chips`) y aplica adiciones o multiplicadores a `Candela` (`mult`).
     - Si la reliquia `paila_cobre` esta activa y el ingrediente es un `chontaduro` con `hasSal && hasMiel`, incrementa `runState.permChontaBonus += 15`.
4. **Fase 4 - Barrido del Estante de Reliquias (Jokers Globales):**
   - Recorre `activeRelics[0..4]` de izquierda a derecha aplicando multiplicadores globales de cierre (ej. `azotea_canoa` multiplica `Candela * 1.5` si se jugo al menos una `BOTELLA_CURADA`).
5. **Fase 5 - Control Termico (`candelaHeat`):**
   - Suma el calor neto de los ingredientes jugados.
   - Si `finalHeat > 100`, se dispara `ON_PAILA_OVERFLOW`: el puntaje total de la mano se multiplica por `0.5` y el calor se reinicia a `45%`.

---

## 2. Estructura de Datos JSON (Ingredientes, Reliquias y Postas)

```json
{
  "ingredients": [
    {
      "id": "chontaduro_boraudo",
      "name": "Chontaduro de Boraudo",
      "family": "SUSTANCIA_ADEREZO",
      "baseSustancia": 35,
      "baseCandelaAdd": 0,
      "baseCandelaMult": 1.0,
      "heatDelta": 0,
      "aderezoSlots": ["SAL_MONTE", "MIEL_ABEJAS"]
    },
    {
      "id": "popocho_san_juan",
      "name": "Popocho del San Juan",
      "family": "TRANSFORMACION_FOGON",
      "stages": [
        { "stage": 0, "name": "Popocho Verde (Patacon)", "baseSustancia": 30, "effect": "COPY_LEFT_NEIGHBOR_SUSTANCIA" },
        { "stage": 1, "name": "Popocho Pinton", "baseSustancia": 45, "baseCandelaAdd": 4 },
        { "stage": 2, "name": "Popocho Maduro (Tajada)", "baseSustancia": 55, "baseCandelaMult": 2.0, "effect": "ABSORB_PAILA_MIEL" }
      ],
      "heatDelta": 5
    },
    {
      "id": "borojo_selva",
      "name": "Borojo del San Juan",
      "family": "MOTOR_RETRIGGER",
      "baseSustancia": 20,
      "baseCandelaAdd": 3,
      "heatDelta": 0,
      "effect": "RETRIGGER_ADJACENT_SLOTS"
    },
    {
      "id": "viche_curado",
      "name": "Botella de Viche Curado",
      "family": "BOTELLA_CURADA",
      "baseSustancia": 15,
      "baseCandelaAdd": 2,
      "baseCandelaMult": 2.0,
      "heatDelta": 30
    },
    {
      "id": "arrechon_pipilongo",
      "name": "Arrechon con Pipilongo",
      "family": "BOTELLA_CURADA",
      "baseSustancia": 25,
      "baseCandelaAdd": 4,
      "baseCandelaMult": 3.0,
      "heatDelta": 45
    },
    {
      "id": "queso_bijao",
      "name": "Queso en Hoja de Bijao",
      "family": "PROTECCION_AZOTEA",
      "baseSustancia": 30,
      "baseCandelaAdd": 2,
      "heatDelta": -25,
      "effect": "SHIELD_SAL_FROM_RAIN_AND_BUFF_CHONTADURO"
    }
  ],
  "relics": [
    { "id": "clarinete", "name": "Clarinete de Chirimia", "cost": 6, "trigger": "ON_BOROJO_RETRIGGER", "effect": "+4 Candela" },
    { "id": "paila_cobre", "name": "Paila de Cobre Curada", "cost": 7, "trigger": "ON_CHONTADURO_FULL_ADEREZO", "effect": "+15 Sustancia permanente" },
    { "id": "azotea_canoa", "name": "Azotea en Canoa (Poleo y Cimarron)", "cost": 6, "trigger": "ON_PAILA_END", "effect": "-20% Calor y x1.5 Candela con Botella" },
    { "id": "bombardino", "name": "Bombardino de San Pacho", "cost": 8, "trigger": "ON_POPOCHO_MADURO", "effect": "x2.0 Candela adicional" },
    { "id": "totumo", "name": "Cuchara de Totumo", "cost": 5, "trigger": "ON_ADEREZO_COUNT", "effect": "+30 Sustancia por aderezo" }
  ]
}
```

---

## 3. Prompts Listos para Pegar en Cursor con Gemini Argon

### Prompt 1: Motor de Resolucion Secuencial y Game Feel ("Juice")
> "Actua como un Senior Game Programmer especialista en roguelikes de sinergias tipo Balatro. Toma el archivo `index.html` y `SPEC-CURSOR-ARGON.md` de `/workspace/pacifico-game/la-paila-del-atrato` y extrae la logica en modulos limpios TypeScript (`engine/pailaEvaluator.ts`, `audio/chirimiaSynth.ts`, `ui/PailaBoard.tsx`). Asegurate de que cuando el jugador pulse SERVIR PAILA, cada paso del vector `steps[]` se ejecute con una corrutina/delay de 180ms que haga saltar la carta activa (`scale(1.12)`), muestre un texto flotante (`+Sustancia` en azul o `xCandela` en rojo/dorado) y dispare el sintetizador Web Audio API subiendo 1 semitono por cada retrigger de Borojo."

### Prompt 2: Generador de Runs Fluviales (Mapa de Champas por el Rio Atrato)
> "Agrega un mapa nodal estilo Slay the Spire / Balatro que represente el curso del rio Atrato desde sus afluentes (Negua, Boraudo, Bojaya) hasta el Malecon de Quibdo en plenas Fiestas de San Pacho. Cada nodo puede ser: (1) Embarcadero Comun (cuota base), (2) Aguacero de Selva Pluvial (evento climatico con recompensa doble de Miel/Sal), (3) Canoa de Azotea (forja donde fusionas Viche + Borojo + Pipilongo en botellas legendarias), o (4) Jefe de Puerto."
