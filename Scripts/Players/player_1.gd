extends CharacterBody3D

@export var speed: float = 5.0
@export var jump_force: float = 4.5
@export var gravity: float = 9.8

@onready var camera: Camera3D = $%MainCamera3D  # Ajusta esta ruta según tu escena
@onready var player_direction: Node3D = $%PlayerDirection  # Ajusta esta ruta

func _ready():
	# Configurar acciones de input si no existen
	_setup_input_actions()

func _setup_input_actions():
	var actions = {
		"move_forward": KEY_W,
		"move_backward": KEY_S,
		"move_left": KEY_A,
		"move_right": KEY_D,
		"jump": KEY_SPACE
	}
	
	for action in actions:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
			var event = InputEventKey.new()
			event.keycode = actions[action]
			InputMap.action_add_event(action, event)

func _physics_process(delta):
	# Aplicar gravedad
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	# Manejar salto
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_force
	
	# Obtener input de movimiento
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = Vector3(input_dir.x, 0, input_dir.y).normalized()
	
	# Convertir la dirección al espacio de la cámara
	if direction.length() > 0 and camera:
		var camera_basis = camera.global_transform.basis
		direction = camera_basis * direction
		direction.y = 0
		direction = direction.normalized()
		
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	
	move_and_slide()
	
	# Rotar el jugador en la dirección del movimiento
	if velocity.length() > 0.2 and player_direction:
		var look_direction = Vector2(velocity.z, velocity.x)
		player_direction.rotation.y = look_direction.angle()
