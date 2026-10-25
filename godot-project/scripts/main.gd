extends Node3D

# Controlador Principal de Godot 4.3 para La Paila del Atrato: Candela en Quibdo 3D
# Cero fotos reales pegadas, cero verde chillon, mallas 3D esculpidas (.glb) y texturas UV pintadas.

var tex_adoquin: Texture2D
var tex_catedral: Texture2D
var tex_madera_casa: Texture2D
var tex_colonial: Texture2D
var tex_rio: Texture2D
var tex_chonta: Texture2D
var tex_borojo: Texture2D
var tex_popocho: Texture2D
var tex_viche: Texture2D
var tex_palma_tronco: Texture2D
var tex_palma_hoja: Texture2D
var tex_madera_muelle: Texture2D
var tex_paila: Texture2D
var tex_personaje: Texture2D
var psx_shader: Shader

var player_node: Node3D
var camera_rig: Node3D
var cam: Camera3D
var hud_label: Label
var borojo_orbs: Array[Node3D] = []
var enemies: Array[Node3D] = []

var hp: int = 120
var max_hp: int = 120
var level: int = 1
var xp: int = 28
var xp_next: int = 120
var gold: int = 85
var kills: int = 4
var candela_mult: float = 1.25
var time_elapsed: float = 0.0

func _ready() -> void:
    _load_painted_assets()
    _setup_sunset_environment()
    _build_quibdo_sculpted_world()
    _spawn_hero_and_camera()
    _spawn_enemies_and_allies()
    _setup_hud()

func _load_painted_assets() -> void:
    psx_shader = load("res://shaders/psx_retro_lit.gdshader")
    tex_adoquin = load("res://assets/textures/tex_adoquin_malecon.png")
    tex_catedral = load("res://assets/textures/tex_catedral_quibdo.png")
    tex_madera_casa = load("res://assets/textures/tex_casa_quibdo_madera.png")
    tex_colonial = load("res://assets/textures/tex_casa_colonial.png")
    tex_rio = load("res://assets/textures/tex_rio_atrato.png")
    tex_chonta = load("res://assets/textures/tex_chontaduro_skin.png")
    tex_borojo = load("res://assets/textures/tex_borojo_skin.png")
    tex_popocho = load("res://assets/textures/tex_popocho_skin.png")
    tex_viche = load("res://assets/textures/tex_botella_viche.png")
    tex_palma_tronco = load("res://assets/textures/tex_palma_tronco.png")
    tex_palma_hoja = load("res://assets/textures/tex_palma_hoja.png")
    tex_madera_muelle = load("res://assets/textures/tex_madera_muelle.png")
    tex_paila = load("res://assets/textures/tex_paila_cobre.png")
    tex_personaje = load("res://assets/textures/tex_personajes_quibdo.png")

func _make_mat(tex: Texture2D, tint: Color = Color(1, 1, 1, 1), uv_scale: Vector3 = Vector3(1, 1, 1)) -> StandardMaterial3D:
    var mat := StandardMaterial3D.new()
    mat.albedo_texture = tex
    mat.albedo_color = tint
    mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
    mat.roughness = 0.78
    mat.uv1_scale = uv_scale
    return mat

func _setup_sunset_environment() -> void:
    var env := Environment.new()
    env.background_mode = Environment.BG_COLOR
    env.background_color = Color(0.86, 0.38, 0.20)
    env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    env.ambient_light_color = Color(0.98, 0.76, 0.56)
    env.ambient_light_energy = 0.72
    env.fog_enabled = true
    env.fog_light_color = Color(0.92, 0.48, 0.28)
    env.fog_density = 0.008

    var we := WorldEnvironment.new()
    we.environment = env
    add_child(we)

    var sun := DirectionalLight3D.new()
    sun.light_color = Color(1.0, 0.85, 0.62)
    sun.light_energy = 1.45
    sun.rotation_degrees = Vector3(-38.0, 32.0, 0.0)
    sun.shadow_enabled = true
    add_child(sun)

func _instantiate_glb(glb_name: String, pos: Vector3, sc: Vector3, rot_y: float = 0.0) -> Node3D:
    var scene_res = load("res://assets/models/" + glb_name + ".glb")
    if scene_res:
        var inst: Node3D = scene_res.instantiate()
        inst.position = pos
        inst.scale = sc
        inst.rotation.y = rot_y
        add_child(inst)
        return inst
    return null

