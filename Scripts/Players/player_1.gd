extends CharacterBody3D

@export var speed: float = 5.0
@export var jump_force: float = 4.5
@export var gravity: float = 9.8
@export var run_speed: float = 8.0  # Velocidad para correr
@export var attack_cooldown_time: float = 0.5  # Tiempo de espera entre ataques

@onready var camera: Camera3D = $%MainCamera3D
@onready var animation_tree: AnimationTree = $AnimationTree

var anim_state: AnimationNodeStateMachinePlayback

# Variables de estado
var is_walking: bool = false
var is_running: bool = false
var is_attacking: bool = false
var is_dying: bool = false
var attack_cooldown: float = 0.0

func _ready():
	# Configurar acciones de input si no existen
	_setup_input_actions()
	
	# Inicializar el AnimationTree y obtener el playback
	if animation_tree:
		animation_tree.active = true
		# Obtener el playback después de activar el AnimationTree
		anim_state = animation_tree.get("parameters/playback")
	else:
		print("Error: AnimationTree no encontrado")

func _setup_input_actions():
	var actions = {
		"move_forward": KEY_W,
		"move_backward": KEY_S,
		"move_left": KEY_A,
		"move_right": KEY_D,
		"jump": KEY_SPACE,
		"run": KEY_SHIFT,
		"attack": KEY_Q
	}
	
	for action in actions:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
			var event = InputEventKey.new()
			event.keycode = actions[action]
			InputMap.action_add_event(action, event)

func _physics_process(delta):
	# Manejar el cooldown del ataque
	if attack_cooldown > 0:
		attack_cooldown -= delta
	
	# Aplicar gravedad
	var on_floor = is_on_floor()
	if not on_floor:
		velocity.y -= gravity * delta
	
	# Manejar salto
	if Input.is_action_just_pressed("jump") and on_floor:
		velocity.y = jump_force
	
	# Determinar si estamos corriendo
	is_running = Input.is_action_pressed("run") and on_floor and not is_attacking
	
	# Determinar si estamos atacando
	if Input.is_action_just_pressed("attack") and attack_cooldown <= 0 and on_floor and not is_dying:
		is_attacking = true
		attack_cooldown = attack_cooldown_time
		# Aquí puedes agregar lógica de daño al atacar
	
	# Obtener input de movimiento
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = Vector3(input_dir.x, 0, input_dir.y).normalized()
	
	# Convertir la dirección al espacio de la cámara
	if direction.length() > 0 and camera and not is_attacking and not is_dying:
		var camera_basis = camera.global_transform.basis
		direction = camera_basis * direction
		direction.y = 0
		direction = direction.normalized()
		
		# Usar la velocidad de correr si corresponde
		var current_speed = run_speed if is_running else speed
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
		
		# Actualizar estado de caminata
		is_walking = true
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
		is_walking = false
	
	move_and_slide()
	
	# Actualizar animaciones
	if animation_tree:
		animation_tree.set("parameters/conditions/IsOnFloor", on_floor)
		animation_tree.set("parameters/conditions/IsInAir", !on_floor)
		animation_tree.set("parameters/conditions/IsWalking", is_walking and not is_running and not is_attacking)
		animation_tree.set("parameters/conditions/IsNotWalking", not is_walking or is_running or is_attacking)
		animation_tree.set("parameters/conditions/IsRunning", is_walking and is_running and not is_attacking)
		animation_tree.set("parameters/conditions/IsNotRunning", not is_running or not is_walking or is_attacking)
		animation_tree.set("parameters/conditions/IsAttacking", is_attacking)
		animation_tree.set("parameters/conditions/IsNotAttacking", not is_attacking)
		animation_tree.set("parameters/conditions/IsDying", is_dying)
	
	# Reiniciar el estado de ataque después de un tiempo
	if is_attacking and attack_cooldown <= attack_cooldown_time * 0.8:  # Permitir que la animación se reproduzca un poco
		is_attacking = false

# Función para manejar la muerte del personaje
func die():
	is_dying = true
	# Deshabilitar el movimiento y otras acciones
	set_physics_process(false)

# Función para revivir el personaje
func revive():
	is_dying = false
	# Habilitar el movimiento y otras acciones
	set_physics_process(true)

# Señal para detectar cuando una animación termina (conectar en el editor)
func _on_animation_finished(anim_name):
	if anim_name == "Attack":  # Reemplaza con el nombre real de tu animación de ataque
		is_attacking = false