func _build_sculpted_palm(pos: Vector3, sc: float, lean_x: float) -> void:
    var root := Node3D.new()
    root.position = pos
    add_child(root)
    var mat_trunk := _make_mat(tex_palma_tronco, Color(1, 1, 1), Vector3(2, 2, 1))
    var mat_leaf := _make_mat(tex_palma_hoja, Color(1, 0.96, 0.85), Vector3(1, 1, 1))
    var cur_y := 0.0
    var cur_x := 0.0
    for i in range(6):
        var seg := MeshInstance3D.new()
        var cyl := CylinderMesh.new()
        cyl.bottom_radius = (0.38 - i * 0.035) * sc
        cyl.top_radius = (0.34 - i * 0.035) * sc
        cyl.height = 1.15 * sc
        cyl.radial_segments = 10
        seg.mesh = cyl
        seg.material_override = mat_trunk
        seg.position = Vector3(cur_x, cur_y + 0.55 * sc, 0)
        seg.rotation.z = -lean_x * 0.12
        root.add_child(seg)
        cur_y += 1.08 * sc
        cur_x += lean_x * 0.18 * sc
    for f in range(8):
        var frond := MeshInstance3D.new()
        var prism := BoxMesh.new()
        prism.size = Vector3(0.75 * sc, 0.08 * sc, 3.4 * sc)
        frond.mesh = prism
        frond.material_override = mat_leaf
        var ang := (float(f) / 8.0) * TAU
        frond.position = Vector3(cur_x + cos(ang) * 1.4 * sc, cur_y - 0.1 * sc, sin(ang) * 1.4 * sc)
        frond.rotation = Vector3(0.32, -ang + PI * 0.5, 0.0)
        root.add_child(frond)

func _build_quibdo_sculpted_world() -> void:
    # 1. Suelo de Adoquin Terracota Calido del Malecon y Plaza (CERO verde!)
    var floor_mi := MeshInstance3D.new()
    var plane := BoxMesh.new()
    plane.size = Vector3(96.0, 0.5, 96.0)
    floor_mi.mesh = plane
    floor_mi.position = Vector3(0, -0.25, 0)
    floor_mi.material_override = _make_mat(tex_adoquin, Color(1.0, 0.94, 0.86), Vector3(28, 28, 1))
    add_child(floor_mi)

    # 2. Rio Atrato al Oeste con Textura Pintada de Agua Profunda y Reflejos del Atardecer
    var river_mi := MeshInstance3D.new()
    var r_box := BoxMesh.new()
    r_box.size = Vector3(28.0, 0.4, 96.0)
    river_mi.mesh = r_box
    river_mi.position = Vector3(-34.0, -0.65, 0.0)
    river_mi.material_override = _make_mat(tex_rio, Color(1.0, 0.95, 0.88), Vector3(8, 24, 1))
    add_child(river_mi)

    # 3. Muelle de Madera del Malecon de Quibdo
    var boardwalk := MeshInstance3D.new()
    var bw_box := BoxMesh.new()
    bw_box.size = Vector3(8.5, 0.35, 84.0)
    boardwalk.mesh = bw_box
    boardwalk.position = Vector3(-16.5, 0.08, 0.0)
    boardwalk.material_override = _make_mat(tex_madera_muelle, Color(1, 0.94, 0.86), Vector3(4, 24, 1))
    add_child(boardwalk)

    # 4. Catedral de San Francisco de Asis de Quibdo Esculpida (.glb) al fondo Norte
    _instantiate_glb("catedral_quibdo", Vector3(0.0, 0.0, -24.0), Vector3(1.15, 1.15, 1.15), 0.0)

    # 5. Casas Coloniales y de Madera de Alameda Reyes
    var house_positions := [
        Vector3(-12.5, 3.2, -10.0),
        Vector3(12.5, 3.2, -10.0),
        Vector3(-13.5, 3.2, 4.0),
        Vector3(13.5, 3.2, 4.0)
    ]
    for i in range(house_positions.size()):
        var h_mi := MeshInstance3D.new()
        var h_box := BoxMesh.new()
        h_box.size = Vector3(6.8, 6.4, 6.2)
        h_mi.mesh = h_box
        h_mi.position = house_positions[i]
        var use_tex := tex_madera_casa if (i % 2 == 0) else tex_colonial
        h_mi.material_override = _make_mat(use_tex, Color(1, 1, 1), Vector3(2, 2, 2))
        add_child(h_mi)
        # Techo de zinc rojizo en piramide/prisma
        var roof_mi := MeshInstance3D.new()
        var roof_m := PrismMesh.new()
        roof_m.size = Vector3(7.4, 2.1, 6.8)
        roof_mi.mesh = roof_m
        roof_mi.position = house_positions[i] + Vector3(0, 4.2, 0)
        roof_mi.material_override = _make_mat(tex_adoquin, Color(0.85, 0.38, 0.24), Vector3(3, 2, 1))
        add_child(roof_mi)

    # 6. Palmeras de Chontaduro Curvas
    _build_sculpted_palm(Vector3(-8.5, 0, -14.0), 1.05, -0.4)
    _build_sculpted_palm(Vector3(8.5, 0, -14.0), 1.05, 0.4)
    _build_sculpted_palm(Vector3(-14.5, 0, -4.0), 1.1, -0.5)
    _build_sculpted_palm(Vector3(14.5, 0, -4.0), 1.1, 0.5)

    # 7. Champas / Pangas Esculpidas en el Rio Atrato y Paila de Cobre Central
    _instantiate_glb("champa_atrato", Vector3(-23.0, -0.35, -6.0), Vector3(1.2, 1.2, 1.2), 0.15)
    _instantiate_glb("paila_cobre_fogon", Vector3(-3.2, 0.1, -2.5), Vector3(1.3, 1.3, 1.3), 0.0)

func _spawn_hero_and_camera() -> void:
    player_node = _instantiate_glb("personaje_quibdo", Vector3(0.0, 0.0, 2.2), Vector3(1.15, 1.15, 1.15), PI)
    # 3 Orbiting Sculpted Borojo & Chontaduro Orbs around Janfry
    for i in range(3):
        var orb := _instantiate_glb("chontaduro_boraudo" if i % 2 == 0 else "borojo_selva", Vector3.ZERO, Vector3(0.65, 0.65, 0.65))
        if orb:
            borojo_orbs.append(orb)

    camera_rig = Node3D.new()
    camera_rig.position = Vector3(0.0, 4.2, 8.2)
    add_child(camera_rig)
    cam = Camera3D.new()
    cam.fov = 58.0
    camera_rig.add_child(cam)
    cam.look_at_from_position(camera_rig.position, Vector3(0.0, 1.8, -6.0), Vector3.UP)

func _spawn_enemies_and_allies() -> void:
    var positions := [
        Vector3(-3.2, 0.0, -3.5),
        Vector3(3.4, 0.0, -4.2),
        Vector3(0.4, 0.0, -7.8),
        Vector3(-5.2, 0.0, -8.5),
        Vector3(5.0, 0.0, -8.2)
    ]
    for i in range(positions.size()):
        var sc := Vector3(1.45, 1.45, 1.45) if i == 2 else Vector3(1.0, 1.0, 1.0)
        var en := _instantiate_glb("personaje_quibdo", positions[i], sc, 0.0)
        if en:
            enemies.append(en)
        # Floating sculpted projectiles / bottles in flight
        _instantiate_glb("botella_viche_arrechon", positions[i] + Vector3(0, 1.8, 1.5), Vector3(0.6, 0.6, 0.6), float(i))
        _instantiate_glb("popocho_san_juan", positions[i] + Vector3(0.8, 1.1, 0.8), Vector3(0.7, 0.7, 0.7), float(i) * 1.2)

func _setup_hud() -> void:
    var canvas := CanvasLayer.new()
    add_child(canvas)

    var top_panel := PanelContainer.new()
    top_panel.position = Vector2(18, 14)
    top_panel.custom_minimum_size = Vector2(680, 92)
    canvas.add_child(top_panel)

    hud_label = Label.new()
    hud_label.text = "LA PAILA DEL ATRATO: CANDELA EN QUIBDO 3D [GODOT ENGINE 4.3]
HEROE: JANFRY (MALLA 3D ESCULPIDA + TEXTURAS UV PINTADAS) | VIDA: 120/120 | NIVEL 1 (XP 28/120)
ZONA: PLAZA DE LA CATEDRAL Y MALECON DEL ATRATO | ARMAS: CHONTADURO, POPOCHO, BOROJO, VICHE"
    hud_label.add_theme_color_override("font_color", Color(1.0, 0.94, 0.82))
    hud_label.add_theme_font_size_override("font_size", 15)
    top_panel.add_child(hud_label)

func _process(delta: float) -> void:
    time_elapsed += delta
    var move_dir := Vector2.ZERO
    if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
        move_dir.y -= 1.0
    if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
        move_dir.y += 1.0
    if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
        move_dir.x -= 1.0
    if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
        move_dir.x += 1.0
    if move_dir.length() > 0.01 and player_node:
        move_dir = move_dir.normalized()
        player_node.position.x = clamp(player_node.position.x + move_dir.x * 7.5 * delta, -22.0, 22.0)
        player_node.position.z = clamp(player_node.position.z + move_dir.y * 7.5 * delta, -18.0, 18.0)

    if player_node:
        for i in range(borojo_orbs.size()):
            var ang := time_elapsed * 3.8 + float(i) * TAU / float(borojo_orbs.size())
            borojo_orbs[i].position = player_node.position + Vector3(cos(ang) * 2.4, 1.15, sin(ang) * 2.4)
            borojo_orbs[i].rotation.y = ang
